#!/usr/bin/env python3
"""Safety regression tests; all fixtures live under the repository's out/ tree."""
import contextlib
import io
import json
import os
import shutil
import subprocess
from pathlib import Path
import sys
sys.dont_write_bytecode = True
import tempfile
import unittest
from unittest.mock import patch

from destruction_build import ROOT, arguments, main, plan, preflight, describe, scene_prerequisites, scene_source_paths
from destruction_build_paths import contained, audit_tree, audit_cmake_caches, local_environment, audit_test_sources, confined_command


class BuildSafetyTests(unittest.TestCase):
    def setUp(self):
        base = contained(ROOT / 'out/tests/build-helper', (ROOT,))
        base.mkdir(parents=True, exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(dir=base)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'PhysX'
        self.root.mkdir()
        self.cumetal = self.root.parent / 'cuda-metal'
        self.cumetal.mkdir()
        (self.cumetal / 'spec.md').write_text('fixture')
        self.roots = (self.root, self.cumetal)

    def args(self, *options):
        return arguments(['--cumetal-root', str(self.cumetal), *options])

    def test_external_and_parent_escape(self):
        for path in ('/tmp/escape', self.root / '../escape', self.root / '../../escape'):
            with self.assertRaises(ValueError):
                contained(path, self.roots)

    def test_existing_parent_and_dangling_symlink_escape(self):
        (self.root / 'link').symlink_to('/tmp/no-such-physx-output')
        with self.assertRaises(ValueError):
            contained(self.root / 'link/new-child', self.roots)

    def test_nested_symlink_escape(self):
        folder = self.root / 'out'
        folder.mkdir()
        (folder / 'redirect').symlink_to('/usr')
        with self.assertRaises(ValueError):
            audit_tree(folder, self.roots)

    def test_cached_install_escape(self):
        (self.root / 'CMakeCache.txt').write_text('CMAKE_INSTALL_PREFIX:PATH=/usr/local\n')
        with self.assertRaises(ValueError):
            audit_cmake_caches(self.root, self.roots)

    def test_cached_configuration_output_escape(self):
        (self.root / 'CMakeCache.txt').write_text('CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE:PATH=/tmp/escape\n')
        with self.assertRaises(ValueError):
            audit_cmake_caches(self.root, self.roots)

    def test_cached_install_directory_escape(self):
        cache = self.root / 'CMakeCache.txt'
        for destination in ('/usr/local/lib', '../../../../outside'):
            cache.write_text(f'CMAKE_INSTALL_PREFIX:PATH={self.root}/out/install\n'
                             f'CMAKE_INSTALL_LIBDIR:PATH={destination}\n')
            with self.assertRaises(ValueError):
                audit_cmake_caches(self.root, self.roots)
        cache.write_text(f'CMAKE_INSTALL_PREFIX:PATH={self.root}/out/install\n'
                         'CMAKE_INSTALL_LIBDIR:PATH=lib\n')
        audit_cmake_caches(self.root, self.roots)

    def test_override_does_not_enlarge_boundary(self):
        with self.assertRaises(ValueError):
            plan(self.args('--backend', 'cuda', '--build-root', '/tmp/new'), self.root)
        with self.assertRaises(ValueError):
            plan(self.args('--backend', 'cuda', '--install-prefix', str(self.root / 'physx')), self.root)

    def test_linux_plan_and_explicit_install(self):
        args = self.args('--preset', 'linux-cuda')
        p = plan(args, self.root)
        commands = json.dumps(p['commands'])
        self.assertIn('-DPX_GPU_BACKEND=CUDA', commands)
        self.assertIn('89-real', commands)
        self.assertNotIn('--install', commands)
        self.assertNotIn('ctest', commands)
        self.assertNotIn('packman', commands.lower())
        args.install = True
        args.test = True
        p = plan(args, self.root)
        self.assertEqual(p['commands'][-1][1], '--install')
        self.assertEqual(p['commands'][-2][0], 'ctest')

    def test_macos_has_no_nvidia_toolkit(self):
        # The GPU stage builds CuMetal; the SDK stage packages that build.
        p = plan(self.args('--preset', 'macos-cumetal', '--stage', 'gpu'), self.root)
        commands = json.dumps(p['commands'])
        self.assertNotIn('/usr/local/cuda', commands)
        self.assertNotIn('CMAKE_CUDA_COMPILER', commands)
        self.assertIn('-DCUMETAL_ENABLE_BINARY_SHIM=OFF', commands)
        self.assertIn('-DPX_CUMETAL_FP64=ieee64', commands)

    def test_response_stamp_protocol_is_explicit(self):
        for atomic in (False,True):
            args=self.args('--backend','cumetal','--stage','gpu',*(['--cumetal-atomic-response-stamp'] if atomic else []))
            p=plan(args,self.root)
            self.assertIn('-DPX_CUMETAL_SPLIT_RESPONSE_STAMP='+('OFF' if atomic else 'ON'),json.dumps(p['commands']))
            self.assertEqual(describe(args,p)['numerical_options']['split_response_stamp'],not atomic)
        p=plan(self.args('--backend','cuda'),self.root)
        self.assertNotIn('PX_CUMETAL_SPLIT_RESPONSE_STAMP',json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend','cuda','--cumetal-atomic-response-stamp')

    def test_contact_id_scheduling_is_explicit(self):
        for parallel in (False,True):
            args=self.args('--backend','cumetal','--stage','gpu',*(['--cumetal-parallel-contact-ids'] if parallel else []))
            p=plan(args,self.root)
            self.assertIn('-DPX_CUMETAL_SERIAL_CONTACT_IDS='+('OFF' if parallel else 'ON'),json.dumps(p['commands']))
            self.assertEqual(describe(args,p)['numerical_options']['serial_contact_ids'],not parallel)
        p=plan(self.args('--backend','cuda'),self.root)
        self.assertNotIn('PX_CUMETAL_SERIAL_CONTACT_IDS',json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend','cuda','--cumetal-parallel-contact-ids')

    def test_rigid_demo_is_explicit_and_scene_cache_matched(self):
        for enabled in (False, True):
            options = ['--cumetal-rigid-demo'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_RIGID_DEMO=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            details = describe(args, p)
            self.assertEqual(details['feature_profile'], 'rigid-demo-experimental' if enabled else 'full')
            self.assertEqual(details['excluded_gpu_features'], ['articulations', 'diffuse_particles'] if enabled else [])
            self.assertNotIn('--install', json.dumps(p['commands']))
            scene = plan(self.args('--backend', 'cumetal', '--stage', 'scene', *options), self.root)
            self.assertEqual(scene['expected_engine_cache']['PX_CUMETAL_RIGID_DEMO'], 'ON' if enabled else 'OFF')
            self.assertFalse(describe(self.args('--backend', 'cumetal', '--stage', 'scene', *options), scene)['sdk_acceptance'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_RIGID_DEMO', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-rigid-demo')

    def test_rigid_demo_cmake_rejects_cuda(self):
        env, _ = local_environment(self.root / 'out/rigid-demo-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for option validation')
        for module in ('destruction/GpuBackend.cmake',
                       'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'):
            command = [cmake, '-DPX_CUMETAL_RIGID_DEMO=ON', '-DPX_GPU_BACKEND=CUDA', '-P', str(ROOT / module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(module=module):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_RIGID_DEMO requires', result.stderr)

    def test_explicit_aggregate_root_is_opt_in_and_backend_scoped(self):
        for enabled in (False, True):
            options = ['--cumetal-explicit-aggregate-root'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['explicit_aggregate_root'], enabled)
            self.assertIn('experimental' if enabled else 'disabled', hints['explicit_aggregate_root_status'])
            scene = plan(self.args('--backend', 'cumetal', '--stage', 'scene', *options), self.root)
            self.assertEqual(scene['expected_engine_cache']['PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT'],
                             'ON' if enabled else 'OFF')
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-explicit-aggregate-root')

    def test_explicit_aggregate_root_cmake_rejects_cuda(self):
        env, _ = local_environment(self.root / 'out/bond-pack-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for option validation')
        for module in ('destruction/GpuBackend.cmake',
                       'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'):
            command = [cmake, '-DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=ON',
                       '-DPX_GPU_BACKEND=CUDA', '-P', str(ROOT / module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(module=module):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_EXPLICIT_AGGREGATE_ROOT requires', result.stderr)

    def test_explicit_aggregate_root_reaches_device_and_host_commands(self):
        work = contained(self.root / 'out/aggregate-root-config', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated-command inspection')
        project = work / 'fixture'
        project.mkdir()
        (project / 'stress.cu').write_text('// Configure-only launch ABI fixture.\n')
        (project / 'host.cpp').write_text('// Configure-only host ABI fixture.\n')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(AggregateRoot LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            'add_library(stress STATIC stress.cu host.cpp)\npx_cumetal_objects(stress)\n')
        # Reconfigure the same build to ensure OFF removes an old enabled ABI.
        for enabled in (False, True, False):
            build = work / 'build'
            command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                       '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                       '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF',
                       '-DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=' + ('ON' if enabled else 'OFF')]
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            native = [line for line in (build / 'CMakeFiles/stress.dir/build.make').read_text().splitlines()
                      if ' -c --backend=cumetal-ir' in line]
            self.assertEqual(len(native), 1)
            definition = '-DPX_CUMETAL_EXPLICIT_AGGREGATE_ROOT=1'
            self.assertEqual(definition in native[0], enabled, native[0])
            host_flags = (build / 'CMakeFiles/stress.dir/flags.make').read_text()
            self.assertEqual(definition in host_flags, enabled, host_flags)

    def test_explicit_motion_root_is_opt_in_and_backend_scoped(self):
        for enabled in (False, True):
            options = ['--cumetal-explicit-motion-root'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_EXPLICIT_MOTION_ROOT=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['explicit_motion_root'], enabled)
            self.assertIn('experimental' if enabled else 'disabled', hints['explicit_motion_root_status'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_EXPLICIT_MOTION_ROOT', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-explicit-motion-root')

    def test_explicit_motion_root_cmake_rejects_cuda(self):
        env, _ = local_environment(self.root / 'out/bond-pack-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for option validation')
        for module in ('destruction/GpuBackend.cmake',
                       'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'):
            command = [cmake, '-DPX_CUMETAL_EXPLICIT_MOTION_ROOT=ON',
                       '-DPX_GPU_BACKEND=CUDA', '-P', str(ROOT / module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(module=module):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_EXPLICIT_MOTION_ROOT requires', result.stderr)

    def test_explicit_motion_root_reaches_device_and_host_commands(self):
        work = contained(self.root / 'out/motion-root-config', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated-command inspection')
        project = work / 'fixture'
        project.mkdir()
        (project / 'stress.cu').write_text('// Configure-only launch ABI fixture.\n')
        (project / 'host.cpp').write_text('// Configure-only host ABI fixture.\n')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(MotionRoot LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            'add_library(stress STATIC stress.cu host.cpp)\npx_cumetal_objects(stress)\n')
        # Reconfigure the same build to ensure OFF removes an old enabled ABI.
        for enabled in (False, True, False):
            build = work / 'build'
            command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                       '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                       '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF',
                       '-DPX_CUMETAL_EXPLICIT_MOTION_ROOT=' + ('ON' if enabled else 'OFF')]
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            native = [line for line in (build / 'CMakeFiles/stress.dir/build.make').read_text().splitlines()
                      if ' -c --backend=cumetal-ir' in line]
            self.assertEqual(len(native), 1)
            definition = '-DPX_CUMETAL_EXPLICIT_MOTION_ROOT=1'
            self.assertEqual(definition in native[0], enabled, native[0])
            host_flags = (build / 'CMakeFiles/stress.dir/flags.make').read_text()
            self.assertEqual(definition in host_flags, enabled, host_flags)

    def test_explicit_hierarchy_root_is_opt_in_and_backend_scoped(self):
        for enabled in (False, True):
            options = ['--cumetal-explicit-hierarchy-root'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_EXPLICIT_HIERARCHY_ROOT=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['explicit_hierarchy_root'], enabled)
            self.assertIn('experimental' if enabled else 'disabled', hints['explicit_hierarchy_root_status'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-explicit-hierarchy-root')

    def test_bond_stress_gate_requires_only_its_scalar_pack_hint(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cumetal', '--stage', 'gpu', '--target', 'PhysXCuMetalBondStressTest')
        args = self.args('--backend', 'cumetal', '--stage', 'gpu', '--target',
                         'PhysXCuMetalBondStressTest', '--cumetal-pack-bond-stress-scalars', '--test')
        self.assertFalse(args.cumetal_block_voted_traps)
        p = plan(args, self.root)
        report = describe(args, p)
        expected = ['physx_cumetal_bond_stress', 'physx_cumetal_bond_stress_batched']
        self.assertEqual(report['component_tests'], expected)
        self.assertEqual(p['commands'][-1][-1], '^(' + '|'.join(expected) + ')$')
        self.assertTrue(report['compiler_hints']['pack_bond_stress_scalars'])
        self.assertFalse(report['compiler_hints']['block_voted_traps'])
        build_command = next(command for command in p['commands'] if
                             '--build' in command and 'PhysXCuMetalBondStressTest' in command)
        self.assertEqual(build_command[build_command.index('--target') + 1], 'PhysXCuMetalBondStressTest')
        for extra in (['--backend', 'cuda'], ['--stage', 'sdk'], ['--install']):
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', 'cumetal', '--stage', 'gpu', '--target',
                          'PhysXCuMetalBondStressTest', '--cumetal-pack-bond-stress-scalars', *extra)

    def test_fine_diagonal_gate_requires_explicit_source_hint(self):
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cumetal', '--stage', 'gpu', '--target', 'PhysXCuMetalFineDiagonalTest')
        args = self.args('--backend', 'cumetal', '--stage', 'gpu', '--target',
                         'PhysXCuMetalFineDiagonalTest', '--cumetal-block-voted-traps', '--test')
        report = describe(args, plan(args, self.root))
        self.assertEqual(report['component_tests'], ['physx_cumetal_fine_diagonal', 'physx_cumetal_fine_diagonal_batched'])
        self.assertIn('fine-diagonal apply', report['resource_options']['block_voted_traps_scope'])

    def test_block_voted_traps_are_opt_in_and_backend_scoped(self):
        for enabled in (False, True):
            options = ['--cumetal-block-voted-traps'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            commands = json.dumps(p['commands'])
            self.assertIn('-DPX_CUMETAL_BLOCK_VOTED_TRAPS=' + ('ON' if enabled else 'OFF'), commands)
            self.assertIn('-DPX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON', commands)
            manifest = describe(args, p)
            self.assertEqual(manifest['compiler_hints']['block_voted_traps'], enabled)
            self.assertIn('experimental' if enabled else 'disabled', manifest['compiler_hints']['block_voted_traps_status'])
            self.assertEqual(manifest['resource_options']['block_voted_traps_max_grid_blocks'], 1 if enabled else None)
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_BLOCK_VOTED_TRAPS', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-block-voted-traps')

    def test_block_voted_traps_cmake_requires_native_one_block_contract(self):
        env, _ = local_environment(self.root / 'out/config-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for direct CMake option validation')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        # Each invalid combination must fail before header discovery/targets,
        # so this script-mode check creates no build or compiler cache.
        for backend, single_block in [('CUDA', 'ON'), ('CUDA', 'OFF'), ('CUMETAL', 'OFF')]:
            command = [cmake, '-DPX_CUMETAL_BLOCK_VOTED_TRAPS=ON',
                       f'-DPX_GPU_BACKEND={backend}',
                       f'-DPX_CUMETAL_COOPERATIVE_SINGLE_BLOCK={single_block}', '-P', str(module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(backend=backend, single_block=single_block):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_BLOCK_VOTED_TRAPS requires', result.stderr)
                self.assertIn('PX_CUMETAL_COOPERATIVE_SINGLE_BLOCK=ON', result.stderr)

    def test_bond_stress_scalar_pack_is_opt_in_backend_scoped_and_recorded(self):
        for enabled in (False, True):
            options = ['--cumetal-pack-bond-stress-scalars'] if enabled else []
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=' + ('ON' if enabled else 'OFF'),
                          json.dumps(p['commands']))
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['pack_bond_stress_scalars'], enabled)
            self.assertIn('experimental' if enabled else 'disabled', hints['pack_bond_stress_scalars_status'])
            self.assertIn('32-byte' if enabled else 'disabled', hints['pack_bond_stress_scalars_scope'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_PACK_BOND_STRESS_SCALARS', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-pack-bond-stress-scalars')

    def test_bond_stress_scalar_pack_cmake_rejects_cuda(self):
        env, _ = local_environment(self.root / 'out/bond-pack-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for option validation')
        for module in ('destruction/GpuBackend.cmake',
                       'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'):
            command = [cmake, '-DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=ON',
                       '-DPX_GPU_BACKEND=CUDA', '-P', str(ROOT / module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(module=module):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_PACK_BOND_STRESS_SCALARS requires', result.stderr)

    def test_bond_stress_scalar_pack_reaches_device_and_host_commands(self):
        work = contained(self.root / 'out/bond-pack-config', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated-command inspection')
        project = work / 'fixture'
        project.mkdir()
        (project / 'stress.cu').write_text('// Configure-only launch ABI fixture.\n')
        (project / 'host.cpp').write_text('// Configure-only host ABI fixture.\n')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(BondPack LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            'add_library(stress STATIC stress.cu host.cpp)\npx_cumetal_objects(stress)\n')
        # Reconfigure the same build to ensure OFF removes an old enabled ABI.
        for enabled in (False, True, False):
            build = work / 'build'
            command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                       '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                       '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF',
                       '-DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=' + ('ON' if enabled else 'OFF')]
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            native = [line for line in (build / 'CMakeFiles/stress.dir/build.make').read_text().splitlines()
                      if ' -c --backend=cumetal-ir' in line]
            self.assertEqual(len(native), 1)
            definition = '-DPX_CUMETAL_PACK_BOND_STRESS_SCALARS=1'
            self.assertEqual(definition in native[0], enabled, native[0])
            host_flags = (build / 'CMakeFiles/stress.dir/flags.make').read_text()
            self.assertEqual(definition in host_flags, enabled, host_flags)

    def test_native_objects_depend_on_private_inl_fragments(self):
        work = contained(self.root / 'out/inl-dependency-check', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated dependency inspection')
        fragments = [self.root / 'blast/source/sdk/extensions/stressgpu/detail/StressSolverLifetime.inl',
                     self.root / 'physx/source/solver/private/Scheduler.inl',
                     self.cumetal / 'runtime/api/cub/detail/select_flagged.cuh',
                     self.cumetal / 'runtime/api/detail/InlineRuntime.inl',
                     self.cumetal / 'runtime/api/cuda_runtime.h']
        for fragment in fragments:
            fragment.parent.mkdir(parents=True, exist_ok=True)
            fragment.write_text('// Private host/device fragment dependency fixture.\n')
        project = work / 'fixture'
        project.mkdir()
        (project / 'solver.cu').write_text('// Configure only; never compiled.\n')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(InlDependencies LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            'add_library(probe STATIC solver.cu)\npx_cumetal_objects(probe)\n')
        build = work / 'build'
        command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                   '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                   '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF']
        result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                env=env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        generated = (build / 'CMakeFiles/probe.dir/build.make').read_text().splitlines()
        for fragment in fragments:
            # Assert a prerequisite of the actual generated native .o, not just
            # a CMake glob mention or dependency of an unrelated host target.
            rules = [line for line in generated if '.o: ' + str(fragment) in line]
            self.assertEqual(len(rules), 1, str(fragment))
            self.assertIn('cumetal/probe/', rules[0])
        globs = (build / 'CMakeFiles/VerifyGlobs.cmake').read_text()
        self.assertIn('stressgpu/*.inl', globs)
        self.assertIn('source/*.inl', globs)
        # Header-only CUB kernels and inline runtime fragments must invalidate
        # the native object too; checking only ordinary .h files left old host
        # stubs/metallibs linked after a .cuh implementation changed.
        self.assertIn('runtime/api/*.cuh', globs)
        self.assertIn('runtime/api/*.inl', globs)

    def test_particle_inline_threshold_is_opt_in_scoped_and_recorded(self):
        for threshold in (None, 0, 500, 2147483647):
            options = [] if threshold is None else ['--cumetal-particle-inline-threshold', str(threshold)]
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD=' + ('' if threshold is None else str(threshold)),
                          [value for command in p['commands'] for value in command])
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['particle_inline_threshold'], threshold)
            self.assertEqual(hints['particle_inline_scope'], 'disabled' if threshold is None else
                             'physx/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu')
            self.assertIn('disabled' if threshold is None else 'experimental', hints['particle_inline_status'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_PARTICLE_INLINE_THRESHOLD', json.dumps(p['commands']))
        for backend, value in [('cuda', '0'), ('cuda', '500'), ('cumetal', '-1'),
                               ('cumetal', '2147483648'), ('cumetal', '1.5'), ('cumetal', 'invalid')]:
            with self.subTest(backend=backend, value=value), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', backend, '--cumetal-particle-inline-threshold', value)

    def test_particle_inline_threshold_cmake_rejects_bad_configuration(self):
        env, _ = local_environment(self.root / 'out/config-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for direct option validation')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        for backend, value in [('CUDA', '0'), ('CUDA', '500'), ('CUMETAL', '-1'),
                               ('CUMETAL', '2147483648'), ('CUMETAL', '999999999999999999999'),
                               ('CUMETAL', '1.5'), ('CUMETAL', '500;600'), ('CUMETAL', 'ON')]:
            command = [cmake, f'-DPX_GPU_BACKEND={backend}',
                       f'-DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD={value}', '-P', str(module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(backend=backend, value=value):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_PARTICLE_INLINE_THRESHOLD', result.stderr)
                self.assertIn('requires PX_GPU_BACKEND=CUMETAL' if backend == 'CUDA' else
                              'must be a decimal integer', result.stderr)

    def test_particle_inline_flag_only_reaches_canonical_translation_unit(self):
        work = contained(self.root / 'out/particle-config', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated-command inspection')
        source = self.root / 'physx/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu'
        duplicate = self.root / 'physx/source/other/cudaParticleSystem.cu'
        ordinary = self.root / 'physx/source/other/ordinary.cu'
        for path in (source, duplicate, ordinary):
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('// Configure-only fixture; no compilation or GPU execution.\n')
        project = work / 'fixture'
        project.mkdir()
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(ParticleFlag LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            f'add_library(particle STATIC "{source}" "{duplicate}" "{ordinary}")\n'
            'px_cumetal_objects(particle)\n')
        for threshold in (None, 0, 500):
            build = work / ('build-default' if threshold is None else f'build-{threshold}')
            command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                       '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                       '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF']
            if threshold is not None:
                command += [f'-DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD={threshold}']
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            generated = (build / 'CMakeFiles/particle.dir/build.make').read_text().splitlines()
            commands = [line for line in generated if ' -c --backend=cumetal-ir' in line]
            self.assertEqual(len(commands), 3)
            for path in (source, duplicate, ordinary):
                selected = [line for line in commands if str(path) in line]
                self.assertEqual(len(selected), 1)
                expected = threshold is not None and path == source
                self.assertEqual('--cuda-inline-threshold' in selected[0], expected, selected[0])
                if expected:
                    self.assertIn(f'--cuda-inline-threshold {threshold}', selected[0])

    def test_softbody_inline_threshold_is_opt_in_scoped_and_recorded(self):
        for threshold in (None, 0, 500, 2147483647):
            options = [] if threshold is None else ['--cumetal-softbody-inline-threshold', str(threshold)]
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD=' + ('' if threshold is None else str(threshold)),
                          [value for command in p['commands'] for value in command])
            hints = describe(args, p)['compiler_hints']
            self.assertEqual(hints['softbody_inline_threshold'], threshold)
            self.assertEqual(hints['softbody_inline_scope'], 'disabled' if threshold is None else
                             'physx/source/gpunarrowphase/src/CUDA/softbodySoftbodyMidPhase.cu')
            self.assertIn('disabled' if threshold is None else 'experimental', hints['softbody_inline_status'])
        p = plan(self.args('--backend', 'cuda'), self.root)
        self.assertNotIn('PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD', json.dumps(p['commands']))
        for backend, value in [('cuda', '0'), ('cuda', '500'), ('cumetal', '-1'),
                               ('cumetal', '2147483648'), ('cumetal', '1.5'), ('cumetal', 'invalid')]:
            with self.subTest(backend=backend, value=value), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', backend, '--cumetal-softbody-inline-threshold', value)

    def test_softbody_inline_threshold_cmake_rejects_bad_configuration(self):
        env, _ = local_environment(self.root / 'out/config-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for direct option validation')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        for backend, value in [('CUDA', '0'), ('CUDA', '500'), ('CUMETAL', '-1'),
                               ('CUMETAL', '2147483648'), ('CUMETAL', '999999999999999999999'),
                               ('CUMETAL', '1.5'), ('CUMETAL', '500;600'), ('CUMETAL', 'ON')]:
            command = [cmake, f'-DPX_GPU_BACKEND={backend}',
                       f'-DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD={value}', '-P', str(module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            with self.subTest(backend=backend, value=value):
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD', result.stderr)
                self.assertIn('requires PX_GPU_BACKEND=CUMETAL' if backend == 'CUDA' else
                              'must be a decimal integer', result.stderr)

    def test_softbody_inline_threshold_package_rejects_cuda(self):
        env, _ = local_environment(self.root / 'out/softbody-package-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for direct option validation')
        command = [cmake, '-DPX_GPU_BACKEND=CUDA', '-DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD=500',
                   '-P', str(ROOT / 'destruction/GpuBackend.cmake')]
        result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                cwd=self.root, env=env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD requires PX_GPU_BACKEND=CUMETAL', result.stderr)

    def test_softbody_inline_flag_only_reaches_canonical_translation_unit(self):
        work = contained(self.root / 'out/softbody-config', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake or not shutil.which('make', path=env.get('PATH')):
            self.skipTest('Installed cmake and make required for generated-command inspection')
        source = self.root / 'physx/source/gpunarrowphase/src/CUDA/softbodySoftbodyMidPhase.cu'
        duplicate = self.root / 'physx/source/other/softbodySoftbodyMidPhase.cu'
        ordinary = self.root / 'physx/source/other/ordinary.cu'
        particle = self.root / 'physx/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu'
        for path in (source, duplicate, ordinary, particle):
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('// Configure-only fixture; no compilation or GPU execution.\n')
        project = work / 'fixture'
        project.mkdir()
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/CuMetalObjects.cmake'
        (project / 'CMakeLists.txt').write_text(
            'cmake_minimum_required(VERSION 3.20)\nproject(SoftbodyFlag LANGUAGES CXX)\n'
            'set(PX_GPU_BACKEND CUMETAL)\n'
            f'set(PHYSX_ROOT_DIR "{self.root / "physx"}")\n'
            f'set(CUMETAL_ROOT_DIR "{self.cumetal}")\n'
            'set(CUMETALC_EXECUTABLE "${CMAKE_COMMAND}")\n'
            'set(CUMETAL_CUDA_CLANG "${CMAKE_CXX_COMPILER}")\n'
            'set(CUMETAL_LIBRARY "${CMAKE_COMMAND}")\n'
            f'include("{module}")\n'
            f'add_library(softbody STATIC "{source}" "{duplicate}" "{ordinary}" "{particle}")\n'
            'px_cumetal_objects(softbody)\n')
        for threshold in (None, 0, 500, None):
            build = work / 'build-reconfigured'
            command = [cmake, '-S', str(project), '-B', str(build), '-G', 'Unix Makefiles',
                       '-DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF', '-DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF',
                       '-DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF',
                       '-DPX_CUMETAL_PARTICLE_INLINE_THRESHOLD=200',
                       '-DPX_CUMETAL_SOFTBODY_INLINE_THRESHOLD=' + ('' if threshold is None else str(threshold))]
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            generated = (build / 'CMakeFiles/softbody.dir/build.make').read_text().splitlines()
            commands = [line for line in generated if ' -c --backend=cumetal-ir' in line]
            self.assertEqual(len(commands), 4)
            for path in (source, duplicate, ordinary, particle):
                selected = [line for line in commands if str(path) in line]
                self.assertEqual(len(selected), 1)
                expected = path == particle or (threshold is not None and path == source)
                self.assertEqual('--cuda-inline-threshold' in selected[0], expected, selected[0])
                if expected:
                    self.assertIn(f'--cuda-inline-threshold {200 if path == particle else threshold}', selected[0])

    def test_radix_sort_resources_record_backend_launch_contract(self):
        # Resource selection is a build fact, not numerical qualification.
        for backend, threads, shared_bytes in (('cumetal', 512, 19648), ('cuda', 1024, 39104)):
            with self.subTest(backend=backend):
                args = self.args('--backend', backend, '--stage', 'gpu')
                resources = describe(args, plan(args, self.root))['resource_options']
                self.assertEqual(resources['radix_sort_block_threads'], threads)
                self.assertEqual(resources['radix_sort_grid_blocks'], 32)
                self.assertEqual(resources['radix_sort_static_shared_bytes'], shared_bytes)

    def test_tgs_shared_capacity_backend_scope_and_manifest(self):
        for capacity in (None, 1, 512, 944):
            options = [] if capacity is None else ['--cumetal-tgs-whole-island-max-bodies', str(capacity)]
            args = self.args('--backend', 'cumetal', '--stage', 'gpu', *options)
            p = plan(args, self.root)
            selected = 512 if capacity is None else capacity
            self.assertIn(f'-DPX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES={selected}', json.dumps(p['commands']))
            self.assertEqual(describe(args, p)['resource_options']['tgs_whole_island_max_bodies'], selected)
            self.assertEqual(describe(args, p)['resource_options']['tgs_whole_island_shared_array_bytes'], 48 * selected)
        args = self.args('--backend', 'cuda', '--stage', 'gpu')
        p = plan(args, self.root)
        self.assertNotIn('PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES', json.dumps(p['commands']))
        self.assertEqual(describe(args, p)['resource_options']['tgs_whole_island_max_bodies'], 944)
        for backend, capacity in [('cumetal', '-1'), ('cumetal', '0'), ('cumetal', '945'),
                                  ('cumetal', '1.5'), ('cumetal', 'invalid'), ('cuda', '512')]:
            with self.subTest(backend=backend, capacity=capacity), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', backend, '--cumetal-tgs-whole-island-max-bodies', capacity)

    def test_tgs_shared_capacity_cmake_rejects_invalid_values(self):
        env, _ = local_environment(self.root / 'out/config-check', self.roots)
        cmake = shutil.which('cmake', path=env.get('PATH'))
        if not cmake:
            self.skipTest('Installed cmake required for direct CMake option validation')
        module = ROOT / 'physx/source/compiler/cmakegpu/mac/PhysXSolverGpu.cmake'
        for capacity in (None, '1', '512', '944', '0', '-1', '945', '1.5', 'invalid', '512;944'):
            command = [cmake]
            if capacity is not None:
                command += [f'-DPX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES={capacity}']
            command += ['-P', str(module)]
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, capture_output=True, text=True)
            valid = capacity in (None, '1', '512', '944')
            with self.subTest(capacity=capacity):
                self.assertEqual(result.returncode == 0, valid, result.stdout + result.stderr)
                if not valid:
                    self.assertIn('must be an integer in [1, 944]', result.stderr)

    def test_gpu_module_c_linkage_is_scoped_to_apple_cumetal(self):
        import platform
        import re
        if platform.system() != 'Darwin':
            self.skipTest('Apple host required for the default macOS ABI control')
        work = contained(self.root / 'out/gpu-export-linkage', self.roots)
        env, paths = local_environment(work, self.roots)
        for path in paths.values():
            (path.parent if path.name.endswith('.profraw') else path).mkdir(parents=True, exist_ok=True)
        compiler = shutil.which('clang++', path=env.get('PATH'))
        if not compiler:
            self.skipTest('Installed clang++ required for emitted GPU export linkage')
        developer = Path(env.get('DEVELOPER_DIR', '/var/db/xcode_select_link')).resolve()
        if developer.suffix == '.app':
            developer /= 'Contents/Developer'
        sdk = Path(env.get('SDKROOT', developer / 'Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk'))
        if not sdk.is_dir():
            self.skipTest('Installed macOS SDK required; no toolchain components are installed by this test')
        definitions = r"""
#include "PxPhysXGpu.h"
physx::PxPhysXGpu* PxCreatePhysXGpu() { return nullptr; }
physx::PxCudaContextManager* PxCreateCudaContextManager(physx::PxFoundation&,
    const physx::PxCudaContextManagerDesc&, physx::PxProfilerCallback*, bool) { return nullptr; }
void PxSetPhysXGpuProfilerCallback(physx::PxProfilerCallback*) {}
void PxSetPhysXGpuFoundationInstance(physx::PxFoundation&) {}
int PxGetSuggestedCudaDeviceOrdinal(physx::PxErrorCallback&) { return 0; }
void PxGpuCudaRegisterFunction(int, const char*) {}
void** PxGpuCudaRegisterFatBinary(void*) { return nullptr; }
#if PX_SUPPORT_GPU_PHYSX
physx::PxKernelIndex* PxGpuGetCudaFunctionTable() { return nullptr; }
physx::PxU32 PxGpuGetCudaFunctionTableSize() { return 0; }
void** PxGpuGetCudaModuleTable() { return nullptr; }
physx::PxU32 PxGpuGetCudaModuleTableSize() { return 0; }
physx::PxPhysicsGpu* PxGpuCreatePhysicsGpu() { return nullptr; }
#endif
// A leaked extern-C region would accidentally change unrelated declarations.
int PxOrdinarySdkLinkageSentinel() { return 0; }
"""
        exports = ('PxCreatePhysXGpu', 'PxCreateCudaContextManager',
                   'PxSetPhysXGpuProfilerCallback', 'PxSetPhysXGpuFoundationInstance',
                   'PxGetSuggestedCudaDeviceOrdinal', 'PxGpuCudaRegisterFunction',
                   'PxGpuCudaRegisterFatBinary')
        gpu_exports = ('PxGpuGetCudaFunctionTable', 'PxGpuGetCudaFunctionTableSize',
                       'PxGpuGetCudaModuleTable', 'PxGpuGetCudaModuleTableSize',
                       'PxGpuCreatePhysicsGpu')
        # The latter controls alter only the already-loaded platform/linkage
        # macros. They check wrapper scope and the existing PX_C_EXPORT contract,
        # not compilation or execution on a Linux CUDA machine.
        cases = (
            ('apple-cumetal', ['-DPX_CUMETAL=1'], '', True, True),
            ('apple-default', [], '', False, False),
            ('nonapple-guard', ['-DPX_CUMETAL=1'], '#undef PX_OSX\n#define PX_OSX 0\n', False, False),
            ('cuda-export-contract', [], '#undef PX_OSX\n#define PX_OSX 0\n'
             '#undef PX_C_EXPORT\n#define PX_C_EXPORT extern "C"\n', True, False),
        )
        header = ROOT / 'physx/source/physxgpu/include/PxPhysXGpu.h'
        # Load its dependencies using the real host configuration before the
        # synthetic guard controls, so platform math intrinsics are untouched.
        dependencies = '\n'.join(re.findall(r'^#include[^\n]+', header.read_text(), re.MULTILINE)) + '\n'
        for label, flags, prelude, c_linkage, gpu_enabled in cases:
            source = dependencies + prelude + definitions
            command = [compiler, '-std=c++14', '-DNDEBUG', '-DPX_PHYSX_STATIC_LIB',
                       '-isysroot', str(sdk), '-S', '-emit-llvm', '-O0', '-x', 'c++', '-I', str(ROOT / 'physx/include'),
                       '-I', str(ROOT / 'physx/source/physxgpu/include'), *flags, '-o', '-', '-']
            result = subprocess.run(confined_command(command, self.roots), cwd=self.root,
                                    env=env, input=source, capture_output=True, text=True)
            with self.subTest(configuration=label):
                self.assertEqual(result.returncode, 0, result.stderr)
                symbols = re.findall(r'^define .*?@([^ (]+)\(', result.stdout, re.MULTILINE)
                for name in exports + (gpu_exports if gpu_enabled else ()):
                    self.assertEqual(name in symbols, c_linkage, (label, name, symbols))
                    if not c_linkage:
                        self.assertTrue(any(symbol.startswith('_Z') and name in symbol for symbol in symbols),
                                        (label, name, symbols))
                self.assertNotIn('PxOrdinarySdkLinkageSentinel', symbols)
                self.assertTrue(any(symbol.startswith('_Z') and 'PxOrdinarySdkLinkageSentinel' in symbol
                                    for symbol in symbols), symbols)

    def test_tgs_common_capacity_macro_validates_bounds(self):
        env, _ = local_environment(self.root / 'out/config-check', self.roots)
        compiler = shutil.which('clang++', path=env.get('PATH'))
        if not compiler:
            self.skipTest('Installed clang++ required for common host/device macro validation')
        include = ROOT / 'physx/source/gpusolver/include'
        for capacity in (None, '1', '512', '944', '0', '-1', '945', 'invalid'):
            command = [compiler, '-std=c++14', '-fsyntax-only', '-x', 'c++', '-I', str(include)]
            if capacity is not None:
                command += [f'-DPXG_TGS_WHOLE_ISLAND_MAX_BODIES={capacity}']
            command += ['-']
            expected = 944 if capacity is None else int(capacity) if capacity.isdigit() else 0
            source = '#include "PxgDynamicsConfiguration.h"\n' + f'static_assert(PXG_TGS_WHOLE_ISLAND_MAX_BODIES == {expected}, "capacity");\n'
            result = subprocess.run(confined_command(command, self.roots, readonly=True),
                                    cwd=self.root, env=env, input=source, capture_output=True, text=True)
            valid = capacity in (None, '1', '512', '944')
            with self.subTest(capacity=capacity):
                self.assertEqual(result.returncode == 0, valid, result.stdout + result.stderr)
                if not valid:
                    self.assertIn('must be an integer in [1, 944]', result.stderr)

    def test_optional_convex_core_scope_is_explicit(self):
        for enabled in (False, True):
            args = self.args('--backend', 'cumetal', *(['--cumetal-convex-core'] if enabled else []))
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_ENABLE_CONVEX_CORE=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            self.assertEqual(describe(args, p)['optional_features']['convex_core'], enabled)
        args = self.args('--backend', 'cuda')
        p = plan(args, self.root)
        self.assertNotIn('PX_CUMETAL_ENABLE_CONVEX_CORE', json.dumps(p['commands']))
        self.assertTrue(describe(args, p)['optional_features']['convex_core'])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-convex-core')

    def test_optional_gpu_sdf_builder_scope(self):
        for enabled in (False, True):
            args = self.args('--backend', 'cumetal', *(['--cumetal-gpu-sdf-builder'] if enabled else []))
            p = plan(args, self.root)
            self.assertIn('-DPX_CUMETAL_ENABLE_GPU_SDF_BUILDER=' + ('ON' if enabled else 'OFF'), json.dumps(p['commands']))
            self.assertEqual(describe(args, p)['optional_features']['gpu_sdf_builder'], enabled)
        args = self.args('--backend', 'cuda')
        p = plan(args, self.root)
        self.assertNotIn('PX_CUMETAL_ENABLE_GPU_SDF_BUILDER', json.dumps(p['commands']))
        self.assertTrue(describe(args, p)['optional_features']['gpu_sdf_builder'])
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cuda', '--cumetal-gpu-sdf-builder')

    def test_scene_build_reuses_gpu_and_only_named_target(self):
        args = self.args('--backend', 'cumetal', '--stage', 'scene')
        p = plan(args, self.root)
        self.assertEqual(args.target, ['native_standard_scene_test'])
        self.assertEqual(len(p['commands']), 2)
        self.assertEqual(p['work'], self.root / 'out/build/macos-cumetal/release/scene')
        self.assertEqual(p['engine'], self.root / 'out/build/macos-cumetal/release/gpu')
        self.assertIn(str(p['work'] / 'destruction'), p['commands'][0])
        self.assertIn('-DPHYSX_LIB_DIR=' + str(p['artifacts'] / 'bin/mac.arm64/release'), p['commands'][0])
        self.assertEqual(p['commands'][1][3:5], ['--target', 'native_standard_scene_test'])
        self.assertFalse(any('ctest' in c or '--install' in c for c in p['commands']))
        self.assertEqual(p['environment']['CUMETAL_USE_METAL_DEVICE_ADDRESSES'], '1')
        self.assertFalse(p['work'].exists())
        self.assertFalse(describe(args, p)['sdk_acceptance'])
        self.assertTrue(all(path.is_relative_to(p['work']) for path in p['caches'].values()))

    def test_cumetal_sdk_packages_the_gpu_engine_without_relinking_it(self):
        args = self.args('--backend', 'cumetal', '--stage', 'sdk', '--install', '--cumetal-rigid-demo')
        p = plan(args, self.root)
        engine = self.root / 'out/build/macos-cumetal/release/gpu'
        self.assertEqual(p['engine'], engine)
        # Host archives only: the GPU module and libcumetal are never rebuilt.
        self.assertIn('PhysXCharacterKinematic', p['commands'][0])
        self.assertNotIn('PhysXGpu', p['commands'][0])
        self.assertFalse(any(str(self.cumetal) in c[2] for c in p['commands'] if c[:2] == ['cmake', '--build']))
        self.assertIn('-DPHYSX_LIB_DIR=' + str(engine / 'artifacts/bin/mac.arm64/release'), p['commands'][1])
        self.assertEqual(p['commands'][-2][:2], ['cmake', '--install'])
        self.assertTrue(p['commands'][-1][2].endswith('relocate-macos-sdk.py'))
        relocate = p['commands'][-1]
        self.assertIn(str(self.root / 'out/sdk-artifacts.json'), relocate)
        self.assertEqual(relocate[relocate.index('--warm') + 1],
                         str(self.cumetal / 'out/build/macos-cumetal/release/cumetal-warm'))
        self.assertIn(self.cumetal / 'out/build/macos-cumetal/release/cumetal-warm', p['required_scene_inputs'])
        self.assertTrue(any('Missing scene prerequisite' in x for x in scene_prerequisites(p)))
        self.assertEqual(describe(args, p)['feature_profile'], 'rigid-demo-experimental')
        self.assertFalse(p['work'].exists())
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--backend', 'cumetal', '--stage', 'sdk', '--test', '--cumetal-rigid-demo')

    def test_scene_test_selection_is_explicit_and_exact(self):
        args = self.args('--backend', 'cumetal', '--stage', 'scene', '--target', 'native_standard_scene_test', '--test')
        p = plan(args, self.root)
        command = p['commands'][-1]
        self.assertEqual(command[0], 'ctest')
        self.assertIn('--no-tests=error', command)
        self.assertEqual(command[-2:], ['-R', '^physx_native_standard_awake$'])
        self.assertEqual(describe(args, p)['scene_timeout_seconds'], 600)
        self.assertEqual(describe(args, p)['scene_test'], 'physx_native_standard_awake')

    def test_scene_rejects_install_and_wrong_target_scope(self):
        for options in (['--stage', 'scene', '--install'],
                        ['--stage', 'scene', '--target', 'PhysX'],
                        ['--stage', 'gpu', '--target', 'native_standard_scene_test'],
                        ['--stage', 'sdk', '--target', 'native_standard_scene_test']):
            with self.subTest(options=options), contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', 'cumetal', *options)

    def test_scene_missing_inputs_and_cache_mismatch_are_read_only(self):
        args = self.args('--backend', 'cumetal', '--stage', 'scene')
        p = plan(args, self.root)
        self.assertTrue(any('Missing scene prerequisite' in x for x in scene_prerequisites(p)))
        self.assertFalse(p['work'].exists())
        for path in p['required_scene_inputs']:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('fixture')
        cache = p['engine_cache']
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(''.join(f'\n// CMake cache entry\n{key}:STRING={value}\n' for key, value in p['expected_engine_cache'].items()))
        self.assertEqual(scene_prerequisites(p), [])
        cache.write_text(cache.read_text().replace('PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES:STRING=512',
                                                 'PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES:STRING=944'))
        self.assertTrue(any('configuration mismatch: PX_CUMETAL_TGS' in x for x in scene_prerequisites(p)))
        self.assertFalse(p['work'].exists())

    def test_scene_engine_symlink_escape_is_rejected_before_writes(self):
        engine = self.root / 'out/build/macos-cumetal/release/gpu'
        engine.parent.mkdir(parents=True)
        engine.symlink_to('/tmp/scene-engine-escape')
        with self.assertRaises(ValueError):
            plan(self.args('--backend', 'cumetal', '--stage', 'scene'), self.root)
        self.assertFalse((engine.parent / 'scene').exists())

    def test_wall_capture_build_is_explicit_and_never_runs_capture(self):
        args = self.args('--backend', 'cumetal', '--stage', 'scene', '--target', 'native_wall_capture', '--cumetal-rigid-demo')
        p = plan(args, self.root)
        command = p['commands'][-1]
        self.assertIn('native_wall_capture', command)
        self.assertEqual(p['scene_executable'].name, 'native_wall_capture')
        self.assertFalse(describe(args, p)['sdk_acceptance'])
        self.assertNotIn('ctest', json.dumps(p['commands']))
        self.assertNotIn('--install', json.dumps(p['commands']))
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--stage', 'scene', '--target', 'native_wall_capture', '--test')
        with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
            self.args('--stage', 'gpu', '--target', 'native_wall_capture')

    def test_scene_cuda_defaults_and_sdk_guard_are_preserved(self):
        args = self.args('--backend', 'cuda', '--stage', 'scene', '--test')
        p = plan(args, self.root)
        self.assertIn('-DCMAKE_CUDA_ARCHITECTURES=89-real', p['commands'][0])
        self.assertEqual(describe(args, p)['scene_timeout_seconds'], 120)
        args = self.args('--backend', 'cumetal', '--stage', 'sdk')
        p = plan(args, self.root)
        with patch('destruction_build.shutil.which', return_value=None), \
             patch('destruction_build.subprocess.run') as run:
            run.return_value.returncode = 0
            run.return_value.stdout = '/fixture/metal'
            issues, _ = preflight(args, p)
        self.assertTrue(any('SDK is not implemented yet' in x for x in issues))
        self.assertFalse(p['work'].exists())

    def test_scene_output_audit_follows_local_includes_only(self):
        demo = self.root / 'demos/blast-stress-demo'
        (demo / 'tests').mkdir(parents=True)
        (demo / 'physx_scene.cpp').write_text('// no output\n')
        (demo / 'tests/native_standard_scene_test.cpp').write_text('#include "nested.h"\n')
        nested = demo / 'tests/nested.h'
        nested.write_text('fopen("/tmp/unsafe-scene", "w");\n')
        (demo / 'tests/unrelated.cpp').write_text('fopen("/tmp/unrelated", "w");\n')
        paths = scene_source_paths(self.root)
        self.assertIn(nested, paths)
        self.assertNotIn(demo / 'tests/unrelated.cpp', paths)
        issues = audit_test_sources(self.root, paths)
        self.assertEqual(len(issues), 1)
        self.assertIn('nested.h', issues[0])

    def test_scene_actual_sources_have_no_hardcoded_external_output(self):
        paths = scene_source_paths(ROOT)
        self.assertGreater(len(paths), 2)
        self.assertEqual(audit_test_sources(ROOT, paths), [])
        cmake = (ROOT / 'demos/blast-stress-demo/CMakeLists.txt').read_text()
        self.assertIn('if(PX_GPU_BACKEND STREQUAL "CUMETAL")\n'
                      '        # A cold native Metal pipeline set', cmake)
        self.assertIn('set_tests_properties(physx_native_standard_awake PROPERTIES TIMEOUT 600)', cmake)

    def test_scene_dry_run_never_probes_or_writes(self):
        destination = ROOT / 'out/tests/scene-dry-run-must-not-create'
        self.assertFalse(destination.exists())
        with patch('destruction_build.preflight', side_effect=AssertionError('probe')), contextlib.redirect_stdout(io.StringIO()):
            result = main(['--backend', 'cumetal', '--stage', 'scene', '--dry-run', '--test',
                           '--build-root', str(destination)])
        self.assertEqual(result, 0)
        self.assertFalse(destination.exists())

    def test_host_and_sdk_trees_are_isolated(self):
        host = plan(self.args('--stage', 'host'), self.root)
        sdk = plan(self.args('--stage', 'sdk'), self.root)
        self.assertNotEqual(host['work'], sdk['work'])

    def test_gpu_stage_uses_native_objects_without_cuda_discovery(self):
        p = plan(self.args('--backend', 'cumetal', '--stage', 'gpu', '--target', 'PhysXCudaContextManager'), self.root)
        text = json.dumps(p['commands'])
        self.assertIn('-DPX_GENERATE_GPU_PROJECTS=TRUE', text)
        self.assertIn('-DPX_CUMETAL_HOST_ONLY=OFF', text)
        self.assertIn('-DPX_CUMETAL_INLINE_REF_GJK_EPA=ON', text)
        self.assertNotIn('CMAKE_CUDA_COMPILER', text)
        self.assertNotIn('--install', text)
        self.assertNotIn('ctest', text)
        self.assertEqual(p['commands'][-1][4], 'PhysXCudaContextManager')
        self.assertEqual(p['work'].name, 'gpu')
        self.assertEqual(p['environment']['CUMETAL_USE_METAL_DEVICE_ADDRESSES'], '1')
        host = plan(self.args('--backend', 'cumetal', '--stage', 'host'), self.root)
        self.assertNotIn('CUMETAL_USE_METAL_DEVICE_ADDRESSES', host['environment'])

    def test_partial_gpu_build_cannot_install_or_claim_tests(self):
        for options in [('--target', 'install'), ('--target', 'PhysXGpu', '--test'), ('--install',)]:
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                self.args('--backend', 'cumetal', '--stage', 'gpu', *options)

    def test_gpu_component_test_is_explicit_and_narrow(self):
        for target, name in [('PhysXCuMetalContactGraphTest', 'physx_cumetal_contact_graph'),
                             ('PhysXCuMetalHierarchyPackingTest', 'physx_cumetal_hierarchy_packing'),
                             ('PhysXCuMetalParticleTailsTest', 'physx_cumetal_particle_tails'),
                             ('PhysXCuMetalTgsContactsTest', 'physx_cumetal_tgs_contacts'),
                             ('PhysXCuMetalNativePairsTest', 'physx_cumetal_native_pairs'),
                             ('PhysXCuMetalNativeAggregatesTest', 'physx_cumetal_native_aggregates'),
                             ('PhysXCuMetalReferenceGjkTest', 'physx_cumetal_reference_gjk')]:
            options = ('--backend', 'cumetal', '--stage', 'gpu', '--target', target)
            build = plan(self.args(*options), self.root)
            self.assertNotIn('ctest', json.dumps(build['commands']))
            tested = plan(self.args(*options, '--test'), self.root)
            self.assertEqual(tested['commands'][-1][-1],
                             f'^({name}|{name}_batched)$')
            self.assertNotIn('--install', json.dumps(tested['commands']))
            self.assertIn('--verbose', tested['commands'][-1])

    def test_gpu_component_test_rejects_mixed_scope_and_wrong_backend(self):
        for target in ['PhysXCuMetalContactGraphTest', 'PhysXCuMetalHierarchyPackingTest', 'PhysXCuMetalParticleTailsTest', 'PhysXCuMetalTgsContactsTest', 'PhysXCuMetalNativePairsTest', 'PhysXCuMetalNativeAggregatesTest', 'PhysXCuMetalReferenceGjkTest']:
            for options in [('--backend', 'cuda', '--target', target),
                            ('--backend', 'cumetal', '--target', target,
                             '--target', 'PhysXGpu', '--test')]:
                with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    self.args('--stage', 'gpu', *options)

    def test_compiler_stage_does_not_claim_physx_sdk(self):
        p = plan(self.args('--backend', 'cumetal', '--stage', 'compiler', '--install', '--test'), self.root)
        text = json.dumps(p['commands'])
        self.assertNotIn('PhysXGpu', text)
        self.assertIn('run_staged_package_consumer.py', text)
        install = next(command for command in p['commands'] if '--install' in command)
        self.assertTrue(Path(install[-1]).is_relative_to(self.cumetal / 'out/install'))

    def test_old_shim_alias_rejected(self):
        directory = self.cumetal / 'out/build/macos-cumetal/release'
        directory.mkdir(parents=True)
        (directory / 'libcuda.dylib').symlink_to('libcumetal.dylib')
        with self.assertRaisesRegex(ValueError, 'Binary-shim alias'):
            plan(self.args('--backend', 'cumetal'), self.root)

    def test_environment_is_local_and_process_only(self):
        inherited = {'PATH': '/usr/bin', 'HOME': '/Users/example', 'DESTDIR': '/tmp',
                     'CUMETAL_SYNC_EACH_LAUNCH': '1', 'CXXFLAGS': '-save-temps'}
        env, paths = local_environment(self.root / 'out/build', self.roots, inherited)
        self.assertEqual(inherited['DESTDIR'], '/tmp')
        self.assertEqual(env['HOME'], inherited['HOME'])
        self.assertNotIn('DESTDIR', env)
        self.assertNotIn('CUMETAL_SYNC_EACH_LAUNCH', env)
        self.assertNotIn('CXXFLAGS', env)
        for path in paths.values():
            self.assertTrue(path.is_relative_to(self.root))

    def test_dry_run_never_probes_or_writes(self):
        destination = ROOT / 'out/tests/dry-run-must-not-create'
        self.assertFalse(destination.exists())
        with patch('destruction_build.preflight', side_effect=AssertionError('probe')), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(main(['--dry-run', '--preset', 'linux-cuda', '--build-root', str(destination)]), 0)
        self.assertFalse(destination.exists())

    def test_missing_ninja_reports_without_writes(self):
        args = self.args('--preset', 'linux-cuda', '--stage', 'host')
        p = plan(args, self.root)
        with patch('destruction_build.shutil.which', return_value=None), patch('destruction_build.platform.system', return_value='Linux'):
            issues, _ = preflight(args, p)
        self.assertTrue(any('Missing tool: ninja' in issue for issue in issues))
        self.assertFalse(p['work'].exists())

    def test_test_audit_detects_hardcoded_external_path(self):
        tests = self.root / 'destruction'
        tests.mkdir()
        (tests / 'unsafe.cpp').write_text('fopen("/tmp/unsafe", "w");\n')
        self.assertEqual(len(audit_test_sources(self.root)), 1)
        (tests / 'unsafe.cpp').unlink()
        (tests / 'safe.sh').write_text('out="${TMPDIR:-/tmp}/test"\n')
        self.assertEqual(audit_test_sources(self.root), [])


if __name__ == '__main__':
    unittest.main()
