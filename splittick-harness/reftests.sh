#!/bin/bash
# reftests.sh build|run <log> [ctest regex]: the destruction reference tests (demos) against this worktree's GPU engine.
W=/Users/glavin/Development/PhysX/.claude/worktrees/splittick; CM=/Users/glavin/Development/cuda-metal/.claude/worktrees/splittick
B=$W/out/build/macos-cumetal/release/reftests
TESTS=${TESTS:-native_feature_reference_test native_gpu_correction_body_test native_post_correction_test native_chained_fracture_test native_gpu_body_test native_gpu_body_allocation_test native_gpu_rigid_checkpoint_test native_connectivity_fracture_test native_standard_scene_test native_gpu_destruction_test}
LOG=/private/tmp/claude-501/splittick/logs/reftests-$2.log
[ -e "$LOG" ] && { echo "log exists"; exit 2; }
export PATH=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH
export CUMETAL_USE_METAL_DEVICE_ADDRESSES=1 CUMETAL_CUDA_CLANG=/opt/homebrew/opt/llvm@21/bin/clang++
if [ "$1" = build ]; then
  [ -e $B/CMakeCache.txt ] || cmake -S $W/destruction -B $B -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=release -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DPX_GPU_BACKEND=CUMETAL \
   -DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
   -DCMAKE_MAKE_PROGRAM=/Applications/Xcode.app/Contents/Developer/usr/bin/make -DCMAKE_OSX_ARCHITECTURES=arm64 -DCUMETAL_ROOT_DIR=$CM \
   -DCUMETALC_EXECUTABLE=$CM/out/build/macos-cumetal/release/cumetalc -DCUMETAL_LIBRARY=$CM/out/build/macos-cumetal/release/libcumetal.dylib \
   -DCUMETAL_CUDA_CLANG=/opt/homebrew/opt/llvm@21/bin/clang++ -DPX_CUMETAL_FP64=ieee64 -DPX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON -DPX_CUMETAL_INLINE_REF_GJK_EPA=ON \
   -DPX_CUMETAL_RIGID_DEMO=ON -DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=ON -DPX_CUMETAL_EXPLICIT_MOTION_ROOT=ON -DPX_CUMETAL_EXPLICIT_HIERARCHY_ROOT=ON \
   -DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=ON -DPX_CUMETAL_BLOCK_VOTED_TRAPS=ON -DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD=500 -DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD=500 \
   -DPX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES=512 -DPX_CUMETAL_ENABLE_GPU_SDF_BUILDER=OFF -DPX_CUMETAL_ENABLE_CONVEX_CORE=OFF -DPX_CUMETAL_SERIAL_CONTACT_IDS=ON \
   -DPX_CUMETAL_SPLIT_RESPONSE_STAMP=ON -DPHYSX_ROOT=$W/physx -DPHYSX_LIB_DIR=$W/out/build/macos-cumetal/release/gpu/artifacts/bin/mac.arm64/release \
   -DPHYSX_CONFIGURATION=release -DPX_GENERATED_INCLUDE_DIR=$W/out/build/macos-cumetal/release/gpu/physx/include -DBLAST_ENABLE_CUDA_STRESS=ON \
   -DNATIVE_GPU_EGL_RENDERER=OFF -DNATIVE_GPU_CUPTI=OFF > $LOG 2>&1
  cmake --build $B --target $TESTS --parallel ${JOBS:-10} >> $LOG 2>&1; echo "build rc=$?"; tail -3 $LOG
else
  cd $B && /Users/glavin/Development/vibe-land/scripts/perf/gpu-run.sh splittick-reftests env CUMETAL_CACHE_DIR=/private/tmp/claude-501/splittick/cumetal-cache-ref ctest --test-dir $B/reference --output-on-failure -R "${3:-physx_native_feature_reference}" > $LOG 2>&1
  echo "ctest rc=$?"; grep -E "tests passed|Failed|Passed|\*\*\*" $LOG | tail -40
fi
