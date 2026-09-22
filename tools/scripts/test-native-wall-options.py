#!/usr/bin/env python3
"""Exercise actual wall CLI validation without creating a scene or launching kernels.

Usage: python3 tools/scripts/test-native-wall-options.py --executable PATH \
    --work-dir out/tests/native-wall-options
All child processes use the repository confinement and local cache environment.
"""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
from destruction_build_paths import audit_tree, contained, confined_command, local_environment


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--executable', required=True, type=Path)
    parser.add_argument('--work-dir', required=True, type=Path,
                        help='temporary-directory parent inside PhysX or sibling cuda-metal')
    args = parser.parse_args(argv)
    physx = Path(__file__).resolve().parents[2]
    roots = (physx, physx.parent / 'cuda-metal')
    executable = contained(args.executable, roots)
    if not executable.is_file() or not os.access(executable, os.X_OK):
        raise ValueError(f'not an executable file: {executable}')
    base = contained(args.work_dir, roots)
    audit_tree(base, roots)
    base.mkdir(parents=True, exist_ok=True)
    cases = [
        ('--foundation-strength', '0', 'foundation strength must be finite and positive'),
        ('--foundation-strength', '-1', 'foundation strength must be finite and positive'),
        ('--foundation-strength', 'nan', 'invalid real option'),
        ('--foundation-strength', 'inf', 'invalid real option'),
        ('--foundation-strength', '3e38', 'foundation material limits must remain finite and positive'),
        ('--record-bond-stress', '2', 'record-bond-stress must be 0 or 1'),
        ('--record-bond-stress', '-1', 'invalid integer option'),
        ('--audit-gpu-state', '2', 'audit-gpu-state must be 0 or 1'),
        ('--audit-gpu-state', '-1', 'invalid integer option'),
    ]
    with tempfile.TemporaryDirectory(prefix='cli-', dir=base) as name:
        work = contained(name, roots)
        env, locations = local_environment(work, roots)
        for key, path in locations.items():
            (path.parent if key == 'LLVM_PROFILE_FILE' else path).mkdir(parents=True, exist_ok=True)

        def invoke(arguments):
            return subprocess.run(confined_command([str(executable), *arguments], roots),
                                  cwd=work, env=env, text=True, capture_output=True, timeout=30)

        help_result = invoke(['--help'])
        if help_result.returncode != 0:
            raise AssertionError(f'help failed: {help_result.stdout}{help_result.stderr}')
        for flag in ('--foundation-strength 1', '--record-bond-stress 0', '--audit-gpu-state 0'):
            if flag not in help_result.stdout:
                raise AssertionError(f'help missing {flag}')
        print('PASS help advertises defaults')
        for index, (flag, value, expected) in enumerate(cases):
            output = contained(work / f'case-{index}' / 'must-not-exist.json', roots)
            result = invoke(['--output', str(output), flag, value])
            if result.returncode != 1 or expected not in result.stderr:
                raise AssertionError(f'{flag} {value}: exit={result.returncode}; '
                                     f'stdout={result.stdout!r}; stderr={result.stderr!r}')
            if output.exists() or output.is_symlink() or output.parent.exists():
                raise AssertionError(f'{flag} {value} created output before validation')
            print(f'PASS {flag} {value}: rejected before output creation')
    print(f'PASS {len(cases)+1} CPU CLI checks; no valid scene requested')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (AssertionError, ValueError, OSError, subprocess.TimeoutExpired) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        sys.exit(1)
