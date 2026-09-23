"""Repository-contained dual-backend destruction build orchestration."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shlex
import shutil
import subprocess
from datetime import datetime, timezone

from destruction_build_paths import contained, local_environment, audit_tree, audit_cmake_caches, audit_test_sources, confined_command

ROOT = Path(__file__).resolve().parents[2]
HOST_TARGETS = ['PhysX', 'PhysXCommon', 'PhysXFoundation', 'PhysXExtensions',
                'PhysXPvdSDK', 'PhysXCooking', 'PhysXCharacterKinematic', 'PhysXVehicle']
CUMETAL_TARGETS = ['cumetal_runtime', 'air_inspect', 'air_validate', 'cumetal-air-emitter',
                   'cumetal', 'cumetalc', 'cumetal-ptx2llvm', 'ptx_diff', 'cumetal_bench',
                   'cumetal_ptxas_shim', 'cumetal_fatbinary_shim', 'cumetal-warm']
GPU_TARGETS = ['PhysXGpu', 'PhysXCudaContextManager', 'PhysXBroadphaseGpu', 'PhysXCommonGpu',
               'PhysXNarrowphaseGpu', 'PhysXSimulationControllerGpu', 'PhysXSolverGpu',
               'PhysXArticulationGpu', 'PhysXGpuDependencies', 'PhysXDestructionGpuRuntime',
               'PhysXDestructionGpuWorkDiagnostic', 'PhysXDestructionGpuProblemDiagnostic']
GPU_COMPONENT_TESTS = {'PhysXCuMetalBondStressTest': ['physx_cumetal_bond_stress', 'physx_cumetal_bond_stress_batched'],
                       'PhysXCuMetalFineDiagonalTest': ['physx_cumetal_fine_diagonal', 'physx_cumetal_fine_diagonal_batched'],
                       'PhysXCuMetalContactGraphTest': ['physx_cumetal_contact_graph', 'physx_cumetal_contact_graph_batched'],
                       'PhysXCuMetalHierarchyPackingTest': ['physx_cumetal_hierarchy_packing', 'physx_cumetal_hierarchy_packing_batched'],
                       'PhysXCuMetalParticleTailsTest': ['physx_cumetal_particle_tails', 'physx_cumetal_particle_tails_batched'],
                       'PhysXCuMetalTgsContactsTest': ['physx_cumetal_tgs_contacts', 'physx_cumetal_tgs_contacts_batched'],
                       'PhysXCuMetalContactResponseTest': ['physx_cumetal_contact_response', 'physx_cumetal_contact_response_batched'],
                       'PhysXCuMetalContactIdsTest': ['physx_cumetal_contact_ids', 'physx_cumetal_contact_ids_batched'],
                       'PhysXCuMetalNativePairsTest': ['physx_cumetal_native_pairs', 'physx_cumetal_native_pairs_batched'],
                       'PhysXCuMetalNativeAggregatesTest': ['physx_cumetal_native_aggregates', 'physx_cumetal_native_aggregates_batched'],
                       'PhysXCuMetalReferenceGjkTest': ['physx_cumetal_reference_gjk', 'physx_cumetal_reference_gjk_batched']}
SCENE_TARGET = 'native_standard_scene_test'
CAPTURE_TARGET = 'native_wall_capture'
SCENE_TARGETS = [SCENE_TARGET, CAPTURE_TARGET]
SCENE_TEST = 'physx_native_standard_awake'
REGISTRY_FLAGS = ['-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                  '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF', '-DFETCHCONTENT_FULLY_DISCONNECTED=ON']


def arguments(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backend', choices=['cuda', 'cumetal'])
    parser.add_argument('--preset', choices=['linux-cuda', 'macos-cumetal'])
    parser.add_argument('--configuration', choices=['debug', 'checked', 'profile', 'release'], default='release')
    parser.add_argument('--stage', choices=['compiler', 'host', 'gpu', 'scene', 'sdk'], default='sdk', help='compiler, host, gpu and scene are intermediate gates, not destruction SDK acceptance')
    parser.add_argument('--target', action='append', choices=HOST_TARGETS + GPU_TARGETS + list(GPU_COMPONENT_TESTS) + SCENE_TARGETS, default=[], help='Build a selected component within --stage gpu or the named --stage scene gate; recorded as a partial build')
    parser.add_argument('--jobs', type=int, default=4)
    parser.add_argument('--generator', choices=['Ninja', 'Unix Makefiles'], default='Ninja')
    parser.add_argument('--cuda', default='/usr/local/cuda/bin/nvcc')
    parser.add_argument('--cuda-architectures', default='89')
    parser.add_argument('--cc', default='clang')
    parser.add_argument('--cxx', default='clang++')
    parser.add_argument('--cuda-clang', default='/opt/homebrew/opt/llvm@21/bin/clang++')
    parser.add_argument('--cumetal-root', type=Path, default=ROOT.parent / 'cuda-metal')
    parser.add_argument('--build-root', type=Path)
    parser.add_argument('--install-prefix', type=Path)
    parser.add_argument('--check', action='store_true')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--test', action='store_true')
    parser.add_argument('--install', action='store_true')
    parser.add_argument('--gpu-renderer', action='store_true')
    parser.add_argument('--gpu-profiler', action='store_true')
    parser.add_argument('--cupti-root', type=Path)
    parser.add_argument('--cumetal-atomic-response-stamp', action='store_true', help='Use a wide atomic response stamp; requires a qualified wide-atomic toolchain')
    parser.add_argument('--cumetal-parallel-contact-ids', action='store_true', help='Use atomic multi-block contact lifetime allocation; requires a qualified wide-atomic toolchain')
    parser.add_argument('--cumetal-gpu-sdf-builder', action='store_true', help='Opt into optional GPU SDF construction; requires qualified device fences')
    parser.add_argument('--cumetal-convex-core', action='store_true', help='Opt into optional ConvexCore compilation; currently unqualified')
    parser.add_argument('--cumetal-rigid-demo', action='store_true', help='Experimental rigid-body destruction demo profile: exclude articulation and diffuse-particle kernels; not full SDK acceptance')
    parser.add_argument('--cumetal-explicit-aggregate-root', action='store_true', help='Experimental restricted aggregate descriptor root for projection sorting; default OFF, native numerical qualification required')
    parser.add_argument('--cumetal-explicit-motion-root', action='store_true', help='Experimental descriptor-only restricted motion/articulation roots and local pointer-helper inlining; default OFF, native graph numerical qualification required')
    parser.add_argument('--cumetal-explicit-hierarchy-root', action='store_true', help='Experimental descriptor-only restricted kernel parameter; default OFF, compiler metadata support and numerical qualification still required')
    parser.add_argument('--cumetal-particle-inline-threshold', type=int, metavar='N', help='Experimental particle-only source-first inlining threshold 0..2147483647; omitted by default; numerical qualification required')
    parser.add_argument('--cumetal-softbody-inline-threshold', type=int, metavar='N', help='Experimental softbody-only source-first inlining threshold 0..2147483647; omitted by default; numerical qualification required')
    parser.add_argument('--cumetal-pack-bond-stress-scalars', action='store_true', help='Experimental scalar-only bond stress launch packaging for Metal buffer limits; default OFF, native ABI and numerical qualification required')
    parser.add_argument('--cumetal-block-voted-traps', action='store_true', help='Experimental terminal error block vote and affected one-block launch bounds; default OFF, requires native collective-trap and numerical qualification')
    parser.add_argument('--cumetal-tgs-whole-island-max-bodies', type=int, metavar='N', help='Shared body/slab capacity 1..944 (CuMetal default 512); larger islands use the existing partitioned TGS solver')
    args = parser.parse_args(argv)
    preset_backend = {'linux-cuda': 'cuda', 'macos-cumetal': 'cumetal'}.get(args.preset)
    if args.backend and preset_backend and args.backend != preset_backend:
        parser.error('--backend conflicts with --preset')
    args.backend = args.backend or preset_backend or ('cumetal' if platform.system() == 'Darwin' else 'cuda')
    args.preset = 'macos-cumetal' if args.backend == 'cumetal' else 'linux-cuda'
    if args.cumetal_atomic_response_stamp and args.backend != 'cumetal':
        parser.error('--cumetal-atomic-response-stamp requires --backend cumetal')
    if args.cumetal_parallel_contact_ids and args.backend != 'cumetal':
        parser.error('--cumetal-parallel-contact-ids requires --backend cumetal')
    if args.cumetal_gpu_sdf_builder and args.backend != 'cumetal':
        parser.error('--cumetal-gpu-sdf-builder requires --backend cumetal')
    if args.cumetal_convex_core and args.backend != 'cumetal':
        parser.error('--cumetal-convex-core requires --backend cumetal')
    if args.cumetal_rigid_demo and args.backend != 'cumetal':
        parser.error('--cumetal-rigid-demo requires --backend cumetal')
    if args.cumetal_explicit_aggregate_root and args.backend != 'cumetal':
        parser.error('--cumetal-explicit-aggregate-root requires --backend cumetal')
    if args.cumetal_explicit_motion_root and args.backend != 'cumetal':
        parser.error('--cumetal-explicit-motion-root requires --backend cumetal')
    if args.cumetal_explicit_hierarchy_root and args.backend != 'cumetal':
        parser.error('--cumetal-explicit-hierarchy-root requires --backend cumetal')
    if args.cumetal_pack_bond_stress_scalars and args.backend != 'cumetal':
        parser.error('--cumetal-pack-bond-stress-scalars requires --backend cumetal')
    if args.cumetal_block_voted_traps and args.backend != 'cumetal':
        parser.error('--cumetal-block-voted-traps requires --backend cumetal')
    if args.cumetal_particle_inline_threshold is not None:
        if args.backend != 'cumetal':
            parser.error('--cumetal-particle-inline-threshold requires --backend cumetal')
        if not 0 <= args.cumetal_particle_inline_threshold <= 2147483647:
            parser.error('--cumetal-particle-inline-threshold must be in [0, 2147483647]')
    if args.cumetal_softbody_inline_threshold is not None:
        if args.backend != 'cumetal':
            parser.error('--cumetal-softbody-inline-threshold requires --backend cumetal')
        if not 0 <= args.cumetal_softbody_inline_threshold <= 2147483647:
            parser.error('--cumetal-softbody-inline-threshold must be in [0, 2147483647]')
    if args.cumetal_tgs_whole_island_max_bodies is not None:
        if args.backend != 'cumetal':
            parser.error('--cumetal-tgs-whole-island-max-bodies requires --backend cumetal')
        if not 1 <= args.cumetal_tgs_whole_island_max_bodies <= 944:
            parser.error('--cumetal-tgs-whole-island-max-bodies must be in [1, 944]')
    else:
        args.cumetal_tgs_whole_island_max_bodies = 512 if args.backend == 'cumetal' else 944
    if args.jobs < 1:
        parser.error('--jobs must be positive')
    if args.backend == 'cuda' and args.cuda_architectures != '89':
        parser.error('This checkout qualifies only CUDA architecture 89')
    if args.backend == 'cumetal' and (args.gpu_renderer or args.gpu_profiler):
        parser.error('CUDA/OpenGL rendering and CUPTI are outside the CuMetal SDK target')
    if args.gpu_profiler and not args.cupti_root:
        parser.error('--gpu-profiler requires an existing --cupti-root')
    if args.backend == 'cumetal' and args.stage == 'sdk' and args.test:
        parser.error('--stage sdk on CuMetal packages the --stage gpu engine; test it with --stage gpu/scene')
    if args.stage in ('host', 'gpu', 'scene') and args.install:
        parser.error('--stage host/gpu/scene does not provide an installable destruction package; use --stage sdk')
    component_test = bool(args.target) and all(t in GPU_COMPONENT_TESTS for t in args.target)
    if 'PhysXCuMetalBondStressTest' in args.target and not args.cumetal_pack_bond_stress_scalars:
        parser.error('PhysXCuMetalBondStressTest requires --cumetal-pack-bond-stress-scalars')
    if 'PhysXCuMetalFineDiagonalTest' in args.target and not args.cumetal_block_voted_traps:
        parser.error('PhysXCuMetalFineDiagonalTest requires --cumetal-block-voted-traps')
    if args.stage == 'scene':
        if args.target and (len(args.target) != 1 or args.target[0] not in SCENE_TARGETS):
            parser.error('--stage scene builds one native scene or capture target')
        args.target = args.target or [SCENE_TARGET]
        if args.test and args.target == [CAPTURE_TARGET]:
            parser.error('native_wall_capture requires explicit capture arguments; use native_standard_scene_test for --test')
    elif any(t in SCENE_TARGETS for t in args.target):
        parser.error('native scene/capture targets require --stage scene')
    elif args.target and args.stage != 'gpu':
        parser.error('--target is for partial GPU component builds or the named scene gate')
    if any(t in GPU_COMPONENT_TESTS for t in args.target) and args.backend != 'cumetal':
        parser.error('CuMetal component tests require --backend cumetal')
    if args.stage == 'gpu' and args.test and not component_test:
        parser.error('--stage gpu --test requires only named component test targets; full GPU acceptance remains in --stage sdk')
    if args.stage == 'compiler' and args.backend != 'cumetal':
        parser.error('--stage compiler is for building CuMetal from source')
    return args


def plan(args, root=ROOT):
    root = root.resolve()
    # Overrides never enlarge the approved write boundary.
    roots = (root, (root.parent / 'cuda-metal').resolve())
    cumetal = contained(args.cumetal_root, roots)
    if args.backend == 'cumetal' and not (cumetal / 'spec.md').is_file():
        raise ValueError(f'CuMetal source checkout not found: {cumetal}')
    work = contained(args.build_root or root / 'out/build' / args.preset / args.configuration / args.stage, (root,))
    prefix = contained(args.install_prefix or root / 'out/install' / args.preset / args.configuration, (root,))
    for path in (work, prefix):
        if not path.is_relative_to(root / 'out') or path == root / 'out':
            raise ValueError(f'Build/install destination must be beneath {root / "out"}: {path}')
        audit_tree(path, roots)
        audit_cmake_caches(path, roots)
    environment, caches = local_environment(work, roots)
    if args.backend == 'cumetal' and args.stage in ('gpu', 'scene', 'sdk'):
        # PhysX descriptors contain nested pointers. CuMetal's device-address
        # mode also makes every live allocation resident at dispatch time.
        environment['CUMETAL_USE_METAL_DEVICE_ADDRESSES'] = '1'
    build_tool = shutil.which('ninja' if args.generator == 'Ninja' else 'make', path=environment.get('PATH'))
    generator_flags = [f'-DCMAKE_MAKE_PROGRAM={build_tool}'] if build_tool else []
    sdk, artifacts, build, package = root / 'physx', work / 'artifacts', work / 'physx', work / 'destruction'
    # CuMetal packages the --stage gpu engine instead of recompiling every
    # kernel: the SDK stage adds only host archives and the install step.
    reuse_engine = args.stage == 'scene' or (args.stage == 'sdk' and args.backend == 'cumetal')
    if reuse_engine:
        engine = contained(root / 'out/build' / args.preset / args.configuration / 'gpu', (root,))
        audit_tree(engine, roots)
        audit_cmake_caches(engine, roots)
        artifacts, build = engine / 'artifacts', engine / 'physx'
    output_platform = 'mac.arm64' if args.backend == 'cumetal' else 'linux.x86_64'
    libraries = artifacts / 'bin' / output_platform / args.configuration
    common = ['-G', args.generator, f'-DCMAKE_BUILD_TYPE={args.configuration}',
              f'-DCMAKE_C_COMPILER={args.cc}', f'-DCMAKE_CXX_COMPILER={args.cxx}',
              f'-DPX_GPU_BACKEND={args.backend.upper()}', f'-DCMAKE_INSTALL_PREFIX={prefix}', *REGISTRY_FLAGS, *generator_flags]
    sdk_flags = [f'-DPHYSX_ROOT_DIR={sdk}', f'-DTARGET_BUILD_PLATFORM={"mac" if args.backend == "cumetal" else "linux"}',
                 f'-DPX_OUTPUT_LIB_DIR={artifacts}', f'-DPX_OUTPUT_BIN_DIR={artifacts}',
                 '-DNV_FORCE_64BIT_SUFFIX=TRUE', f'-DPX_OUTPUT_ARCH={"arm" if args.backend == "cumetal" else "x86"}',
                 '-DPX_GENERATE_STATIC_LIBRARIES=TRUE', '-DPX_BUILDSNIPPETS=FALSE',
                 f'-DPX_GENERATED_INCLUDE_DIR={build / "include"}',
                 f'-DPX_BUILDPVDRUNTIME={"TRUE" if args.backend == "cuda" else "FALSE"}']
    commands, extra_outputs = [], []
    if args.backend == 'cuda':
        if args.stage in ('gpu', 'scene', 'sdk'):
            common += [f'-DCMAKE_CUDA_COMPILER={args.cuda}', '-DCMAKE_CUDA_ARCHITECTURES=89-real',
                       '-DPX_DESTRUCTION_CUDA_ARCHITECTURES=89']
        sdk_flags += [f'-DPX_GENERATE_GPU_PROJECTS={"TRUE" if args.stage in ("gpu", "sdk") else "FALSE"}']
    else:
        cm_build = contained(cumetal / 'out/build/macos-cumetal' / args.configuration, roots)
        cm_prefix = contained(cumetal / 'out/install/macos-cumetal' / args.configuration, roots)
        extra_outputs = [cm_build, cm_prefix]
        for path in extra_outputs:
            audit_tree(path, roots)
            audit_cmake_caches(path, roots)
        for alias in (cm_build / 'libcuda.dylib', cm_prefix / 'lib/libcuda.dylib'):
            if alias.exists() or alias.is_symlink():
                raise ValueError(f'Binary-shim alias exists in a source-first output tree: {alias}. Inspect it manually or choose a fresh configuration.')
        if args.stage in ('gpu', 'compiler'):
            commands += [
                ['cmake', '-S', str(cumetal), '-B', str(cm_build), '-G', args.generator,
                 f'-DCMAKE_BUILD_TYPE={"Debug" if args.configuration == "debug" else "Release"}',
                 '-DCUMETAL_ENABLE_BINARY_SHIM=OFF', f'-DCMAKE_INSTALL_PREFIX={cm_prefix}', *REGISTRY_FLAGS, *generator_flags],
                ['cmake', '--build', str(cm_build), '--target', *CUMETAL_TARGETS, '--parallel', str(args.jobs)],
            ]
        common += ['-DCMAKE_OSX_ARCHITECTURES=arm64', f'-DCUMETAL_ROOT_DIR={cumetal}',
                   f'-DCUMETALC_EXECUTABLE={cm_build / "cumetalc"}',
                   f'-DCUMETAL_LIBRARY={cm_build / "libcumetal.dylib"}',
                   f'-DCUMETAL_CUDA_CLANG={args.cuda_clang}', '-DPX_CUMETAL_FP64=ieee64',
                   '-DPX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON', '-DPX_CUMETAL_INLINE_REF_GJK_EPA=ON',
                   f'-DPX_CUMETAL_RIGID_DEMO={"ON" if args.cumetal_rigid_demo else "OFF"}',
                   f'-DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT={"ON" if args.cumetal_explicit_aggregate_root else "OFF"}',
                   f'-DPX_CUMETAL_EXPLICIT_MOTION_ROOT={"ON" if args.cumetal_explicit_motion_root else "OFF"}',
                   f'-DPX_CUMETAL_EXPLICIT_HIERARCHY_ROOT={"ON" if args.cumetal_explicit_hierarchy_root else "OFF"}',
                   f'-DPX_CUMETAL_PACK_BOND_STRESS_SCALARS={"ON" if args.cumetal_pack_bond_stress_scalars else "OFF"}',
                   f'-DPX_CUMETAL_BLOCK_VOTED_TRAPS={"ON" if args.cumetal_block_voted_traps else "OFF"}',
                   f'-DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD={args.cumetal_particle_inline_threshold if args.cumetal_particle_inline_threshold is not None else ""}',
                   f'-DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD={args.cumetal_softbody_inline_threshold if args.cumetal_softbody_inline_threshold is not None else ""}',
                   f'-DPX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES={args.cumetal_tgs_whole_island_max_bodies}',
                   f'-DPX_CUMETAL_ENABLE_GPU_SDF_BUILDER={"ON" if args.cumetal_gpu_sdf_builder else "OFF"}',
                   f'-DPX_CUMETAL_ENABLE_CONVEX_CORE={"ON" if args.cumetal_convex_core else "OFF"}',
                   f'-DPX_CUMETAL_SERIAL_CONTACT_IDS={"OFF" if args.cumetal_parallel_contact_ids else "ON"}',
                   f'-DPX_CUMETAL_SPLIT_RESPONSE_STAMP={"OFF" if args.cumetal_atomic_response_stamp else "ON"}']
        environment['CUMETAL_CUDA_CLANG'] = args.cuda_clang
        sdk_flags += [f'-DPX_GENERATE_GPU_PROJECTS={"TRUE" if args.stage in ("gpu", "sdk") else "FALSE"}', f'-DPX_CUMETAL_HOST_ONLY={"ON" if args.stage == "host" else "OFF"}']
        if args.stage == 'compiler':
            if args.test:
                commands += [['cmake', '--build', str(cm_build), '--target', 'cumetal_native_registration_test',
                              '--parallel', str(args.jobs)],
                             ['ctest', '--test-dir', str(cm_build), '--output-on-failure',
                              '-R', '^(unit_native_registration|functional_cumetalc_(native_aot_object|native_aot_multi_kernel|native_aot_symbols|native_driver_symbols|link_executable|cooperative_single_block))$']]
            if args.install:
                commands += [['cmake', '--install', str(cm_build), '--prefix', str(cm_prefix)]]
                if args.test:
                    commands += [['python3', '-B', str(cumetal / 'tests/functional/run_staged_package_consumer.py'),
                                  str(cm_prefix), str(work / 'package-consumer'),
                                  str(cumetal / 'tests/functional/fixtures/native_aot_object.cu')]]
            return dict(root=root, roots=roots, work=work, prefix=cm_prefix, artifacts=artifacts,
                        cumetal=cumetal, environment=environment, caches=caches, commands=commands, extra_outputs=extra_outputs)
    if args.stage == 'scene':
        # This target uses the actual engine host archives and dynamically loaded
        # GPU module. Building it is not full SDK acceptance or installation.
        commands = [
            ['cmake', '-S', str(root / 'destruction'), '-B', str(package), *common,
             f'-DPHYSX_ROOT={sdk}', f'-DPHYSX_LIB_DIR={libraries}',
             f'-DPHYSX_CONFIGURATION={args.configuration}', f'-DPX_GENERATED_INCLUDE_DIR={build / "include"}',
             '-DBLAST_ENABLE_CUDA_STRESS=ON', '-DNATIVE_GPU_EGL_RENDERER=OFF', '-DNATIVE_GPU_CUPTI=OFF'],
            ['cmake', '--build', str(package), '--target', *args.target, '--parallel', str(args.jobs)],
        ]
        if args.test:
            commands += [['ctest', '--test-dir', str(package), '--output-on-failure', '--verbose',
                          '--no-tests=error', '-R', f'^{SCENE_TEST}$']]
        required = [libraries / f'lib{name}_static_64.a' for name in
                    ('PhysXExtensions', 'PhysX', 'PhysXPvdSDK', 'PhysXCooking', 'PhysXCommon',
                     'PhysXFoundation', 'PhysXCudaContextManager', 'PhysXVehicle')]
        required += [libraries / ('libPhysXGpuActivity_64.dylib' if args.backend == 'cumetal'
                                  else 'libPhysXGpuActivity_64.so'), build / 'include/PxConfig.h']
        if args.backend == 'cumetal':
            required += [cm_build / 'cumetalc', cm_build / 'libcumetal.dylib']
        return dict(root=root, roots=roots, work=work, prefix=prefix, artifacts=artifacts,
                    cumetal=cumetal, environment=environment, caches=caches, commands=commands,
                    extra_outputs=extra_outputs, engine=engine, engine_cache=build / 'CMakeCache.txt',
                    expected_engine_cache=engine_cache(common), required_scene_inputs=required,
                    scene_executable=package / 'reference' / args.target[0])
    if args.stage == 'sdk' and args.backend == 'cumetal':
        return cumetal_sdk_plan(args, locals())
    targets = HOST_TARGETS + (['PhysXCudaContextManager', 'PhysXGpu'] if args.stage in ('gpu', 'sdk') else [])
    if args.stage == 'host' and args.test:
        if args.backend != 'cumetal':
            raise ValueError('The host smoke gate currently targets macOS; use CUDA SDK tests on Linux')
        sdk_flags += ['-DPX_BUILD_HOST_SMOKE=ON']
        targets += ['physx_macos_host_smoke']
    if args.backend == 'cuda':
        targets += ['PVDRuntime']
    if args.target:
        targets = args.target
    commands += [['cmake', '-S', str(sdk / 'compiler/public'), '-B', str(build), *common, *sdk_flags],
                 ['cmake', '--build', str(build), '--target', *targets, '--parallel', str(args.jobs)]]
    if args.stage == 'host' and args.test:
        commands += [['ctest', '--test-dir', str(build), '--output-on-failure']]
    if args.stage == 'gpu' and args.test:
        pattern = '^(' + '|'.join(name for t in args.target for name in GPU_COMPONENT_TESTS[t]) + ')$'
        # Retain successful GPU provenance in the immutable per-run command log.
        commands += [['ctest', '--test-dir', str(build), '--output-on-failure', '--verbose', '-R', pattern]]
    if args.stage == 'sdk':
        commands += [
            ['cmake', '-S', str(root / 'destruction'), '-B', str(package), *common,
             f'-DPHYSX_ROOT={sdk}', f'-DPHYSX_LIB_DIR={libraries}', f'-DPHYSX_CONFIGURATION={args.configuration}',
             f'-DPX_GENERATED_INCLUDE_DIR={build / "include"}', '-DBLAST_ENABLE_CUDA_STRESS=ON',
             f'-DNATIVE_GPU_EGL_RENDERER={"ON" if args.gpu_renderer else "OFF"}',
             f'-DNATIVE_GPU_CUPTI={"ON" if args.gpu_profiler else "OFF"}',
             f'-DNATIVE_GPU_CUPTI_ROOT={args.cupti_root.resolve() if args.cupti_root else ""}'],
            ['cmake', '--build', str(package), '--parallel', str(args.jobs)],
        ]
        if args.test:
            commands += [['ctest', '--test-dir', str(package), '--output-on-failure']]
        if args.install:
            if args.backend == 'cumetal':
                commands += [['cmake', '--install', str(cm_build), '--prefix', str(cm_prefix)]]
            commands += [['cmake', '--install', str(package), '--prefix', str(prefix)]]
    return dict(root=root, roots=roots, work=work, prefix=prefix, artifacts=artifacts,
                cumetal=cumetal, environment=environment, caches=caches, commands=commands, extra_outputs=extra_outputs)



def engine_cache(common):
    """Backend/compiler hints a reused engine's CMake cache must match."""
    return dict(flag[2:].split('=', 1) for flag in common
                if flag.startswith(('-DPX_', '-DCUMETAL', '-DCMAKE_BUILD_TYPE=', '-DCMAKE_CUDA_')))


