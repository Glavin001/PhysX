#!/usr/bin/env python3
"""Compare accepted wall prefixes; never a complete penetration/performance gate."""
import csv
import gzip
import hashlib
import importlib.util
import itertools
import json
import math
from pathlib import Path

POSITION_TOLERANCE = 1e-3  # Existing native motion/COM audit tolerance, metres.
PHYSICAL_FIELDS = (
    'chunks', 'bonds', 'buildings', 'shot_path', 'projectile_mass_kg',
    'material_strength_scale', 'frame_strength_scale', 'correction_limit',
    'direct_gpu_mode', 'sleeping', 'gpu_connectivity_owner', 'gpu_island_repair',
    'gpu_pre_solve_islands', 'gpu_pre_solve_contacts', 'gpu_pre_solve_support',
    'preserve_contact_pairs', 'spawn_protocol', 'launch_seconds', 'workload',
    'free_bodies', 'crushing_material_enabled', 'record_fps',
)
IDENTITY_FIELDS = ('step', 'chunk', 'root', 'cluster_chunks', 'supported')


def digest(path):
    result = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            result.update(data)
    return result.hexdigest()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def frames(path, count):
    with (path / 'native.frames.csv').open() as stream:
        result = list(itertools.islice(csv.DictReader(stream), count))
    require(len(result) == count, 'Incomplete frame prefix')
    for step, row in enumerate(result):
        require(int(row['step']) == step, 'Missing/duplicate accepted frame')
        require(int(row['stress_converged']) == 1, f'Unconverged stress at step {step}')
        require(0 <= int(row['resim_passes']) <= 1, f'Invalid correction count at step {step}')
        require(1 <= int(row['stress_passes']) <= 2, f'Invalid stress pass count at step {step}')
    return result


def motion(path, count):
    plain = path / 'native.motion.csv'
    stream = plain.open() if plain.exists() else gzip.open(str(plain) + '.gz', 'rt')
    with stream:
        reader = csv.DictReader(stream)
        for step in range(count):
            rows = list(itertools.islice(reader, 444))
            require(len(rows) == 444, f'Incomplete motion observations at step {step}')
            for chunk, row in enumerate(rows):
                require(int(row['step']) == step and int(row['chunk']) == chunk,
                        f'Missing/duplicate motion observation at step {step}, chunk {chunk}')
                require(all(math.isfinite(float(value)) for value in row.values()),
                        f'Non-finite motion at step {step}, chunk {chunk}')
                error = math.dist([float(row['render_' + a]) for a in 'xyz'],
                                  [float(row['physics_' + a]) for a in 'xyz'])
                require(error <= POSITION_TOLERANCE, f'Render/collision disagreement at step {step}')
            yield rows


def options(command):
    require(len(command) % 2 == 1, 'Malformed captured command')
    ignored = {'--seconds', '--steps', '--output', '--motion-path', '--gpu-video', '--gpu-camera', '--color-by-cluster', '--trace-stress'}
    return {k: v for k, v in zip(command[1::2], command[2::2]) if k not in ignored}


