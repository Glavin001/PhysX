#!/usr/bin/env python3
"""Modal GPU fan-out for physx-2 destruction measurements.

Build locally (nvcc needs no GPU), `push` the binaries (content-addressed, only changed
blobs upload), then fan measurement jobs out one GPU per container. Every paired
comparison (A/B repeats, warm A0/B/A1 triple, campaign A-before/B/A-after) runs inside one
container on one GPU. Inside containers the repo is recreated at the same absolute path as
the dev box so the existing scripts run unchanged; results come back under out/modal/<run>/.

    modal run tools/modal/gpu_run.py::smoke
    modal run tools/modal/gpu_run.py::inputs
    modal run tools/modal/gpu_run.py::push
    modal run tools/modal/gpu_run.py::tests --subset eleven
    modal run tools/modal/gpu_run.py::ab --grid 16 --seconds 3 --repeats 3
    modal run tools/modal/gpu_run.py::warm
    modal run tools/modal/gpu_run.py::campaign
    modal run tools/modal/gpu_run.py::qualify --confirm
See tools/modal/README.md.
"""
import csv
import datetime as dt
import hashlib
import io
import json
import os
import re
import shutil
import statistics
import subprocess
import sys
import tarfile
import time
from pathlib import Path

import modal

import functools
print = functools.partial(print, flush=True)  # noqa: A001  (entrypoint output is often redirected to a log)

# ----------------------------------------------------------------------------- constants
REPO = Path('/root/workspace/physx-2')                 # path identity inside containers
LOCAL_ROOT = Path(__file__).resolve().parents[2] if modal.is_local() else REPO   # tools/modal -> repo root (dev box)
SRC_TOOLS = '/src/tools'
VOL_BUILDS, VOL_INPUTS, VOL_RESULTS = '/vol/builds', '/vol/inputs', '/vol/results'
GPU = os.environ.get('PHYSX_MODAL_GPU', 'RTX-PRO-6000')
GPU_RATE_PER_S = 0.000842 + 4 * 0.0000131 + 16 * 0.00000222   # RTX PRO 6000 + 4 cores + 16 GiB
LIBDIR_REL = 'physx/bin/linux.x86_64/release'
REF_REL = 'out/destruction-sdk/reference'
TOPO_REL = 'out/destruction-sdk/topology'
DIAG_REL = 'out/sdk-release/diagnostics/component-work'
PROBE_REL = 'out/probes/profile'
BASELINE_REL = 'out/destruction-baseline-20260913/artifacts'
ARMS_REL = 'out/direct-ab-arms'
SNAPSHOTS_REL = 'out/snapshot-large-20260911'
INPUT_SETS = [BASELINE_REL, ARMS_REL + '/A', ARMS_REL + '/B'] + [
    SNAPSHOTS_REL + '/' + d for d in ('roundtrip-regressions', 'capture-5-bombardment', 'capture-16-idle', 'capture-16-bombardment')]
ARM_FILES = ['native_destruction_demo', 'libPhysXGpuActivity_64.so', 'libPhysXDestructionGpuRuntime_64.so',
             'libPVDRuntime_64.so', 'libnative_gpu_visuals.so']
ELEVEN = (r'^physx_native_gpu_(destruction|body_allocation|pairs|motion_slots|contact_response|node_births|'
          r'accepted_properties|solver_metadata|pre_solve_islands|rigid_checkpoint|command_motion)$')
KNOWN_FAILURES = {'physx_native_gpu_body_allocation', 'physx_native_gpu_node_births', 'physx_native_gpu_rigid_checkpoint',
                  'physx_native_gpu_state_initcheck_accepted-properties', 'physx_native_gpu_state_initcheck_accepted-properties-pgs',
                  'physx_native_gpu_bombardment_contacts'}
NSYS = '/usr/local/cuda-13.0/bin/nsys'   # the CUDA 13.0 Nsight Systems traces kernels on Modal; the 13.4 one (2026.3.2) records none there
CONTAINER_ENV = {'PHYSX_DESTRUCTION_DEVICE_GATE': 'sm120,sm89'}   # see tools/modal/patches/device-gate-sm120.patch
SANITIZER = '/usr/local/cuda-13.4/bin/compute-sanitizer'

# ----------------------------------------------------------------------------- image / app
image = (
    modal.Image.from_registry('nvidia/cuda:13.0.3-base-ubuntu24.04', add_python='3.12')
    .apt_install('cuda-cudart-13-4', 'cuda-sanitizer-13-4', 'cuda-sanitizer-13-0', 'cuda-nsight-systems-13-4', 'cuda-nsight-systems-13-0', 'cuda-compat-13-4',
                 'libegl1', 'libopengl0', 'libglvnd0', 'zlib1g', 'git', 'systemd', 'pciutils', 'rsync', 'file', 'tar', 'gdb')
    .run_commands(
        'echo /usr/local/cuda-13.4/targets/x86_64-linux/lib > /etc/ld.so.conf.d/zz-cuda-13-4.conf && ldconfig',
        'test -e /opt/nvidia/nsight-systems/2026.3.2 || ln -s "$(ls -d /opt/nvidia/nsight-systems/20* | tail -1)" /opt/nvidia/nsight-systems/2026.3.2',
        'test -x /usr/local/cuda-13.0/bin/nsys',
        # gVisor lists GPU processes with host-namespace PIDs, which run-probe.py's ownership check rejects; the
        # container is single-tenant, so hide the process list from `nvidia-smi -q -x` and let the scripts inspect their own child.
        r"""printf '%s\n' '#!/bin/sh' 'if [ "$#" -ge 2 ] && [ "$1" = "-q" ] && [ "$2" = "-x" ]; then' '  /usr/bin/nvidia-smi "$@" | sed "/<process_info>/,/<\/process_info>/d"' '  exit $?' 'fi' 'exec /usr/bin/nvidia-smi "$@"' > /usr/local/bin/nvidia-smi && chmod +x /usr/local/bin/nvidia-smi && sh -n /usr/local/bin/nvidia-smi""",
        'test -x /usr/local/cuda-13.4/bin/compute-sanitizer',
        'ldconfig -p | grep -q libcudart.so.13',
    )
    .pip_install('numpy==2.2.6', 'scipy==1.15.3', 'cmake==3.31.*')
    .env({'PATH': '/usr/local/cuda-13.4/bin:/opt/nvidia/nsight-systems/2026.3.2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin', **CONTAINER_ENV})
    .add_local_dir(str(LOCAL_ROOT / 'tools'), SRC_TOOLS, ignore=['**/__pycache__', '**/*.pyc'])
)
builds_vol = modal.Volume.from_name('physx-builds', create_if_missing=True)
inputs_vol = modal.Volume.from_name('physx-inputs', create_if_missing=True)
results_vol = modal.Volume.from_name('physx-results', create_if_missing=True)
VOLUMES = {VOL_BUILDS: builds_vol, VOL_INPUTS: inputs_vol, VOL_RESULTS: results_vol}
app = modal.App('physx-destruction-gpu')


# ----------------------------------------------------------------------------- shared helpers
def sha256(path, chunk=1 << 20):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for block in iter(lambda: f.read(chunk), b''):
            h.update(block)
    return h.hexdigest()


def utc_stamp():
    return dt.datetime.now(dt.timezone.utc).strftime('%Y%m%dT%H%M%S')


def sh(cmd, env=None, cwd=None, log=None, check=True, timeout=None):
    """Run a command, tee to an optional log file, return CompletedProcess (stdout captured)."""
    cmd = [str(c) for c in cmd]
    proc = subprocess.run(cmd, cwd=str(cwd or REPO), env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          text=True, timeout=timeout)
    if log:
        Path(log).parent.mkdir(parents=True, exist_ok=True)
        with open(log, 'a') as f:
            f.write('$ ' + ' '.join(cmd) + '\n' + proc.stdout)
    if check and proc.returncode:
        raise RuntimeError(f'exit {proc.returncode}: {" ".join(cmd)}\n{proc.stdout[-4000:]}')
    return proc


# ----------------------------------------------------------------------------- container-side staging
def provenance():
    info = {'gpu': GPU, 'region': os.environ.get('MODAL_REGION'), 'cloud': os.environ.get('MODAL_CLOUD_PROVIDER'),
            'task_id': os.environ.get('MODAL_TASK_ID'), 'ncpu': os.cpu_count(), 'unix_seconds': time.time()}
    q = 'name,uuid,driver_version,clocks.sm,clocks.mem,temperature.gpu,power.draw,pstate,memory.total'
    try:
        info['nvidia_smi'] = sh(['nvidia-smi', f'--query-gpu={q}', '--format=csv,noheader'], check=False).stdout.strip()
    except Exception as e:  # noqa: BLE001
        info['nvidia_smi'] = f'unavailable: {e}'
    try:
        info['cpu'] = next(l.split(':', 1)[1].strip() for l in open('/proc/cpuinfo') if l.startswith('model name'))
    except Exception:  # noqa: BLE001
        info['cpu'] = '?'
    import ctypes
    for lib, fn, key in (('libcuda.so.1', 'cuDriverGetVersion', 'driver_api'), ('libcudart.so.13', 'cudaRuntimeGetVersion', 'runtime_api'),
                         ('libcudart.so.13', 'cudaDriverGetVersion', 'runtime_sees_driver')):
        try:
            v = ctypes.c_int(0)
            rc = getattr(ctypes.CDLL(lib), fn)(ctypes.byref(v))
            info[key] = v.value if rc == 0 else f'rc={rc}'
        except Exception as e:  # noqa: BLE001
            info[key] = f'unavailable: {e}'
    for name, cmd in (('nsys', [NSYS, '--version']), ('compute_sanitizer', [SANITIZER, '--version'])):
        info[name] = sh(cmd, check=False).stdout.strip().splitlines()[-1:] if Path(cmd[0]).exists() else 'missing'
    info['systemctl'] = bool(shutil.which('systemctl'))
    info['journalctl'] = bool(shutil.which('journalctl'))
    return info


