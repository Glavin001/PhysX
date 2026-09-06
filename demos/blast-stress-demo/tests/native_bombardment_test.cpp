#include "../native_bombardment.h"
#include <cstdio>
#include <stdexcept>
using namespace physx;
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
int main(){try {
    unsigned oldOverlaps=0,checked=0;
    for(unsigned wave=0;wave<4;++wave)for(unsigned building=0;building<256;++building) {
        const unsigned x=building%16,z=building/16;
        const PxVec3 origin(float(x)*16,.5f,float(z)*16);
        // Old launch is 3m from the preceding building's center, inside its
        // 7.96m footprint. Verify a real wall box overlaps the projectile.
        if((wave%2?x:z)>0) {
            const PxVec3 old=wave%2?PxVec3(3,8.5f,0):PxVec3(0,3.5f,3);
            const PxVec3 wall=wave%2?PxVec3(3.5f,8,.5f):PxVec3(.5f,3,3.5f);
            const PxVec3 delta=old-wall;
            const PxVec3 outside(PxMax(PxAbs(delta.x)-.48f,0.0f),PxMax(PxAbs(delta.y)-.48f,0.0f),PxMax(PxAbs(delta.z)-.48f,0.0f));
            require(outside.magnitudeSquared()<.75f*.75f,"old spawn regression did not overlap its neighbor");++oldOverlaps;
        }
        for(float ceiling:{12.5f,30.0f,60.0f}) {
            auto launch=blast_demo::nativeBombardmentLaunch(origin,wave,ceiling);
            require(launch.position.y-.75f>ceiling,"projectile starts inside scene geometry");
            require(launch.velocity.y<0,"elevated projectile should approach downward");
            const PxVec3 atTarget=launch.position+launch.velocity*1.5f+PxVec3(0,-.5f*9.81f*1.5f*1.5f,0);
            require((atTarget-launch.target).magnitude()<1e-4f,"ballistic aim misses target");
            // Last point over the nearest intervening authored building. The
            // descending trajectory is higher everywhere before this point.
            const float t=(48-(16-3.98f))/32;
            const float y=launch.position.y+launch.velocity.y*t-.5f*9.81f*t*t;
            require(y-.75f>11.98f,"approach intersects intervening authored roof");
            const auto oldPosition=launch.position;blast_demo::raiseNativeBombardmentLaunch(launch);
            require((launch.position-oldPosition).magnitude()>1.5f,"spawn separation cannot clear another projectile");
            require((launch.position+launch.velocity*1.5f+PxVec3(0,-.5f*9.81f*1.5f*1.5f,0)-launch.target).magnitude()<1e-4f,"spawn clearance adjustment changed ballistic aim");
            ++checked;
        }
    }
    require(oldOverlaps==960,"old city spawn regression count changed");
    std::printf("launch audit: old embedded projectiles=%u/1024; safe aerial trajectories=%u passed\n",oldOverlaps,checked);
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
