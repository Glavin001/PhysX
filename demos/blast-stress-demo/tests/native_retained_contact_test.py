"""Real fracture regression: native speculative edges without NP managers."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

work = Path(tempfile.mkdtemp(prefix="physx-retained-contact-"))
capture = work / "capture"
command = [sys.argv[1], "--grid", "1", "--waves", "1", "--seconds", "3",
           "--stress-iterations", "8192", "--preserve-contact-pairs", "1",
           "--gpu-island-repair", "1", "--audit-islands", "1", "--audit-motion", "1",
           "--record-state", "0", "--output", str(capture)]
with (work / "run.log").open("w") as log:
    result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT)
try:
    assert result.returncode == 0, f"demo exited {result.returncode}"
    summary = json.loads((capture / "native.summary.json").read_text())
    graph = json.loads((capture / "native.graph-diagnostics.json").read_text())
    assert summary["status"] == "completed" and summary["frames"] == 180
    assert summary["corrections"] > 0 and summary["correction_limit"] == 1
    assert summary["max_motion_position_error"] == 0
    assert summary["island_boundary_audit_enabled"]
    # Falling fragments no longer falsely sleep when contacts separate. Exercise
    # managerless edges deterministically during real fracture in the native fixture;
    # it asserts nonzero retained edges/uploads and independently audits each step.
    subprocess.run([sys.argv[2], "--retained-fracture"], check=True)
    assert graph["boundary_audits"] > 0 and graph["boundary_audit_failures"] == 0
except Exception:
    print((work / "run.log").read_text())
    print(f"Failed capture retained at {work}")
    raise
print("Real fracture: retained speculative edges included in CUDA; independent pre-mutation audit and motion audit passed")
shutil.rmtree(work)
