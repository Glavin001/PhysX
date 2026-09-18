#!/usr/bin/env python3
"""Label exported GPU-rendered pixels with measured native simulation timings.

This export step never reads poses or reconstructs geometry. It does not form
part of simulation or GPU rendering and is excluded from simulation timings.
"""
import argparse
import csv
import json
import math
from pathlib import Path
import subprocess
import tempfile


def ass_time(seconds):
    centiseconds = round(seconds * 100)
    hours, rest = divmod(centiseconds, 360000)
    minutes, rest = divmod(rest, 6000)
    whole, fraction = divmod(rest, 100)
    return f"{hours}:{minutes:02d}:{whole:02d}.{fraction:02d}"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("capture", type=Path)
    parser.add_argument("video", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    if args.output.exists():
        parser.error("output already exists")
    summary = json.loads((args.capture / "native.summary.json").read_text())
    with (args.capture / "native.frames.csv").open() as stream:
        rows = list(csv.DictReader(stream))
    if summary["status"] != "completed" or len(rows) != summary["frames"]:
        parser.error("capture is incomplete")
    timings = [float(row["physics_step_ms"]) for row in rows]
    if not all(math.isfinite(value) and value > 0 for value in timings):
        parser.error("invalid simulation timing")
    graph_file = args.capture / "native.graph-diagnostics.json"
    graph_bytes = json.loads(graph_file.read_text())["device_to_host_bytes"] if graph_file.exists() else None
    graph_label = f"{graph_bytes / 1e9:.2f} GB" if graph_bytes is not None else "unmeasured"
    duration = summary["seconds"]
    # Refresh labels four times a second for readability; every underlying
    # simulation step still contributes to avg/min/max and deadline statistics.
    average = sum(timings) / len(timings)
    speed = duration * 1000 / sum(timings)
    header = """[Script Info]
ScriptType: v4.00+
PlayResX: 960
PlayResY: 540
[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,DejaVu Sans,17,&H00FFFFFF,&H00FFFFFF,&H00101418,&H90101418,0,0,0,0,100,100,0,0,3,1,0,7,14,14,12,1
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
"""
    events = []
    for interval in range(math.ceil(duration * 4)):
        start = interval / 4
        end = min(duration, (interval + 1) / 4)
        row = rows[min(len(rows) - 1, int(start * 60))]
        text = (
            "PHYSX GPU + CUDA DESTRUCTION | GPU TO GPU RENDERING"
            rf"\NSIMULATION ONLY: avg {average:.2f} ms | min {min(timings):.2f} | max {max(timings):.2f} | budget 16.67 ms"
            rf"\NMeasured speed: {speed:.2f}x real time | missed deadlines {summary['missed_16_67ms']}/{len(rows)} | shared GPU"
            rf"\Nt={start:.2f}s | step {float(row['physics_step_ms']):.2f} ms | correction {int(row['resim_passes'])}/1 | clusters+bodies {row['bodies']}"
            rf"\N{summary['chunks']:,} chunks | {summary['bonds']:,} bonds | renderer pose readback {summary['consumer_pose_readback_bytes']} bytes"
            rf"\NEngine contact-graph CPU readback: {graph_label} | full GPU residency unfinished"
            rf"\NPlayback {summary['record_fps']} fps; encoding and graphics are outside simulation timing."
        )
        events.append(f"Dialogue: 0,{ass_time(start)},{ass_time(end)},Default,,0,0,0,,{text}\n")
    # A fixed basename avoids ffmpeg filter-language quoting of arbitrary paths.
    with tempfile.TemporaryDirectory(prefix="native-gpu-hud-") as work:
        subtitles = Path(work) / "timings.ass"
        subtitles.write_text(header + "".join(events))
        subprocess.run(["ffmpeg", "-hide_banner", "-loglevel", "error", "-n", "-i", str(args.video.resolve()),
                        "-vf", "ass=timings.ass", "-c:v", "libx264", "-preset", "veryfast", "-crf", "20",
                        "-pix_fmt", "yuv420p", str(args.output.resolve())], cwd=work, check=True)
    print(f"Annotated GPU pixel export: {args.output}")


if __name__ == "__main__":
    main()
