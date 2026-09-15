"""Recreate portable CSVs and check their underlying frozen timing evidence.

Does not run simulation, profiling, or access original absolute archive paths.
"""
import csv
import json
import math
from pathlib import Path
import statistics

HERE = Path(__file__).resolve().parent
data = json.loads((HERE / 'data/measurements.json').read_text())
budget = 1000 / 60

def write_csv(name, rows):
    with (HERE / 'data' / name).open('w', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=list(rows[0]), lineterminator='\n')
        writer.writeheader()
        writer.writerows(rows)

summary, samples, frames = [], [], []
assert len(data['scenarios']) == 52
assert len({row['name'] for row in data['scenarios']}) == 52
for row in data['scenarios']:
    values = row['samples']
    assert len(values) == row['n'] == 20
    assert all(math.isfinite(v) and v >= 0 for v in values)
    assert math.isclose(statistics.mean(values), row['mean'], abs_tol=1e-8)
    assert math.isclose(max(values), row['maximum'], abs_tol=1e-8)
    assert math.isclose(statistics.stdev(values), row['sd'], abs_tol=1e-8)
    assert sum(v > budget for v in values) == row['misses']
    assert math.isclose(sum(row['stages'].values()), row['mean'], abs_tol=1e-6)
    summary.append(dict(scenario=row['name'], samples=row['n'], mean_ms=row['mean'],
                        max_ms=row['maximum'], sample_sd_ms=row['sd'],
                        misses_60hz=row['misses'], **row['stages'],
                        context_setup_ms=row['setup'], restore_mean_ms=row['restore'],
                        **row['physical']))
    samples.extend(dict(scenario=row['name'], repeat=i, complete_step_ms=value)
                   for i, value in enumerate(values))
for run in data['warm']:
    assert len(run['frames']) == 600
    values = [f['complete_step_ms'] for f in run['frames']]
    assert math.isclose(statistics.mean(values), run['mean'], abs_tol=1e-8)
    assert math.isclose(max(values), run['maximum'], abs_tol=1e-8)
    assert sum(v > budget for v in values) == run['misses']
    for frame in run['frames']:
        assert math.isclose(sum(frame[k] for k in ['command_ms','physics_step_ms','completion_ms']),
                            frame['complete_step_ms'], abs_tol=1e-6)
        frames.append(dict(run=run['name'], **frame))
for profile in data['profiles']:
    assert math.isclose(sum(profile['wall'].values()), profile['tick'], abs_tol=1e-6)
    assert math.isclose(profile['gpu'] + profile['no_gpu'], profile['tick'], abs_tol=1e-6)
write_csv('scenarios.csv', summary)
write_csv('snapshot-samples.csv', samples)
write_csv('continuous-frames.csv', frames)
print(f'Checked {len(summary)} scenarios, {len(samples)} restored ticks, '
      f'{len(frames)} continuous ticks and {len(data["profiles"])} profile partitions.')
