# Native CUDA stress module. Keep runtime registration local: PhysX's kernel
# wrangler implements its own __cudaRegister* entry points for upstream kernels.
find_package(CUDAToolkit 12.3 REQUIRED)
get_filename_component(DESTRUCTION_REPO_ROOT "${PHYSX_ROOT_DIR}/.." ABSOLUTE)
set(PX_DESTRUCTION_CUDA_ARCHITECTURES "89" CACHE STRING "Native destruction CUDA architectures")
if(NOT PX_DESTRUCTION_CUDA_ARCHITECTURES STREQUAL "89" OR CMAKE_CUDA_COMPILER_VERSION VERSION_LESS "12.8")
    message(FATAL_ERROR "Integrated destruction requires CUDA >= 12.8 and RTX 4090 architecture 89")
endif()
# Match the reference stress compiler's arithmetic, independently of upstream
# PhysX's fast-math switches. Explicit user CUDA flags still apply.
get_property(CMAKE_CUDA_FLAGS CACHE CMAKE_CUDA_FLAGS PROPERTY VALUE)
add_library(PhysXDestructionGpuRuntime SHARED
    ../src/PxgDestructionRuntime.cu
    ../src/PxgDestructionTopology.cu
    ${DESTRUCTION_REPO_ROOT}/blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpu.cu)
target_include_directories(PhysXDestructionGpuRuntime PRIVATE
    ../include ${PHYSX_ROOT_DIR}/include
    ${PHYSX_SOURCE_DIR}/lowlevel/software/include
    ${PHYSX_SOURCE_DIR}/lowlevel/api/include
    ${PHYSX_SOURCE_DIR}/common/include
    ${PHYSX_SOURCE_DIR}/common/src
    ${PHYSX_SOURCE_DIR}/gpunarrowphase/include
    ${PHYSX_SOURCE_DIR}/gpusimulationcontroller/include
    ${PHYSX_SOURCE_DIR}/gpucommon/include
    ${DESTRUCTION_REPO_ROOT}/blast/include/extensions/stressgpu
    ${DESTRUCTION_REPO_ROOT}/blast/include/extensions/stress)
target_compile_definitions(PhysXDestructionGpuRuntime PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PHYSX_RESIDENT_DESTRUCTION)
set_target_properties(PhysXDestructionGpuRuntime PROPERTIES
    CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED YES CUDA_RUNTIME_LIBRARY Static
    CUDA_ARCHITECTURES "${PX_DESTRUCTION_CUDA_ARCHITECTURES}"
    CXX_VISIBILITY_PRESET hidden CUDA_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN YES POSITION_INDEPENDENT_CODE YES)
if(NOT CMAKE_DEBUG_POSTFIX)
    set_target_properties(PhysXDestructionGpuRuntime PROPERTIES OUTPUT_NAME PhysXDestructionGpuRuntime_64)
endif()
target_link_libraries(PhysXDestructionGpuRuntime PRIVATE CUDA::cudart_static CUDA::cuda_driver)
if(UNIX AND NOT APPLE)
    target_link_options(PhysXDestructionGpuRuntime PRIVATE "-Wl,-Bsymbolic" "-Wl,--exclude-libs,ALL")
endif()
