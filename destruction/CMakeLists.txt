cmake_minimum_required(VERSION 3.24)
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 89 CACHE STRING "CUDA architectures for destruction kernels")
endif()
project(PhysXDestructionSDK VERSION 0.1.0 LANGUAGES CXX)
include(CTest)
include(CMakePackageConfigHelpers)

get_filename_component(DESTRUCTION_REPO "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(PHYSX_ROOT "${DESTRUCTION_REPO}/physx" CACHE PATH "Built in-tree PhysX SDK")
set(PHYSX_CONFIGURATION release CACHE STRING "PhysX SDK configuration")
set(PHYSX_LIB_DIR "${PHYSX_ROOT}/bin/linux.x86_64/${PHYSX_CONFIGURATION}" CACHE PATH "PhysX libraries")
option(BLAST_ENABLE_CUDA_STRESS "Require the CUDA stress backend" ON)

# Reference executables and SDK libraries share the same source targets. Keep
# this path until test target definitions have been separated from demo setup.
add_subdirectory("${DESTRUCTION_REPO}/demos/blast-stress-demo" reference)
if(BLAST_ENABLE_CUDA_STRESS)
    enable_language(CUDA)
    add_subdirectory("${DESTRUCTION_REPO}/physx/source/gpudestruction" topology)
endif()

install(TARGETS blast_stress_core NvBlastExtStressPhysX ARCHIVE DESTINATION lib)
if(BLAST_ENABLE_CUDA_STRESS)
    install(TARGETS NvBlastExtStressGpu ARCHIVE DESTINATION lib)
endif()
install(DIRECTORY "${PHYSX_ROOT}/include/" DESTINATION include/physx)
install(DIRECTORY "${DESTRUCTION_REPO}/blast/include/" DESTINATION include/blast)
install(DIRECTORY "${DESTRUCTION_REPO}/blast/rust_stress_example/ffi/"
    DESTINATION include/blast/ffi FILES_MATCHING PATTERN "*.h")
install(DIRECTORY "${PHYSX_LIB_DIR}/" DESTINATION lib
    FILES_MATCHING PATTERN "*.a" PATTERN "*.so")
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
