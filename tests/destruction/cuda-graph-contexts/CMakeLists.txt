cmake_minimum_required(VERSION 3.24)
# Deliberately independent of PhysX, Blast, and their CUDA module loaders.
project(DestructionCudaGraphContextDiagnostic LANGUAGES CXX CUDA)
find_package(CUDAToolkit 12.3 REQUIRED)
add_executable(cuda_graph_contexts main.cu)
set_target_properties(cuda_graph_contexts PROPERTIES CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED YES)
target_compile_options(cuda_graph_contexts PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
target_link_libraries(cuda_graph_contexts PRIVATE CUDA::cuda_driver)