# Targets the destruction package installs; building them is enough for
# `cmake --install`, without the reference demos.
PACKAGE_INSTALL_TARGETS = ['blast_stress_core', 'NvBlastExtStressPhysX', 'NvBlastExtStressGpu',
                           'PhysXDestructionTopologyGpu', 'PhysXNativeVehicle']


def cumetal_sdk_plan(args, v):
    """Install the CuMetal --stage gpu engine as a relocatable SDK package.

    Only host archives (for example PhysXCharacterKinematic) and the package's
    own static libraries are built. The GPU module and libcumetal are copied as
    built by --stage gpu, never relinked here, so a process using the engine
    tree keeps running.
    """
    root, engine, build, libraries = v['root'], v['engine'], v['build'], v['libraries']
    package, prefix, common, cm_build = v['package'], v['prefix'], v['common'], v['cm_build']
    commands = [
        ['cmake', '--build', str(build), '--target', *HOST_TARGETS, 'PhysXCudaContextManager',
         '--parallel', str(args.jobs)],
        ['cmake', '-S', str(root / 'destruction'), '-B', str(package), *common,
         f'-DPHYSX_ROOT={v["sdk"]}', f'-DPHYSX_LIB_DIR={libraries}', f'-DPHYSX_CONFIGURATION={args.configuration}',
         f'-DPX_GENERATED_INCLUDE_DIR={build / "include"}', '-DBLAST_ENABLE_CUDA_STRESS=ON',
         '-DNATIVE_GPU_EGL_RENDERER=OFF', '-DNATIVE_GPU_CUPTI=OFF'],
        ['cmake', '--build', str(package), '--target', *PACKAGE_INSTALL_TARGETS, '--parallel', str(args.jobs)],
    ]
    if args.install:
        commands += [['cmake', '--install', str(package), '--prefix', str(prefix)],
                     ['python3', '-B', str(root / 'tools/scripts/relocate-macos-sdk.py'), str(prefix),
                      str(cm_build / 'libcumetal.dylib'), str(v['cumetal'] / 'runtime/api'),
                      str(root / 'out/sdk-artifacts.json'),
                      # Every shipped kernel must build a Metal pipeline.
                      '--warm', str(cm_build / 'cumetal-warm'), '--gate-dir', str(v['work'] / 'pipeline-gate')]]
    required = [libraries / 'libPhysXGpuActivity_64.dylib', libraries / 'libPhysXDestructionGpuRuntime_64.dylib',
                build / 'include/PxConfig.h', cm_build / 'libcumetal.dylib', cm_build / 'cumetalc',
                cm_build / 'cumetal-warm']
    return dict(root=root, roots=v['roots'], work=v['work'], prefix=prefix, artifacts=v['artifacts'],
                cumetal=v['cumetal'], environment=v['environment'], caches=v['caches'], commands=commands,
                extra_outputs=v['extra_outputs'], engine=engine, engine_cache=build / 'CMakeCache.txt',
                expected_engine_cache=engine_cache(common), required_scene_inputs=required)


