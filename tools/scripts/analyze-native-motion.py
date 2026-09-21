#!/usr/bin/env python3
"""Plot exact GPU-renderer observations against native physical centers of mass.

Requires numpy, matplotlib and Pillow. --video adds screen-space diagnostic
trails to existing rendered pixels; it never advances or modifies simulation.
Use --trace-motion 1 --audit-motion 1 --record-state 1 --gpu-camera diagnostic
at 60 fps to produce its inputs. This diagnostic intentionally reads GPU data.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess

import numpy as np


def trace(path):
    d = np.genfromtxt(path / 'native.motion.csv', delimiter=',', names=True)
    count = int(d['chunk'].max()) + 1
    d = d.reshape(-1, count)
    assert np.all(d['chunk'] == np.arange(count))
    assert np.all(d['step'] == np.arange(len(d))[:, None])
    assert all(np.isfinite(d[name]).all() for name in d.dtype.names)
    return d


def xyz(d, prefix):
    return np.stack([d[prefix + axis] for axis in 'xyz'], axis=-1)


def projectile(path, actor):
    """Read committed TWSTATE1 poses, carrying unchanged frame entries."""
    with path.open('rb') as f:
        def read(fmt):
            return struct.unpack('<' + fmt, f.read(struct.calcsize('<' + fmt)))
        assert f.read(8) == b'TWSTATE1'
        version, fps, frames, width, height, buildings, cameras = read('7I')
        assert version in (2, 3) and fps == 60
        read('2f')
        f.read(cameras * 28)
        positions, result = {}, np.full((frames, 3), np.nan)
        while True:
            tag, = read('B')
            if tag == 255:
                break
            if tag == 1:
                identity, part, shapes, kind = read('IBIB')
                assert shapes == 1 and kind in (1, 2), 'Only demo boxes/spheres supported'
                read('10f')
            elif tag == 2:
                frame, count = read('2I')
                for _ in range(count):
                    identity, = read('I')
                    pose = read('7f')
                    read('B')
                    if version == 3:
                        read('I')  # Rendering group; does not change the physical pose.
                    positions[identity] = pose[:3]
                if actor in positions:
                    result[frame] = positions[actor]
            else:
                raise ValueError(f'Unknown record {tag}')
    return result


def metrics(d):
    r, c = xyz(d, 'render_'), xyz(d, 'com_')
    single = d['cluster_chunks'] == 1
    offset = np.linalg.norm(r-c, axis=-1)
    return {
        'observations': int(d.size),
        'singleton_observations': int(single.sum()),
        'max_render_physics_error_m': float(np.linalg.norm(r-xyz(d, 'physics_'), axis=-1).max()),
        'max_singleton_com_error_m': float(offset[single].max()),
        'singleton_samples_over_1mm': int((single & (offset > .001)).sum()),
        'chunks_with_singleton_com_error_over_1mm': int((single & (offset > .001)).any(axis=0).sum()),
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('before', type=Path)
    ap.add_argument('after', type=Path)
    ap.add_argument('output', type=Path)
    ap.add_argument('--video', type=Path)
    args = ap.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    before, after = trace(args.before), trace(args.after)
    assert before.shape == after.shape
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    plt.rcParams.update({'font.size': 11, 'axes.spines.top': False,
                         'axes.spines.right': False, 'figure.facecolor': '#f7f9fc'})
    t = (np.arange(len(after))+1)/60
    ids, colors = [73, 160, 355], ['#0072B2', '#D55E00', '#009E73']
    report = {'before': metrics(before), 'after': metrics(after), 'tracked_chunks': ids}
    for label, capture in [('before', args.before), ('after', args.after)]:
        report[label]['capture'] = str(capture.resolve())
        report[label]['trace_sha256'] = hashlib.sha256((capture/'native.motion.csv').read_bytes()).hexdigest()
    assert report['after']['max_singleton_com_error_m'] < .001
    assert report['after']['max_render_physics_error_m'] < .001
    fig, ax = plt.subplots(2, 2, figsize=(13, 8), layout='constrained')
    fig.suptitle('The circling was real: fragments rotated around a misplaced center of mass', fontsize=16, fontweight='bold')
    for col, (d, title) in enumerate([(before, 'Before fix'), (after, 'After fix')]):
        r, c = xyz(d, 'render_'), xyz(d, 'com_')
        off = np.linalg.norm(r-c, axis=-1)
        for i, color in zip(ids, colors):
            single = d['cluster_chunks'][:, i] == 1
            ax[0, col].plot(t, np.where(single, off[:, i], np.nan), color=color, label=f'Chunk {i}')
        ax[0, col].set(title=title+' — single-chunk center offset', xlabel='Simulation time (s)', ylabel='Distance from physical COM (m)', ylim=(-.5, 13))
        ax[0, col].grid(alpha=.2); ax[0, col].legend(loc='upper left')
        # Same authored chunk and time window; the trajectories diverge because
        # the bug affected physical collision/torque response, not just drawing.
        i = 160; selected = (t >= 4.7) & (t <= 10)
        ax[1, col].plot(t[selected], r[selected, i, 1], color='#D55E00', lw=2, label='Rendered chunk center')
        ax[1, col].plot(t[selected], c[selected, i, 1], color='#222222', ls='--', lw=1.5, label='Physical center of mass')
        ax[1, col].set(title=f'{title} — chunk {i}, vertical trajectory', xlabel='Simulation time (s)', ylabel='Height (m)', ylim=(0, 65))
        ax[1, col].legend(); ax[1, col].grid(alpha=.2)
    fig.savefig(args.output/'motion-diagnosis.png', dpi=160)
    plt.close(fig)
    r = xyz(after, 'render_')
    ball = projectile(args.after/'native.twstate', after.shape[1])
    fig, ax = plt.subplots(1, 2, figsize=(13, 5), layout='constrained')
    fig.suptitle('One building, one projectile — corrected paths from actual rendered positions', fontsize=15, fontweight='bold')
    end = min(len(after), 360)
    for a, horizontal, title in [(ax[0], 2, 'Side view'), (ax[1], 0, 'Front view')]:
        for i in range(after.shape[1]):
            a.plot(r[:end, i, horizontal], r[:end, i, 1], color='#bbc4ce', alpha=.17, lw=.5)
        for i, color in zip(ids, colors):
            a.plot(r[:end, i, horizontal], r[:end, i, 1], color=color, lw=2, label=f'Chunk {i}')
        a.plot(ball[:end, horizontal], ball[:end, 1], color='#a629c3', lw=2, label='Projectile')
        a.axhline(0, color='#555555', lw=1)
        a.set(title=title+' · first 6 seconds', xlabel=('Z' if horizontal==2 else 'X')+' position (m)', ylabel='Height (m)')
        a.set_aspect('equal', adjustable='datalim'); a.grid(alpha=.2); a.legend(fontsize=9)
    fig.savefig(args.output/'corrected-trajectories.png', dpi=160)
    plt.close(fig)
    (args.output/'motion-analysis.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))
    if args.video:
        annotate(args.video, args.output/'single-building-tracked.mp4', after, ball, args.after, ids, colors)


def annotate(source, target, d, ball, capture, ids, colors):
    from PIL import Image, ImageDraw, ImageFont
    width, height, fps = 960, 540, 60
    summary = json.loads((capture/'native.summary.json').read_text())
    eye, focus = np.array([26, 15, -24]), np.array([0, 6, 0])
    forward = (focus-eye)/np.linalg.norm(focus-eye)
    right = np.cross(forward, [0, 1, 0]); right /= np.linalg.norm(right)
    up = np.cross(right, forward)
    paths = np.concatenate((xyz(d, 'render_')[:, ids], ball[:, None]), axis=1)
    rel = paths-eye; depth = rel@forward
    scale = height/(2*np.tan(np.deg2rad(20)))
    xy = np.stack((width/2+scale*(rel@right)/depth, height/2-scale*(rel@up)/depth), axis=-1)
    visible = (depth > .1) & np.isfinite(xy).all(axis=-1)
    colors = colors + ['#d97bf3']; names = [str(i) for i in ids] + ['ball']
    font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 16)
    title_font = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', 19)
    decode = subprocess.Popen(['ffmpeg', '-v', 'error', '-i', str(source), '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-'], stdout=subprocess.PIPE)
    encode = subprocess.Popen(['ffmpeg', '-v', 'error', '-n', '-f', 'rawvideo', '-pix_fmt', 'rgb24', '-s', f'{width}x{height}', '-r', str(fps), '-i', '-', '-an', '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '19', '-pix_fmt', 'yuv420p', str(target)], stdin=subprocess.PIPE)
    try:
        for frame in range(len(d)):
            raw = decode.stdout.read(width*height*3)
            assert len(raw) == width*height*3, 'Truncated video'
            im = Image.frombytes('RGB', (width, height), raw)
            draw = ImageDraw.Draw(im)
            for j, (color, name) in enumerate(zip(colors, names)):
                for k in range(max(1, frame-45), frame+1):
                    if visible[k-1, j] and visible[k, j]:
                        a, b = xy[k-1, j], xy[k, j]
                        if np.max(np.abs(np.r_[a,b])) < 10000:
                            draw.line([tuple(a), tuple(b)], fill=color, width=2)
                if visible[frame, j]:
                    x, y = xy[frame, j]
                    if 0<x<width and 45<y<height-65:
                        draw.ellipse((x-4, y-4, x+4, y+4), outline=color, width=2)
                        draw.text((x+6, y-8), name, font=font, fill=color, stroke_width=1, stroke_fill='#101820')
            draw.rectangle((0, 0, width, 47), fill='#101820')
            draw.text((12, 4), 'CORRECTED | One building + one ball | PhysX GPU + CUDA destruction', font=title_font, fill='white')
            draw.text((12, 27), f't = {(frame+1)/fps:.2f} s   |   444 chunks / 896 bonds   |   correction limit: 1 per step', font=font, fill='#d1dae4')
            draw.rectangle((0, height-62, width, height), fill='#101820')
            draw.text((12, height-59), 'Tracks: 73 (blue), 160 (orange), 355 (green), projectile (purple) | last 0.75 s', font=font, fill='white')
            draw.text((12, height-39), f"Simulation ms: avg {summary['physics_ms_mean']:.2f} / min {summary['physics_ms_min']:.2f} / max {summary['physics_ms_max']:.2f} | budget 16.67", font=font, fill='white')
            draw.text((12, height-19), 'Offline diagnostic export at 60 fps; observation/render/encoding excluded. Not a scale benchmark.', font=font, fill='#c4cbd3')
            encode.stdin.write(im.tobytes())
    finally:
        decode.stdout.close(); encode.stdin.close()
        assert decode.wait() == 0 and encode.wait() == 0


if __name__ == '__main__':
    main()
