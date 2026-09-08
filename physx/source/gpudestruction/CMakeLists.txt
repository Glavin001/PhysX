cmake_minimum_required(VERSION 3.24)
if(NOT DEFINED CMAKE_CUDA_ARCHITECTURES)
    set(CMAKE_CUDA_ARCHITECTURES 89 CACHE STRING "CUDA architectures for destruction kernels")
endif()
project(PhysXDestructionGpu LANGUAGES CXX CUDA)
find_package(CUDAToolkit 12.3 REQUIRED)

add_library(PhysXDestructionTopologyGpu STATIC src/PxgDestructionTopology.cu)
target_include_directories(PhysXDestructionTopologyGpu PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../../include>
    $<INSTALL_INTERFACE:include/physx/destruction>
    $<INSTALL_INTERFACE:include/physx>)
set_target_properties(PhysXDestructionTopologyGpu PROPERTIES
    CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED ON CXX_STANDARD 17
    POSITION_INDEPENDENT_CODE ON CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
target_link_libraries(PhysXDestructionTopologyGpu PUBLIC CUDA::cudart)

include(CTest)
if(BUILD_TESTING)
    add_executable(destruction_committed_changes_test tests/committed_changes_test.cu)
    target_link_libraries(destruction_committed_changes_test PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_committed_changes_test PRIVATE ../../../blast/include/extensions/stressgpu)
    set_target_properties(destruction_committed_changes_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_committed_changes COMMAND destruction_committed_changes_test)
    add_executable(destruction_topology_test tests/topology_test.cu)
    target_link_libraries(destruction_topology_test PRIVATE PhysXDestructionTopologyGpu)
    set_target_properties(destruction_topology_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_topology COMMAND destruction_topology_test)
    add_executable(destruction_body_test tests/body_test.cu)
    target_link_libraries(destruction_body_test PRIVATE PhysXDestructionTopologyGpu)
    set_target_properties(destruction_body_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_body_state COMMAND destruction_body_test)
    add_executable(destruction_contact_graph_test tests/contact_graph_test.cu)
    target_link_libraries(destruction_contact_graph_test PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_contact_graph_test PRIVATE
        ../gpunarrowphase/include ../gpusimulationcontroller/include ../lowlevel/software/include ../lowlevel/api/include)
    set_target_properties(destruction_contact_graph_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_contact_graph COMMAND destruction_contact_graph_test)
endif()

install(TARGETS PhysXDestructionTopologyGpu EXPORT PhysXDestructionTopologyTargets ARCHIVE DESTINATION lib)
install(FILES include/PxgDestructionTopology.h DESTINATION include/physx/destruction)
install(FILES ../../include/PxDestructionTopologyTypes.h DESTINATION include/physx)
install(EXPORT PhysXDestructionTopologyTargets NAMESPACE PhysX:: DESTINATION lib/cmake/PhysXDestructionTopology)
