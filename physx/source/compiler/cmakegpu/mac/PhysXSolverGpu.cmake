# Four PxVec3 arrays use 48 bytes per body/slab entry. 512 entries use
# 24 KiB, leaving 8 KiB for compiler scratch on the qualified 32 KiB device.
# Larger overrides require pipeline/resource qualification on their device.
SET(PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES "512" CACHE STRING
    "TGS whole-island shared body/slab capacity (1..944); larger islands use partitions")
IF(NOT "${PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES}" MATCHES "^[1-9][0-9]*$")
    MESSAGE(FATAL_ERROR "PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES must be an integer in [1, 944]")
ENDIF()
IF("${PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES}" GREATER 944)
    MESSAGE(FATAL_ERROR "PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES must be an integer in [1, 944]")
ENDIF()

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../linux/PhysXSolverGpu.cmake")
# px_cumetal_objects reads this target's definitions for every .cu command;
# the host scheduler and device arrays therefore receive the same value.
LIST(APPEND PHYSXSOLVERGPU_COMPILE_DEFS
    PXG_TGS_WHOLE_ISLAND_MAX_BODIES=${PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES})
