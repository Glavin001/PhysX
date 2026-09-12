#!/usr/bin/env python3
"""Compare fixed semantic frame selections in an existing matched campaign.

This does not restore snapshots and must not be labelled fixed-input replay.
"""
import argparse
import csv
import gzip
import hashlib
import io
import json
from pathlib import Path
import statistics


def report(campaign, manifest, run_manifest=None):
    if run_manifest is not None:
        if run_manifest['status']!='complete' or any(r['status']!='complete' for r in run_manifest['runs']):
            raise ValueError('Every requested trajectory run must be complete')
    scenarios = []
    fields = ('contacts_frame', 'bonds_broken', 'post_correction_bonds_broken',
              'resim_passes', 'stress_passes', 'stress_iterations',
              'stress_active_nodes', 'stress_active_bonds', 'stress_islands',
              'bodies', 'awake_bodies', 'projectiles_active', 'stress_converged')
    for spec in manifest['scenarios']:
        item = dict(spec, arms={})
        for arm in ('A-before', 'B', 'A-after'):
            runs = []
            if run_manifest is None:
                paths=sorted((campaign / arm / spec['case']).glob('*-plain-*/native.frames.csv.gz'))
            else:
                paths=[campaign/r['name']/'native/native.frames.csv' for r in run_manifest['runs']
                       if r['case']==spec['case'] and r['stage']==arm and r['status']=='complete']
            for path in paths:
                raw = gzip.decompress(path.read_bytes()) if path.suffix=='.gz' else path.read_bytes()
                rows = list(csv.DictReader(io.StringIO(raw.decode())))
                matches = [r for r in rows if int(r['step']) == spec['step']]
                if len(matches) != 1:
                    raise ValueError(f'{path}: selected step is missing or duplicated')
                row = matches[0]
                for key, checks in spec.get('predicates', {}).items():
                    value = int(row[key])
                    for op, expected in checks.items():
                        if op not in ('eq', 'gt'):
                            raise ValueError(f'Unknown predicate {op}')
                        if not (value == expected if op == 'eq' else value > expected):
                            raise ValueError(f'{path}: {spec["id"]}: {key}={value} violates {op} {expected}')
                if not int(row['stress_converged']) or int(row['resim_passes']) > 1 or int(row['stress_passes']) > 2:
                    raise ValueError(f'{path}: convergence/correction/evaluation gate failed')
                runs.append({'run': path.parent.parent.name if run_manifest else path.parent.name, 'frames': str(path),
                             'decompressed_frames_sha256': hashlib.sha256(raw).hexdigest(),
                             'complete_step_ms': float(row['complete_step_ms']),
                             'stages_ms':{k:float(row[k]) for k in ['command_ms','physics_step_ms','completion_ms'] if k in row},
                             'physical_and_work_counters': {k: int(row[k]) for k in fields}})
            if not runs:
                raise ValueError(f'No measured runs for {arm}/{spec["case"]}')
            times = [r['complete_step_ms'] for r in runs]
            item['arms'][arm] = {'samples': len(times), 'mean_ms': statistics.mean(times),
                                 'median_ms': statistics.median(times), 'min_ms': min(times),
                                 'max_ms': max(times), 'runs': runs}
        scenarios.append(item)
    return {'schema': 1, 'scope': 'Selected trajectory-frame timings; NOT restored identical-input snapshots',
            'input_state_hashes_available': False, 'stage_timings': 'Native command / integrated physics / completion fields where present; nested solver time is not separately inferred',
            'selection_manifest': manifest, 'scenarios': scenarios,
            'whole_trajectory_measurements': str(campaign / ('campaign.json' if run_manifest else 'measurements.json'))}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('campaign', type=Path)
    parser.add_argument('--manifest', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--run-manifest',type=Path,help='Completed run-probe warm campaign with case/stage/name records and raw native frame CSVs')
    args = parser.parse_args()
    runs=json.loads(args.run_manifest.read_text()) if args.run_manifest else None
    if runs is not None and runs['status']!='complete':raise ValueError('Run manifest is not complete')
    data = report(args.campaign, json.loads(args.manifest.read_text()),runs)
    args.output.write_text(json.dumps(data, indent=2) + '\n')
    for scenario in data['scenarios']:
        print(scenario['id'], {arm: round(value['mean_ms'], 6) for arm, value in scenario['arms'].items()})


if __name__ == '__main__':
    main()
