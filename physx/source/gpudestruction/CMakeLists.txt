cmake_minimum_required(VERSION 3.24)
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 89 CACHE STRING "CUDA architectures for destruction kernels")
endif()
project(PhysXDestructionGpu LANGUAGES CXX CUDA)
find_package(CUDAToolkit REQUIRED)

add_library(PhysXDestructionTopologyGpu STATIC src/PxgDestructionTopology.cu)
target_include_directories(PhysXDestructionTopologyGpu PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/physx/destruction>)
set_target_properties(PhysXDestructionTopologyGpu PROPERTIES
    CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED ON CXX_STANDARD 17
    POSITION_INDEPENDENT_CODE ON CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
target_link_libraries(PhysXDestructionTopologyGpu PUBLIC CUDA::cudart)

include(CTest)
if(BUILD_TESTING)
    add_executable(destruction_topology_test tests/topology_test.cu)
    target_link_libraries(destruction_topology_test PRIVATE PhysXDestructionTopologyGpu)
    set_target_properties(destruction_topology_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_topology COMMAND destruction_topology_test)
endif()

install(TARGETS PhysXDestructionTopologyGpu EXPORT PhysXDestructionTopologyTargets ARCHIVE DESTINATION lib)
install(FILES include/PxgDestructionTopology.h DESTINATION include/physx/destruction)
install(EXPORT PhysXDestructionTopologyTargets NAMESPACE PhysX:: DESTINATION lib/cmake/PhysXDestructionTopology)
