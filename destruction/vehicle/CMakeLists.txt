# A PhysX Vehicle SDK car packaged for native-destruction scenes. The vehicle
# snippets' base/direct-drive/PhysX-integration classes are compiled in so a
# consumer needs neither the snippet tree nor rapidjson.
set(NATIVE_VEHICLE_SNIPPET_SOURCES
    "${PHYSX_ROOT}/snippets/snippetvehiclecommon/base/Base.cpp"
    "${PHYSX_ROOT}/snippets/snippetvehiclecommon/directdrivetrain/DirectDrivetrain.cpp"
    "${PHYSX_ROOT}/snippets/snippetvehiclecommon/physxintegration/PhysXIntegration.cpp")
add_library(PhysXNativeVehicle STATIC PxNativeVehicle.cpp ${NATIVE_VEHICLE_SNIPPET_SOURCES})
target_compile_features(PhysXNativeVehicle PUBLIC cxx_std_17)
target_include_directories(PhysXNativeVehicle
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include/physx-destruction>
    PRIVATE "${PHYSX_ROOT}/include" "${PHYSX_ROOT}/snippets")
target_compile_definitions(PhysXNativeVehicle PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
set_target_properties(PhysXNativeVehicle PROPERTIES OUTPUT_NAME PhysXNativeVehicle_static_64 POSITION_INDEPENDENT_CODE ON)
install(TARGETS PhysXNativeVehicle ARCHIVE DESTINATION lib)
install(FILES PxNativeVehicle.h DESTINATION include/physx-destruction)
