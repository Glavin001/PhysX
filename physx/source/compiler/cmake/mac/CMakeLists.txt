# Share the Unix source lists and configuration with Linux. Platform-specific
# wrappers keep TARGET_BUILD_PLATFORM=mac for output naming and consumers.
IF(NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|aarch64)$")
    MESSAGE(FATAL_ERROR "This macOS host configuration currently qualifies Apple Silicon only")
ENDIF()
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../linux/CMakeLists.txt")
