# Run one test executable twice with different environments and require the
# files each run writes to be byte-identical.
#   cmake -DEXE=... -DARGS="..." -DENV_A="K=V,K=V" -DENV_B="K=V"  (comma-separated) -DOUT=dir -P compare_runs.cmake
# ARGS may contain %OUT%, replaced by each run's output file.
foreach(run A B)
    set(out "${OUT}/run-${run}.bin")
    file(REMOVE "${out}")
    string(REPLACE "%OUT%" "${out}" args "${ARGS}")
    separate_arguments(args)
    string(REPLACE "," ";" env "${ENV_${run}}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E env ${env} "${EXE}" ${args}
        RESULT_VARIABLE result OUTPUT_VARIABLE stdout ERROR_VARIABLE stderr)
    message("run ${run} (${ENV_${run}}): ${stdout}${stderr}")
    if(NOT result EQUAL 0)
        message(FATAL_ERROR "run ${run} failed with ${result}")
    endif()
    if(NOT EXISTS "${out}")
        message(FATAL_ERROR "run ${run} wrote no ${out}")
    endif()
endforeach()
execute_process(COMMAND "${CMAKE_COMMAND}" -E compare_files "${OUT}/run-A.bin" "${OUT}/run-B.bin"
    RESULT_VARIABLE differ)
if(differ)
    message(FATAL_ERROR "outputs differ between run A (${ENV_A}) and run B (${ENV_B})")
endif()
file(SIZE "${OUT}/run-A.bin" bytes)
message("outputs identical (${bytes} bytes)")