def stage_repo(git_sha='unknown', dirty=False):
    """Recreate /root/workspace/physx-2 with tools/, a git identity, locks and interpreter shims."""
    REPO.mkdir(parents=True, exist_ok=True)
    sh(['rsync', '-a', '--delete', SRC_TOOLS + '/', REPO / 'tools/'])
    (REPO / '.gitignore').write_text('/out/\n/physx/bin/\n/.toolchains/\n**/__pycache__/\n')
    (REPO / 'out').mkdir(exist_ok=True)
    (REPO / 'out/destruction-ab.lock').touch()
    (REPO / 'out/destruction-analysis.lock').touch()
    shim = REPO / '.toolchains/build-env/bin'
    shim.mkdir(parents=True, exist_ok=True)
    for name, target in (('python3.10', sys.executable), ('python3', sys.executable), ('python', sys.executable),
                         ('cmake', shutil.which('cmake') or '/usr/local/bin/cmake'), ('ctest', shutil.which('ctest') or '/usr/local/bin/ctest')):
        link = shim / name
        if not link.exists():
            link.symlink_to(target)
    if not (REPO / '.git').exists():
        g = ['git', '-c', 'user.name=modal', '-c', 'user.email=modal@localhost']
        sh(g + ['init', '-q'])
        sh(g + ['add', '-A'])
        sh(g + ['commit', '-q', '--allow-empty', '-m', f'modal staging of {git_sha} dirty={dirty}'])


def read_manifest(build_id):
    builds_vol.reload()
    return json.loads(Path(VOL_BUILDS, 'bundles', build_id + '.json').read_text())


def stage_bundle(build_id, into=REPO):
    """Copy every bundle blob to its recorded repo-relative path under `into`; verify hashes."""
    manifest = read_manifest(build_id)
    for entry in manifest['files']:
        src = Path(VOL_BUILDS, 'blobs', entry['sha256'])
        dst = Path(into, entry['path'])
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)
        os.chmod(dst, entry['mode'])
        if entry['size'] < (64 << 20) and sha256(dst) != entry['sha256']:
            raise RuntimeError(f'bundle blob mismatch: {entry["path"]}')
    alias = manifest.get('rpath_alias')
    if alias:
        link = Path(into, alias)
        link.parent.mkdir(parents=True, exist_ok=True)
        if not link.exists():
            link.symlink_to(Path(into, LIBDIR_REL))
    return manifest


def stage_inputs(names):
    """Copy the requested input sets from the inputs volume to local disk under out/ (run-probe checks stat identity)."""
    inputs_vol.reload()
    for rel in names:
        src, dst = Path(VOL_INPUTS, rel[len('out/'):]), REPO / rel
        if not src.exists():
            raise RuntimeError(f'input set missing on volume physx-inputs: {src} (run `modal run tools/modal/gpu_run.py::inputs`)')
        if not dst.exists():   # copy (not symlink): the probes memory-map the large snapshot files, which a FUSE volume serves poorly
            shutil.copytree(src, dst)


def make_arm(name, lib_dir, demo_dir=REPO / REF_REL, extra_libs=(), into=None):
    """Assemble a campaign-style arm directory (demo + modules) from a lib dir and a demo dir."""
    arm = Path(into or REPO / 'out/modal/arms' / name)
    if arm.exists():
        return arm
    arm.mkdir(parents=True)
    for f in ARM_FILES:
        for candidate in (Path(lib_dir) / f, Path(demo_dir) / f, REPO / LIBDIR_REL / f, *[Path(e) / f for e in extra_libs]):
            if candidate.exists():
                shutil.copy2(candidate, arm / f)
                break
        else:
            raise RuntimeError(f'arm {name}: missing {f}')
    return arm


def control_dir(control, build_id_of_candidate):
    """Resolve the control arm spec to a directory whose libs go on LD_LIBRARY_PATH."""
    if control in ('baseline', ''):
        return REPO / BASELINE_REL
    if control == 'arms-A':
        return REPO / ARMS_REL / 'A'
    if control == 'arms-B':
        return REPO / ARMS_REL / 'B'
    if control == 'self':
        return REPO / LIBDIR_REL
    # another pushed build id: stage its libraries only, never its demo (ABI stays the candidate's)
    into = REPO / 'out/modal/controls' / control
    if not into.exists():
        stage_bundle(control, into=into)
    return into / LIBDIR_REL


def run_dir(run_id, job):
    d = REPO / 'out/modal' / run_id / job
    d.mkdir(parents=True, exist_ok=False)
    return d


def publish(run_id, job, summary):
    """Tar out/modal/<run>/<job> to the results volume and write the summary JSON next to it."""
    base = REPO / 'out/modal' / run_id
    dest = Path(VOL_RESULTS, run_id)
    dest.mkdir(parents=True, exist_ok=True)
    tmp = dest / (job + '.tar.tmp')
    with tarfile.open(tmp, 'w') as tar:
        tar.add(base / job, arcname=job)
    os.replace(tmp, dest / (job + '.tar'))
    (dest / (job + '.json')).write_text(json.dumps(summary, indent=2, default=str) + '\n')
    results_vol.commit()
    return summary


def common_demo_args():
    return json.loads((REPO / 'tools/profiles/destruction-ordinary-ab.json').read_text())['common']


def run_demo(out_dir, grid, workload, seconds, arm_dir, env_extra=None, extra_args=(), demo=None):
    demo = Path(demo or REPO / REF_REL / 'native_destruction_demo')
    cmd = [demo, *common_demo_args(), '--grid', grid, '--workload', workload, '--seconds', seconds, *extra_args, '--output', out_dir]
    env = dict(os.environ, LD_LIBRARY_PATH=str(arm_dir), **(env_extra or {}))
    t0 = time.monotonic()
    proc = sh(cmd, env=env, log=str(out_dir) + '.log', check=False)
    r = {'exit_code': proc.returncode, 'elapsed_s': round(time.monotonic() - t0, 2), 'arm': str(arm_dir), 'env': env_extra or {},
         'frames': str(Path(out_dir, 'native.frames.csv')), 'stdout_tail': proc.stdout[-1500:]}
    summary = Path(out_dir, 'native.summary.json')
    if summary.exists():
        s = json.loads(summary.read_text())
        r.update({k: s.get(k) for k in ('complete_step_ms_mean', 'complete_step_ms_max', 'missed_8ms', 'initialization_ms', 'physics_ms_mean')})
    return r


def compare_frames(a_frames, b_frames, log):
    proc = sh([sys.executable, REPO / 'tools/diagnostics/destruction-direct-factor/compare_frames.py', a_frames, b_frames], log=log, check=False)
    text = proc.stdout
    mism = {m.group(1): int(m.group(2)) for m in re.finditer(r'^(\S+)\s+mismatching ticks: (\d+)', text, re.M)}
    means = re.search(r'complete_step_ms\s+A mean\s+([\d.]+) max\s+([\d.]+) \| B mean\s+([\d.]+) max\s+([\d.]+)', text)
    misses = re.search(r'>16\.67ms: A (\d+)/(\d+)\s+B (\d+)/(\d+)', text)
    out = {'exit_code': proc.returncode, 'mismatching_ticks': mism, 'identical_histories': bool(mism) and not any(mism.values()), 'text': text}
    if means:
        out.update(a_mean=float(means.group(1)), a_max=float(means.group(2)), b_mean=float(means.group(3)), b_max=float(means.group(4)),
                   ratio=float(means.group(3)) / float(means.group(1)))
    if misses:
        out.update(a_misses=int(misses.group(1)), b_misses=int(misses.group(3)), ticks=int(misses.group(2)))
    return out


def parse_env(spec):
    """'K=V,K2=V2' -> dict; '' -> {}."""
    return dict(kv.split('=', 1) for kv in spec.split(',') if kv.strip()) if spec else {}


def ctest_bin():
    return shutil.which('ctest') or str(Path(sys.executable).parent / 'ctest')


def run_ctest(out_dir, regex='', label='', exclude='', per_test_timeout=600):
    cmd = [ctest_bin(), '--test-dir', REPO / 'out/destruction-sdk', '-j1', '--output-on-failure', '--timeout', per_test_timeout,
           '--output-junit', out_dir / 'ctest.xml']
    if regex:
        cmd += ['-R', regex]
    if label:
        cmd += ['-L', label]
    if exclude:
        cmd += ['-E', exclude]
    t0 = time.monotonic()
    proc = sh(cmd, log=out_dir / 'ctest.log', check=False)
    results = {}
    xml = out_dir / 'ctest.xml'
    if xml.exists():
        import xml.etree.ElementTree as ET
        for tc in ET.parse(xml).getroot().iter('testcase'):
            results[tc.get('name')] = {'status': tc.get('status'), 'seconds': float(tc.get('time') or 0)}
    failed = sorted(n for n, r in results.items() if r['status'] != 'run')
    return {'exit_code': proc.returncode, 'elapsed_s': round(time.monotonic() - t0, 1), 'count': len(results), 'results': results,
            'failed': failed, 'unexpected_failures': sorted(set(failed) - KNOWN_FAILURES),
            'unexpected_passes': sorted(KNOWN_FAILURES & {n for n, r in results.items() if r['status'] == 'run'}),
            'stdout_tail': proc.stdout[-3000:]}


