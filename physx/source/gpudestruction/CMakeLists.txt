cmake_minimum_required(VERSION 3.24)
project(PhysXDestructionGpu LANGUAGES CXX)
get_filename_component(PHYSX_ROOT "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
set(BLAST_ENABLE_CUDA_STRESS ON)
include("${PHYSX_ROOT}/../destruction/GpuBackend.cmake")

add_library(PhysXDestructionTopologyGpu STATIC src/PxgDestructionTopology.cu)
target_include_directories(PhysXDestructionTopologyGpu PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../../include>
    $<INSTALL_INTERFACE:include/physx/destruction>
    $<INSTALL_INTERFACE:include/physx>)
set_target_properties(PhysXDestructionTopologyGpu PROPERTIES CXX_STANDARD 17 POSITION_INDEPENDENT_CODE ON)
px_destruction_cuda_properties(PhysXDestructionTopologyGpu PROPERTIES
    CUDA_STANDARD 17 CUDA_STANDARD_REQUIRED ON CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
target_link_libraries(PhysXDestructionTopologyGpu PUBLIC ${PX_DESTRUCTION_GPU_RUNTIME})

include(CTest)
if(BUILD_TESTING)
    add_executable(destruction_motion_slots_test tests/motion_slots_test.cu)
    target_link_libraries(destruction_motion_slots_test PRIVATE PhysXDestructionTopologyGpu)
    target_compile_options(destruction_motion_slots_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_include_directories(destruction_motion_slots_test PRIVATE ../lowlevel/software/include ../gpusimulationcontroller/include ../gpucommon/include ../common/src ../lowlevel/api/include)
    px_destruction_cuda_properties(destruction_motion_slots_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_motion_slots COMMAND destruction_motion_slots_test)
    add_test(NAME destruction_gpu_motion_descriptor COMMAND destruction_motion_slots_test --descriptor-stability)
    add_test(NAME destruction_gpu_carrier_gravity COMMAND destruction_motion_slots_test --carrier-gravity)
    set_tests_properties(destruction_gpu_motion_descriptor PROPERTIES RUN_SERIAL TRUE TIMEOUT 600 LABELS "gpu;integration")
    add_executable(destruction_rigid_iteration_limits_test tests/rigid_iteration_limits_test.cu)
    target_link_libraries(destruction_rigid_iteration_limits_test PRIVATE PhysXDestructionTopologyGpu)
    target_compile_options(destruction_rigid_iteration_limits_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_include_directories(destruction_rigid_iteration_limits_test PRIVATE ../gpusimulationcontroller/include ../gpucommon/include)
    px_destruction_cuda_properties(destruction_rigid_iteration_limits_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_rigid_iteration_limits COMMAND destruction_rigid_iteration_limits_test)

    add_executable(destruction_registration_test tests/registration_test.cu)
    target_link_libraries(destruction_registration_test PRIVATE PhysXDestructionTopologyGpu)
    px_destruction_cuda_properties(destruction_registration_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_registration COMMAND destruction_registration_test)
    px_destruction_cumetal_unsupported_tests(
        "the registration arena needs a multi-block cooperative launch (grid.sync) on sm_89; CuMetal cooperative launch is single-block (residentBlocksFor returns cudaErrorNotSupported). Not used by the production stage"
        destruction_gpu_registration)
    add_executable(destruction_contact_ownership_test tests/contact_ownership_test.cu)
    target_link_libraries(destruction_contact_ownership_test PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_contact_ownership_test PRIVATE ../gpunarrowphase/include ../lowlevel/software/include)
    px_destruction_cuda_properties(destruction_contact_ownership_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_contact_ownership COMMAND destruction_contact_ownership_test)
    add_executable(destruction_committed_changes_test tests/committed_changes_test.cu)
    target_link_libraries(destruction_committed_changes_test PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_committed_changes_test PRIVATE ../../../blast/include/extensions/stressgpu)
    px_destruction_cuda_properties(destruction_committed_changes_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_committed_changes COMMAND destruction_committed_changes_test)
    add_executable(destruction_topology_test tests/topology_test.cu)
    target_link_libraries(destruction_topology_test PRIVATE PhysXDestructionTopologyGpu)
    px_destruction_cuda_properties(destruction_topology_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_topology COMMAND destruction_topology_test)
    add_executable(destruction_body_test tests/body_test.cu)
    target_link_libraries(destruction_body_test PRIVATE PhysXDestructionTopologyGpu)
    px_destruction_cuda_properties(destruction_body_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_body_state COMMAND destruction_body_test)
    add_executable(destruction_contact_graph_test tests/contact_graph_test.cu)
    target_link_libraries(destruction_contact_graph_test PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_contact_graph_test PRIVATE
        ../gpunarrowphase/include ../gpusimulationcontroller/include ../lowlevel/software/include ../lowlevel/api/include)
    px_destruction_cuda_properties(destruction_contact_graph_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_test(NAME destruction_gpu_contact_graph COMMAND destruction_contact_graph_test)
    # Impact capacity (docs/destruction/IMPACT_CAPACITY_DESIGN.md): the design's
    # failing-first checks, and the same checks on today's path (expected to fail).
    foreach(variant impact_capacity impact_capacity_today)
        add_executable(destruction_${variant}_test tests/impact_capacity_test.cu)
        target_link_libraries(destruction_${variant}_test PRIVATE PhysXDestructionTopologyGpu)
        target_include_directories(destruction_${variant}_test PRIVATE ../../../blast/include/extensions/stress)
        px_destruction_cuda_properties(destruction_${variant}_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    endforeach()
    target_compile_definitions(destruction_impact_capacity_today_test PRIVATE PX_IMPACT_TODAY=1)
    add_test(NAME destruction_gpu_impact_capacity COMMAND destruction_impact_capacity_test)
    add_test(NAME destruction_gpu_impact_capacity_today COMMAND destruction_impact_capacity_today_test)
    set_tests_properties(destruction_gpu_impact_capacity_today PROPERTIES WILL_FAIL TRUE)
    # The impact study's first tick through E, for comparison with the oracle
    # (vibe-land structures/town-kit/scripts/impact-e-replay.py). A tool, not a test.
    add_executable(destruction_impact_capture_replay tests/impact_capture_replay.cu)
    target_link_libraries(destruction_impact_capture_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_capture_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_capture_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_executable(destruction_impact_replay tests/impact_replay.cu)
    target_link_libraries(destruction_impact_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    # The explicit impact step (PxgDestructionImpactExplicit.cuh) on the
    # cannonball's dumped island against vibe-land scripts/impact/explicit-step.py
    # --fp32 --contacts jacobi (the GPU's own contact iteration: every row from the
    # same velocities, mass split) at the same substep: the broken sets' Jaccard
    # index at least 0.9, the impactor's momentum change within 1% (measured: 1.000
    # and 0.00%; the harness's FP32 and FP64 agree exactly; against its
    # Gauss-Seidel rows, a different iteration, 0.927).
    add_executable(destruction_impact_explicit_replay tests/impact_explicit_replay.cu)
    target_link_libraries(destruction_impact_explicit_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_explicit_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_explicit_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_executable(destruction_dynamic_sequence_replay tests/dynamic_sequence_replay.cu)
    target_link_libraries(destruction_dynamic_sequence_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_dynamic_sequence_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_dynamic_sequence_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_executable(destruction_two_body_replay tests/two_body_replay.cu)
    target_link_libraries(destruction_two_body_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_two_body_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_two_body_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    # The static verdict after an impact (the high-profile cannonball's collapse,
    # step arm, garage-impact 3426f54f7: the corrected pass's static verdict broke
    # 2,466 joints): the trial pass's contact load (the cannonball's rigid stop,
    # 4.6e7 N on a 2 kg chunk) in the elastic solve, whose 64-iteration corrected
    # pass starts from it. Routed (Settings::route), the corrected pass breaks what
    # its own loads break; unrouted it collapses (WILL_FAIL: the reproducer).
    add_executable(destruction_impact_pair_bounds tests/impact_pair_bounds.cu)
    target_include_directories(destruction_impact_pair_bounds PRIVATE ../gpusolver/include)
    target_link_libraries(destruction_impact_pair_bounds PRIVATE PhysXDestructionTopologyGpu)
    px_destruction_cuda_properties(destruction_impact_pair_bounds PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    add_executable(destruction_impact_static_handoff tests/impact_static_handoff.cu)
    target_link_libraries(destruction_impact_static_handoff PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_static_handoff PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_static_handoff PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    # One dumped level of the impact solve through its ADMM alone (IMPACT_DUMP):
    # the convergence reproducer and its test (tests/fixtures/impact-level/).
    add_executable(destruction_impact_level_replay tests/impact_level_replay.cu)
    target_link_libraries(destruction_impact_level_replay PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_level_replay PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_level_replay PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    # The veneer house's cannonball, level 5 (lambda 2.8e-4), with the section
    # model: resumed from the state where its solve sat in a limit cycle for 2e6
    # steps (J step inexact at the tolerance), it converges in one step with the
    # J step solved to its limit (64 allowed); from cold within 8192 (2393 run).
    # The third compares a cold solve with the FP64 optimum (Clarabel,
    # vibe-land scripts/impact/oracle-level.py --out): a known gap -- converged
    # by its step residuals at 1e-4, the solve differs from the optimum by 15%
    # of the contact impulse and 9 brittle joints' capacity; WILL_FAIL until the
    # termination bounds the error, not the step.
    # Every capacity set's projection against an exact FP64 reference.
    add_executable(destruction_impact_projection_fuzz tests/impact_projection_fuzz.cu tests/impact_projection_reference.cpp)
    target_link_libraries(destruction_impact_projection_fuzz PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_impact_projection_fuzz PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_impact_projection_fuzz PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    set_target_properties(destruction_impact_projection_fuzz PROPERTIES CXX_STANDARD 17)
    add_test(NAME destruction_gpu_impact_projection_fuzz COMMAND destruction_impact_projection_fuzz)
    set_tests_properties(destruction_gpu_impact_projection_fuzz PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1")
    # Mohr-Coulomb joint shear (PX_DESTRUCTION_MOHR_COULOMB_SHEAR): one law in
    # every grader -- the static verdict, the impact models' utilisation,
    # projection and ray capacity -- and mu 0 the old law bit for bit.
    add_executable(destruction_mohr_coulomb_graders tests/mohr_coulomb_graders.cu)
    target_link_libraries(destruction_mohr_coulomb_graders PRIVATE PhysXDestructionTopologyGpu)
    target_include_directories(destruction_mohr_coulomb_graders PRIVATE ../../../blast/include/extensions/stress)
    px_destruction_cuda_properties(destruction_mohr_coulomb_graders PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}")
    set_target_properties(destruction_mohr_coulomb_graders PROPERTIES CXX_STANDARD 17)
    add_test(NAME destruction_gpu_mohr_coulomb_graders COMMAND destruction_mohr_coulomb_graders)
    set_tests_properties(destruction_gpu_mohr_coulomb_graders PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1")
    set(_level "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/impact-level/cannon-level5")
    set(_levelEnv "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_LENGTH_SCALE=0.5616397;IMPACT_DISPATCH_WORK=131072")
    add_test(NAME destruction_gpu_impact_level_cycle COMMAND destruction_impact_level_replay "${_level}.bin")
    set_tests_properties(destruction_gpu_impact_level_cycle PROPERTIES ENVIRONMENT "${_levelEnv};IMPACT_ITERATIONS=64;IMPACT_START=${_level}.state.bin")
    add_test(NAME destruction_gpu_impact_level_cold COMMAND destruction_impact_level_replay "${_level}.bin")
    set_tests_properties(destruction_gpu_impact_level_cold PROPERTIES ENVIRONMENT "${_levelEnv};IMPACT_ITERATIONS=8192")
    add_test(NAME destruction_gpu_impact_level_optimum COMMAND destruction_impact_level_replay "${_level}.bin" "${_level}.opt.f64")
    set_tests_properties(destruction_gpu_impact_level_optimum PROPERTIES ENVIRONMENT "${_levelEnv};IMPACT_ITERATIONS=8192" WILL_FAIL TRUE)
    add_test(NAME destruction_gpu_impact_explicit_cannon COMMAND destruction_impact_explicit_replay "${_level}.bin" "${_level}.explicit.txt")
    set_tests_properties(destruction_gpu_impact_explicit_cannon PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_EXPLICIT_DT_US=32")
    # The two-body window (Settings::explicitTwoBody) against vibe-land scripts/impact/two-body.py
    # --export: the monster truck into the lab's masonry wall, real joints at 21.7 m/s and default
    # joints at 10 m/s (compliant rows, implicit car joints); and the row law alone, a steel sphere
    # on a steel block (Hertz: contact_law.py hertz_check).
    foreach(_case truck-wall-w21rj truck-wall-w10 hertz)
        add_test(NAME destruction_gpu_two_body_${_case} COMMAND destruction_two_body_replay "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/two-body/${_case}")
        set_tests_properties(destruction_gpu_two_body_${_case} PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1")
    endforeach()
    # The dynamic sequence's window (C10) against the CPU reference's ensemble (sequence-lab.py
    # --law stage --export --ensemble 8: the bungalow's removals, 0.5 s each; rest: the intact house at its
    # equilibrium, which a window must hold at rest, tests/dynamic_sequence_replay.cu PREFIX.rest).
    foreach(_case truck-door truck bay2 rest)
        add_test(NAME destruction_gpu_dynamic_sequence_${_case} COMMAND destruction_dynamic_sequence_replay "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/dynamic-sequence/${_case}")
        set_tests_properties(destruction_gpu_dynamic_sequence_${_case} PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1")
    endforeach()
    # (brittle default joints: the harness's own dv spread over h = 2.5-5 us is 9%)
    set_tests_properties(destruction_gpu_two_body_truck-wall-w10 PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;TWO_BODY_MAX_DV=0.09")
    # The cannonball's pair, and the truck's (framed-house: its chassis's released
    # rows, 3.5e6 N of depenetration on a 2 kg brick): routed 0 and 12 breaks
    # (their own loads converged: 0 and 21); unrouted 2,610 and 3,053.
    foreach(_shot cannon truck)
        set(_handoff "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/impact-handoff/${_shot}")
        add_test(NAME destruction_gpu_impact_static_handoff_${_shot} COMMAND destruction_impact_static_handoff "${_handoff}-trial.impc" "${_handoff}-corrected.impc")
        set_tests_properties(destruction_gpu_impact_static_handoff_${_shot} PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_ROUTE=1;IMPACT_STATIC_ISLAND=1443")
        add_test(NAME destruction_gpu_impact_static_handoff_${_shot}_unrouted COMMAND destruction_impact_static_handoff "${_handoff}-trial.impc" "${_handoff}-corrected.impc")
        set_tests_properties(destruction_gpu_impact_static_handoff_${_shot}_unrouted PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_ROUTE=0;IMPACT_STATIC_ISLAND=1443" WILL_FAIL TRUE)
        # Unrouted, the corrected pass warm-started from the tick's start
        # (PX_DESTRUCTION_CORRECTED_WARM_START): its verdict is its own loads'.
        add_test(NAME destruction_gpu_impact_static_handoff_${_shot}_pretick COMMAND destruction_impact_static_handoff "${_handoff}-trial.impc" "${_handoff}-corrected.impc")
        set_tests_properties(destruction_gpu_impact_static_handoff_${_shot}_pretick PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_ROUTE=0;IMPACT_WARM=pretick;IMPACT_STATIC_ISLAND=1443")
    endforeach()
    # The invariant (impact::heldOverCapacity, Status::heldOverCapacity): no
    # impactor stopped rigidly by a struck chunk past capacity with nothing of it
    # broken, on the cannonball's first contact through the explicit step with
    # the routing and the bounds per impactor (exit 1 on any).
    # The corrected pass's bounds act on the pairs the impact step evaluated only.
    add_test(NAME destruction_gpu_impact_pair_bounds COMMAND destruction_impact_pair_bounds)
    set_tests_properties(destruction_gpu_impact_pair_bounds PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1")
    add_test(NAME destruction_gpu_impact_pair_bounds_per_body COMMAND destruction_impact_pair_bounds)
    set_tests_properties(destruction_gpu_impact_pair_bounds_per_body PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_PAIR_RULE_MIN=1" WILL_FAIL TRUE)
    add_test(NAME destruction_gpu_impact_held_over_capacity COMMAND destruction_impact_capture_replay "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/impact-handoff/cannon-first.impc")
    set_tests_properties(destruction_gpu_impact_held_over_capacity PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_QUIET=1;IMPACT_METHOD=2;IMPACT_ROUTE=1;IMPACT_BOUND_IMPACTOR=1;IMPACT_HELD_CHECK=1")
    # The explicit step's energy invariant (Status::energyDeficit): fracture and
    # plastic work paid by the impactors' kinetic energy loss, the joints' held
    # energy and the dead load's work. The cannonball's fragments 13 ticks on (31
    # impactors, one a 7.8 kg piece spinning at 180 rad/s): with the tangential
    # clamp in place of the cone's projection in W the impactors gained 430 J.
    add_test(NAME destruction_gpu_impact_explicit_energy COMMAND destruction_impact_capture_replay "${CMAKE_CURRENT_SOURCE_DIR}/tests/fixtures/impact-handoff/cannon-fragments.impc")
    set_tests_properties(destruction_gpu_impact_explicit_energy PROPERTIES ENVIRONMENT "CUMETAL_USE_METAL_DEVICE_ADDRESSES=1;IMPACT_QUIET=1;IMPACT_ENERGY_CHECK=1")
    px_destruction_label_tests()
endif()

install(TARGETS PhysXDestructionTopologyGpu EXPORT PhysXDestructionTopologyTargets ARCHIVE DESTINATION lib)
install(FILES include/PxgDestructionTopology.h DESTINATION include/physx/destruction)
install(FILES ../../include/PxDestructionTopologyTypes.h DESTINATION include/physx)
install(EXPORT PhysXDestructionTopologyTargets NAMESPACE PhysX:: DESTINATION lib/cmake/PhysXDestructionTopology)

px_destruction_finalize_gpu_targets()