def scene_prerequisites(build_plan):
    issues = []
    for path in build_plan['required_scene_inputs']:
        checked = contained(path, build_plan['roots'])
        if not checked.is_file():
            issues.append(f'Missing scene prerequisite: {checked}. Complete --stage gpu with matching options first.')
    cache = build_plan['engine_cache']
    if not cache.is_file():
        issues.append(f'Missing existing GPU configuration: {cache}. Complete --stage gpu first.')
    else:
        entries = dict(re.findall(r'^([^/#\s][^:=\r\n]*):[^=\r\n]*=([^\r\n]*)$', cache.read_text(), re.MULTILINE))
        for name, expected in build_plan['expected_engine_cache'].items():
            if entries.get(name) != expected:
                issues.append(f'Scene/GPU configuration mismatch: {name}: scene={expected!r}, '
                              f'GPU={entries.get(name)!r}. Reuse the same options or rebuild --stage gpu.')
    return issues


def scene_source_paths(root):
    """Audit the scene sources and their repository-local quoted includes.

    Shared engine/library code is additionally confined at process execution;
    this narrow gate must not select or run unrelated SDK tests.
    """
    demo = root / 'demos/blast-stress-demo'
    pending = [demo / 'tests/native_standard_scene_test.cpp', demo / 'physx_scene.cpp']
    visited = set()
    while pending:
        path = contained(pending.pop(), (root,))
        if path in visited:
            continue
        if not path.is_file():
            raise ValueError(f'Missing scene source for output audit: {path}')
        visited.add(path)
        for name in re.findall(r'^\s*#\s*include\s*"([^"]+)"', path.read_text(), re.MULTILINE):
            for base in (path.parent, demo, root / 'physx/include'):
                candidate = base / name
                if candidate.is_file():
                    pending.append(contained(candidate, (root,)))
                    break
    return sorted(visited)


