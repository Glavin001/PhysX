#!/usr/bin/env python3
"""Import the approved destruction sources without replacing upstream changes.

Source checkouts are read-only. Conflicts are retained under the destination's
provenance directory and require resolution before compilation.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile


def git(root, *args, env=None):
    return subprocess.check_output(['git', '-C', str(root), *args], env=env)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    parser.add_argument('--game', type=Path, required=True)
    args = parser.parse_args()
    dest = Path(__file__).resolve().parents[2]
    source = args.source.resolve()
    game = args.game.resolve()
    report = dest / 'docs/destruction/provenance'
    if (report / 'import.json').exists():
        parser.error('Import already recorded; refusing to overwrite implementation work.')
    report.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, GIT_ALTERNATE_OBJECT_DIRECTORIES=str(source / '.git/objects'))
    source_head = git(source, 'rev-parse', 'HEAD').decode().strip()
    upstream = git(dest, 'rev-parse', 'HEAD').decode().strip()
    common = git(dest, 'merge-base', upstream, source_head, env=env).decode().strip()
    roots = ['blast', 'demos/blast-stress-demo', 'scripts', 'tools/scripts', 'patches/physx',
             'package.json', 'package-lock.json']
    changed = set(git(source, 'diff', '--name-only', '-z', common, '--', *roots).decode().split('\0'))
    changed.update(git(source, 'ls-files', '--others', '--exclude-standard', '-z', '--', *roots).decode().split('\0'))
    manifest = {'upstream': upstream, 'common_ancestor': common,
                'source': {'path': str(source), 'head': source_head,
                           'status': git(source, 'status', '--porcelain=v1').decode()},
                'game': {'path': str(game), 'head': git(game, 'rev-parse', 'HEAD').decode().strip(),
                         'status': git(game, 'status', '--porcelain=v1').decode()},
                'files': [], 'conflicts': []}
    for name in sorted(changed - {''}):
        src, out = source / name, dest / name
        if any(part in {'node_modules', 'target', '.git', '__pycache__'} or part.startswith('build-') for part in src.parts):
            continue
        if src.is_symlink():
            raise RuntimeError(f'Explicit review required for symlink: {name}')
        old = subprocess.run(['git', '-C', str(source), 'show', f'{common}:{name}'], capture_output=True)
        base = old.stdout if old.returncode == 0 else None
        data = src.read_bytes() if src.is_file() else None
        current = out.read_bytes() if out.is_file() else None
        entry = {'source': name, 'destination': name,
                 'source_sha256': digest(data) if data is not None else None,
                 'upstream_sha256': digest(current) if current is not None else None}
        if data == current:
            entry['action'] = 'identical'
        elif current == base or current is None:
            if data is None:
                if out.exists():
                    out.unlink()
                entry['action'] = 'delete'
            else:
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(data)
                out.chmod(src.stat().st_mode & 0o777)
                entry['action'] = 'import'
        elif data == base:
            entry['action'] = 'preserve-upstream'
        else:
            if data is None or base is None or b'\0' in data + base + current:
                merged, code = current, 1
            else:
                with tempfile.TemporaryDirectory() as tmp:
                    paths = [Path(tmp) / x for x in ('upstream', 'base', 'destruction')]
                    for p, payload in zip(paths, (current, base, data)):
                        p.write_bytes(payload)
                    result = subprocess.run(['git', 'merge-file', '-p', *map(str, paths)], capture_output=True)
                    merged, code = result.stdout, result.returncode
            if code != 0:
                conflict = report / 'conflicts' / name
                conflict.parent.mkdir(parents=True, exist_ok=True)
                conflict.with_name(conflict.name + '.source').write_bytes(data or b'')
                conflict.with_name(conflict.name + '.base').write_bytes(base or b'')
                conflict.with_name(conflict.name + '.merge').write_bytes(merged or b'')
                manifest['conflicts'].append(name)
                entry['action'] = 'conflict-upstream-preserved'
            else:
                out.write_bytes(merged)
                entry['action'] = 'merge'
        manifest['files'].append(entry)
    # Game physics fixtures/contracts are independent inputs, not game runtime.
    game_roots = ['destruction/assets/scenes', 'destruction/tests', 'physx-bridge/tests',
                  'docs/simulation-fidelity-contract.md', 'docs/rotation-fidelity-2026-09-05.md',
                  'docs/direct-gpu-city-qualification-2026-09-05.md']
    names = set(git(game, 'ls-files', '-z', '--', *game_roots).decode().split('\0'))
    names.update(git(game, 'ls-files', '--others', '--exclude-standard', '-z', '--', *game_roots).decode().split('\0'))
    for name in sorted(names - {''}):
        src = game / name
        if not src.is_file() or src.is_symlink():
            continue
        data = src.read_bytes()
        target = 'tests/destruction/game-reference/' + name
        out = dest / target
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_bytes(data)
        manifest['files'].append({'game_source': name, 'destination': target,
                                  'source_sha256': digest(data), 'action': 'reference-fixture'})
    (report / 'import.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps({'files': len(manifest['files']), 'conflicts': manifest['conflicts'],
                      'upstream': upstream, 'common': common}, indent=2))


if __name__ == '__main__':
    main()
