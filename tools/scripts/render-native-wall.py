#!/usr/bin/env python3
"""Confined native wall JSON -> Metal Blender frames -> H.264 video.

With no action, or --dry-run, only validate and print the plan; nothing is written.
Rendering and encoding require explicit --render / --encode switches.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

sys.dont_write_bytecode = True
from destruction_build_paths import audit_tree, confined_command, contained, local_environment
from native_wall_blender import validate_capture


def digest(path):
    result = hashlib.sha256()
    with Path(path).open('rb') as source:
        for block in iter(lambda: source.read(1024 * 1024), b''):
            result.update(block)
    return result.hexdigest()


def tool(value, name):
    found = value or shutil.which(name)
    if not found or not Path(found).is_file() or not os.access(found, os.X_OK):
        raise ValueError(f'{name} is unavailable: provide its installed executable; no installation will be attempted')
    return str(Path(found).resolve())


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--render', action='store_true')
    parser.add_argument('--encode', action='store_true')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--diagnostic', action='store_true')
    parser.add_argument('--sample-frame', type=int)
    parser.add_argument('--width', type=int, default=1920)
    parser.add_argument('--height', type=int, default=1080)
    parser.add_argument('--samples', type=int, default=8)
    parser.add_argument('--engine', choices=('eevee', 'cycles-metal', 'cycles-cpu'), default='eevee',
                        help='GPU Eevee raster rendering (default), GPU Metal path tracing, or explicit CPU path tracing')
    parser.add_argument('--threads', type=int, default=4)
    parser.add_argument('--timeout', type=int, default=21600)
    parser.add_argument('--blender', default='/Applications/Blender.app/Contents/MacOS/Blender')
    parser.add_argument('--ffmpeg')
    parser.add_argument('--ffprobe')
    args = parser.parse_args(argv)
    repo = Path(__file__).resolve().parents[2]
    roots = (repo, repo.parent / 'cuda-metal')
    output_roots = tuple(root / 'out' for root in roots)
    capture = contained(args.capture, roots)
    work = contained(args.output, output_roots)
    if work in tuple(path.resolve() for path in output_roots):
        raise ValueError('choose a dedicated subdirectory beneath out/')
    audit_tree(work, output_roots)
    data = validate_capture(json.loads(capture.read_text()), args.diagnostic)
    if not (2 <= args.width <= 7680 and 2 <= args.height <= 4320 and args.width % 2 == 0 and args.height % 2 == 0):
        raise ValueError('render dimensions must be positive even sizes within 7680x4320')
    if not (1 <= args.samples <= 4096 and 1 <= args.threads <= 128 and 1 <= args.timeout <= 86400):
        raise ValueError('invalid samples, threads or timeout bound')
    if args.sample_frame is not None and not 0 <= args.sample_frame < len(data['frames']):
        raise ValueError('sample frame is outside the accepted capture')
    if args.encode and args.sample_frame is not None:
        raise ValueError('a sample frame cannot be encoded as a complete capture')
    renderer = Path(__file__).with_name('native_wall_blender.py').resolve()
    frames, video = work / 'frames', work / 'native-wall.mp4'
    env, locations = local_environment(work, roots)
    extra = {
        'XDG_CONFIG_HOME': work / 'config/xdg',
        'XDG_DATA_HOME': work / 'data/xdg',
        'XDG_STATE_HOME': work / 'state/xdg',
        'BLENDER_USER_RESOURCES': work / 'blender',
        'BLENDER_USER_CONFIG': work / 'blender/config',
        'BLENDER_USER_SCRIPTS': work / 'blender/scripts',
        'BLENDER_USER_DATAFILES': work / 'blender/datafiles',
        'BLENDER_USER_EXTENSIONS': work / 'blender/extensions',
        'MPLCONFIGDIR': work / 'cache/matplotlib',
    }
    for key, path in extra.items():
        env[key] = str(contained(path, output_roots))
    env['PYTHONNOUSERSITE'] = '1'
    env.pop('PYTHONPATH', None)
    env.pop('PYTHONHOME', None)
    # HOME and the active Xcode selection are deliberately left untouched.
    commands = {}
    if args.render:
        commands['render'] = [tool(args.blender, 'Blender'), '--background', '--factory-startup',
                              '--disable-autoexec', '--threads', str(args.threads),
                              '--python-exit-code', '1', '--python', str(renderer), '--',
                              '--capture', str(capture), '--frames', str(frames),
                              '--temporary', env['TMPDIR'], '--width', str(args.width),
                              '--height', str(args.height), '--samples', str(args.samples),
                              '--threads', str(args.threads), '--engine', args.engine]
        if args.engine != 'cycles-cpu':
            commands['render'][1:1] = ['--gpu-backend', 'metal', '--debug-gpu']
        if args.sample_frame is not None:
            commands['render'] += ['--sample-frame', str(args.sample_frame)]
        if args.diagnostic:
            commands['render'] += ['--diagnostic']
    if args.encode:
        ffmpeg, ffprobe = tool(args.ffmpeg, 'ffmpeg'), tool(args.ffprobe, 'ffprobe')
        if video.exists():
            raise ValueError('refusing to overwrite an existing video')
        commands['encode'] = [ffmpeg, '-hide_banner', '-nostdin', '-n', '-framerate', '60',
                              '-start_number', '0', '-i', str(frames / 'frame_%06d.png'),
                              '-frames:v', str(len(data['frames'])), '-an', '-c:v', 'libx264',
                              '-preset', 'medium', '-crf', '18', '-pix_fmt', 'yuv420p',
                              '-movflags', '+faststart', str(video)]
        commands['probe'] = [ffprobe, '-v', 'error', '-count_frames', '-select_streams', 'v:0',
                             '-show_entries', 'stream=codec_name,width,height,r_frame_rate,nb_read_frames',
                             '-of', 'json', str(video)]
        commands['decode'] = [ffmpeg, '-hide_banner', '-nostdin', '-v', 'error', '-i', str(video), '-f', 'null', '-']
    plan = {'capture': str(capture), 'capture_sha256': digest(capture), 'output': str(work),
            'diagnostic': args.diagnostic, 'backend': data['backend'], 'device': data['metadata']['device'],
            'simulation_summary': data['summary'], 'frames': len(data['frames']), 'sample_frame': args.sample_frame,
            'fps': 60, 'resolution': [args.width, args.height], 'render_device': 'CPU' if args.engine == 'cycles-cpu' else 'GPU', 'engine': args.engine,
            'samples': args.samples, 'threads': args.threads, 'realtime_claim': False,
            'renderer_sha256': digest(renderer), 'commands': commands,
            'environment_paths': {key: str(path) for key, path in {**locations, **extra}.items()}}
    print(json.dumps(plan, indent=2), flush=True)
    if args.dry_run or not (args.render or args.encode):
        return 0
    for path in (work, frames, work / 'logs', *locations.values(), *extra.values()):
        path = contained(path, output_roots)
        (path.parent if '%' in path.name else path).mkdir(parents=True, exist_ok=True)
    audit_tree(work, output_roots)

    plan['timings_seconds'] = {}
    def execute(name):
        started = time.perf_counter()
        command = commands[name]
        with (work / 'logs' / f'{name}.log').open('w') as log:
            result = subprocess.run(confined_command(command, roots), env=env, cwd=work,
                                    stdout=log, stderr=subprocess.STDOUT, timeout=args.timeout)
        plan['timings_seconds'][name] = time.perf_counter() - started
        if result.returncode:
            raise RuntimeError(f'{name} failed ({result.returncode}); inspect {work / "logs" / (name + ".log")}; confinement will not be bypassed')
        audit_tree(work, output_roots)

    if args.render:
        execute('render')
        plan['renderer_runtime'] = json.loads((work / 'renderer-runtime.json').read_text())
        if args.engine != 'cycles-cpu':
            evidence = sorted({line.strip() for line in (work / 'logs/render.log').read_text().splitlines()
                               if line.startswith(('Selected Metal Device:', 'METAL API - DETECTED GPU:'))})
            if not evidence:
                raise ValueError('Blender did not identify its selected Metal GPU; inspect render.log')
            plan['renderer_runtime']['observed_gpu_log'] = evidence
        selected = range(len(data['frames'])) if args.sample_frame is None else [args.sample_frame]
        rendered = {}
        for index in selected:
            path = contained(frames / f'frame_{index:06d}.png', output_roots)
            if not path.is_file() or path.stat().st_size == 0:
                raise ValueError(f'render did not produce committed frame {index}')
            rendered[path.name] = digest(path)
        receipt = {'capture_sha256': plan['capture_sha256'], 'renderer_sha256': plan['renderer_sha256'],
                   'resolution': plan['resolution'], 'engine': plan['engine'], 'samples': plan['samples'],
                   'renderer_runtime': plan['renderer_runtime'], 'frames': rendered}
        (work / ('sample-frames.json' if args.sample_frame is not None else 'rendered-frames.json')).write_text(json.dumps(receipt, indent=2) + '\n')
    if args.encode:
        receipt = json.loads((work / 'rendered-frames.json').read_text())
        if any(receipt.get(key) != plan[key] for key in ('capture_sha256', 'renderer_sha256', 'resolution', 'engine', 'samples')):
            raise ValueError('rendered frames do not match this capture, renderer and resolution')
        plan['renderer_runtime'] = receipt['renderer_runtime']
        expected = {f'frame_{index:06d}.png' for index in range(len(data['frames']))}
        if {path.name for path in frames.glob('frame_*.png')} != expected:
            raise ValueError('encoding requires exactly one rendered PNG per committed frame')
        for name in expected:
            path = contained(frames / name, output_roots)
            if not path.is_file() or path.stat().st_size == 0:
                raise ValueError(f'missing or empty rendered frame: {name}')
            if receipt['frames'].get(name) != digest(path):
                raise ValueError(f'rendered frame provenance/hash mismatch: {name}')
        execute('encode')
        execute('probe')
        observed = json.loads((work / 'logs/probe.log').read_text())['streams']
        if (len(observed) != 1 or observed[0]['codec_name'] != 'h264' or
                [observed[0]['width'], observed[0]['height']] != [args.width, args.height] or
                observed[0]['r_frame_rate'] != '60/1' or int(observed[0]['nb_read_frames']) != len(data['frames'])):
            raise ValueError(f'encoded stream does not match the accepted capture: {observed}')
        execute('decode')
        plan['video'] = {'path': str(video), 'sha256': digest(video), 'stream': observed[0], 'full_decode': 'passed'}
    plan['rendered_frames'] = {path.name: digest(path) for path in sorted(frames.glob('frame_*.png'))}
    plan['status'] = 'completed'
    (work / ('sample-manifest.json' if args.sample_frame is not None else 'render-manifest.json')).write_text(json.dumps(plan, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError, KeyError, TypeError, OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(f'native wall render: {error}', file=sys.stderr)
        raise SystemExit(1)
