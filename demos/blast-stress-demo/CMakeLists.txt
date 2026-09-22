cmake_minimum_required(VERSION 3.20)
project(blast_stress_physx_demo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

get_filename_component(REPO_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(BLAST_ROOT "${REPO_ROOT}/blast" CACHE PATH "Blast source root")
set(PHYSX_ROOT "${REPO_ROOT}/physx" CACHE PATH "Built PhysX SDK root")
set(PHYSX_CONFIGURATION "release" CACHE STRING "PhysX binary configuration")
option(BLAST_ENABLE_CUDA_STRESS "Build the shared GPU stress solver" ON)
include("${REPO_ROOT}/destruction/GpuBackend.cmake")
set(PHYSX_LIB_DIR "${PHYSX_ROOT}/bin/${PX_DESTRUCTION_PLATFORM}/${PHYSX_CONFIGURATION}" CACHE PATH
    "PhysX library directory")

if(NOT EXISTS "${PHYSX_ROOT}/include/PxPhysicsAPI.h")
    message(FATAL_ERROR "PHYSX_ROOT does not contain include/PxPhysicsAPI.h: ${PHYSX_ROOT}")
endif()

function(require_physx_library output name)
    find_library(${output}
        NAMES "${name}"
        PATHS "${PHYSX_LIB_DIR}"
        NO_DEFAULT_PATH
        REQUIRED)
    set(${output} "${${output}}" PARENT_SCOPE)
endfunction()

require_physx_library(PHYSX_EXTENSIONS PhysXExtensions_static_64)
require_physx_library(PHYSX_CORE PhysX_static_64)
require_physx_library(PHYSX_PVD PhysXPvdSDK_static_64)
require_physx_library(PHYSX_COOKING PhysXCooking_static_64)
require_physx_library(PHYSX_COMMON PhysXCommon_static_64)
require_physx_library(PHYSX_FOUNDATION PhysXFoundation_static_64)
require_physx_library(PHYSX_CUDA_MANAGER PhysXCudaContextManager_static_64)
require_physx_library(PHYSX_VEHICLE PhysXVehicle_static_64)
find_library(PVD_RUNTIME
    NAMES PVDRuntime_64
    PATHS "${PHYSX_LIB_DIR}"
    NO_DEFAULT_PATH)

set(BLAST_CORE_SOURCES
    "${BLAST_ROOT}/rust_stress_example/ffi/ext_stress_bridge.cpp"
    "${BLAST_ROOT}/source/shared/stress_solver/stress.cpp"
    "${BLAST_ROOT}/source/sdk/common/NvBlastAssert.cpp"
    "${BLAST_ROOT}/source/sdk/common/NvBlastAtomic.cpp"
    "${BLAST_ROOT}/source/sdk/common/NvBlastTime.cpp"
    "${BLAST_ROOT}/source/sdk/common/NvBlastTimers.cpp"
    "${BLAST_ROOT}/source/sdk/globals/NvBlastGlobals.cpp"
    "${BLAST_ROOT}/source/sdk/globals/NvBlastInternalProfiler.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastAsset.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastAssetHelper.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastFamily.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastFamilyGraph.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastActor.cpp"
    "${BLAST_ROOT}/source/sdk/lowlevel/NvBlastActorSerializationBlock.cpp"
    "${BLAST_ROOT}/source/sdk/extensions/stress/NvBlastExtStressSolver.cpp")

add_library(blast_stress_core STATIC ${BLAST_CORE_SOURCES})
target_include_directories(blast_stress_core PUBLIC
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/globals"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/extensions/stress"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/source/shared"
    "${BLAST_ROOT}/source/shared/stress_solver"
    "${BLAST_ROOT}/source/sdk/common"
    "${BLAST_ROOT}/source/sdk/lowlevel"
    "${BLAST_ROOT}/source/shared/NsFoundation/include"
    "${BLAST_ROOT}/rust_stress_example/ffi")
target_compile_definitions(blast_stress_core PRIVATE NDEBUG)
if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64")
    target_compile_options(blast_stress_core PRIVATE -mavx -mfma)
else()
    target_compile_definitions(blast_stress_core PRIVATE
        STRESS_SOLVER_FORCE_SCALAR
        STRESS_SOLVER_NO_SIMD
        STRESS_SOLVER_NO_DEVICE_QUERY)
endif()

file(GLOB STRESS_PHYSX_SOURCES CONFIGURE_DEPENDS
    "${BLAST_ROOT}/source/sdk/extensions/stressphysx/*.cpp")
if(NOT STRESS_PHYSX_SOURCES)
    message(FATAL_ERROR "PhysX adapter sources are missing under blast/source/sdk/extensions/stressphysx")
endif()

add_library(NvBlastExtStressPhysX STATIC ${STRESS_PHYSX_SOURCES})
target_include_directories(NvBlastExtStressPhysX PUBLIC
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${BLAST_ROOT}/rust_stress_example/ffi"
    "${PHYSX_ROOT}/include")
target_compile_definitions(NvBlastExtStressPhysX PUBLIC PX_PHYSX_STATIC_LIB NDEBUG)
target_link_libraries(NvBlastExtStressPhysX PUBLIC blast_stress_core)

if(BLAST_ENABLE_CUDA_STRESS)
    target_sources(NvBlastExtStressPhysX PRIVATE
        "${BLAST_ROOT}/source/sdk/extensions/stressphysx/NvBlastExtStressPhysXContactGpu.cu")
    target_compile_definitions(NvBlastExtStressPhysX PRIVATE NVBLAST_ENABLE_DIRECT_GPU_CONTACT_DRAIN)
    px_destruction_cuda_properties(NvBlastExtStressPhysX PROPERTIES CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}" CUDA_RUNTIME_LIBRARY Shared)
    target_link_libraries(NvBlastExtStressPhysX PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})

    add_library(NvBlastExtStressGpu STATIC
        "${BLAST_ROOT}/source/sdk/extensions/stressgpu/NvBlastExtStressGpu.cu")
    target_include_directories(NvBlastExtStressGpu PUBLIC
        "${BLAST_ROOT}/include/extensions/stressgpu"
        # NvBlastExtStressGpu.cu includes NvBlastExtStressFormula.h, the shared
        # host/device stress equation, which lives with the CPU solver's
        # headers. Without this the demo's test targets cannot build the CUDA
        # solver at all.
        "${BLAST_ROOT}/include/extensions/stress")
    set_target_properties(NvBlastExtStressGpu PROPERTIES POSITION_INDEPENDENT_CODE ON)
    px_destruction_cuda_properties(NvBlastExtStressGpu PROPERTIES
        CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    target_compile_definitions(blast_stress_core PRIVATE
        NVBLAST_ENABLE_CUDA_STRESS)
    target_link_libraries(NvBlastExtStressGpu PUBLIC
        ${PX_DESTRUCTION_GPU_RUNTIME}
        ${PX_DESTRUCTION_GPU_DRIVER})
    target_link_libraries(blast_stress_core PUBLIC NvBlastExtStressGpu)
endif()

set(PHYSX_LINK_LIBS)
if(NOT APPLE)
    list(APPEND PHYSX_LINK_LIBS "-Wl,--start-group")
endif()
list(APPEND PHYSX_LINK_LIBS
    ${PHYSX_EXTENSIONS} ${PHYSX_CUDA_MANAGER} ${PHYSX_CORE} ${PHYSX_PVD}
    ${PHYSX_COOKING} ${PHYSX_COMMON} ${PHYSX_FOUNDATION})
if(NOT APPLE)
    list(APPEND PHYSX_LINK_LIBS "-Wl,--end-group")
endif()
if(PVD_RUNTIME)
    list(APPEND PHYSX_LINK_LIBS ${PVD_RUNTIME})
endif()
list(APPEND PHYSX_LINK_LIBS ${PX_DESTRUCTION_GPU_DRIVER} ${CMAKE_DL_LIBS} Threads::Threads)
if(UNIX AND NOT APPLE)
    list(APPEND PHYSX_LINK_LIBS rt)
endif()

# Application CUDA registration must resolve before the PhysX static group.
# Otherwise its private CudaKernelWrangler intercepts __cudaRegisterFatBinary
# and looks for engine-only PxGpuCudaRegister* symbols in our kernels.
if(BLAST_ENABLE_CUDA_STRESS)
    list(PREPEND PHYSX_LINK_LIBS ${PX_DESTRUCTION_GPU_RUNTIME})
endif()

add_executable(blast_stress_demo
    mini_city_main.cpp
    physx_scene.cpp
    scene_pack.cpp
    state_writer.cpp)
target_include_directories(blast_stress_demo PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(blast_stress_demo PRIVATE PX_PHYSX_STATIC_LIB NDEBUG
    BLAST_DEFAULT_SCENE_PATH="${BLAST_ROOT}/blast-stress-demo-rs/assets/scenes/fractured-tower.json")
target_link_options(blast_stress_demo PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(blast_stress_demo PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})

add_executable(blast_direct_gpu_p0
    direct_gpu_p0.cpp
    physx_scene.cpp)
target_include_directories(blast_direct_gpu_p0 PRIVATE
    "${PHYSX_ROOT}/include")
target_compile_definitions(blast_direct_gpu_p0 PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(blast_direct_gpu_p0 PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(blast_direct_gpu_p0 PRIVATE
    ${PHYSX_LINK_LIBS})

enable_testing()
add_test(NAME blast_stress_physx_cpu_contract
    COMMAND blast_stress_demo --self-test --physics cpu)
add_test(NAME blast_stress_physx_resim_penetration
    COMMAND blast_stress_demo --self-test --physics cpu
        --resim-passes 1 --resim-assert penetrate)
add_test(NAME blast_stress_physx_resim_baseline
    COMMAND blast_stress_demo --self-test --physics cpu
        --resim-passes 0 --resim-assert deflect)

add_executable(resim_snapshot_test
    tests/resim_snapshot_test.cpp
    physx_scene.cpp)
target_include_directories(resim_snapshot_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(resim_snapshot_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(resim_snapshot_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(resim_snapshot_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_physx_resim_snapshot COMMAND resim_snapshot_test)
add_test(NAME blast_stress_physx_resim_policy_gpu COMMAND resim_snapshot_test --gpu)

add_executable(velocity_fidelity_test tests/velocity_fidelity_test.cpp physx_scene.cpp)
target_link_libraries(velocity_fidelity_test PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})
target_link_options(velocity_fidelity_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}" "${PX_DESTRUCTION_GC_SECTIONS}")
add_test(NAME blast_stress_velocity_fidelity_cpu COMMAND velocity_fidelity_test cpu)
if(BLAST_ENABLE_CUDA_STRESS)
    add_test(NAME blast_stress_velocity_fidelity_gpu COMMAND velocity_fidelity_test gpu)
    set_tests_properties(blast_stress_velocity_fidelity_gpu PROPERTIES RUN_SERIAL TRUE)
    if(EXISTS "${PHYSX_ROOT}/gpu-activity-manifest.json")
        add_test(NAME blast_stress_velocity_fidelity_direct COMMAND velocity_fidelity_test direct)
        set_tests_properties(blast_stress_velocity_fidelity_direct PROPERTIES RUN_SERIAL TRUE)
    endif()
endif()

add_executable(load_path_test
    tests/load_path_test.cpp
    physx_scene.cpp)
target_include_directories(load_path_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(load_path_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(load_path_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(load_path_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_load_path COMMAND load_path_test)

# Depth-scaling probe for CPU/GPU stress divergence. Not registered with ctest:
# it prints a stress field to be diffed between solvers rather than asserting.
add_executable(solver_divergence_test
    tests/solver_divergence_test.cpp
    physx_scene.cpp)
target_include_directories(solver_divergence_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(solver_divergence_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(solver_divergence_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(solver_divergence_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})

add_executable(resim_punchthrough_test
    tests/resim_punchthrough_test.cpp
    physx_scene.cpp)
target_include_directories(resim_punchthrough_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(resim_punchthrough_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(resim_punchthrough_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(resim_punchthrough_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_physx_resim_punchthrough COMMAND resim_punchthrough_test)
add_test(NAME blast_stress_physx_resim_punchthrough_gpu COMMAND resim_punchthrough_test --gpu)

add_executable(resim_scoped_cascade_test
    tests/resim_scoped_cascade_test.cpp
    physx_scene.cpp)
target_include_directories(resim_scoped_cascade_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(resim_scoped_cascade_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(resim_scoped_cascade_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(resim_scoped_cascade_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_physx_resim_scoped_cascade COMMAND resim_scoped_cascade_test)

add_executable(direct_gpu_resim_test
    tests/direct_gpu_resim_test.cpp
    physx_scene.cpp)
target_include_directories(direct_gpu_resim_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(direct_gpu_resim_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(direct_gpu_resim_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(direct_gpu_resim_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_physx_direct_gpu_resim COMMAND direct_gpu_resim_test)

# Opt-in performance experiment: sleeping versus readback savings. Not a CTest
# latency gate; run exclusively on the GPU and retain the raw CSV.
add_executable(gpu_activity_bench tests/gpu_activity_bench.cpp physx_scene.cpp)
target_include_directories(gpu_activity_bench PRIVATE "${PHYSX_ROOT}/include")
target_compile_definitions(gpu_activity_bench PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(gpu_activity_bench PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
target_link_libraries(gpu_activity_bench PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})

# The activity extension is intentionally opt-in and unavailable in stock SDKs.
file(STRINGS "${PHYSX_ROOT}/include/PxSceneDesc.h" PHYSX_GPU_ACTIVITY_FEATURE
    REGEX "^#define PX_DIRECT_GPU_SLEEPING_VERSION ")
if(PHYSX_GPU_ACTIVITY_FEATURE)
    add_executable(gpu_activity_test tests/gpu_activity_test.cpp physx_scene.cpp)
    target_link_options(gpu_activity_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(gpu_activity_test PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})
    add_test(NAME blast_stress_physx_gpu_activity COMMAND gpu_activity_test)
endif()

add_executable(scene_pack_test
    tests/scene_pack_test.cpp
    scene_pack.cpp)
target_include_directories(scene_pack_test PRIVATE "${PHYSX_ROOT}/include")
target_compile_definitions(scene_pack_test PRIVATE PX_PHYSX_STATIC_LIB)
# The worked reference building must keep the calibration its documentation
# claims: it stands under its own weight with every joint class inside the
# target safety-factor bands (see the authoring skill). If a change to the
# solver, the loader or the pack moves those numbers, this fails.
add_test(NAME blast_stress_reference_building_load_path
    COMMAND blast_stress_demo --physics cpu --grid 1 --duration 6 --settle 2
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building.json"
        --projectile-mass-scale 0.0001 --projectile-speed-scale 0.0001
        --require-min-safety-factor 2 --require-max-safety-factor 2000
        --output-state "")

add_executable(material_behavior_test
    tests/material_behavior_test.cpp
    physx_scene.cpp)
target_include_directories(material_behavior_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(material_behavior_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(material_behavior_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(material_behavior_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_material_behavior COMMAND material_behavior_test)

add_executable(chunk_crush_test
    tests/chunk_crush_test.cpp
    physx_scene.cpp)
target_include_directories(chunk_crush_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(chunk_crush_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(chunk_crush_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(chunk_crush_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_chunk_crush COMMAND chunk_crush_test)

add_executable(scene_pack_v3_test
    tests/scene_pack_v3_test.cpp
    scene_pack.cpp)
target_include_directories(scene_pack_v3_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${PHYSX_ROOT}/include")
target_compile_definitions(scene_pack_v3_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(scene_pack_v3_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(scene_pack_v3_test PRIVATE ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_scene_pack_v3
    COMMAND scene_pack_v3_test
        "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building-crush.json")

# The crush-enabled reference building, end to end. Two runs on the SAME pack:
# gravity alone must comminute nothing, and an impact must comminute a small
# localized fraction. The upper bound is the load-bearing half -- a crush model
# that grinds up the whole structure has reproduced the over-fragmentation this
# project already treats as failure.
add_test(NAME blast_stress_reference_building_crush_gravity
    COMMAND blast_stress_demo
        --physics cpu --grid 1 --duration 10 --settle 2
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building-crush.json"
        --projectile-mass-scale 0.0001 --projectile-speed-scale 0.0001
        --require-crush-fraction-max 0
        --output-state "")

# An ORDINARY impact must comminute nothing: the wall comes apart at its joints
# and every chunk survives. Crushing is reserved for violence, and this is the
# test that says so.
add_test(NAME blast_stress_reference_building_crush_ordinary_impact
    COMMAND blast_stress_demo
        --physics cpu --grid 1 --duration 10 --settle 2
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building-crush.json"
        --require-crush-fraction-max 0
        --output-state "")

# A HARD impact must comminute a small, localized fraction -- and only that.
# The upper bound is the load-bearing half: a crush model that grinds up the
# whole structure has reproduced the over-fragmentation this project already
# treats as failure.
add_test(NAME blast_stress_reference_building_crush_hard_impact
    COMMAND blast_stress_demo
        --physics cpu --grid 1 --duration 10 --settle 2
        --projectile-mass-scale 8
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building-crush.json"
        --require-crush-fraction-min 0.01 --require-crush-fraction-max 0.25
        --output-state "")

# Crushing across MANY structures with resimulation on. This is the shape the
# single-building tests cannot cover: retiring a body mid-frame while the frame
# stepper still holds it in its pre-simulate capture. That combination segfaulted
# and is only reachable with several buildings and a resim pass, so it gets its
# own gate.
# The punch-through wall, both ways, at the PRODUCTION resim setting
# (resim-passes 1). Crush ON must take a bite out of the impact zone; the SAME
# impact with crush OFF must comminute nothing. Measured at this energy the
# bond-only wall cracks internally but keeps every block in place, which is
# exactly the regime where crushing is the only source of visible damage.
add_test(NAME blast_stress_crush_wall_bite
    COMMAND blast_stress_demo
        --physics cpu --grid 1 --duration 8 --settle 2
        --projectile-waves 1 --resim-passes 1
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/crush-wall.json"
        --require-crush-fraction-min 0.015 --require-crush-fraction-max 0.2
        --output-state "")

add_test(NAME blast_stress_crush_wall_bond_only
    COMMAND blast_stress_demo
        --physics cpu --grid 1 --duration 8 --settle 2
        --projectile-waves 1 --resim-passes 1 --no-crush
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/crush-wall.json"
        --require-crush-fraction-max 0
        --output-state "")

add_test(NAME blast_stress_crush_multi_structure_resim
    COMMAND blast_stress_demo
        --physics cpu --grid 3 --duration 12 --settle 2
        --projectile-mass-scale 8 --resim-passes 2
        --scene "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building-crush.json"
        --require-crush-fraction-min 0.01 --require-crush-fraction-max 0.25
        --output-state "")

add_executable(destruction_quality_test
    tests/destruction_quality_test.cpp
    physx_scene.cpp
    scene_pack.cpp)
target_include_directories(destruction_quality_test PRIVATE
    "${BLAST_ROOT}/include"
    "${BLAST_ROOT}/include/lowlevel"
    "${BLAST_ROOT}/include/shared/NvFoundation"
    "${BLAST_ROOT}/include/extensions/stressphysx"
    "${PHYSX_ROOT}/include")
target_compile_definitions(destruction_quality_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(destruction_quality_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}"
    "${PX_DESTRUCTION_GC_SECTIONS}")
target_link_libraries(destruction_quality_test PRIVATE
    NvBlastExtStressPhysX
    ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_destruction_quality
    COMMAND destruction_quality_test
        "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building.json")

add_executable(scene_pack_conformance_test
    tests/scene_pack_conformance_test.cpp
    scene_pack.cpp)
target_include_directories(scene_pack_conformance_test PRIVATE
    "${PHYSX_ROOT}/include")
target_compile_definitions(scene_pack_conformance_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(scene_pack_conformance_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}")
target_link_libraries(scene_pack_conformance_test PRIVATE ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_scene_pack_conformance
    COMMAND scene_pack_conformance_test
        "${REPO_ROOT}/blast/blast-stress-solver/assets/conformance/structure-conformance-v2.json")

add_test(NAME blast_stress_scene_pack
    COMMAND scene_pack_test
        "${BLAST_ROOT}/blast-stress-demo-rs/assets/scenes/fractured-tower.json")

add_executable(node_mesh_test
    tests/node_mesh_test.cpp
    scene_pack.cpp)
target_include_directories(node_mesh_test PRIVATE
    "${PHYSX_ROOT}/include")
target_compile_definitions(node_mesh_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
target_link_options(node_mesh_test PRIVATE
    "-Wl,-rpath,${PHYSX_LIB_DIR}")
target_link_libraries(node_mesh_test PRIVATE ${PHYSX_LINK_LIBS})
add_test(NAME blast_stress_node_mesh
    COMMAND node_mesh_test
        "${BLAST_ROOT}/blast-stress-demo-rs/assets/scenes/fractured-tower.json"
        "${REPO_ROOT}/blast/blast-stress-solver/assets/reference/reference-building.json")

if(BLAST_ENABLE_CUDA_STRESS)
    add_test(NAME blast_stress_gpu_crush_correction COMMAND chunk_crush_test --gpu)
    add_executable(direct_gpu_contact_test tests/direct_gpu_contact_test.cu physx_scene.cpp)
    px_destruction_cuda_properties(direct_gpu_contact_test PROPERTIES CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}" CUDA_RUNTIME_LIBRARY Shared)
    target_link_options(direct_gpu_contact_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(direct_gpu_contact_test PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})
    add_test(NAME blast_stress_physx_direct_gpu_contacts COMMAND direct_gpu_contact_test)

    add_executable(gpu_lazy_readback_test tests/gpu_lazy_readback_test.cpp physx_scene.cpp)
    target_link_options(gpu_lazy_readback_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(gpu_lazy_readback_test PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})
    add_test(NAME blast_stress_gpu_lazy_readback COMMAND gpu_lazy_readback_test)
    add_test(NAME blast_stress_gpu_lazy_cpu_observer COMMAND gpu_lazy_readback_test --cpu-walk)
    add_test(NAME blast_stress_gpu_lazy_parallel_observer COMMAND gpu_lazy_readback_test --parallel-cpu-walk)
    add_test(NAME blast_stress_gpu_cpu_walk_preparation COMMAND gpu_lazy_readback_test --cpu-gpu-walk)
    set_tests_properties(blast_stress_gpu_lazy_readback blast_stress_gpu_lazy_cpu_observer
        blast_stress_gpu_lazy_parallel_observer blast_stress_gpu_cpu_walk_preparation PROPERTIES ENVIRONMENT "BLAST_GPU_DETERMINISTIC_REDUCTIONS=1;BLAST_GPU_GATHER=1")

    add_executable(gpu_quiet_load_test tests/gpu_quiet_load_test.cpp)
    target_link_libraries(gpu_quiet_load_test PRIVATE NvBlastExtStressGpu)
    add_test(NAME blast_stress_gpu_quiet_load COMMAND gpu_quiet_load_test)
    add_test(NAME blast_stress_gpu_quiet_load_bond_space COMMAND gpu_quiet_load_test)
    set_tests_properties(blast_stress_gpu_quiet_load_bond_space PROPERTIES ENVIRONMENT "BLAST_GPU_NODE_SPACE=0")
    add_test(NAME blast_stress_gpu_quiet_load_deterministic COMMAND gpu_quiet_load_test)
    set_tests_properties(blast_stress_gpu_quiet_load_deterministic PROPERTIES ENVIRONMENT "BLAST_GPU_DETERMINISTIC_REDUCTIONS=1")
    add_test(NAME blast_stress_gpu_quiet_load_unrolled COMMAND gpu_quiet_load_test)
    set_tests_properties(blast_stress_gpu_quiet_load_unrolled PROPERTIES ENVIRONMENT "BLAST_GPU_COND_LOOP=0")

    add_executable(native_gpu_material_test tests/native_gpu_material_test.cpp physx_scene.cpp)
    target_include_directories(native_gpu_material_test PRIVATE ${PX_DESTRUCTION_GPU_INCLUDE_DIRS})
    target_link_options(native_gpu_material_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_material_test PRIVATE NvBlastExtStressPhysX ${PHYSX_LINK_LIBS})
    add_test(NAME physx_native_gpu_material COMMAND native_gpu_material_test)

    add_executable(native_gpu_destruction_test tests/native_gpu_destruction_test.cpp physx_scene.cpp)
    target_include_directories(native_gpu_destruction_test PRIVATE ${PX_DESTRUCTION_GPU_INCLUDE_DIRS} ${PHYSX_ROOT}/include)
    target_compile_definitions(native_gpu_destruction_test PRIVATE PX_PHYSX_STATIC_LIB)
    target_link_options(native_gpu_destruction_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    set(NATIVE_DESTRUCTION_TEST_LIBS ${PHYSX_LINK_LIBS})
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        list(REMOVE_ITEM NATIVE_DESTRUCTION_TEST_LIBS ${PX_DESTRUCTION_GPU_RUNTIME})
    endif()
    target_link_libraries(native_gpu_destruction_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_destruction COMMAND native_gpu_destruction_test)

    add_executable(persistent_shape_owner_test tests/persistent_shape_owner_test.cpp physx_scene.cpp)
    target_include_directories(persistent_shape_owner_test PRIVATE ${PX_DESTRUCTION_GPU_INCLUDE_DIRS}
        "${PHYSX_ROOT}/include"
        "${PHYSX_ROOT}/source/common/include"
        "${PHYSX_ROOT}/source/common/src"
        "${PHYSX_ROOT}/source/physx/src"
        "${PHYSX_ROOT}/source/physxgpu/include"
        "${PHYSX_ROOT}/source/geomutils/include"
        "${PHYSX_ROOT}/source/geomutils/src"
        "${PHYSX_ROOT}/source/geomutils/src/contact"
        "${PHYSX_ROOT}/source/geomutils/src/common"
        "${PHYSX_ROOT}/source/geomutils/src/convex"
        "${PHYSX_ROOT}/source/geomutils/src/distance"
        "${PHYSX_ROOT}/source/geomutils/src/sweep"
        "${PHYSX_ROOT}/source/geomutils/src/gjk"
        "${PHYSX_ROOT}/source/geomutils/src/intersection"
        "${PHYSX_ROOT}/source/geomutils/src/mesh"
        "${PHYSX_ROOT}/source/geomutils/src/hf"
        "${PHYSX_ROOT}/source/geomutils/src/pcm"
        "${PHYSX_ROOT}/source/geomutils/src/ccd"
        "${PHYSX_ROOT}/source/lowlevel/api/include"
        "${PHYSX_ROOT}/source/lowlevel/software/include"
        "${PHYSX_ROOT}/source/lowlevel/common/include/pipeline"
        "${PHYSX_ROOT}/source/lowlevel/common/include/utils"
        "${PHYSX_ROOT}/source/lowlevelaabb/include"
        "${PHYSX_ROOT}/source/lowleveldynamics/include"
        "${PHYSX_ROOT}/source/lowleveldynamics/shared"
        "${PHYSX_ROOT}/source/simulationcontroller/include"
        "${PHYSX_ROOT}/source/simulationcontroller/src"
        "${PHYSX_ROOT}/source/scenequery/include"
        "${PHYSX_ROOT}/source/physxmetadata/core/include"
        "${PHYSX_ROOT}/source/immediatemode/include"
        "${PHYSX_ROOT}/source/pvd/include"
        "${PHYSX_ROOT}/source/gpucommon/include"
        "${PHYSX_ROOT}/source/gpucommon/src/CUDA"
        "${PHYSX_ROOT}/source/omnipvd"
        "${PHYSX_ROOT}/pvdruntime/include"
    )
    target_compile_definitions(persistent_shape_owner_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(persistent_shape_owner_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(persistent_shape_owner_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_persistent_shape_owner COMMAND persistent_shape_owner_test)
    add_test(NAME physx_persistent_shape_owner_gpu_bounds COMMAND persistent_shape_owner_test --gpu-bounds)
    add_test(NAME physx_persistent_shape_owner_gpu_bounds_growth COMMAND persistent_shape_owner_test --gpu-bounds-growth)
    add_test(NAME physx_persistent_shape_owner_host_pose_bounds COMMAND persistent_shape_owner_test --host-pose-bounds)
    add_test(NAME physx_persistent_shape_owner_overflow COMMAND persistent_shape_owner_test --overflow)
    add_test(NAME physx_persistent_shape_owner_overflow_split COMMAND persistent_shape_owner_test --overflow-split)

    add_executable(native_gpu_body_test tests/native_gpu_body_test.cpp physx_scene.cpp)
    get_target_property(PERSISTENT_OWNER_TEST_INCLUDES persistent_shape_owner_test INCLUDE_DIRECTORIES)
    target_include_directories(native_gpu_body_test PRIVATE ${PERSISTENT_OWNER_TEST_INCLUDES})
    target_compile_definitions(native_gpu_body_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(native_gpu_body_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_body_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_body_state COMMAND native_gpu_body_test)

    add_executable(native_gpu_allocation_test tests/native_gpu_allocation_test.cpp physx_scene.cpp)
    target_include_directories(native_gpu_allocation_test PRIVATE ${PERSISTENT_OWNER_TEST_INCLUDES}
        "${PHYSX_ROOT}/source/gpudestruction/include"
        "${PHYSX_ROOT}/source/gpusimulationcontroller/include"
        "${PHYSX_ROOT}/source/gpusolver/include"
        "${PHYSX_ROOT}/source/gpunarrowphase/include"
        "${PHYSX_ROOT}/source/gpubroadphase/include"
        "${PHYSX_ROOT}/source/gpuarticulation/include")
    target_compile_definitions(native_gpu_allocation_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(native_gpu_allocation_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_allocation_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_body_allocation COMMAND native_gpu_allocation_test)

    add_executable(native_gpu_incremental_pairs_test tests/native_gpu_incremental_pairs_test.cu
        "${PHYSX_ROOT}/source/gpubroadphase/src/CUDA/broadphase.cu")
    target_include_directories(native_gpu_incremental_pairs_test PRIVATE "${PHYSX_ROOT}/include"
        "${PHYSX_ROOT}/source/gpubroadphase/include" "${PHYSX_ROOT}/source/gpucommon/include"
        "${PHYSX_ROOT}/source/gpucommon/src/CUDA" "${PHYSX_ROOT}/source/lowlevelaabb/include")
    target_compile_definitions(native_gpu_incremental_pairs_test PRIVATE NDEBUG)
    px_destruction_cuda_properties(native_gpu_incremental_pairs_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_link_libraries(native_gpu_incremental_pairs_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    add_test(NAME physx_native_gpu_incremental_pairs COMMAND native_gpu_incremental_pairs_test)

    add_executable(native_gpu_pairs_test tests/native_gpu_pairs_test.cu)
    target_include_directories(native_gpu_pairs_test PRIVATE "${PHYSX_ROOT}/include"
        "${PHYSX_ROOT}/source/gpucommon/include" "${PHYSX_ROOT}/source/gpubroadphase/include"
        "${PHYSX_ROOT}/source/gpubroadphase/src/CUDA")
    target_compile_definitions(native_gpu_pairs_test PRIVATE NDEBUG)
    px_destruction_cuda_properties(native_gpu_pairs_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_link_libraries(native_gpu_pairs_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    add_test(NAME physx_native_gpu_pairs COMMAND native_gpu_pairs_test)

    # One production-kernel oracle is shared by the SDK and demo test entry points.
    add_executable(native_gpu_motion_slots_test "${PHYSX_ROOT}/source/gpudestruction/tests/motion_slots_test.cu")
    target_include_directories(native_gpu_motion_slots_test PRIVATE "${PHYSX_ROOT}/include"
        "${PHYSX_ROOT}/source/lowlevel/software/include" "${PHYSX_ROOT}/source/gpudestruction/src"
        "${PHYSX_ROOT}/source/gpusimulationcontroller/include" "${PHYSX_ROOT}/source/gpucommon/include"
        "${PHYSX_ROOT}/source/common/src" "${PHYSX_ROOT}/source/lowlevel/api/include")
    target_compile_definitions(native_gpu_motion_slots_test PRIVATE NDEBUG)
    px_destruction_cuda_properties(native_gpu_motion_slots_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_link_libraries(native_gpu_motion_slots_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    add_test(NAME physx_native_gpu_motion_slots COMMAND native_gpu_motion_slots_test)
    add_test(NAME physx_native_gpu_motion_descriptor COMMAND native_gpu_motion_slots_test --descriptor-stability)
    set_tests_properties(physx_native_gpu_motion_descriptor PROPERTIES RUN_SERIAL TRUE TIMEOUT 600 LABELS "gpu;integration")


    add_executable(native_gpu_collision_test tests/native_gpu_collision_test.cpp physx_scene.cpp)
    get_target_property(NATIVE_COLLISION_TEST_INCLUDES native_gpu_allocation_test INCLUDE_DIRECTORIES)
    target_include_directories(native_gpu_collision_test PRIVATE ${NATIVE_COLLISION_TEST_INCLUDES}
        "${PHYSX_ROOT}/source/gpudestruction/include")
    target_compile_definitions(native_gpu_collision_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_compile_definitions(native_gpu_collision_test PRIVATE NATIVE_KINEMATIC_REFERENCE_FILE="${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/native-kinematic-inputs.csv")
    target_link_options(native_gpu_collision_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_collision_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_collision_preparation COMMAND native_gpu_collision_test)
    add_test(NAME physx_native_gpu_contact_response COMMAND native_gpu_collision_test --contact-response)
    add_test(NAME physx_native_gpu_retained_registry COMMAND native_gpu_collision_test --retained-registry)
    add_test(NAME physx_native_gpu_contact_lifetime_exhaustion COMMAND native_gpu_collision_test --lifetime-exhaustion)
    add_test(NAME physx_native_gpu_initialization_failure COMMAND native_gpu_collision_test --initialization-failure)
    add_test(NAME physx_native_gpu_preparation_before_compatibility COMMAND native_gpu_collision_test --preparation-before-compatibility)
    add_test(NAME physx_native_gpu_node_births COMMAND native_gpu_collision_test --native-node-births)
    add_test(NAME physx_native_gpu_kinematic_inputs COMMAND native_gpu_collision_test --kinematic-inputs)
    add_test(NAME physx_native_gpu_accepted_properties COMMAND native_gpu_collision_test --accepted-properties)
    add_test(NAME physx_native_gpu_accepted_properties_pgs COMMAND native_gpu_collision_test --accepted-properties-pgs)
    # Unfiltered audit: quiet initialization, fracture/correction, accepted
    # properties and the next ordinary tick must read only initialized storage.
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(native_init_mode accepted-properties accepted-properties-pgs)
            add_test(NAME physx_native_gpu_state_initcheck_${native_init_mode}
                COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool initcheck --error-exitcode 99
                    $<TARGET_FILE:native_gpu_collision_test> --${native_init_mode})
            set_tests_properties(physx_native_gpu_state_initcheck_${native_init_mode}
                PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer;integration" RUN_SERIAL TRUE)
        endforeach()
    endif()
    add_test(NAME physx_native_gpu_solver_metadata COMMAND native_gpu_collision_test --solver-metadata)
    add_test(NAME physx_native_gpu_pre_solve_islands COMMAND native_gpu_collision_test --pre-solve-islands)
    add_test(NAME physx_native_gpu_pre_solve_contacts COMMAND native_gpu_collision_test --pre-solve-contacts)
    add_test(NAME physx_native_gpu_pre_solve_support COMMAND native_gpu_collision_test --pre-solve-support)
    add_test(NAME physx_native_gpu_connectivity_owner COMMAND native_gpu_collision_test --connectivity-owner)


    add_executable(native_kinematic_support_test tests/native_kinematic_support_test.cpp physx_scene.cpp)
    target_include_directories(native_kinematic_support_test PRIVATE ${NATIVE_COLLISION_TEST_INCLUDES})
    target_compile_definitions(native_kinematic_support_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(native_kinematic_support_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_kinematic_support_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_kinematic_support COMMAND native_kinematic_support_test)

    add_executable(native_gpu_checkpoint_test tests/native_gpu_checkpoint_test.cpp physx_scene.cpp)
    target_include_directories(native_gpu_checkpoint_test PRIVATE ${NATIVE_COLLISION_TEST_INCLUDES}
        "${PHYSX_ROOT}/source/gpudestruction/include")
    target_compile_definitions(native_gpu_checkpoint_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(native_gpu_checkpoint_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_checkpoint_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_rigid_checkpoint COMMAND native_gpu_checkpoint_test)

    add_executable(native_gpu_correction_body_test tests/native_gpu_correction_body_test.cpp physx_scene.cpp)
    get_target_property(NATIVE_CHECKPOINT_TEST_INCLUDES native_gpu_checkpoint_test INCLUDE_DIRECTORIES)
    target_include_directories(native_gpu_correction_body_test PRIVATE ${NATIVE_CHECKPOINT_TEST_INCLUDES})
    target_compile_definitions(native_gpu_correction_body_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_link_options(native_gpu_correction_body_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_correction_body_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_correction_bodies COMMAND native_gpu_correction_body_test)

    add_executable(native_bombardment_test tests/native_bombardment_test.cpp)
    target_include_directories(native_bombardment_test PRIVATE ${PHYSX_ROOT}/include)
    add_test(NAME physx_native_demo_projectile_launch COMMAND native_bombardment_test)

    # A separate CUDA DSO keeps application kernels out of PhysX's private
    # kernel-wrangler registration. This is a device consumer, not a solver.
    add_library(native_gpu_visuals SHARED native_gpu_visuals.cu)
    target_include_directories(native_gpu_visuals PUBLIC ${PHYSX_ROOT}/include ${PX_DESTRUCTION_GPU_INCLUDE_DIRS})
    target_compile_definitions(native_gpu_visuals PUBLIC NDEBUG)
    target_link_libraries(native_gpu_visuals PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    px_destruction_cuda_properties(native_gpu_visuals PROPERTIES CUDA_RUNTIME_LIBRARY Shared CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    target_compile_options(native_gpu_visuals PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    add_executable(native_gpu_visuals_test tests/native_gpu_visuals_test.cpp)
    target_link_libraries(native_gpu_visuals_test PRIVATE native_gpu_visuals ${PX_DESTRUCTION_GPU_DRIVER})
    add_test(NAME physx_native_gpu_visual_consumer COMMAND native_gpu_visuals_test)
    option(NATIVE_GPU_EGL_RENDERER "Enable the optional CUDA/OpenGL native demo renderer" OFF)
    if(NATIVE_GPU_EGL_RENDERER)
        if(PX_GPU_BACKEND STREQUAL "CUMETAL")
            message(FATAL_ERROR "The existing renderer requires NVIDIA CUDA/OpenGL interop. A native Metal rendering consumer is not implemented yet; no EGL installation can supply this backend.")
        endif()
        find_package(OpenGL REQUIRED COMPONENTS OpenGL EGL)
    endif()
    add_executable(native_destruction_demo native_destruction_main.cpp native_gpu_consumer.cpp native_gpu_activity.cpp physx_scene.cpp state_writer.cpp)
    find_package(ZLIB REQUIRED)
    target_link_libraries(native_destruction_demo PRIVATE ZLIB::ZLIB)
    option(NATIVE_GPU_CUPTI "Enable optional non-serializing GPU activity diagnostics" OFF)
    if(NATIVE_GPU_CUPTI)
        if(PX_GPU_BACKEND STREQUAL "CUMETAL")
            message(FATAL_ERROR "CUPTI profiling is NVIDIA-only; the CuMetal backend has no qualified replacement profiler yet")
        endif()
        set(NATIVE_GPU_CUPTI_ROOT "" CACHE PATH "Qualified CUPTI 13.2 Update 2 SDK root (include/ and lib/); independent of physics CUDA toolkit")
        find_path(NATIVE_CUPTI_INCLUDE cupti_activity.h HINTS "${NATIVE_GPU_CUPTI_ROOT}/include" NO_DEFAULT_PATH REQUIRED)
        find_library(NATIVE_CUPTI_LIBRARY NAMES cupti libcupti.so.13 HINTS "${NATIVE_GPU_CUPTI_ROOT}/lib" "${NATIVE_GPU_CUPTI_ROOT}/lib64" NO_DEFAULT_PATH REQUIRED)
        file(STRINGS "${NATIVE_CUPTI_INCLUDE}/cupti_version.h" NATIVE_CUPTI_VERSION_LINE REGEX "^#define CUPTI_API_VERSION [0-9]+")
        string(REGEX MATCH "[0-9]+" NATIVE_CUPTI_VERSION "${NATIVE_CUPTI_VERSION_LINE}")
        if(NATIVE_CUPTI_VERSION LESS 130202)
            message(FATAL_ERROR "Native conditional-graph profiling requires CUPTI 13.2 Update 2 (130202) or newer; run tools/scripts/fetch-destruction-cupti.py and set NATIVE_GPU_CUPTI_ROOT")
        endif()
        target_compile_definitions(native_destruction_demo PRIVATE NATIVE_GPU_CUPTI)
        target_include_directories(native_destruction_demo BEFORE PRIVATE "${NATIVE_CUPTI_INCLUDE}")
        target_link_libraries(native_destruction_demo PRIVATE "${NATIVE_CUPTI_LIBRARY}" ZLIB::ZLIB)
        add_executable(native_cupti_capture_test ../../tools/diagnostics/cupti-conditional-loop/repro.cu native_gpu_activity.cpp)
        target_compile_definitions(native_cupti_capture_test PRIVATE NATIVE_GPU_CUPTI)
        target_include_directories(native_cupti_capture_test BEFORE PRIVATE "${NATIVE_CUPTI_INCLUDE}")
        target_link_libraries(native_cupti_capture_test PRIVATE "${NATIVE_CUPTI_LIBRARY}" ZLIB::ZLIB ${PX_DESTRUCTION_GPU_RUNTIME} ${PX_DESTRUCTION_GPU_DRIVER})
        find_package(Python3 COMPONENTS Interpreter REQUIRED)
        add_test(NAME physx_native_cupti_long_capture COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_cupti_capture_test.py $<TARGET_FILE:native_cupti_capture_test>)
        add_test(NAME physx_native_cupti_overflow_rejected COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_cupti_capture_test.py $<TARGET_FILE:native_cupti_capture_test> --overflow)
        add_test(NAME physx_native_destruction_timing_accounting COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/../../tools/scripts/test-destruction-timing.py)
    endif()
    target_link_libraries(native_destruction_demo PRIVATE native_gpu_visuals)
    if(NATIVE_GPU_EGL_RENDERER)
        target_compile_definitions(native_destruction_demo PRIVATE NATIVE_GPU_EGL)
        target_link_libraries(native_destruction_demo PRIVATE OpenGL::OpenGL OpenGL::EGL)
    endif()
    target_compile_definitions(native_destruction_demo PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_destruction_demo PRIVATE ${NATIVE_COLLISION_TEST_INCLUDES}
        "${PHYSX_ROOT}/source/gpudestruction/include")
    target_link_options(native_destruction_demo PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_destruction_demo PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS} ${PX_DESTRUCTION_GPU_DRIVER})
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
    # Counterfactual output-poisoning diagnostic; never linked into production.
    get_target_property(NATIVE_DEMO_SOURCES native_destruction_demo SOURCES)
    add_executable(destruction_force_freshness_diagnostic EXCLUDE_FROM_ALL ${NATIVE_DEMO_SOURCES})
    foreach(PROPERTY INCLUDE_DIRECTORIES COMPILE_DEFINITIONS COMPILE_OPTIONS LINK_OPTIONS LINK_LIBRARIES)
        get_target_property(VALUE native_destruction_demo ${PROPERTY})
        if(VALUE)
            set_property(TARGET destruction_force_freshness_diagnostic PROPERTY ${PROPERTY} "${VALUE}")
        endif()
    endforeach()
    target_compile_definitions(destruction_force_freshness_diagnostic PRIVATE NATIVE_FORCE_FRESHNESS_DIAGNOSTIC)

    add_test(NAME physx_native_gpu_connectivity_fracture COMMAND ${Python3_EXECUTABLE}
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/native_connectivity_fracture_test.py" $<TARGET_FILE:native_destruction_demo> $<TARGET_FILE:native_gpu_collision_test>)
    add_test(NAME physx_native_profile_accounting COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/../../tools/scripts/test-native-gpu-profile.py)
    add_test(NAME physx_native_gpu_consumer COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_gpu_consumer_test.py $<TARGET_FILE:native_destruction_demo>)
    if(NATIVE_GPU_EGL_RENDERER)
        add_test(NAME physx_native_gpu_renderer COMMAND ${Python3_EXECUTABLE}
            ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_gpu_consumer_test.py $<TARGET_FILE:native_destruction_demo> --render)
    endif()
    add_test(NAME physx_native_gpu_retained_contact_graph COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_retained_contact_test.py $<TARGET_FILE:native_destruction_demo> $<TARGET_FILE:native_gpu_resimulation_test>)


    add_test(NAME physx_native_gpu_bombardment_contacts COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_bombardment_contacts_test.py $<TARGET_FILE:native_destruction_demo>)
    add_test(NAME physx_native_standard_bombardment_contacts COMMAND ${Python3_EXECUTABLE}
        ${CMAKE_CURRENT_SOURCE_DIR}/tests/native_bombardment_contacts_test.py $<TARGET_FILE:native_destruction_demo> --standard-scene)
    set_tests_properties(physx_native_gpu_bombardment_contacts physx_native_standard_bombardment_contacts PROPERTIES
        RUN_SERIAL TRUE TIMEOUT 300 LABELS "gpu;integration")

    add_executable(native_gpu_resimulation_test tests/native_gpu_resimulation_test.cpp physx_scene.cpp)
    target_compile_definitions(native_gpu_resimulation_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_gpu_resimulation_test PRIVATE ${NATIVE_CHECKPOINT_TEST_INCLUDES}
        "${PHYSX_ROOT}/source/gpudestruction/include")
    target_link_options(native_gpu_resimulation_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_resimulation_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS} ${PX_DESTRUCTION_GPU_DRIVER})
    add_test(NAME physx_native_gpu_resimulation COMMAND native_gpu_resimulation_test)

    # Minimal native GPU simulation capture. Rendering consumes committed JSON
    # separately; this target has no graphics interop or visual-kernel dependency.
    add_executable(native_wall_capture native_wall_capture.cpp physx_scene.cpp)
    target_compile_features(native_wall_capture PRIVATE cxx_std_17)
    target_compile_definitions(native_wall_capture PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_wall_capture PRIVATE ${NATIVE_CHECKPOINT_TEST_INCLUDES})
    target_link_options(native_wall_capture PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_wall_capture PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS} ${PX_DESTRUCTION_GPU_DRIVER})

    add_executable(native_standard_scene_test tests/native_standard_scene_test.cpp physx_scene.cpp)
    target_compile_definitions(native_standard_scene_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_standard_scene_test PRIVATE ${NATIVE_CHECKPOINT_TEST_INCLUDES})
    target_link_options(native_standard_scene_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_standard_scene_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS} ${PX_DESTRUCTION_GPU_DRIVER})
    add_test(NAME physx_native_standard_reported_reuse COMMAND native_standard_scene_test --reported-reuse)
    add_test(NAME physx_native_standard_reuse COMMAND native_standard_scene_test --reuse)
    add_test(NAME physx_native_post_correction COMMAND native_standard_scene_test --post-correction)
    add_test(NAME physx_native_post_correction_pgs COMMAND native_standard_scene_test --post-correction-pgs)
    add_test(NAME physx_native_post_correction_multi COMMAND native_standard_scene_test --post-correction-multi)
    add_test(NAME physx_native_chained_fracture COMMAND native_standard_scene_test --chained-fracture)
    add_test(NAME physx_native_standard_awake COMMAND native_standard_scene_test --awake)
    add_test(NAME physx_native_standard_sleep COMMAND native_standard_scene_test)
    add_test(NAME physx_native_compound_sleep COMMAND native_standard_scene_test --compound-sleep)
    set_tests_properties(physx_native_compound_sleep PROPERTIES RUN_SERIAL TRUE TIMEOUT 120 LABELS "gpu;integration")
    add_test(NAME physx_native_standard_sleep_boundary COMMAND native_standard_scene_test --sleep-boundary)
    add_test(NAME physx_native_standard_gpu_islands COMMAND native_standard_scene_test --device-graph)
    add_test(NAME physx_native_standard_wake_boundary COMMAND native_standard_scene_test --wake-boundary)
    add_test(NAME physx_native_standard_late_impact COMMAND native_standard_scene_test --late-impact)
    set_tests_properties(physx_native_post_correction physx_native_post_correction_pgs physx_native_post_correction_multi physx_native_chained_fracture physx_native_standard_reported_reuse physx_native_standard_reuse physx_native_standard_late_impact physx_native_standard_wake_boundary physx_native_standard_awake physx_native_standard_sleep physx_native_standard_sleep_boundary physx_native_standard_gpu_islands PROPERTIES RUN_SERIAL TRUE TIMEOUT 120 LABELS "gpu;integration")

    if(PX_GPU_BACKEND STREQUAL "CUMETAL")
        # A cold native Metal pipeline set can take several minutes to compile.
        # Keep the actual awake scene/assertions unchanged and bound that warmup.
        set_tests_properties(physx_native_standard_awake PROPERTIES TIMEOUT 600)
    endif()

    # A vehicle SDK car ramming a native-destruction wall, through the packaged
    # PxNativeVehicle helper (destruction/vehicle).
    add_executable(native_vehicle_wall_test tests/native_vehicle_wall_test.cpp physx_scene.cpp state_writer.cpp)
    target_compile_definitions(native_vehicle_wall_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_vehicle_wall_test PRIVATE ${PHYSX_ROOT}/include)
    target_link_options(native_vehicle_wall_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_vehicle_wall_test PRIVATE PhysXNativeVehicle ${PHYSX_VEHICLE} ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_vehicle_wall COMMAND native_vehicle_wall_test)
    add_test(NAME physx_native_vehicle_wall_control COMMAND native_vehicle_wall_test --no-fracture)
    add_test(NAME physx_native_vehicle_wall_no_constraints COMMAND native_vehicle_wall_test --drop-constraints)
    # The same ram with a two-pass budget: momentum still reaches the bricks,
    # and no tick runs more corrected solves than it was allowed.
    add_test(NAME physx_native_vehicle_wall_limit2 COMMAND native_vehicle_wall_test --correction-limit 2)
    # Pins the remaining limitation: a constraint on a body the stage owns
    # refuses the fracture step, and the status says so before it happens.
    add_test(NAME physx_native_vehicle_wall_constraint_gate COMMAND native_vehicle_wall_test --constrain-wall)
    add_test(NAME physx_native_vehicle_wall_sweep COMMAND native_vehicle_wall_test --sweep)
    # The questions a game asks before it ships a car on this stage.
    add_test(NAME physx_native_vehicle_parked_sleeps COMMAND native_vehicle_wall_test --park)
    add_test(NAME physx_native_vehicle_rubble_crossing COMMAND native_vehicle_wall_test --rubble)
    add_test(NAME physx_native_vehicle_force_replay COMMAND native_vehicle_wall_test --remote-fracture)
    add_test(NAME physx_native_vehicle_scale COMMAND native_vehicle_wall_test --scale)
    add_test(NAME physx_native_vehicle_demo COMMAND native_vehicle_wall_test --demo)
    set_tests_properties(physx_native_vehicle_wall physx_native_vehicle_wall_control physx_native_vehicle_wall_no_constraints physx_native_vehicle_wall_limit2
        physx_native_vehicle_wall_constraint_gate physx_native_vehicle_wall_sweep physx_native_vehicle_parked_sleeps
        physx_native_vehicle_rubble_crossing physx_native_vehicle_force_replay physx_native_vehicle_scale physx_native_vehicle_demo
        PROPERTIES RUN_SERIAL TRUE TIMEOUT 120 LABELS "gpu;integration")
    # A stage fault found while writing the parked-car case, pinned as an
    # expected failure: a fragment released while already resting on a static
    # shape never forms a contact with it. Flip WILL_FAIL off when it is fixed.
    add_test(NAME physx_native_fragment_resting_on_static COMMAND native_vehicle_wall_test --resting-course --frames 240)
    set_tests_properties(physx_native_fragment_resting_on_static PROPERTIES WILL_FAIL TRUE RUN_SERIAL TRUE TIMEOUT 120 LABELS "gpu;integration;known-fault")

    add_executable(native_group_filter_test tests/native_group_filter_test.cpp physx_scene.cpp)
    target_compile_definitions(native_group_filter_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_group_filter_test PRIVATE ${PHYSX_ROOT}/include)
    target_link_options(native_group_filter_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_group_filter_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS} ${PX_DESTRUCTION_GPU_DRIVER})
    add_test(NAME physx_native_gpu_group_filtering COMMAND native_group_filter_test)

    add_executable(native_gpu_publication_test tests/native_gpu_publication_test.cpp physx_scene.cpp)
    target_compile_definitions(native_gpu_publication_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG PX_SUPPORT_PVD=0 PX_SUPPORT_OMNI_PVD=0)
    target_include_directories(native_gpu_publication_test PRIVATE ${PHYSX_ROOT}/include)
    target_link_options(native_gpu_publication_test PRIVATE "-Wl,-rpath,${PHYSX_LIB_DIR}")
    target_link_libraries(native_gpu_publication_test PRIVATE ${NATIVE_DESTRUCTION_TEST_LIBS})
    add_test(NAME physx_native_gpu_publication COMMAND native_gpu_publication_test)


    add_executable(native_shape_publication_test tests/native_shape_publication_test.cu)
    target_include_directories(native_shape_publication_test PRIVATE "${PHYSX_ROOT}/include"
        "${REPO_ROOT}/physx/source/gpudestruction/src")
    target_compile_definitions(native_shape_publication_test PRIVATE PX_PHYSX_STATIC_LIB NDEBUG)
    px_destruction_cuda_properties(native_shape_publication_test PROPERTIES CUDA_ARCHITECTURES 89)
    target_link_libraries(native_shape_publication_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    add_test(NAME physx_native_gpu_shape_publication COMMAND native_shape_publication_test)

    add_executable(gpu_device_input_test tests/gpu_device_input_test.cu)
    px_destruction_cuda_properties(gpu_device_input_test PROPERTIES CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    target_link_libraries(gpu_device_input_test PRIVATE NvBlastExtStressGpu)
    add_test(NAME blast_stress_gpu_device_input COMMAND gpu_device_input_test)

    add_executable(gpu_stress_topology_test tests/gpu_stress_topology_test.cu)
    px_destruction_cuda_properties(gpu_stress_topology_test PROPERTIES CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    target_link_libraries(gpu_stress_topology_test PRIVATE NvBlastExtStressGpu)
    add_test(NAME blast_stress_gpu_topology COMMAND gpu_stress_topology_test)
    add_test(NAME blast_stress_gpu_topology_deterministic COMMAND gpu_stress_topology_test)
    set_tests_properties(blast_stress_gpu_topology_deterministic PROPERTIES ENVIRONMENT "BLAST_GPU_DETERMINISTIC_REDUCTIONS=1")
    add_test(NAME blast_stress_gpu_topology_jacobi COMMAND gpu_stress_topology_test)
    set_tests_properties(blast_stress_gpu_topology_jacobi PROPERTIES ENVIRONMENT "BLAST_GPU_JACOBI=1")
    add_test(NAME blast_stress_gpu_topology_bond_space COMMAND gpu_stress_topology_test)
    set_tests_properties(blast_stress_gpu_topology_bond_space PROPERTIES ENVIRONMENT "BLAST_GPU_NODE_SPACE=0")

    add_executable(gpu_stress_test tests/gpu_stress_test.cpp)
    target_include_directories(gpu_stress_test PRIVATE
        "${BLAST_ROOT}/include/extensions/stressgpu"
        "${BLAST_ROOT}/source/shared"
        "${BLAST_ROOT}/source/shared/stress_solver"
        "${BLAST_ROOT}/include/shared/NvFoundation")
    target_compile_definitions(gpu_stress_test PRIVATE
        STRESS_SOLVER_FORCE_SCALAR
        STRESS_SOLVER_NO_SIMD
        STRESS_SOLVER_NO_DEVICE_QUERY)
    target_link_libraries(gpu_stress_test PRIVATE
        NvBlastExtStressGpu
        blast_stress_core)
    add_test(NAME blast_stress_gpu_equivalence COMMAND gpu_stress_test)

    add_executable(gpu_stress_benchmark tests/gpu_stress_benchmark.cpp)
    target_include_directories(gpu_stress_benchmark PRIVATE
        "${BLAST_ROOT}/include/extensions/stressgpu"
        "${BLAST_ROOT}/source/shared"
        "${BLAST_ROOT}/source/shared/stress_solver"
        "${BLAST_ROOT}/include/shared/NvFoundation")
    target_link_libraries(gpu_stress_benchmark PRIVATE
        NvBlastExtStressGpu
        blast_stress_core)

    # The real-pack topology stress suite. Links the same ScenePack
    # loader the demo uses, so the graph it solves is production's graph rather
    # than a synthetic model of it -- which is what makes its island histogram
    # usable as a design input. Needs PhysX headers only for PxVec3 in the
    # loader's structs; it creates no PhysX scene.
    add_executable(gpu_stress_suite tests/gpu_stress_suite.cpp scene_pack.cpp)
    target_include_directories(gpu_stress_suite PRIVATE
        "${BLAST_ROOT}/include/extensions/stressgpu"
        "${BLAST_ROOT}/source/shared"
        "${BLAST_ROOT}/source/shared/stress_solver"
        "${BLAST_ROOT}/include/shared/NvFoundation"
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${PHYSX_ROOT}/include")
    target_link_libraries(gpu_stress_suite PRIVATE
        NvBlastExtStressGpu
        blast_stress_core)
endif()

# Standalone analytic qualification of the production CUDA specialization.
# No reference-backend library is linked into this executable.
if(BLAST_ENABLE_CUDA_STRESS AND (PX_GPU_BACKEND STREQUAL "CUMETAL" OR (CMAKE_CUDA_COMPILER AND CUDAToolkit_VERSION VERSION_GREATER_EQUAL "12.8")))
    add_executable(gpu_resident_hierarchy_test EXCLUDE_FROM_ALL tests/gpu_resident_hierarchy_test.cu)
    target_include_directories(gpu_resident_hierarchy_test PRIVATE "${BLAST_ROOT}/source/sdk/extensions/stressgpu/detail")
    px_destruction_cuda_properties(gpu_resident_hierarchy_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_compile_options(gpu_resident_hierarchy_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_link_libraries(gpu_resident_hierarchy_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME})
    add_test(NAME blast_stress_gpu_fine_only_preparation COMMAND gpu_resident_hierarchy_test --fine-only)
    set_tests_properties(blast_stress_gpu_fine_only_preparation PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(preparation_tool memcheck synccheck)
            add_test(NAME blast_stress_gpu_fine_only_preparation_${preparation_tool}
                COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool ${preparation_tool}
                        --error-exitcode 99 $<TARGET_FILE:gpu_resident_hierarchy_test> --fine-only)
            set_tests_properties(blast_stress_gpu_fine_only_preparation_${preparation_tool}
                PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer" RUN_SERIAL TRUE)
        endforeach()
    endif()
    add_test(NAME blast_stress_gpu_resident_hierarchy COMMAND gpu_resident_hierarchy_test)
    set_tests_properties(blast_stress_gpu_resident_hierarchy PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(hierarchy_tool memcheck synccheck racecheck)
            set(hierarchy_options)
            if(hierarchy_tool STREQUAL "memcheck")
                list(APPEND hierarchy_options --leak-check full)
            endif()
            add_test(NAME blast_stress_gpu_resident_hierarchy_${hierarchy_tool}
                COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool ${hierarchy_tool}
                        ${hierarchy_options} --error-exitcode 99 $<TARGET_FILE:gpu_resident_hierarchy_test>)
            set_tests_properties(blast_stress_gpu_resident_hierarchy_${hierarchy_tool}
                PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer" RUN_SERIAL TRUE)
        endforeach()
    endif()
    add_test(NAME blast_stress_gpu_assembled_hierarchy COMMAND gpu_resident_hierarchy_test --assembled)
    set_tests_properties(blast_stress_gpu_assembled_hierarchy PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(hierarchy_tool memcheck synccheck racecheck)
            set(hierarchy_options)
            if(hierarchy_tool STREQUAL "memcheck")
                list(APPEND hierarchy_options --leak-check full)
            endif()
            add_test(NAME blast_stress_gpu_assembled_hierarchy_${hierarchy_tool}
                COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool ${hierarchy_tool}
                        ${hierarchy_options} --error-exitcode 99 $<TARGET_FILE:gpu_resident_hierarchy_test> --assembled)
            set_tests_properties(blast_stress_gpu_assembled_hierarchy_${hierarchy_tool}
                PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer" RUN_SERIAL TRUE)
        endforeach()
    endif()
    add_test(NAME blast_stress_gpu_coarse_long_rows COMMAND gpu_resident_hierarchy_test --cycle coarse-long-rows)
    set_tests_properties(blast_stress_gpu_coarse_long_rows PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    foreach(coarse_case coarse-long-rows coarse-self-columns)
        add_test(NAME blast_stress_gpu_cycle_${coarse_case} COMMAND gpu_resident_hierarchy_test --cycle ${coarse_case})
        set_tests_properties(blast_stress_gpu_cycle_${coarse_case} PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    endforeach()
    add_test(NAME blast_stress_gpu_resident_cycle COMMAND gpu_resident_hierarchy_test --cycle)
    set_tests_properties(blast_stress_gpu_resident_cycle PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(hierarchy_tool memcheck synccheck)
            set(hierarchy_options)
            if(hierarchy_tool STREQUAL "memcheck")
                list(APPEND hierarchy_options --leak-check full)
            endif()
            add_test(NAME blast_stress_gpu_resident_cycle_${hierarchy_tool}
                COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool ${hierarchy_tool}
                        ${hierarchy_options} --error-exitcode 99 $<TARGET_FILE:gpu_resident_hierarchy_test> --cycle)
            set_tests_properties(blast_stress_gpu_resident_cycle_${hierarchy_tool}
                PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer" RUN_SERIAL TRUE)
        endforeach()
    endif()
    # Retain every basis assertion and topology transition. Expensive fixtures
    # qualify one transition per process, replaying the same full build sequence
    # so graph reuse and stale/incomplete publication checks are still exercised.
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        foreach(hierarchy_case empty singleton isolated supported path self parallel omitted star fixed mixed large)
            if(hierarchy_case MATCHES "^(supported|omitted|large)$")
                set(hierarchy_steps 0 1 2 3 4 5)
            elseif(hierarchy_case STREQUAL "path")
                set(hierarchy_steps 0 1)
            else()
                set(hierarchy_steps all)
            endif()
            foreach(hierarchy_step IN LISTS hierarchy_steps)
                set(hierarchy_step_argument)
                if(NOT hierarchy_step STREQUAL "all")
                    set(hierarchy_step_argument ${hierarchy_step})
                endif()
                add_test(NAME blast_stress_gpu_resident_cycle_racecheck_${hierarchy_case}_${hierarchy_step}
                    COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool racecheck --error-exitcode 99
                            $<TARGET_FILE:gpu_resident_hierarchy_test> --cycle ${hierarchy_case} ${hierarchy_step_argument})
                set_tests_properties(blast_stress_gpu_resident_cycle_racecheck_${hierarchy_case}_${hierarchy_step}
                    PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer" RUN_SERIAL TRUE)
            endforeach()
        endforeach()
    endif()
    add_executable(gpu_resident_stress_phase_probe EXCLUDE_FROM_ALL tests/gpu_resident_stress_phase_probe.cu)
    target_include_directories(gpu_resident_stress_phase_probe PRIVATE
        "${BLAST_ROOT}/source/sdk/extensions/stressgpu"
        "${BLAST_ROOT}/include/extensions/stressgpu" "${BLAST_ROOT}/include/extensions/stress")
    target_compile_definitions(gpu_resident_stress_phase_probe PRIVATE PHYSX_RESIDENT_DESTRUCTION BLAST_GPU_COMPONENT_PHASE_PROBE)
    px_destruction_cuda_properties(gpu_resident_stress_phase_probe PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_compile_options(gpu_resident_stress_phase_probe PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_link_libraries(gpu_resident_stress_phase_probe PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME} ${PX_DESTRUCTION_GPU_DRIVER})
    foreach(work_buildings 1 256)
        add_test(NAME blast_stress_component_work_${work_buildings}
            COMMAND gpu_resident_stress_phase_probe ${work_buildings})
        set_tests_properties(blast_stress_component_work_${work_buildings}
            PROPERTIES TIMEOUT 60 LABELS "gpu;diagnostic" RUN_SERIAL TRUE)
    endforeach()
    add_executable(gpu_resident_motion_modes_test EXCLUDE_FROM_ALL tests/gpu_resident_motion_modes_test.cu)
    target_include_directories(gpu_resident_motion_modes_test PRIVATE
        "${BLAST_ROOT}/source/sdk/extensions/stressgpu" "${BLAST_ROOT}/include/extensions/stressgpu" "${BLAST_ROOT}/include/extensions/stress")
    target_compile_definitions(gpu_resident_motion_modes_test PRIVATE PHYSX_RESIDENT_DESTRUCTION)
    px_destruction_cuda_properties(gpu_resident_motion_modes_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_compile_options(gpu_resident_motion_modes_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_link_libraries(gpu_resident_motion_modes_test PRIVATE ${PX_DESTRUCTION_GPU_RUNTIME} ${PX_DESTRUCTION_GPU_DRIVER})
    add_test(NAME blast_stress_gpu_resident_motion_modes COMMAND gpu_resident_motion_modes_test)
    set_tests_properties(blast_stress_gpu_resident_motion_modes PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    # Native AOT outputs are external objects. A static archive includes them
    # explicitly; CMake OBJECT libraries do not reliably propagate such files.
    set(resident_stress_core_type OBJECT)
    if(PX_GPU_BACKEND STREQUAL "CUMETAL")
        set(resident_stress_core_type STATIC)
    endif()
    add_library(gpu_resident_stress_test_core ${resident_stress_core_type} EXCLUDE_FROM_ALL
        "${BLAST_ROOT}/source/sdk/extensions/stressgpu/NvBlastExtStressGpu.cu")
    target_include_directories(gpu_resident_stress_test_core PUBLIC
        "${BLAST_ROOT}/include/extensions/stressgpu" "${BLAST_ROOT}/include/extensions/stress")
    target_compile_definitions(gpu_resident_stress_test_core PRIVATE PHYSX_RESIDENT_DESTRUCTION BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC)
    px_destruction_cuda_properties(gpu_resident_stress_test_core PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_link_libraries(gpu_resident_stress_test_core PUBLIC ${PX_DESTRUCTION_GPU_RUNTIME} ${PX_DESTRUCTION_GPU_DRIVER})
    add_executable(gpu_resident_stress_test EXCLUDE_FROM_ALL tests/gpu_resident_stress_test.cu)
    px_destruction_cuda_properties(gpu_resident_stress_test PROPERTIES CUDA_ARCHITECTURES 89 CUDA_STANDARD 17)
    target_link_libraries(gpu_resident_stress_test PRIVATE gpu_resident_stress_test_core)
    add_executable(gpu_resident_stress_parity_test EXCLUDE_FROM_ALL tests/gpu_stress_test.cpp)
    target_include_directories(gpu_resident_stress_parity_test PRIVATE
        "${BLAST_ROOT}/source/shared" "${BLAST_ROOT}/source/shared/stress_solver"
        "${BLAST_ROOT}/include/shared/NvFoundation")
    target_compile_definitions(gpu_resident_stress_parity_test PRIVATE
        STRESS_SOLVER_FORCE_SCALAR STRESS_SOLVER_NO_SIMD STRESS_SOLVER_NO_DEVICE_QUERY)
    target_link_libraries(gpu_resident_stress_parity_test PRIVATE gpu_resident_stress_test_core blast_stress_core)
    add_executable(gpu_resident_stress_3d_test EXCLUDE_FROM_ALL tests/gpu_resident_stress_3d_test.cpp)
    target_include_directories(gpu_resident_stress_3d_test PRIVATE
        "${BLAST_ROOT}/source/shared" "${BLAST_ROOT}/source/shared/stress_solver"
        "${BLAST_ROOT}/include/shared/NvFoundation")
    target_compile_definitions(gpu_resident_stress_3d_test PRIVATE
        STRESS_SOLVER_FORCE_SCALAR STRESS_SOLVER_NO_SIMD STRESS_SOLVER_NO_DEVICE_QUERY)
    target_link_libraries(gpu_resident_stress_3d_test PRIVATE gpu_resident_stress_test_core blast_stress_core)
    add_test(NAME blast_stress_gpu_resident_3d COMMAND gpu_resident_stress_3d_test)
    set_tests_properties(blast_stress_gpu_resident_3d PROPERTIES TIMEOUT 120 LABELS "gpu" RUN_SERIAL TRUE)
    add_test(NAME blast_stress_gpu_resident_cpu_parity COMMAND gpu_resident_stress_parity_test)
    add_test(NAME blast_stress_gpu_resident_analytic COMMAND gpu_resident_stress_test)
    set_tests_properties(blast_stress_gpu_resident_analytic PROPERTIES TIMEOUT 120)
    # Native lifecycle gate: allocation removal must not hide stale accesses,
    # and repeated solver creation/release must return pinned and device memory.
    if(PX_GPU_BACKEND STREQUAL "CUDA")
        add_test(NAME blast_stress_gpu_resident_memory
            COMMAND "${CUDAToolkit_BIN_DIR}/compute-sanitizer" --tool memcheck
                    --leak-check full --error-exitcode 99 $<TARGET_FILE:gpu_resident_stress_test>)
        set_tests_properties(blast_stress_gpu_resident_memory PROPERTIES TIMEOUT 120 LABELS "gpu;sanitizer")
    endif()
endif()

# Rebuild every private-ABI consumer together after engine interface/layout edits.
# Keeping this derived from local executable targets also covers new fixtures.
if(BLAST_ENABLE_CUDA_STRESS)
    add_custom_target(native_destruction_consumers)
    get_property(DESTRUCTION_LOCAL_TARGETS DIRECTORY PROPERTY BUILDSYSTEM_TARGETS)
    foreach(DESTRUCTION_TARGET IN LISTS DESTRUCTION_LOCAL_TARGETS)
        get_target_property(DESTRUCTION_TARGET_TYPE ${DESTRUCTION_TARGET} TYPE)
        if(DESTRUCTION_TARGET MATCHES "^native_" AND DESTRUCTION_TARGET_TYPE STREQUAL "EXECUTABLE")
            add_dependencies(native_destruction_consumers ${DESTRUCTION_TARGET})
        endif()
    endforeach()
endif()

# Translate every .cu target after its final includes/definitions are known.
px_destruction_finalize_gpu_targets()
if(PX_GPU_BACKEND STREQUAL "CUMETAL")
    message(STATUS "NVIDIA compute-sanitizer tests are not registered for CuMetal; native memory/synchronization qualification remains separate")
endif()
