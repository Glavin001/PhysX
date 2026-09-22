# Source-first Apple Silicon GPU compilation. Reuse the upstream source lists;
# .cu files become native host objects with embedded Metal libraries.
IF(NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    MESSAGE(FATAL_ERROR "The macOS GPU platform requires PX_GPU_BACKEND=CUMETAL")
ENDIF()
FOREACH(required CUMETAL_ROOT_DIR CUMETALC_EXECUTABLE CUMETAL_LIBRARY CUMETAL_CUDA_CLANG)
    IF(NOT EXISTS "${${required}}")
        MESSAGE(FATAL_ERROR "Missing installed/build prerequisite ${required}: ${${required}}")
    ENDIF()
ENDFOREACH()
SET(CMAKE_CXX_FLAGS "${PHYSX_CXX_FLAGS}")
SET(CMAKE_CXX_FLAGS_DEBUG "${PHYSX_CXX_FLAGS_DEBUG}")
SET(CMAKE_CXX_FLAGS_CHECKED "${PHYSX_CXX_FLAGS_CHECKED}")
SET(CMAKE_CXX_FLAGS_PROFILE "${PHYSX_CXX_FLAGS_PROFILE}")
SET(CMAKE_CXX_FLAGS_RELEASE "${PHYSX_CXX_FLAGS_RELEASE}")
INCLUDE_DIRECTORIES(BEFORE "${PX_GENERATED_INCLUDE_DIR}" "${CUMETAL_ROOT_DIR}/runtime/api")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/CuMetalObjects.cmake")

FOREACH(component PhysXBroadphaseGpu PhysXCommonGpu PhysXNarrowphaseGpu
        PhysXSimulationControllerGpu PhysXSolverGpu PhysXCudaContextManager
        PhysXArticulationGpu PhysXGpuDependencies)
    INCLUDE(${component}.cmake)
    px_cumetal_objects(${component})
ENDFOREACH()
INCLUDE(PhysXGpu.cmake)
GET_FILENAME_COMPONENT(cumetal_library_dir "${CUMETAL_LIBRARY}" DIRECTORY)
SET_PROPERTY(TARGET PhysXGpu APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")

# Qualify the production canonicalization kernels before the aggregate-pair
# component or full scene is available. Link the actual broadphase object;
# never copy its equations into a reduced Metal fixture.
GET_TARGET_PROPERTY(pair_objects PhysXBroadphaseGpu CUMETAL_NATIVE_OBJECTS)
LIST(FILTER pair_objects INCLUDE REGEX "/broadphase-[^/]+\\.o$")
ADD_EXECUTABLE(PhysXCuMetalNativePairsTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-native-pairs.cpp" ${pair_objects})
TARGET_COMPILE_FEATURES(PhysXCuMetalNativePairsTest PRIVATE cxx_std_17)
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalNativePairsTest PRIVATE
    $<TARGET_PROPERTY:PhysXBroadphaseGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalNativePairsTest PRIVATE
    $<TARGET_PROPERTY:PhysXBroadphaseGpu,COMPILE_DEFINITIONS>)
TARGET_LINK_LIBRARIES(PhysXCuMetalNativePairsTest PRIVATE "${CUMETAL_LIBRARY}")
SET_PROPERTY(TARGET PhysXCuMetalNativePairsTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalNativePairsTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Numerical coverage for the actual aggregate collision object.
GET_TARGET_PROPERTY(aggregate_objects PhysXBroadphaseGpu CUMETAL_NATIVE_OBJECTS)
LIST(FILTER aggregate_objects INCLUDE REGEX "/aggregate-[^/]+\\.o$")
ADD_EXECUTABLE(PhysXCuMetalNativeAggregatesTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-native-aggregates.cpp" ${aggregate_objects})
TARGET_COMPILE_FEATURES(PhysXCuMetalNativeAggregatesTest PRIVATE cxx_std_17)
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalNativeAggregatesTest PRIVATE
    $<TARGET_PROPERTY:PhysXBroadphaseGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalNativeAggregatesTest PRIVATE
    $<TARGET_PROPERTY:PhysXBroadphaseGpu,COMPILE_DEFINITIONS>)
TARGET_LINK_LIBRARIES(PhysXCuMetalNativeAggregatesTest PRIVATE "${CUMETAL_LIBRARY}")
SET_PROPERTY(TARGET PhysXCuMetalNativeAggregatesTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalNativeAggregatesTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# The actual shared reference equations qualify the narrow inlining hint.
ADD_EXECUTABLE(PhysXCuMetalReferenceGjkTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-reference-gjk.cu")
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalReferenceGjkTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalReferenceGjkTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,COMPILE_DEFINITIONS>)
px_cumetal_objects(PhysXCuMetalReferenceGjkTest)
SET_PROPERTY(TARGET PhysXCuMetalReferenceGjkTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalReferenceGjkTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Reuse the fork's lifetime allocation tests and actual shared device helper.
ADD_EXECUTABLE(PhysXCuMetalContactIdsTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-contact-ids.cu")
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalContactIdsTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalContactIdsTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,COMPILE_DEFINITIONS>)
px_cumetal_objects(PhysXCuMetalContactIdsTest)
SET_PROPERTY(TARGET PhysXCuMetalContactIdsTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalContactIdsTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Qualify the actual response publication helper with both solver headers.
ADD_EXECUTABLE(PhysXCuMetalContactResponseTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-contact-response.cu")
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalContactResponseTest PRIVATE
    $<TARGET_PROPERTY:PhysXSolverGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalContactResponseTest PRIVATE
    $<TARGET_PROPERTY:PhysXSolverGpu,COMPILE_DEFINITIONS>)
px_cumetal_objects(PhysXCuMetalContactResponseTest)
SET_PROPERTY(TARGET PhysXCuMetalContactResponseTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalContactResponseTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Qualify both actual production TGS solve entry points with authored contact
# rows. The initSolverKernels5 reference pulls the real native archive member;
# this does not claim contact preparation, full timesteps or scene integration.
ADD_EXECUTABLE(PhysXCuMetalTgsContactsTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-tgs-contacts.cpp")
TARGET_COMPILE_FEATURES(PhysXCuMetalTgsContactsTest PRIVATE cxx_std_17)
TARGET_COMPILE_OPTIONS(PhysXCuMetalTgsContactsTest PRIVATE -fexceptions)
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalTgsContactsTest PRIVATE
    $<TARGET_PROPERTY:PhysXSolverGpu,INCLUDE_DIRECTORIES>)
# Includes the same whole-island capacity definition as the host/device solver.
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalTgsContactsTest PRIVATE
    $<TARGET_PROPERTY:PhysXSolverGpu,COMPILE_DEFINITIONS>)
TARGET_LINK_LIBRARIES(PhysXCuMetalTgsContactsTest PRIVATE PhysXSolverGpu "${CUMETAL_LIBRARY}")
SET_PROPERTY(TARGET PhysXCuMetalTgsContactsTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalTgsContactsTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Execute production particle kernels to qualify inactive compacted tails.
GET_TARGET_PROPERTY(particle_objects PhysXNarrowphaseGpu CUMETAL_NATIVE_OBJECTS)
LIST(FILTER particle_objects INCLUDE REGEX "/cudaParticleSystem-[^/]+\\.o$")
ADD_EXECUTABLE(PhysXCuMetalParticleTailsTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-particle-tails.cpp" ${particle_objects})
TARGET_COMPILE_FEATURES(PhysXCuMetalParticleTailsTest PRIVATE cxx_std_17)
TARGET_COMPILE_OPTIONS(PhysXCuMetalParticleTailsTest PRIVATE -fexceptions)
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalParticleTailsTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalParticleTailsTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,COMPILE_DEFINITIONS>)
TARGET_LINK_LIBRARIES(PhysXCuMetalParticleTailsTest PRIVATE "${CUMETAL_LIBRARY}")
SET_PROPERTY(TARGET PhysXCuMetalParticleTailsTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalParticleTailsTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")


# Run the fork's existing destruction contact-graph suite and shared kernels.
ADD_EXECUTABLE(PhysXCuMetalContactGraphTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/source/gpudestruction/tests/contact_graph_test.cu")
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalContactGraphTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:PhysXSimulationControllerGpu,INCLUDE_DIRECTORIES>
    $<TARGET_PROPERTY:PhysXSolverGpu,INCLUDE_DIRECTORIES>)
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalContactGraphTest PRIVATE
    $<TARGET_PROPERTY:PhysXNarrowphaseGpu,COMPILE_DEFINITIONS>)
px_cumetal_objects(PhysXCuMetalContactGraphTest)
SET_PROPERTY(TARGET PhysXCuMetalContactGraphTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalContactGraphTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# Exact integer coverage of the real hierarchy radix-prefix helpers, including
# one-block bin coverage. This does not qualify a complete packing transaction.
ADD_EXECUTABLE(PhysXCuMetalHierarchyPackingTest EXCLUDE_FROM_ALL
    "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-hierarchy-packing.cu")
TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalHierarchyPackingTest PRIVATE
    "${PHYSX_ROOT_DIR}/../blast/source/sdk/extensions/stressgpu/detail")
TARGET_COMPILE_DEFINITIONS(PhysXCuMetalHierarchyPackingTest PRIVATE NDEBUG)
px_cumetal_objects(PhysXCuMetalHierarchyPackingTest)
SET_PROPERTY(TARGET PhysXCuMetalHierarchyPackingTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
SET_PROPERTY(TARGET PhysXCuMetalHierarchyPackingTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
    "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")

# The production bond walk keeps ordinary multi-block scheduling. Its scalar
# record is a private launch ABI, not a cooperative/terminal-trap specialization.
IF(PX_CUMETAL_PACK_BOND_STRESS_SCALARS)
    ADD_EXECUTABLE(PhysXCuMetalBondStressTest EXCLUDE_FROM_ALL
        "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-bond-stress.cu")
    TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalBondStressTest PRIVATE
        "${PHYSX_ROOT_DIR}/../blast/include/extensions/stressgpu"
        "${PHYSX_ROOT_DIR}/../blast/include/extensions/stress"
        "${PHYSX_ROOT_DIR}/../blast/source/sdk/extensions/stressgpu/detail")
    TARGET_COMPILE_DEFINITIONS(PhysXCuMetalBondStressTest PRIVATE NDEBUG)
    px_cumetal_objects(PhysXCuMetalBondStressTest)
    SET_PROPERTY(TARGET PhysXCuMetalBondStressTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
    SET_PROPERTY(TARGET PhysXCuMetalBondStressTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
        "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")
ENDIF()

# The production fine-diagonal error vote and one-block warp-stride schedule
# are qualified only when the matching experimental source hint is selected.
IF(PX_CUMETAL_BLOCK_VOTED_TRAPS)
    ADD_EXECUTABLE(PhysXCuMetalFineDiagonalTest EXCLUDE_FROM_ALL
        "${PHYSX_ROOT_DIR}/../tools/tests/cumetal-fine-diagonal.cu")
    TARGET_INCLUDE_DIRECTORIES(PhysXCuMetalFineDiagonalTest PRIVATE
        "${PHYSX_ROOT_DIR}/../blast/source/sdk/extensions/stressgpu/detail")
    TARGET_COMPILE_DEFINITIONS(PhysXCuMetalFineDiagonalTest PRIVATE NDEBUG)
    px_cumetal_objects(PhysXCuMetalFineDiagonalTest)
    SET_PROPERTY(TARGET PhysXCuMetalFineDiagonalTest APPEND PROPERTY BUILD_RPATH "${cumetal_library_dir}")
    SET_PROPERTY(TARGET PhysXCuMetalFineDiagonalTest PROPERTY RUNTIME_OUTPUT_DIRECTORY
        "${PX_OUTPUT_BIN_DIR}/bin/mac.arm64/$<CONFIG>")
ENDIF()