def preflight(args, build_plan):
    issues, versions = [], {}
    expected = 'Darwin' if args.backend == 'cumetal' else 'Linux'
    if platform.system() != expected:
        issues.append(f'{args.preset} must execute on {expected}; use --dry-run to inspect it here')
    if args.backend == 'cumetal' and platform.machine() not in ('arm64', 'aarch64'):
        issues.append('CuMetal requires Apple Silicon')
    if args.test and args.stage == 'sdk':
        issues += audit_test_sources(build_plan['root'])
    if args.stage == 'scene' or 'engine' in build_plan:
        issues += scene_prerequisites(build_plan)
        if args.test:
            issues += audit_test_sources(build_plan['root'], scene_source_paths(build_plan['root']))
    tools = ['cmake', 'ctest', 'git', args.cc, args.cxx, 'ninja' if args.generator == 'Ninja' else 'make']
    if args.stage in ('gpu', 'scene', 'sdk', 'compiler'):
        tools += [args.cuda] if args.backend == 'cuda' else [args.cuda_clang]
    for tool in dict.fromkeys(tools):
        path = shutil.which(str(tool), path=build_plan['environment'].get('PATH'))
        if not path:
            issues.append(f'Missing tool: {tool}. Provide it manually; no installer will run.')
            continue
        result = subprocess.run(confined_command([path, '--version'], build_plan['roots'], readonly=True), capture_output=True, text=True,
                                env=build_plan['environment'], timeout=20)
        versions[tool] = dict(path=str(Path(path).resolve()), version=(result.stdout + result.stderr).strip())
        if result.returncode:
            detail = (result.stderr or result.stdout).strip()
            issues.append(f'Tool version probe failed: {tool}: {detail}')
        if tool == args.cuda and args.stage in ('gpu', 'scene', 'sdk') and args.backend == 'cuda':
            match = re.search(r'release (\d+)\.(\d+)', result.stdout)
            if not match or tuple(map(int, match.groups())) < (12, 8):
                issues.append('This checkout requires CUDA 12.8 or newer and sm_89')
    if args.backend == 'cumetal' and args.stage in ('gpu', 'scene', 'sdk', 'compiler'):
        for name in ('metal', 'metallib'):
            if not Path('/usr/bin/xcrun').exists():
                issues.append('Apple xcrun unavailable; install Xcode manually')
                break
            result = subprocess.run(confined_command(['/usr/bin/xcrun', '--no-cache', '--find', name], build_plan['roots'], readonly=True),
                                    capture_output=True, text=True, env=build_plan['environment'], timeout=20)
            if result.returncode:
                detail = (result.stderr or result.stdout).strip()
                if 'sandbox' in detail.lower():
                    issues.append(f'Cannot run the confined Apple {name} prerequisite probe: {detail}. This is a confinement failure, not evidence of a missing toolchain; no unconfined retry was performed.')
                else:
                    issues.append(f'Apple {name} tool unavailable: {detail}. Xcode/Metal Toolchain installation is a manual external prerequisite.')
            else:
                versions[name] = dict(path=result.stdout.strip())
    if args.backend == 'cumetal' and args.stage == 'sdk' and not args.cumetal_rigid_demo:
        issues.append('CuMetal destruction SDK is not implemented yet: full PhysX GPU module integration and numerical qualification remain required. See docs/CUMETAL_COMPATIBILITY.md; --stage host validates only the CPU host SDK.')
    return issues, versions


