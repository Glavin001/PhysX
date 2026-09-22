# Native CUDA stress module. Keep runtime registration local: PhysX's kernel
# wrangler implements its own __cudaRegister* entry points for upstream kernels.
get_filename_component(DESTRUCTION_REPO_ROOT "${PHYSX_ROOT_DIR}/.." ABSOLUTE)
if(NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
find_package(CUDAToolkit 12.8 REQUIRED)
set(PX_DESTRUCTION_CUDA_ARCHITECTURES "89" CACHE STRING "Native destruction CUDA architectures")
if(NOT PX_DESTRUCTION_CUDA_ARCHITECTURES STREQUAL "89" OR CMAKE_CUDA_COMPILER_VERSION VERSION_LESS "12.8")
    message(FATAL_ERROR "Integrated destruction requires CUDA >= 12.8 and RTX 4090 architecture 89")
endif()
# Match the reference stress compiler's arithmetic, independently of upstream
# PhysX's fast-math switches. Explicit user CUDA flags still apply.
get_property(CMAKE_CUDA_FLAGS CACHE CMAKE_CUDA_FLAGS PROPERTY VALUE)
endif()
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
if(NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    target_link_libraries(PhysXDestructionGpuRuntime PRIVATE CUDA::cudart_static CUDA::cuda_driver)
endif()
if(UNIX AND NOT APPLE)
    target_link_options(PhysXDestructionGpuRuntime PRIVATE "-Wl,-Bsymbolic" "-Wl,--exclude-libs,ALL")
endif()

# Isolated diagnostic implementation. Never replaces the production output and
# is excluded from default builds. The capture process explicitly selects it.
get_target_property(DESTRUCTION_DIAGNOSTIC_SOURCES PhysXDestructionGpuRuntime SOURCES)
add_library(PhysXDestructionGpuWorkDiagnostic SHARED EXCLUDE_FROM_ALL ${DESTRUCTION_DIAGNOSTIC_SOURCES})
foreach(property INCLUDE_DIRECTORIES COMPILE_DEFINITIONS CUDA_STANDARD CUDA_STANDARD_REQUIRED
        CUDA_RUNTIME_LIBRARY CUDA_ARCHITECTURES CXX_VISIBILITY_PRESET CUDA_VISIBILITY_PRESET
        VISIBILITY_INLINES_HIDDEN POSITION_INDEPENDENT_CODE LINK_LIBRARIES LINK_OPTIONS)
    get_target_property(value PhysXDestructionGpuRuntime ${property})
    if(NOT value STREQUAL "value-NOTFOUND")
        set_property(TARGET PhysXDestructionGpuWorkDiagnostic PROPERTY ${property} "${value}")
    endif()
endforeach()
target_compile_definitions(PhysXDestructionGpuWorkDiagnostic PRIVATE
    BLAST_GPU_COMPONENT_PHASE_PROBE BLAST_GPU_COMPONENT_WORK_CAPTURE)
get_target_property(diagnostic_name PhysXDestructionGpuRuntime OUTPUT_NAME)
if(diagnostic_name STREQUAL "diagnostic_name-NOTFOUND")
    set(diagnostic_name PhysXDestructionGpuRuntime)
endif()
set_target_properties(PhysXDestructionGpuWorkDiagnostic PROPERTIES
    OUTPUT_NAME "${diagnostic_name}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/diagnostics/component-work"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/diagnostics/component-work")

# Exact native equation snapshots, deliberately intrusive and never selected by
# a production build. Same ABI, separate output directory and explicit target.
add_library(PhysXDestructionGpuProblemDiagnostic SHARED EXCLUDE_FROM_ALL ${DESTRUCTION_DIAGNOSTIC_SOURCES})
foreach(property INCLUDE_DIRECTORIES COMPILE_DEFINITIONS CUDA_STANDARD CUDA_STANDARD_REQUIRED
        CUDA_RUNTIME_LIBRARY CUDA_ARCHITECTURES CXX_VISIBILITY_PRESET CUDA_VISIBILITY_PRESET
        VISIBILITY_INLINES_HIDDEN POSITION_INDEPENDENT_CODE LINK_LIBRARIES LINK_OPTIONS)
    get_target_property(value PhysXDestructionGpuWorkDiagnostic ${property})
    if(NOT value STREQUAL "value-NOTFOUND")
        set_property(TARGET PhysXDestructionGpuProblemDiagnostic PROPERTY ${property} "${value}")
    endif()
endforeach()
target_compile_definitions(PhysXDestructionGpuProblemDiagnostic PRIVATE BLAST_GPU_NATIVE_PROBLEM_CAPTURE)
set_target_properties(PhysXDestructionGpuProblemDiagnostic PROPERTIES
    OUTPUT_NAME "${diagnostic_name}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/diagnostics/stress-problem"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/diagnostics/stress-problem")

if(PX_GPU_BACKEND STREQUAL "CUMETAL")
    foreach(target PhysXDestructionGpuRuntime PhysXDestructionGpuWorkDiagnostic PhysXDestructionGpuProblemDiagnostic)
        px_cumetal_objects(${target})
    endforeach()
endif()
