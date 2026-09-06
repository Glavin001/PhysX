// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "native_gpu_consumer.h"
#include <cuda.h>
#include <stdexcept>
#include <cmath>
#include <cstring>
#include <cstdio>
#include <cerrno>
#ifdef NATIVE_GPU_EGL
#define GL_GLEXT_PROTOTYPES
#include <GL/gl.h>
#include <GL/glext.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <cudaGL.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/socket.h>
#endif
namespace blast_demo {
namespace {
using namespace physx;
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
void check(CUresult r){if(r!=CUDA_SUCCESS){const char* text=nullptr;cuGetErrorString(r,&text);throw std::runtime_error(text?text:"CUDA consumer failed");}}
#ifdef NATIVE_GPU_EGL
GLuint shader(GLenum type,const char* source){
    GLuint result=glCreateShader(type);glShaderSource(result,1,&source,nullptr);glCompileShader(result);
    GLint ok=0;glGetShaderiv(result,GL_COMPILE_STATUS,&ok);
    if(!ok){char log[4096]{};glGetShaderInfoLog(result,sizeof(log),nullptr,log);glDeleteShader(result);throw std::runtime_error(log);}return result;
}
#endif
}
struct NativeGpuConsumer::Impl {
    PxCudaContextManager& cuda;PxDestructionScene& stage;PxDestructionDeviceView view{};
    CUstream stream{};CUevent uploaded{},shotsReady{},consumed{};
    CUdeviceptr visuals{},ids{},poses{},height{},status{};
    bool colorByCluster=false;
    unsigned shotCount=0,shotCapacity=0,chunkCount=0,frames=0;
    unsigned long long queryBytes=0,pixelBytes=0;std::string renderer;
#ifdef NATIVE_GPU_EGL
    EGLDisplay display=EGL_NO_DISPLAY;EGLContext context=EGL_NO_CONTEXT;EGLSurface surface=EGL_NO_SURFACE;
    GLuint program=0,vao=0,mesh=0,instances=0;CUgraphicsResource resource{};
    unsigned width=0,heightPixels=0,sphereStart=0,sphereCount=0;Camera camera;
    int videoFd=-1;pid_t videoPid=-1;std::vector<unsigned char> pixels;
#endif
    Impl(PxCudaContextManager& c,PxDestructionScene& s):cuda(c),stage(s){}
    ~Impl(){
        // The caller owns the scene/context. End all borrowed reads before
        // releasing events or allowing scene-owned storage to be destroyed.
        PxScopedCudaLock lock(cuda);if(stream)cuStreamSynchronize(stream);stage.setConsumerEvent(nullptr);
#ifdef NATIVE_GPU_EGL
        if(videoFd>=0)close(videoFd);
        if(videoPid>0){int code;while(waitpid(videoPid,&code,0)<0 && errno==EINTR){}}
        if(display!=EGL_NO_DISPLAY && context!=EGL_NO_CONTEXT)eglMakeCurrent(display,surface,surface,context);
        if(resource)cuGraphicsUnregisterResource(resource);
        if(instances)glDeleteBuffers(1,&instances);if(mesh)glDeleteBuffers(1,&mesh);if(vao)glDeleteVertexArrays(1,&vao);if(program)glDeleteProgram(program);
        if(display!=EGL_NO_DISPLAY){eglMakeCurrent(display,EGL_NO_SURFACE,EGL_NO_SURFACE,EGL_NO_CONTEXT);if(surface!=EGL_NO_SURFACE)eglDestroySurface(display,surface);if(context!=EGL_NO_CONTEXT)eglDestroyContext(display,context);eglTerminate(display);}
#endif
        for(auto p:{visuals,ids,poses,height,status})if(p)cuMemFree(p);
        for(auto e:{uploaded,shotsReady,consumed})if(e)cuEventDestroy(e);if(stream)cuStreamDestroy(stream);
    }
    void publish(){check(cuEventRecord(consumed,stream));stage.setConsumerEvent(consumed);}
};
NativeGpuConsumer::NativeGpuConsumer(PxCudaContextManager& cuda,PxDestructionScene& stage,
    const std::vector<NativeGpuVisual>& visuals,unsigned projectileCapacity):m(new Impl(cuda,stage)){
    require(!visuals.empty() && projectileCapacity,"empty GPU visual capacity");PxScopedCudaLock lock(cuda);
    m->chunkCount=unsigned(visuals.size());m->shotCapacity=projectileCapacity;
    check(cuStreamCreate(&m->stream,CU_STREAM_NON_BLOCKING));
    for(auto e:{&m->uploaded,&m->shotsReady,&m->consumed})check(cuEventCreate(e,CU_EVENT_DISABLE_TIMING));
    check(cuMemAlloc(&m->visuals,visuals.size()*sizeof(NativeGpuVisual)));
    check(cuMemcpyHtoD(m->visuals,visuals.data(),visuals.size()*sizeof(NativeGpuVisual)));
    check(cuMemAlloc(&m->ids,projectileCapacity*sizeof(PxU32)));check(cuMemAlloc(&m->poses,projectileCapacity*sizeof(PxTransform)));
    check(cuMemAlloc(&m->height,sizeof(float)));check(cuMemAlloc(&m->status,sizeof(NativeGpuVisualStatus)));check(cuMemsetD8(m->status,0,sizeof(NativeGpuVisualStatus)));
}
NativeGpuConsumer::~NativeGpuConsumer()=default;
void NativeGpuConsumer::setClusterColors(bool enabled){m->colorByCluster=enabled;}
void NativeGpuConsumer::addProjectile(PxU32 body,const PxTransform& pose){
    require(m->shotCount<m->shotCapacity,"GPU projectile capacity exhausted");PxScopedCudaLock lock(m->cuda);
    // Authored input commands, not observed motion. Synchronous tiny uploads
    // keep stack input lifetime explicit. Later motion never returns to CPU.
    check(cuMemcpyHtoD(m->ids+m->shotCount*sizeof(body),&body,sizeof(body)));
    check(cuMemcpyHtoD(m->poses+m->shotCount*sizeof(pose),&pose,sizeof(pose)));++m->shotCount;
}
float NativeGpuConsumer::launchHeight(PxVec3 position,float radius){
    PxScopedCudaLock lock(m->cuda);
    queryNativeGpuLaunch(m->view,reinterpret_cast<const NativeGpuVisual*>(m->visuals),reinterpret_cast<const PxTransform*>(m->poses),m->shotCount,position,radius,reinterpret_cast<float*>(m->height),m->stream);
    m->publish();check(cuEventSynchronize(m->consumed));float height;check(cuMemcpyDtoH(&height,m->height,sizeof(height)));m->queryBytes+=sizeof(height);
    require(std::isfinite(height),"invalid committed GPU launch query");return height;
}
void NativeGpuConsumer::update(PxDirectGPUAPI& api){
    PxScopedCudaLock lock(m->cuda);m->view=m->stage.getDeviceView();require(m->view.chunkCount==m->chunkCount,"GPU visual asset was reconfigured");
    check(cuStreamWaitEvent(m->stream,m->view.readyEvent,0));
    if(m->shotCount){check(cuEventRecord(m->uploaded,m->stream));
        require(api.getRigidDynamicData(reinterpret_cast<void*>(m->poses),reinterpret_cast<const PxU32*>(m->ids),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,m->shotCount,m->uploaded,m->shotsReady),"GPU projectile gathering failed");
        check(cuStreamWaitEvent(m->stream,m->shotsReady,0));}
    m->publish();
}
const std::string& NativeGpuConsumer::rendererName() const{return m->renderer;}
unsigned NativeGpuConsumer::renderedFrames() const{return m->frames;}
unsigned long long NativeGpuConsumer::queryReadbackBytes() const{return m->queryBytes;}
unsigned long long NativeGpuConsumer::pixelReadbackBytes() const{return m->pixelBytes;}
void NativeGpuConsumer::enableRenderer(unsigned width,unsigned height,const Camera& camera,const std::string& video,unsigned fps){
#ifndef NATIVE_GPU_EGL
    throw std::runtime_error("GPU graphics requested but demo was built without NATIVE_GPU_EGL_RENDERER");
#else
    require(m->display==EGL_NO_DISPLAY && width && height,"invalid GPU renderer initialization");PxScopedCudaLock lock(m->cuda);
    auto queryDevices=reinterpret_cast<PFNEGLQUERYDEVICESEXTPROC>(eglGetProcAddress("eglQueryDevicesEXT"));
    auto queryAttribute=reinterpret_cast<PFNEGLQUERYDEVICEATTRIBEXTPROC>(eglGetProcAddress("eglQueryDeviceAttribEXT"));
    auto getDisplay=reinterpret_cast<PFNEGLGETPLATFORMDISPLAYEXTPROC>(eglGetProcAddress("eglGetPlatformDisplayEXT"));
    require(queryDevices && queryAttribute && getDisplay,"EGL device enumeration unavailable");
    EGLint count=0;require(queryDevices(0,nullptr,&count),"EGL device count failed");std::vector<EGLDeviceEXT> devices(count);
    require(queryDevices(count,devices.data(),&count),"EGL device enumeration failed");CUdevice cudaDevice;check(cuCtxGetDevice(&cudaDevice));
    for(auto device:devices){EGLAttrib ordinal=-1;if(queryAttribute(device,EGL_CUDA_DEVICE_NV,&ordinal) && ordinal==cudaDevice){m->display=getDisplay(EGL_PLATFORM_DEVICE_EXT,device,nullptr);break;}}
    require(m->display!=EGL_NO_DISPLAY,"no EGL device matches the PhysX CUDA device");
    EGLint major,minor;require(eglInitialize(m->display,&major,&minor) && eglBindAPI(EGL_OPENGL_API),"EGL initialization failed");
    const EGLint configAttributes[]={EGL_SURFACE_TYPE,EGL_PBUFFER_BIT,EGL_RENDERABLE_TYPE,EGL_OPENGL_BIT,EGL_RED_SIZE,8,EGL_GREEN_SIZE,8,EGL_BLUE_SIZE,8,EGL_DEPTH_SIZE,24,EGL_NONE};
    EGLConfig config;require(eglChooseConfig(m->display,configAttributes,&config,1,&count) && count,"EGL framebuffer config failed");
    const EGLint contextAttributes[]={EGL_CONTEXT_MAJOR_VERSION,3,EGL_CONTEXT_MINOR_VERSION,3,EGL_CONTEXT_OPENGL_PROFILE_MASK,EGL_CONTEXT_OPENGL_CORE_PROFILE_BIT,EGL_NONE};
    m->context=eglCreateContext(m->display,config,EGL_NO_CONTEXT,contextAttributes);require(m->context!=EGL_NO_CONTEXT,"OpenGL 3.3 context failed");
    const EGLint surfaceAttributes[]={EGL_WIDTH,EGLint(width),EGL_HEIGHT,EGLint(height),EGL_NONE};
    m->surface=eglCreatePbufferSurface(m->display,config,surfaceAttributes);require(m->surface!=EGL_NO_SURFACE && eglMakeCurrent(m->display,m->surface,m->surface,m->context),"EGL surface failed");
    m->renderer=reinterpret_cast<const char*>(glGetString(GL_RENDERER));m->width=width;m->heightPixels=height;m->camera=camera;
    const char* vertex=R"GLSL(#version 330 core
layout(location=0) in vec3 point;layout(location=1) in vec3 normal;
layout(location=2) in vec4 origin;layout(location=3) in vec4 rotation;layout(location=4) in vec4 scale;layout(location=5) in vec4 color;
uniform mat4 vp;out vec3 world;out vec3 n;out vec3 tint;flat out float ground;
vec3 rotate(vec3 p){return p+2.0*cross(rotation.xyz,cross(rotation.xyz,p)+rotation.w*p);}
void main(){world=origin.xyz+rotate(point*scale.xyz);n=rotate(normal);tint=color.rgb;ground=1.0-color.w;gl_Position=origin.w==0.0?vec4(2,2,2,1):vp*vec4(world,1);}
)GLSL";
    const char* fragment=R"GLSL(#version 330 core
in vec3 world;in vec3 n;in vec3 tint;flat in float ground;out vec4 pixel;
void main(){float light=.3+.7*max(0.0,dot(normalize(n),normalize(vec3(-.5,1,.35))));float fog=clamp(length(world.xz)*.001,0.0,.25);vec3 base=tint;if(ground>0.5){vec2 grid=abs(fract(world.xz-.5)-.5)/max(fwidth(world.xz),vec2(.001));base*=mix(.65,1.0,clamp(min(grid.x,grid.y),0.0,1.0));}pixel=vec4(mix(base*light,vec3(.10,.14,.18),fog),1);}
)GLSL";
    GLuint v=shader(GL_VERTEX_SHADER,vertex),f=shader(GL_FRAGMENT_SHADER,fragment);m->program=glCreateProgram();glAttachShader(m->program,v);glAttachShader(m->program,f);glLinkProgram(m->program);glDeleteShader(v);glDeleteShader(f);
    GLint linked=0;glGetProgramiv(m->program,GL_LINK_STATUS,&linked);require(linked,"GPU renderer shader link failed");
    std::vector<float> vertices;
    auto emit=[&](PxVec3 p,PxVec3 n){for(unsigned i=0;i<3;++i)vertices.push_back(p[i]);for(unsigned i=0;i<3;++i)vertices.push_back(n[i]);};
    for(unsigned axis=0;axis<3;++axis)for(int sign:{-1,1}){
        const unsigned a=(axis+1)%3,b=(axis+2)%3;PxVec3 normal(0);normal[axis]=float(sign);
        const int uv[6][2]={{-1,-1},{1,-1},{1,1},{-1,-1},{1,1},{-1,1}};
        for(auto& corner:uv){PxVec3 p(0);p[axis]=float(sign);p[a]=float(corner[0]);p[b]=float(corner[1]);emit(p,normal);}
    }
    m->sphereStart=unsigned(vertices.size()/6);
    auto sphere=[](float lat,float lon){return PxVec3(std::cos(lat)*std::cos(lon),std::sin(lat),std::cos(lat)*std::sin(lon));};
    for(int y=0;y<12;++y)for(int x=0;x<24;++x){
        const float a=-PxPi*.5f+PxPi*y/12,b=-PxPi*.5f+PxPi*(y+1)/12,c=PxTwoPi*x/24,d=PxTwoPi*(x+1)/24;
        for(auto p:{sphere(a,c),sphere(b,c),sphere(b,d),sphere(a,c),sphere(b,d),sphere(a,d)})emit(p,p);
    }m->sphereCount=unsigned(vertices.size()/6)-m->sphereStart;
    glGenVertexArrays(1,&m->vao);glBindVertexArray(m->vao);glGenBuffers(1,&m->mesh);glBindBuffer(GL_ARRAY_BUFFER,m->mesh);glBufferData(GL_ARRAY_BUFFER,vertices.size()*sizeof(float),vertices.data(),GL_STATIC_DRAW);
    for(unsigned i=0;i<2;++i){glEnableVertexAttribArray(i);glVertexAttribPointer(i,3,GL_FLOAT,GL_FALSE,6*sizeof(float),reinterpret_cast<void*>(i*3*sizeof(float)));}
    glGenBuffers(1,&m->instances);glBindBuffer(GL_ARRAY_BUFFER,m->instances);glBufferData(GL_ARRAY_BUFFER,(size_t(m->chunkCount)+m->shotCapacity)*sizeof(NativeGpuInstance),nullptr,GL_STREAM_DRAW);
    check(cuGraphicsGLRegisterBuffer(&m->resource,m->instances,CU_GRAPHICS_REGISTER_FLAGS_WRITE_DISCARD));
    require(glGetError()==GL_NO_ERROR,"GPU renderer buffer creation failed");
    if(!video.empty()){
        int descriptors[2];require(socketpair(AF_UNIX,SOCK_STREAM,0,descriptors)==0,"video encoder socket failed");
        const auto resolution=std::to_string(width)+"x"+std::to_string(height),rate=std::to_string(fps);
        m->videoPid=fork();if(m->videoPid<0){close(descriptors[0]);close(descriptors[1]);throw std::runtime_error("video encoder fork failed");}
        if(!m->videoPid){dup2(descriptors[0],STDIN_FILENO);close(descriptors[0]);close(descriptors[1]);
            execlp("ffmpeg","ffmpeg","-hide_banner","-loglevel","error","-nostdin","-n","-f","rawvideo","-pixel_format","rgb24","-video_size",resolution.c_str(),"-framerate",rate.c_str(),"-i","pipe:0","-vf","vflip","-c:v","libx264","-preset","veryfast","-crf","20","-pix_fmt","yuv420p",video.c_str(),static_cast<char*>(nullptr));_exit(127);}
        close(descriptors[0]);m->videoFd=descriptors[1];m->pixels.resize(size_t(width)*height*3);
    }
