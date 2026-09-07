// Demo input authoring; all projectile motion after insertion is solved by PhysX.
#pragma once
#include <foundation/PxVec3.h>
#include <foundation/PxMath.h>
namespace blast_demo {
struct NativeBombardmentLaunch { physx::PxVec3 position, velocity, target; };
// Keep building zero and its accepted shot unchanged. Additional city geometry
// sits beside the entire flight corridor, so world-size tests do not silently
// become a chain of additional projectile impacts.
inline physx::PxVec3 nativeBuildingOrigin(unsigned building,unsigned grid,bool impactCorridor) {
    if(impactCorridor && building)
        return physx::PxVec3(float(1+(building-1)%grid)*16,.5f,float((building-1)/grid)*16);
    return physx::PxVec3(float(building%grid)*16,.5f,float(building/grid)*16);
}
inline NativeBombardmentLaunch nativeBombardmentLaunch(const physx::PxVec3& origin,unsigned wave,float observedChunkTop) {
    using namespace physx;
    const PxVec3 directions[]={PxVec3(0,0,1),PxVec3(1,0,0),PxVec3(0,0,-1),PxVec3(-1,0,0)};
    NativeBombardmentLaunch launch;
    launch.target=origin+PxVec3(0,8.5f+float(wave%2),0);
    launch.position=launch.target-directions[wave%4]*48;
    launch.position.y=PxMax(24.0f,observedChunkTop+2.0f);
    const float flight=1.5f;
    launch.velocity=(launch.target-launch.position)/flight;
    launch.velocity.y+=.5f*9.81f*flight;
    return launch;
}
// Single-building demonstration: clear approach through the wall panel between
// floor slabs. Only initial conditions are authored; no post-launch steering.
inline NativeBombardmentLaunch nativeWallPenetrationLaunch(const physx::PxVec3& origin) {
    using namespace physx;
    NativeBombardmentLaunch launch{origin+PxVec3(0,6,-16),PxVec3(0,3,40),PxVec3(0)};
    const float flight=.4f;
    launch.target=launch.position+launch.velocity*flight+PxVec3(0,-.5f*9.81f*flight*flight,0);
    return launch;
}
inline void raiseNativeBombardmentLaunch(NativeBombardmentLaunch& launch) {
    launch.position.y+=2.0f;
    launch.velocity=(launch.target-launch.position)/1.5f;
    launch.velocity.y+=.5f*9.81f*1.5f;
}
}
