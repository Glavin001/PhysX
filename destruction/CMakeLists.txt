cmake_minimum_required(VERSION 3.24)
project(PhysXDestructionSDK VERSION 0.1.0 LANGUAGES CXX)
include(CTest)
include(CMakePackageConfigHelpers)

get_filename_component(DESTRUCTION_REPO "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(PHYSX_ROOT "${DESTRUCTION_REPO}/physx" CACHE PATH "Built in-tree PhysX SDK")
set(PHYSX_CONFIGURATION release CACHE STRING "PhysX SDK configuration")
set(PX_GPU_BACKEND "CUDA" CACHE STRING "GPU compiler: CUDA or CUMETAL")
if(APPLE)
    set(_px_platform mac.arm64)
else()
    set(_px_platform linux.x86_64)
endif()
set(PHYSX_LIB_DIR "${PHYSX_ROOT}/bin/${_px_platform}/${PHYSX_CONFIGURATION}" CACHE PATH "PhysX libraries")
if(PX_GENERATED_INCLUDE_DIR)
    include_directories(BEFORE "${PX_GENERATED_INCLUDE_DIR}")
endif()
option(BLAST_ENABLE_CUDA_STRESS "Require the shared GPU stress backend" ON)
include("${CMAKE_CURRENT_LIST_DIR}/GpuBackend.cmake")

# Reference executables and SDK libraries share the same source targets. Keep
# this path until test target definitions have been separated from demo setup.
add_subdirectory("${DESTRUCTION_REPO}/destruction/vehicle" vehicle)
add_subdirectory("${DESTRUCTION_REPO}/demos/blast-stress-demo" reference)
if(BLAST_ENABLE_CUDA_STRESS)
    add_subdirectory("${DESTRUCTION_REPO}/physx/source/gpudestruction" topology)
endif()

install(TARGETS blast_stress_core NvBlastExtStressPhysX ARCHIVE DESTINATION lib)
if(BLAST_ENABLE_CUDA_STRESS)
    install(TARGETS NvBlastExtStressGpu ARCHIVE DESTINATION lib)
endif()
install(DIRECTORY "${PHYSX_ROOT}/include/" DESTINATION include/physx)
if(PX_GENERATED_INCLUDE_DIR)
    install(FILES "${PX_GENERATED_INCLUDE_DIR}/PxConfig.h" DESTINATION include/physx)
endif()
install(DIRECTORY "${DESTRUCTION_REPO}/blast/include/" DESTINATION include/blast)
install(DIRECTORY "${DESTRUCTION_REPO}/blast/rust_stress_example/ffi/"
    DESTINATION include/blast/ffi FILES_MATCHING PATTERN "*.h")
install(DIRECTORY "${PHYSX_LIB_DIR}/" DESTINATION lib
    FILES_MATCHING PATTERN "*.a" PATTERN "*.so" PATTERN "*.so.*" PATTERN "*.dylib")
install(DIRECTORY "${DESTRUCTION_REPO}/blast/blast-stress-demo-rs/assets/scenes/"
    DESTINATION share/physx-destruction/scenes FILES_MATCHING PATTERN "*.json")
configure_package_config_file(PhysXDestructionConfig.cmake.in
    "${CMAKE_CURRENT_BINARY_DIR}/PhysXDestructionConfig.cmake"
    INSTALL_DESTINATION lib/cmake/PhysXDestruction)
write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/PhysXDestructionConfigVersion.cmake"
    VERSION ${PROJECT_VERSION} COMPATIBILITY SameMajorVersion)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/PhysXDestructionConfig.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/PhysXDestructionConfigVersion.cmake"
    DESTINATION lib/cmake/PhysXDestruction)
