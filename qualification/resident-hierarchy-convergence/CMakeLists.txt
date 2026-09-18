cmake_minimum_required(VERSION 3.24)
project(RejectedResidentKrylovCandidate LANGUAGES CXX CUDA)
find_package(CUDAToolkit 12.8 REQUIRED)
# Archived numerical experiment only. It is deliberately absent from every
# production SDK and native test target, and its physical qualification FAILS.
add_executable(gpu_resident_krylov_test candidate/gpu_resident_krylov_test.cu)
target_include_directories(gpu_resident_krylov_test PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../../blast/source/sdk/extensions/stressgpu/detail")
set_target_properties(gpu_resident_krylov_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
target_compile_options(gpu_resident_krylov_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
target_link_libraries(gpu_resident_krylov_test PRIVATE CUDA::cudart)
