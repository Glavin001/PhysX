#!/usr/bin/env python3
"""Order-perturbation ensemble for the g16 bombardment (README section 11 protocol).

Each arm is run with the baseline insertion order and with the order rotated by
several offsets (PHYSX_DESTRUCTION_PARTITION_ROTATE_AUDIT). Reports per-arm
distributions of bonds broken, peak clusters, tick mean, peak tick and 60 Hz
misses so that an order-changing candidate is judged against the spread of
order perturbations of the control, not against a single run.
"""
import argparse, csv, json, os, subprocess, statistics, sys
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
COMMON = ("--waves 1 --launch-seconds 0 --stress-iterations 8192 --preserve-contact-pairs 1 --gpu-island-repair 1 "
          "--gpu-pre-solve-islands 1 --gpu-pre-solve-contacts 1 --gpu-pre-solve-support 1 --gpu-connectivity-owner 0 "
          "--projectile-mass 18000 --material-strength 24 --frame-strength 40 --record-state 0 --gpu-render 0 "
          "--audit-motion 1 --trace-motion 0 --standard-scene 1 --sleeping 1 --shot-path aerial --grid 16 --workload bombardment").split()
def run_one(demo, libdir, out, env, seconds):
    if os.path.isdir(out):
        return
    e = dict(os.environ); e.update(env); e["LD_LIBRARY_PATH"] = libdir
    with open(out + ".log", "w") as log:
        subprocess.run([demo] + COMMON + ["--seconds", str(seconds), "--output", out], env=e, stdout=log, stderr=subprocess.STDOUT, timeout=900)
def metrics(out):
    rows = list(csv.DictReader(open(os.path.join(out, "native.frames.csv"))))
    step = [float(r["complete_step_ms"]) for r in rows]
    summary = json.load(open(os.path.join(out, "native.summary.json")))
    return dict(bonds=sum(int(float(r["bonds_broken"])) for r in rows), clusters=summary.get("peak_clusters"),
                mean=sum(step) / len(step), peak=max(step), misses=sum(1 for v in step if v > 16.667),
                motion=summary.get("max_motion_position_error"))
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--demo", default=os.path.join(ROOT, "out/destruction-sdk/reference/native_destruction_demo"))
    ap.add_argument("--libdir", default=os.path.join(ROOT, "physx/bin/linux.x86_64/release"))
    ap.add_argument("--outdir", required=True)
    ap.add_argument("--arm", action="append", required=True, help="name=ENV1=v1,ENV2=v2 (empty env for control)")
    ap.add_argument("--rotations", default="0,7,101,1013")
    ap.add_argument("--seconds", type=int, default=3)
    a = ap.parse_args()
    rotations = [int(x) for x in a.rotations.split(",")]
    os.makedirs(a.outdir, exist_ok=True)
    results = {}
    for arm in a.arm:
        name, _, envs = arm.partition("=")
        env = dict(kv.split("=", 1) for kv in envs.split(",") if kv)
        results[name] = []
        for k in rotations:
            e = dict(env); e["PHYSX_DESTRUCTION_PARTITION_ROTATE_AUDIT"] = str(k)
            out = os.path.join(a.outdir, f"{name}-rot{k}")
            run_one(a.demo, a.libdir, out, e, a.seconds)
            results[name].append((k, metrics(out)))
    print(f"{'arm':14s} {'rot':>5s} {'bonds':>7s} {'clusters':>8s} {'mean':>6s} {'peak':>6s} {'misses':>6s} {'motion':>8s}")
    for name, rs in results.items():
        for k, m in rs:
            print(f"{name:14s} {k:5d} {m['bonds']:7d} {m['clusters'] or 0:8d} {m['mean']:6.2f} {m['peak']:6.1f} {m['misses']:6d} {m['motion'] if m['motion'] is not None else 0:8.1e}")
        b = [m["bonds"] for _, m in rs]; mn = [m["mean"] for _, m in rs]; pk = [m["peak"] for _, m in rs]
        print(f"  {name}: bonds {min(b)}-{max(b)} (median {statistics.median(b):.0f}), mean {min(mn):.1f}-{max(mn):.1f} (median {statistics.median(mn):.1f}), peak {min(pk):.0f}-{max(pk):.0f} (median {statistics.median(pk):.0f})")
    json.dump({n: [(k, m) for k, m in rs] for n, rs in results.items()}, open(os.path.join(a.outdir, "ensemble.json"), "w"), indent=1)
if __name__ == "__main__":
    main()
