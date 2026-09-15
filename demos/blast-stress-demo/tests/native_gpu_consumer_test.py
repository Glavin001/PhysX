"""Exercise committed GPU consumers through real native fracture/correction."""
import csv
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

work = Path(tempfile.mkdtemp(prefix="physx-gpu-consumer-"))
render = "--render" in sys.argv[2:]
results = []
try:
    for observe in (False, True):
        capture = work / ("observed" if observe else "resident")
        # Keep this historical consumer audit's API mode fixed across demo defaults.
        command = [sys.argv[1], "--standard-scene", "0", "--grid", "1", "--waves", "4", "--seconds", "8",
                   "--stress-iterations", "8192", "--preserve-contact-pairs", "1",
                   "--gpu-island-repair", "1", "--gpu-pre-solve-islands", "1",
                   "--gpu-pre-solve-contacts", "1", "--gpu-pre-solve-support", "1",
                   "--audit-islands", "1", "--audit-motion", str(int(observe)),
                   "--record-state", "0", "--gpu-render", str(int(render)), "--output", str(capture)]
        with (work / (capture.name + ".log")).open("w") as log:
            subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=120)
        summary = json.loads((capture / "native.summary.json").read_text())
        graph = json.loads((capture / "native.graph-diagnostics.json").read_text())
        assert summary["status"] == "completed" and summary["frames"] == 480
        assert summary["corrections"] > 0 and summary["correction_limit"] == 1
        assert summary["gpu_rendered_frames"] == (480 if render else 0)
        assert bool(summary["consumer_pose_readback_bytes"]) == observe
        assert summary["consumer_query_readback_bytes"] == 4 * 4 + 8
        assert summary["export_pixel_readback_bytes"] == 0
        assert 0 <= summary["max_motion_position_error"] < 1e-3  # Same physical gate as the native pose audit.
        assert graph["boundary_audits"] > 0 and graph["boundary_audit_failures"] == 0
        assert not (capture / "native.twstate").exists()
        frames = list(csv.DictReader((capture / "native.frames.csv").open()))
        assert len(frames) == 480 and all(int(row["resim_passes"]) <= 1 for row in frames)
        # Input authoring is identical with and without CPU observations.
        results.append((capture / "native.launches.csv").read_text().splitlines())
    # The final column is a legacy optional CPU diagnostic, not a launch input.
    assert [line.rsplit(",", 1)[0] for line in results[0]] == [line.rsplit(",", 1)[0] for line in results[1]]
except Exception:
    for log in work.glob("*.log"):
        print(log.read_text())
    print(f"Failed capture retained at {work}")
    raise
print("Native GPU consumer: actual fracture, one-correction limit, zero resident pose readbacks, optional CPU audit parity, GPU launch queries and committed publication passed")
shutil.rmtree(work)