def verify(capture, reference, count):
    require(count in (32, 128), 'Only approved 32/128-step wall prefixes are supported')
    actual = json.loads((capture / 'native.summary.json').read_text())
    expected = json.loads((reference / 'native.summary.json').read_text())
    require(actual['status'] == expected['status'] == 'completed', 'Incomplete simulation')
    require(actual['frames'] >= count and expected['frames'] >= count, 'Wrong prefix duration')
    require(actual['chunks'] == 444 and actual['bonds'] == 896, 'Wrong wall asset')
    require(actual['correction_limit']==1 and actual['record_fps']==60 and actual['projectiles']==1, 'Wrong wall simulation contract')
    require(actual['motion_audit_enabled'] and actual['motion_trace_enabled'], 'Missing motion audit')
    for key in PHYSICAL_FIELDS:
        require(actual[key] == expected[key], f'Reference physical setting differs: {key}')
    for path, summary in ((capture, actual), (reference, expected)):
        require(summary['max_motion_position_error'] <= POSITION_TOLERANCE, 'Invalid render/physics audit')
        require(summary['max_cluster_com_error'] <= POSITION_TOLERANCE, 'Invalid COM audit')
    cap = json.loads((capture / 'capture.json').read_text())
    ref = json.loads((reference / 'capture.json').read_text())
    require(cap['config_sha256'] == ref['config_sha256'], 'Reference config digest differs')
    require(options(cap['command']) == options(ref['command']), 'Reference command settings differ')
    require(cap['exit_code'] == ref['exit_code'] == 0, 'Invalid capture exit status')
    require(cap.get('artifacts') and ref.get('artifacts'), 'Missing artifact attestation')
    # A reference must already have a physical audit; do not bless an arbitrary
    # trajectory merely because comparing it with itself would pass.
    quality = json.loads((reference / 'quality.json').read_text())
    require(quality.get('all_stress_steps_converged') is True, 'Reference lacks physical quality audit')
    require(quality['max_cluster_com_error'] <= POSITION_TOLERANCE, 'Reference COM audit failed')
    if expected['direct_gpu_mode']:
        require(quality.get('frozen_identity_gate_passed') is True, 'Reference lacks frozen identity gate')
    a_frames, b_frames = frames(capture, count), frames(reference, count)
    spec = importlib.util.spec_from_file_location('native_motion', Path(__file__).with_name('analyze-native-motion.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    a_ball = module.projectile(capture / 'native.twstate', 444)
    b_ball = module.projectile(reference / 'native.twstate', 444)
    require(len(a_ball) == actual['frames'] and len(b_ball) == expected['frames'], 'Incomplete projectile observation')
    max_position_error = 0.0
    identity = hashlib.sha256()
    result = dict(schema=1, status='passed', tier='early' if count == 32 else 'screen',
                  compared_steps=count, chunks=444, bonds=896, projectiles=actual['projectiles'],
                  performance_qualification=False, complete_regression=False,
                  position_tolerance_m=POSITION_TOLERANCE, first_difference=None)
    for step, (a_rows, b_rows) in enumerate(zip(motion(capture, count), motion(reference, count))):
        difference = None
        if not all(math.isfinite(float(v)) for v in (*a_ball[step], *b_ball[step])):
            difference = dict(step=step, kind='nonfinite_projectile')
        else:
            error = math.dist(a_ball[step], b_ball[step])
            max_position_error = max(max_position_error, error)
            if error > POSITION_TOLERANCE:
                difference = dict(step=step, kind='projectile_position', error_m=error,
                                  actual=a_ball[step].tolist(), reference=b_ball[step].tolist())
        for key in ('resim_passes', 'stress_passes', 'bonds_broken', 'post_correction_bonds_broken'):
            if int(a_frames[step][key]) != int(b_frames[step][key]) and difference is None:
                difference = dict(step=step, kind=key, actual=a_frames[step][key], reference=b_frames[step][key])
        for chunk, (a, b) in enumerate(zip(a_rows, b_rows)):
            values = [int(a[k]) for k in IDENTITY_FIELDS]
            identity.update(json.dumps(values, separators=(',', ':')).encode())
            if values != [int(b[k]) for k in IDENTITY_FIELDS] and difference is None:
                difference = dict(step=step, chunk=chunk, kind='topology_identity')
            for prefix in ('physics_', 'com_'):
                error = math.dist([float(a[prefix + axis]) for axis in 'xyz'],
                                  [float(b[prefix + axis]) for axis in 'xyz'])
                max_position_error = max(max_position_error, error)
                if error > POSITION_TOLERANCE and difference is None:
                    difference = dict(step=step, chunk=chunk, kind=prefix + 'position', error_m=error)
        if difference:
            result.update(status='failed', first_difference=difference, compared_steps=step + 1)
            break
    result['max_position_error_m'] = max_position_error
    result['compared_identity_sha256'] = identity.hexdigest()
    result['reference'] = str(reference.resolve())
    result['reference_sha256'] = {name: digest(reference / name) for name in
        ('capture.json', 'quality.json', 'native.summary.json', 'native.frames.csv', 'native.twstate')}
    motion_name='native.motion.csv' if (reference/'native.motion.csv').exists() else 'native.motion.csv.gz'
    result['reference_sha256'][motion_name]=digest(reference/motion_name)
    # Tier 3 additionally retains the established rear-clearance/two-second-hole
    # checks; it never applies the 600-step final topology golden to a prefix.
    if result['status'] == 'passed' and count == 128:
        spec = importlib.util.spec_from_file_location('native_penetration', Path(__file__).with_name('verify-native-penetration.py'))
        full = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(full)
        result['penetration_checks'] = full.verify(capture, None)
    return result
