#!/usr/bin/env python3
"""Inventory audit scope; static declarations are NOT executed test counts."""
import argparse
import csv
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
SOURCE_EXT = {'.cpp', '.cu', '.cuh', '.h', '.inl', '.py', '.rs', '.ts', '.js', '.sh'}
TREES = {
    'demos/blast-stress-demo/tests': 'demo-native-and-adapter',
    'physx/source/gpudestruction/tests': 'native-runtime',
    'blast/source/sdk/extensions/stressgpu/test': 'stress-extension-and-prototype',
    'blast/blast-stress-solver-rs/tests': 'rust-adapters',
    'blast/blast-stress-demo-rs/tests': 'rust-demo',
    'blast/blast-stress-solver/src/tests': 'typescript-wasm-rapier',
    'tests/destruction': 'consumer-diagnostic-and-archived-reference',
}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--ctest-json', type=Path, required=True)
    args = parser.parse_args()
    paths = {}
    for folder, family in TREES.items():
        for path in (ROOT / folder).rglob('*'):
            if path.is_file() and path.suffix in SOURCE_EXT:
                paths[path] = family
    for path in (ROOT / 'blast/js_stress_example').rglob('*'):
        if path.is_file() and path.suffix in SOURCE_EXT and 'node_modules' not in path.parts:
            if re.search(r'\.(spec|test)\.[jt]s$', path.name):
                paths[path] = 'javascript-bridge-browser'
    for path in (ROOT / 'tools/scripts').glob('*.py'):
        if path.name.startswith(('test-', 'test_', 'verify-native-')):
            paths[path] = 'python-checker-accounting'
    for folder in ('destruction-snapshot', 'destruction-load-capture'):
        for path in (ROOT / 'tools/diagnostics' / folder).iterdir():
            if path.suffix in SOURCE_EXT and (path.name.startswith(('test-', 'check_', 'check-', 'compare-'))
                    or path.name in ('serialization-probe.cpp', 'file-replay.inl', 'file-replay-observation.inl')):
                paths[path] = 'snapshot-and-load-checker'
    for folder in ('blast/blast-stress-solver-rs/src', 'blast/blast-stress-demo-rs/src'):
        for path in (ROOT / folder).rglob('*.rs'):
            if '#[test]' in path.read_text():
                paths[path] = 'rust-embedded-tests'
    rows = []
    snippets = []
    for path, family in sorted(paths.items()):
        raw = path.read_bytes()
        content = raw.decode(errors='replace')
        selected = [(n, line.strip()) for n, line in enumerate(content.splitlines(), 1)
                    if re.search(r'\b(?:require|assert|assert_eq|assert_ne|expect|CHECK)\b|#\[test\]|\b(?:it|test)(?:\.skip|\.todo)?\(', line)]
        rows.append(dict(path=str(path.relative_to(ROOT)), family=family,
                         sha256=hashlib.sha256(raw).hexdigest(), lines=len(content.splitlines()),
                         assertion_or_declaration_lines=len(selected),
                         rust_file_cfg='; '.join(re.findall(r'^#!\[cfg\((.*)\)\]', content, re.M)),
                         role='inventory; family review, not an execution receipt'))
        snippets.append(dict(path=str(path.relative_to(ROOT)), lines=selected))
    with (HERE / 'source-inventory.csv').open('w') as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)
    (HERE / 'assertion-index.json').write_text(json.dumps(snippets, indent=2) + '\n')
    ctest = json.loads(args.ctest_json.read_text())
    (HERE / 'ctest-inventory.json').write_text(json.dumps(ctest, indent=2) + '\n')
    tests = ctest['tests']
    summary = dict(schema=1, scope='Custom destruction test and helper sources; upstream SDK suites excluded',
                   date='2026-09-13', worktree_head=subprocess.check_output(['git','rev-parse','HEAD'], cwd=ROOT, text=True).strip(),
                   worktree_clean=False, sources=len(rows),
                   families={k:sum(r['family'] == k for r in rows) for k in sorted(set(paths.values()))},
                   configured_ctest_entries=len(tests),
                   run_serial=sum(any(p['name'] == 'RUN_SERIAL' and p['value'] for p in t['properties']) for t in tests),
                   labeled=sum(any(p['name'] == 'LABELS' for p in t['properties']) for t in tests),
                   warning='Inventory is not line/branch coverage or proof these binaries match the current worktree. No GPU tests run in this audit.')
    (HERE / 'inventory-summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
