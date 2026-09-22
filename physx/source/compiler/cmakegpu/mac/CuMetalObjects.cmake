OPTION(PX_CUMETAL_RIGID_DEMO "Rigid destruction demo: omit articulation and diffuse-particle GPU kernels" OFF)
IF(PX_CUMETAL_RIGID_DEMO AND NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    MESSAGE(FATAL_ERROR "PX_CUMETAL_RIGID_DEMO requires PX_GPU_BACKEND=CUMETAL")
ENDIF()

SET(PX_CUMETAL_FP64 "ieee64" CACHE STRING "Software double precision policy for destruction")
IF(NOT PX_CUMETAL_FP64 STREQUAL "ieee64")
    MESSAGE(FATAL_ERROR "Integrated destruction requires ieee64; reduced-precision modes are not qualified")
ENDIF()
OPTION(PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK
    "Use enforced one-block cooperative grid synchronization; ordinary kernels remain multi-block" ON)

OPTION(PX_CUMETAL_INLINE_REF_GJK_EPA
    "Inline reference GJK/EPA helpers to expose local pointer provenance; equations remain shared" ON)

# Experimental, OFF until compiler metadata preservation and both solver entry
# points are qualified. This changes only a private launch ABI, never equations.
OPTION(PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT
    "Experimental explicit restricted hierarchy descriptor root (unqualified)" OFF)

# Only the separately allocated aggregate descriptor array is restricted.
# The sorting kernel still mutates its descriptor fields; nested buffers retain
# their existing aliases. Host launch and native kernel must share the signature.
OPTION(PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT
    "Experimental restricted aggregate descriptor root for projection sorting (unqualified)" OFF)
IF(PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT AND NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    MESSAGE(FATAL_ERROR "PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT requires PX_GPU_BACKEND=CUMETAL")
ENDIF()

# Descriptor bytes alone are restricted; nested pointees retain their aliases.
# See docs/destruction/CUMETAL_EXPLICIT_MOTION_ROOT.md for allocator evidence.
OPTION(PX_CUMETAL_EXPLICIT_MOTION_ROOT
    "Experimental restricted motion/articulation descriptor roots and local pointer-helper inlining (unqualified)" OFF)
IF(PX_CUMETAL_EXPLICIT_MOTION_ROOT AND NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    MESSAGE(FATAL_ERROR "PX_CUMETAL_EXPLICIT_MOTION_ROOT requires PX_GPU_BACKEND=CUMETAL")
ENDIF()

# See docs/destruction/CUMETAL_BLOCK_VOTED_TRAPS.md. This changes only error
# rendezvous and affected launch geometry; default CUDA equations stay shared.
OPTION(PX_CUMETAL_BLOCK_VOTED_TRAPS
    "Experimental full-block terminal error vote and one-block launch bound (unqualified)" OFF)
IF(PX_CUMETAL_BLOCK_VOTED_TRAPS AND
   (NOT PX_GPU_BACKEND STREQUAL "CUMETAL" OR NOT PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK))
    MESSAGE(FATAL_ERROR "PX_CUMETAL_BLOCK_VOTED_TRAPS requires PX_GPU_BACKEND=CUMETAL and PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON")
ENDIF()

OPTION(PX_CUMETAL_PACK_BOND_STRESS_SCALARS
    "Experimental scalar-only bond stress launch packaging for Metal buffer limits (unqualified)" OFF)
IF(PX_CUMETAL_PACK_BOND_STRESS_SCALARS AND NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
    MESSAGE(FATAL_ERROR "PX_CUMETAL_PACK_BOND_STRESS_SCALARS requires PX_GPU_BACKEND=CUMETAL")
ENDIF()

# Empty means the ordinary frontend. A value (including zero) opts only the
# actual particle translation unit into the audited source-first inlining path.
# See docs/destruction/CUMETAL_PARTICLE_INLINE_THRESHOLD.md.
SET(PX_CUMETAL_PARTICLE_INLINE_THRESHOLD "" CACHE STRING
    "Experimental cudaParticleSystem.cu frontend inlining threshold; empty disables")
IF(NOT "${PX_CUMETAL_PARTICLE_INLINE_THRESHOLD}" STREQUAL "")
    IF(NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
        MESSAGE(FATAL_ERROR "PX_CUMETAL_PARTICLE_INLINE_THRESHOLD requires PX_GPU_BACKEND=CUMETAL")
    ENDIF()
    STRING(LENGTH "${PX_CUMETAL_PARTICLE_INLINE_THRESHOLD}" threshold_length)
    IF(NOT PX_CUMETAL_PARTICLE_INLINE_THRESHOLD MATCHES "^(0|[1-9][0-9]*)$" OR threshold_length GREATER 10)
        MESSAGE(FATAL_ERROR "PX_CUMETAL_PARTICLE_INLINE_THRESHOLD must be a decimal integer in [0, 2147483647] or empty")
    ENDIF()
    IF(PX_CUMETAL_PARTICLE_INLINE_THRESHOLD GREATER 2147483647)
        MESSAGE(FATAL_ERROR "PX_CUMETAL_PARTICLE_INLINE_THRESHOLD must be a decimal integer in [0, 2147483647] or empty")
    ENDIF()
ENDIF()

# Empty means the ordinary frontend. A value (including zero) opts only the
# actual soft-body midphase translation unit into the audited source-first inlining path.
# See docs/destruction/CUMETAL_SOFTBODY_INLINE_THRESHOLD.md.
SET(PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD "" CACHE STRING
    "Experimental softbodySoftbodyMidPhase.cu frontend inlining threshold; empty disables")
IF(NOT "${PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD}" STREQUAL "")
    IF(NOT PX_GPU_BACKEND STREQUAL "CUMETAL")
        MESSAGE(FATAL_ERROR "PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD requires PX_GPU_BACKEND=CUMETAL")
    ENDIF()
    STRING(LENGTH "${PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD}" threshold_length)
    IF(NOT PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD MATCHES "^(0|[1-9][0-9]*)$" OR threshold_length GREATER 10)
        MESSAGE(FATAL_ERROR "PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD must be a decimal integer in [0, 2147483647] or empty")
    ENDIF()
    IF(PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD GREATER 2147483647)
        MESSAGE(FATAL_ERROR "PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD must be a decimal integer in [0, 2147483647] or empty")
    ENDIF()
ENDIF()

# Until cumetalc emits dependency files, conservatively rebuild native objects
# after shared headers or private host/device fragments change. In particular,
# stress dispatch/lifetime .inl edits must never reuse a stale embedded kernel.
# No downloaded include trees.
FILE(GLOB_RECURSE PX_CUMETAL_HEADERS CONFIGURE_DEPENDS
    "${CUMETAL_ROOT_DIR}/runtime/api/*.h"
    "${CUMETAL_ROOT_DIR}/runtime/api/*.cuh"
    "${CUMETAL_ROOT_DIR}/runtime/api/*.inl"
    "${PHYSX_ROOT_DIR}/include/*.h" "${PHYSX_ROOT_DIR}/source/*.h"
    "${PHYSX_ROOT_DIR}/source/*.cuh" "${PHYSX_ROOT_DIR}/source/*.inl"
    "${PHYSX_ROOT_DIR}/../blast/include/*.h"
    "${PHYSX_ROOT_DIR}/../blast/source/sdk/extensions/stressgpu/*.cuh"
    "${PHYSX_ROOT_DIR}/../blast/source/sdk/extensions/stressgpu/*.inl")

FUNCTION(px_cumetal_objects target)
    IF(PX_CUMETAL_PACK_BOND_STRESS_SCALARS)
        # The native device signature and its host launch stub share this ABI.
        TARGET_COMPILE_DEFINITIONS(${target} PRIVATE PX_CUMETAL_PACK_BOND_STRESS_SCALARS=1)
    ENDIF()
    IF(PX_CUMETAL_BLOCK_VOTED_TRAPS)
        # Native device compilation and its host launch code must agree.
        TARGET_COMPILE_DEFINITIONS(${target} PRIVATE PX_CUMETAL_BLOCK_VOTED_TRAPS=1)
    ENDIF()
    IF(PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT)
        # Shared by native device/host compilation and any host target sources.
        TARGET_COMPILE_DEFINITIONS(${target} PRIVATE PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT=1)
    ENDIF()
    IF(PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT)
        TARGET_COMPILE_DEFINITIONS(${target} PRIVATE PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=1)
    ENDIF()
    IF(PX_CUMETAL_EXPLICIT_MOTION_ROOT)
        # The private kernel argument and captured host graph must use one ABI.
        TARGET_COMPILE_DEFINITIONS(${target} PRIVATE PX_CUMETAL_EXPLICIT_MOTION_ROOT=1)
    ENDIF()
    GET_TARGET_PROPERTY(sources ${target} SOURCES)
    GET_TARGET_PROPERTY(source_dir ${target} SOURCE_DIR)
    # Capability checks and registration live in host code. Avoid changing
    # every retained CUDA command when this exact source subset is selected.
    IF(PX_CUMETAL_RIGID_DEMO)
        FOREACH(source IN LISTS sources)
            IF(source MATCHES "\\.(cpp|cc|cxx)$")
                SET_PROPERTY(SOURCE "${source}" APPEND PROPERTY COMPILE_DEFINITIONS PX_CUMETAL_RIGID_DEMO=1)
            ENDIF()
        ENDFOREACH()
    ENDIF()
    SET(objects)
    SET(cooperative_flag)
    IF(PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK)
        SET(cooperative_flag --cooperative-single-block)
    ENDIF()
    SET(reference_inline_flag)
    IF(PX_CUMETAL_INLINE_REF_GJK_EPA)
        SET(reference_inline_flag -DPX_CUMETAL_INLINE_REF_GJK_EPA=1)
    ENDIF()
    GET_FILENAME_COMPONENT(particle_source "${PHYSX_ROOT_DIR}/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu" REALPATH)
    GET_FILENAME_COMPONENT(softbody_source "${PHYSX_ROOT_DIR}/source/gpunarrowphase/src/CUDA/softbodySoftbodyMidPhase.cu" REALPATH)
    FOREACH(source IN LISTS sources)
        IF(NOT source MATCHES "\\.cu$")
            CONTINUE()
        ENDIF()
        GET_FILENAME_COMPONENT(absolute "${source}" ABSOLUTE BASE_DIR "${source_dir}")
        GET_FILENAME_COMPONENT(resolved_source "${absolute}" REALPATH)
        IF(PX_CUMETAL_RIGID_DEMO AND
           (resolved_source MATCHES "/gpuarticulation/src/CUDA/(articulationDirectGpuApi|forwardDynamic2|internalConstraints2|inverseDynamic)\\.cu$" OR
            resolved_source STREQUAL "${PHYSX_ROOT_DIR}/source/gpusimulationcontroller/src/CUDA/diffuseParticles.cu"))
            SET_SOURCE_FILES_PROPERTIES("${source}" PROPERTIES HEADER_FILE_ONLY TRUE)
            CONTINUE()
        ENDIF()
        SET(particle_inline_flag)
        IF(NOT "${PX_CUMETAL_PARTICLE_INLINE_THRESHOLD}" STREQUAL "" AND
           resolved_source STREQUAL particle_source)
            SET(particle_inline_flag --cuda-inline-threshold "${PX_CUMETAL_PARTICLE_INLINE_THRESHOLD}")
        ENDIF()
        SET(softbody_inline_flag)
        IF(NOT "${PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD}" STREQUAL "" AND
           resolved_source STREQUAL softbody_source)
            SET(softbody_inline_flag --cuda-inline-threshold "${PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD}")
        ENDIF()
        GET_FILENAME_COMPONENT(stem "${source}" NAME_WE)
        STRING(SHA256 identity "${absolute}")
        STRING(SUBSTRING "${identity}" 0 16 identity)
        SET(directory "${CMAKE_CURRENT_BINARY_DIR}/cumetal/${target}/$<CONFIG>")
        SET(object "${directory}/${stem}-${identity}.o")
        ADD_CUSTOM_COMMAND(OUTPUT "${object}"
            COMMAND ${CMAKE_COMMAND} -E make_directory "${directory}"
            COMMAND "${CUMETALC_EXECUTABLE}" "${absolute}" -c --backend=cumetal-ir
                --cuda-clang "${CUMETAL_CUDA_CLANG}" --fp64=${PX_CUMETAL_FP64}
                -std=c++17 ${cooperative_flag} ${reference_inline_flag} ${particle_inline_flag} ${softbody_inline_flag}
                "-I$<JOIN:$<TARGET_PROPERTY:${target},INCLUDE_DIRECTORIES>,;-I>"
                "-D$<JOIN:$<TARGET_PROPERTY:${target},COMPILE_DEFINITIONS>,;-D>"
                -o "${object}"
            DEPENDS "${absolute}" ${PX_CUMETAL_HEADERS} "${CUMETALC_EXECUTABLE}"
            COMMAND_EXPAND_LISTS VERBATIM)
        SET_SOURCE_FILES_PROPERTIES("${source}" PROPERTIES HEADER_FILE_ONLY TRUE)
        SET_SOURCE_FILES_PROPERTIES("${object}" PROPERTIES EXTERNAL_OBJECT TRUE GENERATED TRUE)
        LIST(APPEND objects "${object}")
    ENDFOREACH()
    TARGET_SOURCES(${target} PRIVATE ${objects})
    SET_PROPERTY(TARGET ${target} PROPERTY CUMETAL_NATIVE_OBJECTS "${objects}")
    SET_PROPERTY(TARGET ${target} PROPERTY LINKER_LANGUAGE CXX)
    TARGET_INCLUDE_DIRECTORIES(${target} PRIVATE "${CUMETAL_ROOT_DIR}/runtime/api")
    TARGET_LINK_LIBRARIES(${target} PRIVATE "${CUMETAL_LIBRARY}")
ENDFUNCTION()