def describe(args, build_plan):
    return dict(preset=args.preset, backend=args.backend, configuration=args.configuration, stage=args.stage,
                selected_targets=args.target, partial_build=bool(args.target),
                scene_test=SCENE_TEST if args.stage == 'scene' and args.test else None,
                scene_timeout_seconds=(600 if args.backend == 'cumetal' else 120) if args.stage == 'scene' else None,
                reused_engine_root=str(build_plan['engine']) if 'engine' in build_plan else None,
                required_scene_inputs=list(map(str, build_plan.get('required_scene_inputs', []))),
                sdk_acceptance=False if args.stage == 'scene' else None,
                feature_profile='rigid-demo-experimental' if args.cumetal_rigid_demo else 'full',
                excluded_gpu_features=['articulations', 'diffuse_particles'] if args.cumetal_rigid_demo else [],
                optional_features={'convex_core': args.cumetal_convex_core if args.backend == 'cumetal' else True,
                                   'gpu_sdf_builder': args.cumetal_gpu_sdf_builder if args.backend == 'cumetal' else True},
                component_tests=[name for t in args.target if t in GPU_COMPONENT_TESTS for name in GPU_COMPONENT_TESTS[t]] if args.test else [],
                source=str(build_plan['root']), cumetal_source=str(build_plan['cumetal']),
                build_root=str(build_plan['work']), install_prefix=str(build_plan['prefix']),
                additional_output_roots=list(map(str, build_plan['extra_outputs'])), install_requested=args.install,
                compiler_hints={'pack_bond_stress_scalars': args.cumetal_pack_bond_stress_scalars,
                                'pack_bond_stress_scalars_scope': 'bondStressWalk private launch ABI: 32-byte scalar record plus 27 pointers' if args.cumetal_pack_bond_stress_scalars else 'disabled',
                                'pack_bond_stress_scalars_status': 'experimental; native ABI, graph capture and numerical qualification required' if args.cumetal_pack_bond_stress_scalars else 'disabled',
                                'particle_inline_threshold': args.cumetal_particle_inline_threshold,
                                'particle_inline_scope': 'physx/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu' if args.cumetal_particle_inline_threshold is not None else 'disabled',
                                'particle_inline_status': 'experimental; particle tail/compaction component tests passed, complete narrowphase unqualified' if args.cumetal_particle_inline_threshold is not None else 'disabled',
                                'softbody_inline_threshold': args.cumetal_softbody_inline_threshold,
                                'softbody_inline_scope': 'physx/source/gpunarrowphase/src/CUDA/softbodySoftbodyMidPhase.cu' if args.cumetal_softbody_inline_threshold is not None else 'disabled',
                                'softbody_inline_status': 'experimental; isolated native compile passed, complete narrowphase and soft-body numerical behavior unqualified' if args.cumetal_softbody_inline_threshold is not None else 'disabled',
                                'explicit_aggregate_root': args.cumetal_explicit_aggregate_root,
                                'explicit_aggregate_root_scope': 'aggregate descriptor allocation in sorting, collision and bounds-update bookkeeping; nested buffers unrestricted' if args.cumetal_explicit_aggregate_root else 'disabled',
                                'explicit_aggregate_root_status': 'experimental; native registration and numerical qualification required' if args.cumetal_explicit_aggregate_root else 'disabled',
                                'explicit_motion_root': args.cumetal_explicit_motion_root,
                                'explicit_motion_root_scope': 'motion and explicit descriptor roots; pointer-helper inlining; per-record tendon update dispatch; nested payloads unrestricted' if args.cumetal_explicit_motion_root else 'disabled',
                                'explicit_motion_root_status': 'experimental; motion component graph tests passed; full native scene and other affected features unqualified' if args.cumetal_explicit_motion_root else 'disabled',
                                'explicit_hierarchy_root': args.cumetal_explicit_hierarchy_root,
                                'explicit_hierarchy_root_status': 'experimental; compiler metadata support and numerical qualification required' if args.cumetal_explicit_hierarchy_root else 'disabled',
                                'block_voted_traps': args.cumetal_block_voted_traps,
                                'block_voted_traps_status': 'experimental; collective-trap and numerical qualification required' if args.cumetal_block_voted_traps else 'disabled'},
                resource_options={'radix_sort_block_threads': 512 if args.backend == 'cumetal' else 1024,
                                  'radix_sort_grid_blocks': 32,
                                  'radix_sort_static_shared_bytes': 19648 if args.backend == 'cumetal' else 39104,
                                  'tgs_whole_island_max_bodies': args.cumetal_tgs_whole_island_max_bodies,
                                  'tgs_whole_island_shared_array_bytes': 48 * args.cumetal_tgs_whole_island_max_bodies,
                                  'tgs_larger_islands': 'existing partitioned solver',
                                  'block_voted_traps_max_grid_blocks': 1 if args.cumetal_block_voted_traps else None,
                                  'block_voted_traps_scope': 'terminal apply; global/component cycles; hierarchy-preconditioned persistent stress; fine-diagonal apply' if args.cumetal_block_voted_traps else 'disabled'},
                numerical_options={'required_destruction_fp64': 'ieee64', 'runtime_fp64_environment': 'ieee64',
                                   'cooperative_single_block': args.stage in ('gpu', 'scene', 'sdk'), 'forced_kernel_sync': False,
                                   'inline_ref_gjk_epa': args.stage in ('gpu', 'scene', 'sdk'),
                                   'split_response_stamp': not args.cumetal_atomic_response_stamp,
                                   'response_stamp_ordering': 'wide atomic' if args.cumetal_atomic_response_stamp else 'same epoch writers; readers and next epoch join all writers',
                                   'serial_contact_ids': not args.cumetal_parallel_contact_ids,
                                   'contact_id_ordering': 'atomic' if args.cumetal_parallel_contact_ids else 'single-block; shared sequence requires ordered stream/events',
                                   'metal_device_addresses': args.stage in ('gpu', 'scene', 'sdk'),
                                   'residency_policy': 'all-live-read-write' if args.stage in ('gpu', 'scene', 'sdk') else 'bound-arguments'} if args.backend == 'cumetal' else {'cuda_architectures': '89'},
                tool_paths={name: shutil.which(name, path=build_plan['environment'].get('PATH')) for name in ('cmake', 'ctest', args.cc, args.cxx,
                    'ninja' if args.generator == 'Ninja' else 'make', args.cuda if args.backend == 'cuda' else args.cuda_clang)},
                write_confinement='macOS sandbox-exec; path/cache validation on Linux',
                caches={k: str(v) for k, v in build_plan['caches'].items()}, commands=build_plan['commands'])


