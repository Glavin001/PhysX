"""Large real-fracture regression for persistent contact lifecycle during correction.

This is an explicit heavy audit, not a performance measurement. In particular,
retaining managers while failing to mark restored GPU bounds used to leave a
separated pair live and create a duplicate when its bounds overlapped again.
"""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[3]
config = json.loads((root / 'tools/profiles/destruction-scaling.json').read_text())
case = next(case for case in config['cases'] if case['id'] == 'impacts-256')
args = list(config['common']) + case['args']
args[args.index('--audit-motion') + 1] = '1'
ordinary = len(sys.argv) == 3 and sys.argv[2] == '--standard-scene'
assert len(sys.argv) == 2 or ordinary, 'unexpected audit arguments'
if ordinary:
    args[args.index('--gpu-connectivity-owner') + 1] = '0'
    args += ['--standard-scene', '1', '--sleeping', '1']
else:
    # Preserve the historical Direct GPU control independently of demo defaults.
    args += ['--standard-scene', '0']
work = Path(tempfile.mkdtemp(prefix='physx-bombardment-contacts-'))
output = work / 'capture'
command = [sys.argv[1], *args, '--seconds', '3', '--audit-islands', '1', '--output', str(output)]
try:
    with (work / 'run.log').open('w') as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=240)
    assert result.returncode == 0, f'Bombardment audit exited {result.returncode}'
    summary = json.loads((output / 'native.summary.json').read_text())
    graph = json.loads((output / 'native.graph-diagnostics.json').read_text())
    assert summary['status'] == 'completed' and summary['frames'] == 180
    assert (summary['chunks'], summary['bonds'], summary['projectiles']) == (113664, 229376, 256)
    assert summary['correction_limit'] == 1 and summary['corrections'] > 1
    assert summary['broken_bonds'] > 0 and summary['peak_clusters'] > 256
    assert summary['motion_audit_enabled'] and summary['island_boundary_audit_enabled']
    assert summary['direct_gpu_mode'] == (not ordinary)
    assert summary['sleeping'] == ordinary
    assert summary['max_motion_position_error'] == 0
    assert graph['boundary_audits'] > 0 and graph['boundary_audit_failures'] == 0
    assert graph['cuda_pre_solve_passes'] > 0
except BaseException:
    if (work / 'run.log').exists():
        print((work / 'run.log').read_text())
    print(f'Failed audit retained at {work}')
    raise
print(f'256-building bombardment (ordinary API/sleeping={ordinary}): '
      '113,664 chunks, 229,376 bonds, 256 projectiles, '
      '180 steps; unique live shape pairs, contact ownership/connectivity, corrected '
      'motion and publication audits passed. Not a performance capture.')
shutil.rmtree(work)
