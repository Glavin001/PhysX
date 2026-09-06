"""Exercise repeated fracture, connectivity fallback, and committed GPU motion."""
import json
import subprocess
import sys
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory(prefix='physx-connectivity-fracture-') as root:
    output = Path(root)/'capture'
    subprocess.run([sys.argv[1], '--output', str(output), '--grid', '1', '--waves', '2',
        '--seconds', '6', '--launch-seconds', '1', '--stress-iterations', '8192',
        '--preserve-contact-pairs', '1', '--gpu-island-repair', '1', '--gpu-pre-solve-islands', '1',
        '--gpu-pre-solve-contacts', '1', '--gpu-pre-solve-support', '1', '--gpu-connectivity-owner', '1',
        '--audit-islands', '1', '--audit-motion', '1'], check=True)
    summary = json.loads((output/'native.summary.json').read_text())
    graph = json.loads((output/'native.graph-diagnostics.json').read_text())
    assert summary['status'] == 'completed' and summary['frames'] == 360
    assert summary['broken_bonds'] > 0 and summary['corrections'] > 0
    assert summary['max_motion_position_error'] < 1e-3
    assert graph['device_connectivity_passes'] > 300
    assert graph['host_connectivity_restores'] > 0  # Exercises the post-partition fallback bug.
    print('GPU connectivity: fractured scene, host fallback and committed motion passed')