# ----------------------------------------------------------------------------- GPU classes
COMMON_CLS = dict(image=image, gpu=GPU, cpu=4, memory=16384, volumes=VOLUMES, scaledown_window=120)


class _Staged:
    """Mixin: every GPU container stages the bundle + inputs once in @modal.enter().
    Modal only sees parameters declared on the decorated class itself, so each class repeats PARAMS."""

    def _setup(self):
        stage_repo(self.git_sha)
        self.manifest = stage_bundle(self.build_id)
        wanted = self.inputs.split(',')
        names = []
        if 'baseline' in wanted:
            names.append(BASELINE_REL)
        if 'arms' in wanted:
            names += [ARMS_REL + '/A', ARMS_REL + '/B']
        if 'snapshots' in wanted:
            names += [s for s in INPUT_SETS if s.startswith(SNAPSHOTS_REL)]
        stage_inputs(names)
        self.prov = provenance()
        self.prov['build_id'] = self.build_id


@app.cls(timeout=1800, max_containers=12, **COMMON_CLS)
class TimingRunner(_Staged):
    build_id: str = modal.parameter()
    inputs: str = modal.parameter(default='baseline,arms')
    git_sha: str = modal.parameter(default='unknown')

    @modal.enter()
    def setup(self):
        self._setup()

    @modal.method()
    def ab(self, run_id: str, grid: int, seconds: int, workload: str, control: str, env_spec: str, repeats: int, tag: str) -> dict:
        """Paired A/B on one GPU: control libs then candidate libs, per repeat; histories compared."""
        job = f'ab-{tag}'
        d = run_dir(run_id, job)
        ctrl = control_dir(control, self.build_id)
        cand = REPO / LIBDIR_REL
        env_vars = parse_env(env_spec)
        reps = []
        for r in range(repeats):
            a = run_demo(d / f'A-r{r}', grid, workload, seconds, ctrl)
            b = run_demo(d / f'B-r{r}', grid, workload, seconds, cand, env_vars)
            cmp_ = compare_frames(a['frames'], b['frames'], d / f'compare-r{r}.txt') if a['exit_code'] == 0 and b['exit_code'] == 0 else {'identical_histories': None}
            reps.append({'repeat': r, 'A': a, 'B': b, 'compare': cmp_})
        ratios = [x['compare']['ratio'] for x in reps if 'ratio' in x['compare']]
        summary = {'job': job, 'run_id': run_id, 'grid': grid, 'seconds': seconds, 'workload': workload, 'control': control, 'env': env_vars,
                   'repeats': reps, 'median_ratio': statistics.median(ratios) if ratios else None,
                   'a_means': [x['compare'].get('a_mean') for x in reps], 'b_means': [x['compare'].get('b_mean') for x in reps],
                   'identical_histories': all(x['compare'].get('identical_histories') for x in reps) if reps else None,
                   'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2, default=str))
        return publish(run_id, job, summary)


@app.cls(timeout=1800, max_containers=9, **COMMON_CLS)
class WarmRunner(_Staged):
    build_id: str = modal.parameter()
    inputs: str = modal.parameter(default='baseline,arms')
    git_sha: str = modal.parameter(default='unknown')

    @modal.enter()
    def setup(self):
        self._setup()
        self.probe = REPO / REF_REL / 'native_destruction_snapshot_test'
        self.profile_probe = REPO / PROBE_REL / 'serialization-probe'

    @modal.method()
    def window(self, run_id: str, window: str, repetitions: int, contract: str, control: str, direct: bool) -> dict:
        """One warm window: A0, B, A1 serially on this GPU (the paired triple), profiler jobs dropped."""
        job = f'warm-{window}'
        d = run_dir(run_id, job)
        suite = json.loads((REPO / 'tools/profiles/destruction-warm-suite.json').read_text())
        cases = [c for c in suite['cases'] if c['name'] == window]
        if not cases:
            raise ValueError(f'unknown window {window}; known: {[c["name"] for c in suite["cases"]]}')
        suite.update(cases=cases, default_profile_case=window)
        (d / 'suite.json').write_text(json.dumps(suite, indent=2))
        ctrl = control_dir(control, self.build_id)
        profile_probe = self.profile_probe if self.profile_probe.exists() else self.probe
        here = REPO / 'tools/diagnostics/destruction-snapshot'
        sh([sys.executable, here / 'make-warm-screen.py', d / 'plan-full.json', '--binary', self.probe, '--profile-binary', profile_probe,
            '--artifacts', ctrl, '--candidate-binary', self.probe, '--candidate-profile-binary', profile_probe,
            '--candidate-artifacts', REPO / LIBDIR_REL, '--suite', d / 'suite.json', '--repetitions', repetitions], log=d / 'plan.log')
        plan = json.loads((d / 'plan-full.json').read_text())
        plan['jobs'] = [j for j in plan['jobs'] if not j.get('profiler')]
        (d / 'plan.json').write_text(json.dumps(plan, indent=2))
        results = d / 'results'
        t0 = time.monotonic()
        if not Path('/proc/locks').exists():
            direct = True   # run-probe.py's lease check reads /proc/locks, which gVisor does not provide
        if not direct:
            proc = sh([sys.executable, here / 'run-warm-suite.py', d / 'plan.json', results, '--contract-version', contract, '--budget-seconds', 900],
                      log=d / 'run-warm-suite.log', check=False)
            exit_code = proc.returncode
        else:  # fallback: drive run-probe.py ourselves (no lease protocol), then the paired checker
            results.mkdir()
            exit_code = 0
            checker = here / f'compare-warm-observations-v{contract}.py' if contract != '1' else here / 'compare-warm-observations.py'
            record = {'status': 'running', 'plan': plan, 'jobs': [], 'contract_version': contract, 'mode': 'direct'}
            env = dict(os.environ, PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first')
            for j in plan['jobs']:
                dest = results / j['name']
                cmd = [sys.executable, here / 'run-probe.py', dest, '--binary', j.get('binary', plan['binary']), '--artifacts', j.get('artifacts', plan['artifacts']),
                       '--replay-prefix', j['prefix'], '--repetitions', j.get('repetitions', 2), '--watchdog-seconds', 180]
                if 'warmup_ticks' in j:
                    cmd += ['--warmup-ticks', j['warmup_ticks'], '--measure-ticks', j.get('measure_ticks', 1)]
                proc = sh(cmd, env=env, log=results / (j['name'] + '.log'), check=False)
                entry = {'name': j['name'], 'exit_code': proc.returncode, 'status': 'complete' if proc.returncode == 0 else 'failed'}
                if proc.returncode == 0 and j.get('compare_to'):
                    chk = sh([sys.executable, checker, results / j['compare_to'], dest, results / (j['name'] + '-physical.json'), '--all-errors'],
                             log=results / (j['name'] + '-check.log'), check=False)
                    entry['physical_comparison_exit_code'] = chk.returncode
                    if chk.returncode:
                        entry['status'] = 'failed'
                record['jobs'].append(entry)
                exit_code |= proc.returncode
            record['status'] = 'complete' if all(e['status'] == 'complete' for e in record['jobs']) else 'failed'
            (results / 'campaign.json').write_text(json.dumps(record, indent=2))
        arms = {}
        for arm in ('A0', 'B', 'A1'):
            f = results / f'{window}-{arm}' / 'replay.json'
            if f.exists():
                try:
                    s = [x['complete_step_ms'] for x in json.loads(f.read_text())['samples'] if x.get('measured')]
                    arms[arm] = {'mean_ms': statistics.mean(s), 'max_ms': max(s), 'misses': sum(v > 16.67 for v in s), 'ticks': len(s)}
                except Exception as e:  # noqa: BLE001  (partial file after a failed probe; the log is published anyway)
                    arms[arm] = {'error': f'{type(e).__name__}: {e}', 'bytes': f.stat().st_size, 'head': f.read_text()[:300]}
        physical = results / f'{window}-B-physical.json'
        campaign = results / 'campaign.json'
        summary = {'job': job, 'run_id': run_id, 'window': window, 'exit_code': exit_code, 'elapsed_s': round(time.monotonic() - t0, 1), 'arms': arms,
                   'ratio': arms['B']['mean_ms'] / arms['A0']['mean_ms'] if 'mean_ms' in arms.get('B', {}) and 'mean_ms' in arms.get('A0', {}) else None,
                   'physical_status': json.loads(physical.read_text()).get('status') if physical.exists() else None,
                   'campaign_status': json.loads(campaign.read_text()).get('status') if campaign.exists() else None,
                   'campaign_error': json.loads(campaign.read_text()).get('error') if campaign.exists() else None,
                   'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2, default=str))
        return publish(run_id, job, summary)


@app.cls(timeout=7200, max_containers=2, **COMMON_CLS)
class CampaignRunner(_Staged):
    build_id: str = modal.parameter()
    inputs: str = modal.parameter(default='baseline,arms')
    git_sha: str = modal.parameter(default='unknown')

    @modal.enter()
    def setup(self):
        self._setup()

    @modal.method()
    def case(self, run_id: str, case_id: str, trials: int, seconds: int, control: str, hypothesis: str) -> dict:
        """One campaign case with A-before / B / A-after on this GPU, mirroring run-destruction-ab.py."""
        import importlib.util
        job = f'campaign-{case_id}'
        d = run_dir(run_id, job)
        spec = importlib.util.spec_from_file_location('ab', REPO / 'tools/scripts/run-destruction-ab.py')
        ab = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(ab)
        config = json.loads((REPO / 'tools/profiles/destruction-ordinary-ab.json').read_text())
        case = next(c for c in config['cases'] if c['id'] == case_id)
        (d / 'config.json').write_text(json.dumps(config, indent=2))
        arms = {'A': REPO / ARMS_REL / 'A' if control == 'arms-A' else make_arm('control', control_dir(control, self.build_id)),
                'B': make_arm('B', REPO / LIBDIR_REL)}
        receipt = {'schema': 'modal-campaign-case-1', 'run_id': run_id, 'case': case_id, 'hypothesis': hypothesis, 'trials': trials, 'seconds': seconds,
                   'artifacts': {k: ab.artifacts(v) for k, v in arms.items()}, 'runs': [], 'comparisons': [], 'status': 'running', 'provenance': self.prov}
        save = lambda: (d / 'experiment.json').write_text(json.dumps(receipt, indent=2, default=str))  # noqa: E731
        deadline_failure = False
        t0 = time.monotonic()
        try:
            for stage, arm in (('A-before', 'A'), ('B', 'B'), ('A-after', 'A')):
                directory = d / stage / case_id
                cmd = [sys.executable, REPO / 'tools/scripts/run-destruction-timing.py', directory, '--binary', arms[arm] / 'native_destruction_demo',
                       '--config', d / 'config.json', '--case', case_id, '--trials', trials, '--seconds', seconds, '--gate-only']
                record = {'stage': stage, 'case': case_id, 'LD_LIBRARY_PATH': str(arms[arm])}
                receipt['runs'].append(record); save()
                proc = sh(cmd, env=dict(os.environ, LD_LIBRARY_PATH=str(arms[arm])), log=d / f'{stage}-{case_id}.log', check=False)
                record['exit_code'] = proc.returncode; save()
                campaign = json.loads((directory / 'campaign.json').read_text())
                ab.verify_campaign(campaign, arms[arm], receipt['artifacts'][arm])
                if proc.returncode not in (0, 2):
                    raise ValueError(f'capture/report failed: {directory}\n{proc.stdout[-2000:]}')
                record['report'] = str(directory / 'report/report.json.gz')
                deadline_failure |= proc.returncode == 2
                save()
            for stage in ('A-before', 'A-after'):
                out = d / 'comparisons' / stage / case_id
                proc = sh([sys.executable, REPO / 'tools/scripts/compare-destruction-candidates.py', '--baseline', d / stage / case_id / 'report/report.json.gz',
                           '--candidate', d / 'B' / case_id / 'report/report.json.gz', '--output', out], log=d / f'compare-{stage}.log', check=False)
                entry = {'stage': stage, 'exit_code': proc.returncode}
                cj = out / 'comparison.json'
                if cj.exists():
                    c = json.loads(cj.read_text())
                    entry.update(aggregates=c.get('aggregates'), physical_counter_differences=len(c.get('physical_counter_differences') or []),
                                 iteration_differences=len(c.get('iteration_differences') or []))
                    receipt['physical_comparison_failed'] = receipt.get('physical_comparison_failed', False) or bool(c.get('physical_counter_differences'))
                receipt['comparisons'].append(entry); save()
            receipt.update(deadline_gate_failed=deadline_failure, status='complete')
        except BaseException as e:  # noqa: BLE001
            receipt.update(status='failed', error=str(e))
        receipt['elapsed_s'] = round(time.monotonic() - t0, 1)
        save()
        return publish(run_id, job, receipt)


@app.cls(timeout=3600, max_containers=8, **COMMON_CLS)
class TestRunner(_Staged):
    build_id: str = modal.parameter()
    inputs: str = modal.parameter(default='baseline,arms')
    git_sha: str = modal.parameter(default='unknown')

    @modal.enter()
    def setup(self):
        self._setup()

    @modal.method()
    def ctest(self, run_id: str, shard: str, regex: str, label: str, exclude: str) -> dict:
        job = f'tests-{shard}'
        d = run_dir(run_id, job)
        summary = {'job': job, 'run_id': run_id, 'regex': regex, 'label': label, **run_ctest(d, regex, label, exclude), 'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2))
        return publish(run_id, job, summary)

    @modal.method()
    def sanitize(self, run_id: str, tool: str, target: str, args: str) -> dict:
        job = f'sanitizer-{tool}-{target}'
        d = run_dir(run_id, job)
        cmd = [SANITIZER, '--tool', tool, '--error-exitcode', '97', REPO / REF_REL / target, *args.split()]
        t0 = time.monotonic()
        proc = sh(cmd, log=d / 'sanitizer.log', check=False, timeout=3000)
        m = re.search(r'ERROR SUMMARY: (\d+) error', proc.stdout)
        summary = {'job': job, 'run_id': run_id, 'tool': tool, 'target': target, 'exit_code': proc.returncode, 'errors': int(m.group(1)) if m else None,
                   'elapsed_s': round(time.monotonic() - t0, 1), 'stdout_tail': proc.stdout[-3000:], 'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2))
        return publish(run_id, job, summary)


@app.cls(timeout=1800, max_containers=4, **COMMON_CLS)
class InstrumentedRunner(_Staged):
    build_id: str = modal.parameter()
    inputs: str = modal.parameter(default='baseline,arms')
    git_sha: str = modal.parameter(default='unknown')

    @modal.enter()
    def setup(self):
        self._setup()

    @modal.method()
    def profile(self, run_id: str, grid: int, workload: str, seconds: int, env_spec: str) -> dict:
        """nsys trace of one demo run (no CPU sampling; graph nodes traced), plus the kernel summary."""
        job = f'nsys-g{grid}-{workload}'
        d = run_dir(run_id, job)
        env = dict(os.environ, LD_LIBRARY_PATH=str(REPO / LIBDIR_REL), **parse_env(env_spec))
        demo_out = d / 'demo'
        cmd = [NSYS, 'profile', '--trace=cuda,nvtx', '--sample=none', '--cpuctxsw=none', '--cuda-graph-trace=node', '--force-overwrite=true',
               '-o', d / 'trace', REPO / REF_REL / 'native_destruction_demo', *common_demo_args(), '--grid', grid, '--workload', workload, '--seconds', seconds,
               '--output', demo_out]
        t0 = time.monotonic()
        proc = sh(cmd, env=env, log=d / 'nsys.log', check=False)
        stats = ''
        if proc.returncode == 0:
            for stale in d.glob('*.sqlite'):
                stale.unlink()
            stats = sh([NSYS, 'stats', '--report', 'cuda_gpu_kern_sum', '--format', 'csv', d / 'trace.nsys-rep'], log=d / 'stats.log', check=False).stdout
            (d / 'kernels.csv').write_text(stats)
        summary = {'job': job, 'run_id': run_id, 'exit_code': proc.returncode, 'elapsed_s': round(time.monotonic() - t0, 1),
                   'kernel_summary_head': '\n'.join(stats.splitlines()[:30]), 'stdout_tail': proc.stdout[-2000:], 'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2))
        return publish(run_id, job, summary)

    @modal.method()
    def census(self, run_id: str, grid: int, workload: str, seconds: int, lo: int, hi: int) -> dict:
        """Per-component work census with the intrusive diagnostic runtime selected via LD_LIBRARY_PATH."""
        job = f'census-g{grid}-{workload}'
        d = run_dir(run_id, job)
        diag = REPO / DIAG_REL
        lib = REPO / LIBDIR_REL
        ldd = sh(['ldd', lib / 'libPhysXGpuActivity_64.so'], env=dict(os.environ, LD_LIBRARY_PATH=f'{diag}:{lib}'), check=False).stdout
        if str(diag / 'libPhysXDestructionGpuRuntime_64.so') not in ldd:
            raise RuntimeError('diagnostic runtime was not selected:\n' + ldd)
        out_jsonl = d / 'components.jsonl'
        r = run_demo(d / 'demo', grid, workload, seconds, f'{diag}:{lib}', {'PHYSX_COMPONENT_WORK_OUTPUT': str(out_jsonl)})
        census = sh([sys.executable, REPO / 'tools/diagnostics/destruction-direct-factor/component_census.py', out_jsonl, lo, hi], check=False).stdout if out_jsonl.exists() else ''
        (d / 'census.txt').write_text(census)
        summary = {'job': job, 'run_id': run_id, 'demo': r, 'lo': lo, 'hi': hi, 'census': census, 'provenance': self.prov}
        (d / 'summary.json').write_text(json.dumps(summary, indent=2, default=str))
        sh(['gzip', '-f', out_jsonl], check=False)
        return publish(run_id, job, summary)


@app.function(image=image, gpu=GPU, cpu=4, memory=16384, volumes=VOLUMES, timeout=900)
def smoke_remote(build_id: str, git_sha: str) -> dict:
    """Ladder steps 1-2: image, driver, runtime, tool paths; optionally one stress test + tiny demo from a bundle."""
    stage_repo(git_sha)
    info = {'provenance': provenance(), 'nvidia_smi_q': sh(['nvidia-smi', '-q', '-x'], check=False).stdout[:1500]}
    info['ldconfig_cudart'] = [l for l in sh(['ldconfig', '-p'], check=False).stdout.splitlines() if 'libcudart' in l]
    info['nsys_path'] = os.path.realpath(NSYS) if Path(NSYS).exists() else None
    info['libcuda_candidates'] = sh(['sh', '-c', 'ls -la /usr/lib/x86_64-linux-gnu/libcuda.so* /usr/local/cuda*/compat/libcuda.so* /usr/local/nvidia/lib64/libcuda.so* 2>/dev/null; cat /etc/ld.so.conf.d/*.conf'], check=False).stdout
    info['ldconfig_libcuda'] = [l.strip() for l in sh(['ldconfig', '-p'], check=False).stdout.splitlines() if 'libcuda.so' in l]
    probe = ("import ctypes,sys; c=ctypes.CDLL('libcuda.so.1'); v=ctypes.c_int(); c.cuDriverGetVersion(ctypes.byref(v)); rc=c.cuInit(0); n=ctypes.c_int(); "
             "rc2=c.cuDeviceGetCount(ctypes.byref(n)) if rc==0 else -1; print('driver_api',v.value,'cuInit',rc,'devices',n.value if rc==0 else None,'count_rc',rc2); "
             "import subprocess; print(subprocess.run(['sh','-c','grep libcuda /proc/%d/maps | head -1' % __import__('os').getpid()],capture_output=True,text=True).stdout.strip())")
    system_dir = next((os.path.dirname(l.split('=>')[-1].strip()) for l in info['ldconfig_libcuda'] if '/compat/' not in l), '/usr/lib/x86_64-linux-gnu')
    info['system_driver_dir'] = system_dir
    info['cuinit_default'] = sh([sys.executable, '-c', probe], check=False).stdout.strip()
    info['cuinit_system_driver'] = sh([sys.executable, '-c', probe], env=dict(os.environ, LD_LIBRARY_PATH=system_dir), check=False).stdout.strip()
    if build_id:
        stage_bundle(build_id)
        stage_inputs([BASELINE_REL])
        d = REPO / 'out/modal/smoke'
        d.mkdir(parents=True)
        t = sh([REPO / REF_REL / 'gpu_resident_stress_3d_test'], log=d / 'stress3d.log', check=False, timeout=600)
        info['gpu_resident_stress_3d_test'] = {'exit_code': t.returncode, 'tail': t.stdout[-1500:]}
        info['demo_idle_g2'] = run_demo(d / 'demo', 2, 'idle', 3, REPO / LIBDIR_REL)
        info['demo_idle_g2_system_driver'] = run_demo(d / 'demo-sysdrv', 2, 'idle', 3, f'{REPO / LIBDIR_REL}:{system_dir}')
        info['destruction_test_system_driver'] = sh([REPO / REF_REL / 'native_gpu_destruction_test'], env=dict(os.environ, LD_LIBRARY_PATH=system_dir),
                                                    log=d / 'destruction-test.log', check=False, timeout=600).stdout[-1500:]
        # genuine 580 driver library (the compat package re-pointed libcuda.so.1 at 615): isolate it in a private dir
        real = d / 'driver580'
        real.mkdir()
        for so in Path(system_dir).glob('libcuda.so.5*'):
            (real / 'libcuda.so.1').symlink_to(so)
            (real / so.name).symlink_to(so)
        for so in Path(system_dir).glob('libnvidia-ptxjitcompiler.so.5*'):
            (real / 'libnvidia-ptxjitcompiler.so.1').symlink_to(so)
        info['driver580_dir'] = sorted(p.name for p in real.iterdir())
        info['cuinit_driver580'] = sh([sys.executable, '-c', probe], env=dict(os.environ, LD_LIBRARY_PATH=str(real)), check=False).stdout.strip()
        info['demo_idle_g2_driver580'] = run_demo(d / 'demo-580', 2, 'idle', 3, f'{real}:{REPO / LIBDIR_REL}')
        dl = ("import ctypes,sys; "
              "[print(n, ctypes.CDLL(n, mode=ctypes.RTLD_GLOBAL) and 'ok') for n in ['libcuda.so.1']]; "
              "import os; os.chdir('%s'); "
              "print(ctypes.CDLL('%s/libPhysXGpuActivity_64.so', mode=ctypes.RTLD_GLOBAL) and 'gpu module ok')" % (REPO / LIBDIR_REL, REPO / LIBDIR_REL))
        info['dlopen_gpu_module_default'] = sh([sys.executable, '-c', dl], check=False).stdout[-1200:]
        info['dlopen_gpu_module_driver580'] = sh([sys.executable, '-c', dl], env=dict(os.environ, LD_LIBRARY_PATH=str(real)), check=False).stdout[-1200:]
        info['ldd_r_gpu_module'] = [l.strip() for l in sh(['ldd', '-r', REPO / LIBDIR_REL / 'libPhysXGpuActivity_64.so'], check=False).stdout.splitlines() if 'undefined' in l or 'not found' in l][:20]
        info['demo_idle_g2_stderr_env'] = run_demo(d / 'demo-verbose', 2, 'idle', 3, REPO / LIBDIR_REL, {'PHYSX_DESTRUCTION_ALLOC_DIAG': '1', 'CUDA_LAUNCH_BLOCKING': '1'})
        ldd = sh(['ldd', REPO / REF_REL / 'native_destruction_demo'], check=False).stdout
        info['demo_missing_libs'] = [l.strip() for l in ldd.splitlines() if 'not found' in l]
    return info


@app.function(image=image, gpu=GPU, cpu=4, memory=16384, volumes=VOLUMES, timeout=1800)
def adhoc_remote(blob_sha: str, name: str, arg_sets: list, sanitizer: str, driver: str, build_id: str = '', env_spec: str = '',
                 preload_sha: str = '', preload_name: str = '', lib_dir: str = '', wrapper: str = '') -> dict:
    """Run a binary on a Modal GPU with several argument sets. The binary is either an uploaded local file (blob_sha)
    or a repo-relative path inside a staged bundle (build_id + name). Optional sanitizer, env, LD_PRELOAD, driver library."""
    stage_repo()
    inputs_vol.reload()
    d = REPO / 'out/modal/adhoc'
    d.mkdir(parents=True)
    if build_id:
        stage_bundle(build_id)
        stage_inputs([BASELINE_REL])
        binary = REPO / name
    else:
        binary = d / name
        shutil.copyfile(Path(VOL_INPUTS, 'adhoc', blob_sha), binary)
        os.chmod(binary, 0o755)
    env = dict(os.environ, **parse_env(env_spec))
    if lib_dir:
        env['LD_LIBRARY_PATH'] = str(REPO / lib_dir)
    if preload_sha:
        pre = d / preload_name
        shutil.copyfile(Path(VOL_INPUTS, 'adhoc', preload_sha), pre)
        env['LD_PRELOAD'] = str(pre)
    if driver == '580':   # genuine host driver library instead of the cuda-compat one
        real = d / 'driver580'
        real.mkdir()
        for so in Path('/usr/lib/x86_64-linux-gnu').glob('libcuda.so.5*'):
            (real / 'libcuda.so.1').symlink_to(so)
        env['LD_LIBRARY_PATH'] = str(real) + (':' + env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
    out = {'provenance': provenance(), 'driver_mode': driver, 'runs': []}
    for args in arg_sets:
        cmd = [binary, *args]
        if sanitizer:
            cmd = [env.get('SANITIZER_BIN', SANITIZER), '--tool', sanitizer, '--error-exitcode', '99', '--print-limit', '3', *cmd]
        if wrapper == 'gdb':
            cmd = ['gdb', '-q', '-batch', '-ex', 'set pagination off', '-ex', 'run', '-ex', 'bt 25', '-ex', 'info symbol $pc', '-ex', 'x/12i $pc-40', '-ex', 'info registers rax rbx rcx rdx rsi rdi rbp rsp r12 r13 r14 r15', '-ex', 'info sharedlibrary', '--args', *cmd]
        elif wrapper == 'gdb-errors':   # print every PhysX error-callback message (message pointer is the 3rd argument: rdx), then the crash backtrace
            script = d / 'errors.gdb'
            script.write_text('set pagination off\nset breakpoint pending on\nbreak blast_demo::TrackingErrorCallback::reportError\ncommands\nsilent\nprintf "[physx-error] %s\\n", (char*)$rdx\ncontinue\nend\nrun\nbt 12\n')
            cmd = ['gdb', '-q', '-batch', '-x', script, '--args', *cmd]
        elif wrapper == 'nsys':
            cmd = [env.get('NSYS_BIN', NSYS), 'profile', '--trace=cuda,nvtx', '--sample=none', '--cpuctxsw=none', '--cuda-graph-trace=node', '--force-overwrite=true',
                   '-o', d / f'trace-{len(out["runs"])}', *cmd]
        t0 = time.monotonic()
        proc = sh(cmd, env=env, check=False, timeout=1500)
        run = {'args': args, 'sanitizer': sanitizer, 'wrapper': wrapper, 'exit_code': proc.returncode, 'elapsed_s': round(time.monotonic() - t0, 2), 'output': proc.stdout[-3500:]}
        if wrapper == 'nsys' and proc.returncode == 0:
            run['kernels'] = sh([env.get('NSYS_BIN', NSYS), 'stats', '--report', 'cuda_gpu_kern_sum', '--format', 'csv', d / f'trace-{len(out["runs"])}.nsys-rep'], check=False).stdout[-2500:]
        if wrapper == 'nsys':
            run['nsys_versions'] = sh(['sh', '-c', 'ls -d /opt/nvidia/nsight-systems/*/'], check=False).stdout
        out['runs'].append(run)
    return out


# ----------------------------------------------------------------------------- local side
def local_git():
    try:
        sha = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=LOCAL_ROOT, text=True).strip()
        status = subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'], cwd=LOCAL_ROOT, text=True)
        patch = subprocess.check_output(['git', 'diff', 'HEAD', '--binary'], cwd=LOCAL_ROOT)
    except Exception:  # noqa: BLE001
        return {'sha': 'unknown', 'dirty': None, 'status': '', 'patch': b''}
    return {'sha': sha, 'dirty': bool(status.strip()), 'status': status, 'patch': patch}


def bundle_files(profile_probe_dir, build_root=''):
    """Files that make up a run bundle as (local_path, canonical repo-relative path) pairs.
    build_root='' scans the canonical trees; build_root='out/modal/sm89' scans an alternate tree laid out as
    <root>/physx/bin/..., <root>/sdk-release, <root>/destruction-sdk and maps them to the canonical paths."""
    root = LOCAL_ROOT
    files = []

    def local_of(rel):
        if not build_root:
            return root / rel
        alt = rel.replace('out/sdk-release', f'{build_root}/sdk-release', 1).replace('out/destruction-sdk', f'{build_root}/destruction-sdk', 1)
        alt = alt.replace('physx/bin/', f'{build_root}/physx/bin/', 1) if rel.startswith('physx/bin/') else alt
        return root / alt

    def add(rel):
        p = local_of(rel)
        if p.is_file():
            files.append((p.resolve(), rel))

    for p in sorted(local_of(LIBDIR_REL).glob('*.so')):
        add(f'{LIBDIR_REL}/{p.name}')
    add(f'{DIAG_REL}/libPhysXDestructionGpuRuntime_64.so')
    add('out/sdk-artifacts.json')
    add('out/destruction-sdk/CTestTestfile.cmake')
    for sub in (REF_REL, TOPO_REL):
        for name in ('CTestTestfile.cmake', 'DartConfiguration.tcl'):
            add(f'{sub}/{name}')
        for p in sorted(local_of(sub).iterdir()):
            if p.is_file() and os.access(p, os.X_OK) and not p.suffix in ('.a', '.cmake', '.tcl', '.txt') and p.name != 'Makefile':
                add(f'{sub}/{p.name}')
    pp = Path(profile_probe_dir)
    if pp.is_dir() and not build_root:
        for name in ('serialization-probe', 'build.json'):
            if (pp / name).is_file():
                files.append(((pp / name).resolve(), f'{PROBE_REL}/{name}'))
    return files


def vol_read_json(vol, path, default=None):
    try:
        return json.loads(b''.join(vol.read_file(path)))
    except Exception:  # noqa: BLE001
        return default


GPU_ARCH = {'RTX-PRO-6000': '120', 'L4': '89', 'L40S': '89'}


def resolve_build(build_id):
    if build_id:
        return build_id
    arch = GPU_ARCH.get(GPU.rstrip('!'), '120')
    latest = vol_read_json(builds_vol, f'bundles/latest-sm{arch}.json') or (vol_read_json(builds_vol, 'bundles/latest.json') if arch == '120' else None)
    if not latest:
        sys.exit('no pushed bundle; run `modal run tools/modal/gpu_run.py::push` first')
    return latest['build_id']


def new_run_id(tag):
    return f'{utc_stamp()}-{tag}'


def fetch_run(run_id, dest_root=None):
    """Download every <job>.tar/<job>.json for a run and unpack under out/modal/<run_id>/ (same relative layout as the container)."""
    dest = Path(dest_root or LOCAL_ROOT / 'out/modal') / run_id
    dest.mkdir(parents=True, exist_ok=True)
    if not modal.is_local():
        results_vol.reload()
    n = 0
    for entry in results_vol.listdir(f'/{run_id}'):
        name = entry.path.rsplit('/', 1)[-1]
        data = b''.join(results_vol.read_file(entry.path))
        if name.endswith('.tar'):
            with tarfile.open(fileobj=io.BytesIO(data)) as tar:
                tar.extractall(dest)
            n += 1
        else:
            (dest / name).write_bytes(data)
    return dest, n


def print_table(headers, rows):
    widths = [max(len(str(x)) for x in col) for col in zip(headers, *rows)] if rows else [len(h) for h in headers]
    line = lambda r: '| ' + ' | '.join(str(x).ljust(w) for x, w in zip(r, widths)) + ' |'  # noqa: E731
    print(line(headers)); print('|' + '|'.join('-' * (w + 2) for w in widths) + '|')
    for r in rows:
        print(line(r))


def estimate(gpu_minutes):
    return gpu_minutes * 60 * GPU_RATE_PER_S


@app.function(image=image, gpu=GPU, cpu=1, memory=2048, timeout=600, max_containers=64)
def capacity_remote(i: int, hold_s: int) -> dict:
    t = time.time()
    q = 'name,uuid,driver_version'
    smi = sh(['nvidia-smi', f'--query-gpu={q}', '--format=csv,noheader'], check=False, cwd='/').stdout.strip()
    time.sleep(hold_s)
    return {'i': i, 'started': t, 'gpu': smi, 'region': os.environ.get('MODAL_REGION'), 'task': os.environ.get('MODAL_TASK_ID')}


@app.local_entrypoint()
def capacity(n: int = 12, hold_s: int = 60):
    """Ask for n GPUs of the class in PHYSX_MODAL_GPU at once and report when each one actually started."""
    t0 = time.time()
    print(f'requesting {n} x {GPU}, holding each {hold_s}s')
    starts = []
    for r in capacity_remote.map(list(range(n)), [hold_s] * n, order_outputs=False):
        starts.append(r['started'] - t0)
        print(f'  #{len(starts):2d} started at {starts[-1]:6.1f}s  {r["gpu"][:60]}  {r["region"]}')
    starts.sort()
    print(f'{GPU}: first {starts[0]:.0f}s, 5th {starts[min(4, n - 1)]:.0f}s, 10th {starts[min(9, n - 1)]:.0f}s, last {starts[-1]:.0f}s of {n}; concurrent within 30 s of first: {sum(s < starts[0] + 30 for s in starts)}')


@app.local_entrypoint()
def smoke(build_id: str = ''):
    """Ladder 1-2: image, driver/runtime versions, tool paths; with --build-id also a stress test and a tiny demo."""
    info = smoke_remote.remote(build_id, local_git()['sha'])
    print(json.dumps(info, indent=2, default=str))


@app.local_entrypoint()
def adhoc(binary: str, args: str = '', sanitizer: str = '', driver: str = 'default', build_id: str = '', env: str = '', preload: str = '', lib_dir: str = '', wrapper: str = ''):
    """Run a binary on a Modal GPU. --binary: a local file (uploaded) or, with --build-id, a repo-relative path in that bundle.
    --args 'a b;c d' runs it twice; --sanitizer memcheck; --driver 580|default; --env K=V,K=V; --preload local.so; --lib-dir repo-relative LD_LIBRARY_PATH."""
    path = Path(binary)
    digest = ''
    preload_sha = ''
    with inputs_vol.batch_upload(force=True) as batch:
        if not build_id:
            digest = sha256(path)
            batch.put_file(str(path), f'adhoc/{digest}')
        if preload:
            preload_sha = sha256(Path(preload))
            batch.put_file(preload, f'adhoc/{preload_sha}')
    arg_sets = [a.split() for a in args.split(';')] if args else [[]]
    r = adhoc_remote.remote(digest, binary if build_id else path.name, arg_sets, sanitizer, driver, build_id, env, preload_sha, Path(preload).name if preload else '', lib_dir, wrapper)
    print(r['provenance']['nvidia_smi'], '| driver mode', driver)
    for run in r['runs']:
        print(f"\n=== args={run['args']} sanitizer={run['sanitizer'] or '-'} wrapper={run.get('wrapper') or '-'} exit={run['exit_code']} {run['elapsed_s']}s\n{run['output']}")
        if run.get('kernels'):
            print('--- kernels\n' + run['kernels'])


@app.local_entrypoint()
def inputs(force: bool = False):
    """Upload the frozen arms and warm-window snapshots once (skips sets already on the volume)."""
    existing = set()
    try:
        existing = {e.path.strip('/') for e in inputs_vol.listdir('/', recursive=True)}
    except Exception:  # noqa: BLE001
        pass
    with inputs_vol.batch_upload(force=force) as batch:
        for rel in INPUT_SETS:
            remote = rel[len('out/'):]
            local = LOCAL_ROOT / rel
            if not local.exists():
                print('missing locally, skipped:', rel); continue
            if not force and any(e.startswith(remote) for e in existing):
                print('already on volume:', remote); continue
            print('uploading', rel)
            batch.put_directory(str(local), remote)
    print('done; volume physx-inputs')


@app.local_entrypoint()
def push(profile_probe: str = 'out/probes/profile', note: str = '', arch: str = '120', build_root: str = ''):
    """Hash the local build outputs, upload only new blobs, write bundles/<build_id>.json and latest-<arch>.json.
    --arch 89 --build-root out/modal/sm89 pushes an alternate tree (see README, L4/L40S)."""
    if not (LOCAL_ROOT / PROBE_REL).exists() and profile_probe == 'out/probes/profile' and (LOCAL_ROOT / 'out/warm-replay-20260915/profile').exists():
        profile_probe = 'out/warm-replay-20260915/profile'
    git = local_git()
    files = bundle_files(LOCAL_ROOT / profile_probe, build_root)
    entries = []
    for local, rel in files:
        st = local.stat()
        entries.append({'path': rel, 'sha256': sha256(local), 'size': st.st_size, 'mode': st.st_mode & 0o777, 'local': str(local)})
    if not entries:
        sys.exit(f'no bundle files found under {build_root or "the canonical trees"}')
    build_id = f'{utc_stamp()}-sm{arch}-{git["sha"][:10]}' + ('-dirty' if git['dirty'] else '')
    # ABI-skew guard: statically linked tests must be built from the same headers as the shipped modules.
    oldest = min(Path(e['local']).stat().st_mtime for e in entries if e['path'].endswith('.so') or '/reference/' in e['path'])
    newer = sorted(str(f.relative_to(LOCAL_ROOT)) for sub in ('physx/source', 'blast/source', 'demos') for f in (LOCAL_ROOT / sub).rglob('*')
                   if f.is_file() and f.suffix in ('.h', '.hpp', '.inl', '.cuh', '.cu', '.cpp') and f.stat().st_mtime > oldest)
    spread = max(Path(e['local']).stat().st_mtime for e in entries) - oldest
    if newer or spread > 3 * 3600:
        print(f'WARNING: possible ABI skew: {len(newer)} sources newer than the oldest shipped binary, binaries span {spread / 60:.0f} min: '
              + ', '.join(newer[:6]) + (' ...' if len(newer) > 6 else ''))
    have = set()
    try:
        have = {e.path.rsplit('/', 1)[-1] for e in builds_vol.listdir('/blobs')}
    except Exception:  # noqa: BLE001
        pass
    todo = [e for e in {e['sha256']: e for e in entries}.values() if e['sha256'] not in have]
    patch_sha = hashlib.sha256(git['patch']).hexdigest()
    with builds_vol.batch_upload(force=True) as batch:
        for e in todo:
            batch.put_file(e['local'], f'blobs/{e["sha256"]}')
        if git['patch'] and patch_sha not in have:
            batch.put_file(io.BytesIO(git['patch']), f'blobs/{patch_sha}')
        # binaries in an alternate tree bake an rpath to <root>/<build_root>/physx/bin/...; the container aliases it to the canonical lib dir
        rpath_alias = f'{build_root}/{LIBDIR_REL}' if build_root else ''
        manifest = {'build_id': build_id, 'created': utc_stamp(), 'note': note, 'arch': arch, 'build_root': build_root, 'rpath_alias': rpath_alias,
                    'git': {k: git[k] for k in ('sha', 'dirty', 'status')},
                    'worktree_patch_sha256': patch_sha, 'host': os.uname().nodename, 'local_root': str(LOCAL_ROOT), 'profile_probe_dir': profile_probe,
                    'files': [{k: v for k, v in e.items() if k != 'local'} for e in entries], 'bytes': sum(e['size'] for e in entries),
                    'skew': {'sources_newer_than_oldest_binary': newer, 'binary_mtime_spread_s': round(spread)}}
        batch.put_file(io.BytesIO(json.dumps(manifest, indent=2).encode()), f'bundles/{build_id}.json')
        batch.put_file(io.BytesIO(json.dumps({'build_id': build_id}).encode()), f'bundles/latest-sm{arch}.json')
        if arch == '120':
            batch.put_file(io.BytesIO(json.dumps({'build_id': build_id}).encode()), 'bundles/latest.json')
    print(f'build_id {build_id}: {len(entries)} files, {manifest["bytes"] / 1e6:.0f} MB, uploaded {len(todo)} new blobs '
          f'({sum(e["size"] for e in todo) / 1e6:.0f} MB); git {git["sha"][:10]} dirty={git["dirty"]}')


def _ctest_names(regex, label):
    """List locally registered ctest names by parsing CTestTestfile.cmake (no round trip)."""
    names = []
    for sub in (REF_REL, TOPO_REL):
        f = LOCAL_ROOT / sub / 'CTestTestfile.cmake'
        if f.exists():
            names += re.findall(r'add_test\(\[=\[([^\]]+)\]=\]', f.read_text())
    if regex:
        names = [n for n in names if re.search(regex, n)]
    return names


@app.local_entrypoint()
def tests(build_id: str = '', subset: str = 'eleven', shards: int = 1, sanitizers: str = '', sanitizer_targets: str = 'gpu_resident_stress_3d_test,gpu_resident_motion_modes_test',
          tag: str = 'tests'):
    """ctest subsets (eleven|gpu|all|<regex>) sharded across GPUs, plus optional compute-sanitizer tools (memcheck,initcheck,synccheck)."""
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    regex, label = {'eleven': (ELEVEN, ''), 'gpu': ('', 'gpu'), 'all': ('', '')}.get(subset, (subset, ''))
    runner = TestRunner(build_id=build_id, git_sha=local_git()['sha'])
    calls = []
    if shards > 1 and not label:
        names = _ctest_names(regex, label)
        for i in range(shards):
            part = names[i::shards]
            if part:
                calls.append(runner.ctest.spawn(run_id, f'shard{i}', '^(' + '|'.join(re.escape(n) for n in part) + ')$', '', ''))
    else:
        calls.append(runner.ctest.spawn(run_id, subset.replace('^', '').replace('$', '')[:20] or 'all', regex, label, ''))
    for tool in [t for t in sanitizers.split(',') if t]:
        for target in sanitizer_targets.split(','):
            calls.append(runner.sanitize.spawn(run_id, tool, target, ''))
    print('run', run_id, 'build', build_id, '->', len(calls), 'containers')
    rows = []
    for c in calls:
        r = c.get()
        if 'results' in r:
            rows.append([r['job'], r['count'], len(r['failed']), ','.join(r['unexpected_failures']) or '-', ','.join(r['unexpected_passes']) or '-', r['elapsed_s'], r['provenance']['nvidia_smi'][:40]])
        else:
            rows.append([r['job'], '-', r['errors'], f'exit {r["exit_code"]}', '-', r['elapsed_s'], r['provenance']['nvidia_smi'][:40]])
    print_table(['job', 'tests', 'failed', 'unexpected failures', 'unexpected passes', 's', 'gpu'], rows)
    dest, n = fetch_run(run_id)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def ab(build_id: str = '', grid: int = 16, seconds: int = 3, workload: str = 'bombardment', control: str = 'self', variants: str = '',
       repeats: int = 3, tag: str = 'ab'):
    """Paired A/B: one GPU per variant (';'-separated 'K=V,K=V' env sets; '' = unmodified candidate), control arm run first in the same container."""
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    runner = TimingRunner(build_id=build_id, git_sha=local_git()['sha'])
    specs = variants.split(';') if variants else ['']
    calls = [(spec, runner.ab.spawn(run_id, grid, seconds, workload, control, spec, repeats, f'v{i}' if spec else 'base')) for i, spec in enumerate(specs)]
    print('run', run_id, 'build', build_id, '->', len(calls), 'containers; est', f'${estimate(len(calls) * (1.5 + repeats * seconds * 0.4)):.2f}')
    rows = []
    for spec, c in calls:
        r = c.get()
        rows.append([spec or '(defaults)', r['median_ratio'] and f'{r["median_ratio"]:.3f}', r['identical_histories'],
                     ' '.join(f'{x:.1f}' for x in r['a_means'] if x), ' '.join(f'{x:.1f}' for x in r['b_means'] if x), r['provenance']['nvidia_smi'][:60]])
    print_table(['variant', 'median B/A', 'identical', 'A means ms', 'B means ms', 'gpu'], rows)
    dest, n = fetch_run(run_id)
    print('fetched', n, 'jobs into', dest)


WINDOWS = ['bridge64', 'chain256', 'dense12', 'tower64', 'city25-impact', 'city256-idle', 'city256-impact', 'city256-cascade', 'city256-debris']


def _merge_warm(dest):
    """Merge warm-<w>/results/* into warm/ so summarize-warm-screen.py sees a serial-run layout."""
    merged = dest / 'warm'
    merged.mkdir(exist_ok=True)
    for wdir in sorted(dest.glob('warm-*')):
        w = wdir.name[len('warm-'):]
        res = wdir / 'results'
        if not res.exists():
            continue
        for item in res.iterdir():
            target = merged / (f'{w}-campaign.json' if item.name == 'campaign.json' else item.name)
            if target.exists():
                shutil.rmtree(target) if target.is_dir() else target.unlink()
            shutil.move(str(item), str(target))
    for f in merged.glob('*/replay.json'):   # a failed probe leaves a partial file that summarize-warm-screen.py cannot parse
        try:
            json.loads(f.read_text())
        except Exception:  # noqa: BLE001
            f.rename(f.with_name('replay.partial.json'))
    return merged


@app.local_entrypoint()
def warm(build_id: str = '', windows: str = 'all', repetitions: int = 2, contract: str = '4', control: str = 'self', direct: bool = False, tag: str = 'warm'):
    """Nine-window warm screen, one window (its A0/B/A1 triple) per GPU; merged and summarised locally."""
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    names = WINDOWS if windows == 'all' else windows.split(',')
    runner = WarmRunner(build_id=build_id, inputs='baseline,snapshots', git_sha=local_git()['sha'])
    calls = [(w, runner.window.spawn(run_id, w, repetitions, contract, control, direct)) for w in names]
    print('run', run_id, 'build', build_id, '->', len(calls), 'containers')
    rows = []
    for w, c in calls:
        r = c.get()
        a = r['arms']
        f = lambda arm, k: f'{a[arm][k]:.2f}' if k in a.get(arm, {}) else '-'  # noqa: E731
        rows.append([w, f('A0', 'mean_ms'), f('B', 'mean_ms'), f('A1', 'mean_ms'), f('B', 'max_ms'), r['physical_status'] or '-', r['campaign_status'], r['elapsed_s']])
    print_table(['window', 'A0 mean', 'B mean', 'A1 mean', 'B max', 'B check', 'status', 's'], rows)
    dest, n = fetch_run(run_id)
    merged = _merge_warm(dest)
    print(subprocess.run([sys.executable, LOCAL_ROOT / 'tools/diagnostics/destruction-snapshot/summarize-warm-screen.py', merged], capture_output=True, text=True).stdout)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def campaign(build_id: str = '', cases: str = 'idle-256,impacts-256', trials: int = 2, seconds: int = 10, control: str = 'self', hypothesis: str = 'modal fan-out', tag: str = 'campaign'):
    """Continuous campaign: one GPU per case, A-before/B/A-after kept together on that GPU."""
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    runner = CampaignRunner(build_id=build_id, git_sha=local_git()['sha'])
    calls = [(c, runner.case.spawn(run_id, c, trials, seconds, control, hypothesis)) for c in cases.split(',')]
    print('run', run_id, 'build', build_id, '->', len(calls), 'containers; est', f'${estimate(len(calls) * 14):.2f}')
    rows = []
    for case, c in calls:
        r = c.get()
        for cmp_ in r.get('comparisons', []):
            ag = cmp_.get('aggregates') or {}
            b, cnd = ag.get('baseline', {}), ag.get('candidate', {})
            rows.append([case, cmp_['stage'], f'{b.get("mean_ms", 0):.2f}', f'{cnd.get("mean_ms", 0):.2f}', f'{b.get("median_peak_ms", 0):.1f}', f'{cnd.get("median_peak_ms", 0):.1f}',
                         cmp_.get('physical_counter_differences'), r['status'], r.get('error', '')[:60]])
        if not r.get('comparisons'):
            rows.append([case, '-', '-', '-', '-', '-', '-', r['status'], r.get('error', '')[:80]])
    print_table(['case', 'stage', 'A mean', 'B mean', 'A med peak', 'B med peak', 'counter diffs', 'status', 'error'], rows)
    dest, n = fetch_run(run_id)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def profile(build_id: str = '', grid: int = 16, workload: str = 'bombardment', seconds: int = 3, variant: str = '', tag: str = 'profile'):
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    r = InstrumentedRunner(build_id=build_id, git_sha=local_git()['sha']).profile.remote(run_id, grid, workload, seconds, variant)
    print(r['kernel_summary_head'] or r['stdout_tail'])
    dest, n = fetch_run(run_id)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def census(build_id: str = '', grid: int = 16, workload: str = 'bombardment', seconds: int = 5, lo: int = 200, hi: int = 300, tag: str = 'census'):
    build_id = resolve_build(build_id)
    run_id = new_run_id(tag)
    r = InstrumentedRunner(build_id=build_id, git_sha=local_git()['sha']).census.remote(run_id, grid, workload, seconds, lo, hi)
    print(r['census'] or r['demo'].get('stdout_tail'))
    dest, n = fetch_run(run_id)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def fetch(run_id: str):
    dest, n = fetch_run(run_id)
    if any(dest.glob('warm-*')):
        _merge_warm(dest)
    print('fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def qualify(build_id: str = '', control: str = 'self', repeats: int = 3, trials: int = 2, seconds: int = 10, sanitizers: bool = False, confirm: bool = False, tag: str = 'qual'):
    """Everything at once: 11 tests, sanitizers, A/B repeats, nine warm windows, both campaign cases, nsys, census."""
    build_id = resolve_build(build_id)
    gpu_minutes = 2.5 + (3 * 6 if sanitizers else 0) + (1.5 + repeats * 1.2) + 4 * 2 + 5 * 3.5 + 2 * 14 + 4 + 4
    if control == 'self':
        print('note: control=self runs the same libraries in every arm (calibration); pass --control <pushed build_id> for a real control arm')
    cost = estimate(gpu_minutes)
    print(f'qualify {build_id}: ~{gpu_minutes:.0f} GPU-minutes across ~{(4 if sanitizers else 1) + 1 + 9 + 2 + 2} containers, est ${cost:.2f}')
    if cost > 10 and not confirm:
        sys.exit('estimated cost above $10: re-run with --confirm')
    run_id = new_run_id(tag)
    sha = local_git()['sha']
    tests_r, timing, warm_r = TestRunner(build_id=build_id, git_sha=sha), TimingRunner(build_id=build_id, git_sha=sha), WarmRunner(build_id=build_id, inputs='baseline,snapshots', git_sha=sha)
    camp, instr = CampaignRunner(build_id=build_id, git_sha=sha), InstrumentedRunner(build_id=build_id, git_sha=sha)
    calls = {'tests': tests_r.ctest.spawn(run_id, 'eleven', ELEVEN, '', '')}
    for tool in (('memcheck', 'initcheck', 'synccheck') if sanitizers else ()):   # compute-sanitizer is unsupported in Modal's sandbox
        calls[f'san-{tool}'] = tests_r.sanitize.spawn(run_id, tool, 'gpu_resident_stress_3d_test', '')
    calls['ab'] = timing.ab.spawn(run_id, 16, 3, 'bombardment', control, '', repeats, 'base')
    for w in WINDOWS:
        calls[f'warm-{w}'] = warm_r.window.spawn(run_id, w, 2, '4', control, False)
    for case in ('idle-256', 'impacts-256'):
        calls[f'campaign-{case}'] = camp.case.spawn(run_id, case, trials, seconds, control, 'qualification')
    calls['nsys'] = instr.profile.spawn(run_id, 16, 'bombardment', 3, '')
    calls['census'] = instr.census.spawn(run_id, 16, 'bombardment', 5, 200, 300)
    print('run', run_id, '->', len(calls), 'containers spawned')
    report = {'run_id': run_id, 'build_id': build_id, 'jobs': {}}
    t0 = time.monotonic()
    for name, c in calls.items():
        try:
            r = c.get()
        except Exception as e:  # noqa: BLE001
            r = {'error': str(e)}
        report['jobs'][name] = {k: v for k, v in r.items() if k not in ('repeats', 'results', 'stdout_tail', 'census', 'kernel_summary_head')}
        print(f'{name:28s} {time.monotonic() - t0:6.0f}s  ' + (r.get('error') or r.get('status') or r.get('campaign_status') or
              (f'median B/A {r["median_ratio"]:.3f} identical={r["identical_histories"]}' if 'median_ratio' in r else '') or
              (f'{len(r["failed"])} failed, unexpected {r["unexpected_failures"]}' if 'failed' in r else '') or (f'errors={r["errors"]}' if 'errors' in r else 'ok')))
    dest, n = fetch_run(run_id)
    merged = _merge_warm(dest)
    warm_table = subprocess.run([sys.executable, LOCAL_ROOT / 'tools/diagnostics/destruction-snapshot/summarize-warm-screen.py', merged], capture_output=True, text=True).stdout
    print(warm_table)
    report['warm_table'] = warm_table
    report['wall_s'] = round(time.monotonic() - t0, 1)
    (dest / 'qualify.json').write_text(json.dumps(report, indent=2, default=str))
    print('wall', report['wall_s'], 's; fetched', n, 'jobs into', dest)


@app.local_entrypoint()
def prune(older_than_days: int = 14, dry_run: bool = True):
    """Delete result runs older than N days from the physx-results volume."""
    cutoff = dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=older_than_days)
    for e in results_vol.listdir('/'):
        name = e.path.strip('/')
        try:
            when = dt.datetime.strptime(name[:15], '%Y%m%dT%H%M%S').replace(tzinfo=dt.timezone.utc)
        except ValueError:
            continue
        if when < cutoff:
            print('remove' if not dry_run else 'would remove', name)
            if not dry_run:
                results_vol.remove_file('/' + name, recursive=True)