#endif
}
void NativeGpuConsumer::render(std::vector<NativeGpuInstance>* observed){
#ifndef NATIVE_GPU_EGL
    throw std::runtime_error("GPU renderer unavailable");
#else
    require(m->resource && m->view.chunkCount,"GPU renderer has no accepted view");PxScopedCudaLock lock(m->cuda);
    require(eglMakeCurrent(m->display,m->surface,m->surface,m->context),"EGL context switch failed");
    check(cuGraphicsMapResources(1,&m->resource,m->stream));CUdeviceptr mapped;size_t bytes;
    try{check(cuGraphicsResourceGetMappedPointer(&mapped,&bytes,m->resource));require(bytes>=(size_t(m->chunkCount)+m->shotCount)*sizeof(NativeGpuInstance),"mapped render capacity exhausted");
        writeNativeGpuInstances(m->view,reinterpret_cast<const NativeGpuVisual*>(m->visuals),reinterpret_cast<const PxTransform*>(m->poses),m->shotCount,reinterpret_cast<NativeGpuInstance*>(mapped),reinterpret_cast<NativeGpuVisualStatus*>(m->status),m->stream,m->colorByCluster);
        if(observed) {
            observed->resize(size_t(m->chunkCount)+m->shotCount);
            check(cuMemcpyDtoHAsync(observed->data(),mapped,observed->size()*sizeof(NativeGpuInstance),m->stream));
            check(cuStreamSynchronize(m->stream));
        }
        m->publish();check(cuGraphicsUnmapResources(1,&m->resource,m->stream));
    }catch(...){cuGraphicsUnmapResources(1,&m->resource,m->stream);throw;}
    // CUDA unmap orders GL consumption. No CPU wait or state observation is
    // needed to draw. Sticky device errors are checked at explicit finalization.
    glViewport(0,0,m->width,m->heightPixels);glClearColor(.10f,.14f,.18f,1);glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);glEnable(GL_DEPTH_TEST);glUseProgram(m->program);glBindVertexArray(m->vao);
    const auto forward=m->camera.direction.getNormalized(),right=forward.cross(PxVec3(0,1,0)).getNormalized(),up=right.cross(forward);const auto eye=m->camera.eye;
    const float s=1/std::tan(m->camera.fovDegrees*PxPi/360),aspect=float(m->width)/m->heightPixels,near=.1f,far=10000;
    const float view[16]={right.x,up.x,-forward.x,0,right.y,up.y,-forward.y,0,right.z,up.z,-forward.z,0,-right.dot(eye),-up.dot(eye),forward.dot(eye),1};
    const float projection[16]={s/aspect,0,0,0,0,s,0,0,0,0,-(far+near)/(far-near),-1,0,0,-2*far*near/(far-near),0};float vp[16]{};
    for(unsigned c=0;c<4;++c)for(unsigned r=0;r<4;++r)for(unsigned k=0;k<4;++k)vp[c*4+r]+=projection[k*4+r]*view[c*4+k];
    glUniformMatrix4fv(glGetUniformLocation(m->program,"vp"),1,GL_FALSE,vp);glBindBuffer(GL_ARRAY_BUFFER,m->instances);
    auto bind=[&](unsigned first){for(unsigned j=0;j<4;++j){glEnableVertexAttribArray(j+2);glVertexAttribPointer(j+2,4,GL_FLOAT,GL_FALSE,sizeof(NativeGpuInstance),reinterpret_cast<void*>(size_t(first)*sizeof(NativeGpuInstance)+j*4*sizeof(float)));glVertexAttribDivisor(j+2,1);}};
    bind(0);glDrawArraysInstanced(GL_TRIANGLES,0,36,m->chunkCount);if(m->shotCount){bind(m->chunkCount);glDrawArraysInstanced(GL_TRIANGLES,m->sphereStart,m->sphereCount,m->shotCount);}
    // The simulation's immutable y=0 plane. Constant GL attributes are scene
    // authoring, never a CPU mirror of moving chunks or projectiles.
    for(unsigned j=2;j<6;++j)glDisableVertexAttribArray(j);
    glVertexAttrib4f(2,0,-.1f,0,1);glVertexAttrib4f(3,0,0,0,1);
    glVertexAttrib4f(4,2000,.1f,2000,0);glVertexAttrib4f(5,.23f,.28f,.32f,0);
    glDrawArrays(GL_TRIANGLES,0,36);
    require(glGetError()==GL_NO_ERROR,"GPU draw failed");
    if(m->videoFd>=0){
        // Export only: read final pixels for the software encoder. Simulation
        // and graphics never obtain poses from this readback.
        glPixelStorei(GL_PACK_ALIGNMENT,1);glReadPixels(0,0,m->width,m->heightPixels,GL_RGB,GL_UNSIGNED_BYTE,m->pixels.data());require(glGetError()==GL_NO_ERROR,"video pixel export failed");
        size_t offset=0;while(offset<m->pixels.size()){const auto n=send(m->videoFd,m->pixels.data()+offset,m->pixels.size()-offset,MSG_NOSIGNAL);if(n<0 && errno==EINTR)continue;require(n>0,"video encoder write failed");offset+=size_t(n);}m->pixelBytes+=m->pixels.size();
    }else glFlush();++m->frames;
#endif
}
void NativeGpuConsumer::finishVideo(){
    {PxScopedCudaLock lock(m->cuda);check(cuStreamSynchronize(m->stream));NativeGpuVisualStatus status;check(cuMemcpyDtoH(&status,m->status,sizeof(status)));m->queryBytes+=sizeof(status);require(!status.errors,"GPU consumer encountered an invalid accepted view");}
#ifdef NATIVE_GPU_EGL
    if(m->videoFd>=0){close(m->videoFd);m->videoFd=-1;int status;pid_t result;do{result=waitpid(m->videoPid,&status,0);}while(result<0 && errno==EINTR);m->videoPid=-1;require(result>0 && WIFEXITED(status) && WEXITSTATUS(status)==0,"video encoder failed");}
#endif
}
}