def provenance(root, env):
    def git(*args):
        return subprocess.check_output(['git', '--no-optional-locks', '-c', 'core.fsmonitor=false',
                                        '-c', 'core.untrackedCache=false', *args], cwd=root, env=env)
    revision = git('rev-parse', 'HEAD').decode().strip()
    # Raw source hashes avoid invoking Git LFS filters or refreshing the index.
    hashes, working_blobs = {}, {}
    object_format = git('rev-parse', '--show-object-format').decode().strip()
    names = git('ls-files', '--cached', '--others', '--exclude-standard', '-z').decode().split('\0')
    for name in sorted(set(names) - {''}):
        if name.split('/')[0] in ('out', '.git'):
            continue
        path = root / name
        data = os.readlink(path).encode() if path.is_symlink() else path.read_bytes() if path.is_file() else b'<missing>'
        hashes[name] = hashlib.sha256(data).hexdigest()
        working_blobs[name] = hashlib.new(object_format, b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
    baseline = {}
    for record in git('ls-tree', '-rz', 'HEAD').decode().split('\0'):
        if record:
            metadata, name = record.split('\t', 1)
            baseline[name] = metadata.split()[2]
    changes = {name: {'head_blob': baseline.get(name), 'working_sha256': hashes.get(name)}
               for name in sorted(set(baseline) | set(working_blobs))
               if baseline.get(name) != working_blobs.get(name)}
    return dict(revision=revision, source_files=hashes, raw_working_changes=changes,
                change_note='Raw content versus HEAD; hydrated LFS data also differs from its stored pointer. No Git clean filters were invoked.',
                source_content_sha256=hashlib.sha256(json.dumps(hashes, sort_keys=True).encode()).hexdigest())


def main(argv=None):
    args = arguments(argv)
    try:
        build_plan = plan(args)
        print(json.dumps(describe(args, build_plan), indent=2), flush=True)
        if args.dry_run:
            return 0
        issues, versions = preflight(args, build_plan)
        print(json.dumps(dict(tools=versions, prerequisites=issues), indent=2), flush=True)
        if issues:
            return 2
        if args.check:
            return 0
        # Every prerequisite check precedes the first write.
        for directory in [build_plan['work'], *[p for k, p in build_plan['caches'].items() if k != 'LLVM_PROFILE_FILE']]:
            contained(directory, build_plan['roots']).mkdir(parents=True, exist_ok=True)
        report = describe(args, build_plan)
        run_id = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S.%fZ') + f'-{os.getpid()}'
        log_directory = contained(build_plan['work'] / 'runs' / run_id, build_plan['roots'])
        log_directory.mkdir(parents=True, exist_ok=False)
        report['run_directory'] = str(log_directory)
        report.update(tools=versions, status='building', completed_commands=[],
                      sources={'physx': provenance(ROOT, build_plan['environment'])})
        if args.backend == 'cumetal':
            report['sources']['cumetal'] = provenance(build_plan['cumetal'], build_plan['environment'])
        manifest = contained(build_plan['work'] / 'sdk-artifacts.json', build_plan['roots'])
        try:
            for index, command in enumerate(build_plan['commands']):
                for directory in [build_plan['work'], build_plan['prefix'], *build_plan['extra_outputs'],
                                  *([build_plan['engine']] if 'engine' in build_plan else [])]:
                    audit_tree(directory, build_plan['roots'])
                    audit_cmake_caches(directory, build_plan['roots'])
                print('+ ' + shlex.join(command), flush=True)
                log = contained(log_directory / f'command-{index:02}.log', build_plan['roots'])
                with log.open('w') as output:
                    result = subprocess.run(confined_command(command, build_plan['roots']), cwd=ROOT, env=build_plan['environment'], stdout=output, stderr=subprocess.STDOUT)
                print(f'Log: {log}', flush=True)
                if result.returncode:
                    print('\n'.join(log.read_text(errors='replace').splitlines()[-40:]), flush=True)
                    raise subprocess.CalledProcessError(result.returncode, command)
                report['completed_commands'].append(command)
            status = 'scene-tested' if args.stage == 'scene' and args.test else 'gpu-component-tested' if args.stage == 'gpu' and args.test else (
                f'{args.stage}-build-only' if args.stage != 'sdk' else 'built')
            report.update(status=status, tested=args.test, installed=args.install)
        except subprocess.CalledProcessError as error:
            report.update(status='failed', failed_command=error.cmd, returncode=error.returncode)
            raise
        finally:
            report['artifacts'] = {}
            if build_plan['artifacts'].exists():
                for path in build_plan['artifacts'].rglob('*'):
                    if path.is_file():
                        checked = contained(path, build_plan['roots'])
                        report['artifacts'][str(path.relative_to(build_plan['work'])) if path.is_relative_to(build_plan['work']) else str(path)] = hashlib.sha256(checked.read_bytes()).hexdigest()
            if args.stage == 'scene' and build_plan['scene_executable'].is_file():
                path = contained(build_plan['scene_executable'], build_plan['roots'])
                report['artifacts'][str(path.relative_to(build_plan['work']))] = hashlib.sha256(path.read_bytes()).hexdigest()
            if args.backend == 'cumetal' and args.stage != 'host':
                for path in build_plan['extra_outputs'][0].iterdir():
                    if path.is_file() and (os.access(path, os.X_OK) or path.suffix in ('.dylib', '.a')):
                        report['artifacts'][str(path)] = hashlib.sha256(contained(path, build_plan['roots']).read_bytes()).hexdigest()
            encoded = json.dumps(report, indent=2) + '\n'
            contained(log_directory / 'sdk-artifacts.json', build_plan['roots']).write_text(encoded)
            contained(manifest, build_plan['roots']).write_text(encoded)
        return 0
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f'error: {error}', file=__import__('sys').stderr)
        return 1
