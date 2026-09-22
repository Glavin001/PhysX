#!/usr/bin/env python3
"""Prove a TWSTATE1 trajectory carries exactly the poses its capture JSON records.

The JSON is the audit artifact; the trajectory is what the native renderer draws.
If they ever disagree, a video no longer depicts the simulation that was verified,
so this is a gate rather than a diagnostic: every body, every frame, bit-exact
after the float32 narrowing the binary format performs.

Reads only. Writes nothing.
"""
import argparse
import json
import struct
import sys
from pathlib import Path

MAGIC = b'TWSTATE1'
RECORD_ACTOR, RECORD_FRAME, RECORD_END = 1, 2, 255
SHAPE_BOX, SHAPE_SPHERE, SHAPE_MESH = 1, 2, 3
NO_GROUP = 0xFFFFFFFF


class Reader:
    """Sequential cursor over the trajectory; refuses to run off the end."""

    def __init__(self, data):
        self.data, self.at = data, 0

    def take(self, count):
        end = self.at + count
        if end > len(self.data):
            raise ValueError(f'truncated trajectory at byte {self.at}')
        chunk = self.data[self.at:end]
        self.at = end
        return chunk

    def u8(self):
        return self.take(1)[0]

    def u32(self):
        return struct.unpack('<I', self.take(4))[0]

    def f32(self):
        return struct.unpack('<f', self.take(4))[0]

    def vec3(self):
        return struct.unpack('<3f', self.take(12))

    def transform(self):
        return struct.unpack('<7f', self.take(28))


def read_trajectory(path):
    r = Reader(Path(path).read_bytes())
    if r.take(8) != MAGIC:
        raise ValueError('not a TWSTATE1 file')
    version, fps, frames, pane_w, pane_h, buildings, cameras = (r.u32() for _ in range(7))
    if version not in (2, 3):
        raise ValueError(f'unsupported trajectory version {version}')
    duration, settle = r.f32(), r.f32()
    for _ in range(cameras):
        r.take(28)

    actors, poses, by_frame = {}, {}, {}
    seen_end = False
    while r.at < len(r.data):
        tag = r.u8()
        if tag == RECORD_END:
            seen_end = True
            break
        if tag == RECORD_ACTOR:
            ident, part = r.u32(), r.u8()
            shapes = []
            for _ in range(r.u32()):
                kind = r.u8()
                params, local = r.vec3(), r.transform()
                mesh = None
                if kind == SHAPE_MESH:
                    vertices = [(r.vec3(), r.vec3()) for _ in range(r.u32())]
                    indices = [r.u32() for _ in range(r.u32())]
                    mesh = (vertices, indices)
                elif kind not in (SHAPE_BOX, SHAPE_SPHERE):
                    raise ValueError(f'unknown shape {kind} for actor {ident}')
                shapes.append({'kind': kind, 'parameters': params, 'local': local, 'mesh': mesh})
            if ident in actors:
                raise ValueError(f'actor {ident} defined twice')
            actors[ident] = {'part': part, 'shapes': shapes}
        elif tag == RECORD_FRAME:
            index, updates = r.u32(), r.u32()
            for _ in range(updates):
                ident = r.u32()
                pose = r.transform()
                sleeping = r.u8()
                group = r.u32() if version >= 3 else NO_GROUP
                if ident not in actors:
                    raise ValueError(f'frame {index} updates undeclared actor {ident}')
                poses[ident] = (pose, sleeping, group)
            # Snapshot the full state: omitted actors deliberately retain prior values.
            by_frame[index] = dict(poses)
        else:
            raise ValueError(f'unknown record tag {tag} at byte {r.at - 1}')

    expected = sorted(range(len(actors)))
    if sorted(actors) != expected:
        raise ValueError('actor ids are not contiguous from zero')
    return {'version': version, 'fps': fps, 'declared_frames': frames, 'pane': (pane_w, pane_h),
            'buildings': buildings, 'cameras': cameras, 'duration': duration, 'settle': settle,
            'actors': actors, 'frames': by_frame, 'terminated': seen_end}


def narrow(value):
    """The binary format stores float32; compare the JSON at the same precision."""
    return struct.unpack('<f', struct.pack('<f', value))[0]


def verify(capture_path, trajectory_path, tolerance):
    capture = json.loads(Path(capture_path).read_text())
    trajectory = read_trajectory(trajectory_path)
    problems, checked = [], 0

    if not trajectory['terminated']:
        problems.append('trajectory has no end record; the run did not finalize it')

    bodies = capture['bodies']
    if len(bodies) != len(trajectory['actors']):
        problems.append(f"body count differs: JSON {len(bodies)}, trajectory {len(trajectory['actors'])}")

    for body in bodies:
        actor = trajectory['actors'].get(body['id'])
        if actor is None:
            problems.append(f"body {body['id']} missing from trajectory")
            continue
        kind = actor['shapes'][0]['kind']
        want = SHAPE_BOX if body['shape'] == 'box' else SHAPE_SPHERE
        if kind != want:
            problems.append(f"body {body['id']} shape differs: JSON {body['shape']}, trajectory {kind}")
        parameters = actor['shapes'][0]['parameters']
        reference = body['half_extents'] if body['shape'] == 'box' else [body['radius']] * 3
        for axis, (got, expect) in enumerate(zip(parameters, reference)):
            if abs(got - narrow(expect)) > tolerance:
                problems.append(f"body {body['id']} geometry axis {axis}: {got} vs {expect}")

    frames = capture['frames']
    for frame in frames:
        index = frame['frame']
        state = trajectory['frames'].get(index)
        if state is None:
            problems.append(f'frame {index} missing from trajectory')
            continue
        for pose in frame['bodies']:
            entry = state.get(pose['id'])
            if entry is None:
                problems.append(f"frame {index} body {pose['id']} has no pose")
                continue
            values, _sleeping, group = entry
            expected = [narrow(v) for v in pose['position']] + [narrow(v) for v in pose['rotation']]
            for axis, (got, want) in enumerate(zip(values, expected)):
                if abs(got - want) > tolerance:
                    problems.append(f"frame {index} body {pose['id']} component {axis}: {got} vs {want}")
                    break
            cluster = pose.get('cluster_id')
            if cluster is not None and group != cluster:
                problems.append(f"frame {index} body {pose['id']} group {group} vs cluster_id {cluster}")
            checked += 1

    if len(trajectory['frames']) != len(frames):
        problems.append(f"frame count differs: JSON {len(frames)}, trajectory {len(trajectory['frames'])}")

    return trajectory, checked, problems


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('capture')
    parser.add_argument('trajectory')
    parser.add_argument('--tolerance', type=float, default=0.0,
                        help='absolute difference permitted per component (default 0: bit-exact)')
    args = parser.parse_args()

    trajectory, checked, problems = verify(args.capture, args.trajectory, args.tolerance)
    capture_bytes = Path(args.capture).stat().st_size
    trajectory_bytes = Path(args.trajectory).stat().st_size
    bodies = len(trajectory['actors'])
    frames = len(trajectory['frames'])

    print(f'{args.trajectory}')
    print(f"  version {trajectory['version']}  fps {trajectory['fps']}  "
          f"declared {trajectory['declared_frames']} frames  cameras {trajectory['cameras']}")
    print(f'  {bodies} actors, {frames} frames recorded, {checked} body-poses compared')
    if frames and bodies:
        print(f'  size {trajectory_bytes} B vs JSON {capture_bytes} B '
              f'({capture_bytes / max(trajectory_bytes, 1):.1f}x smaller, '
              f'{trajectory_bytes / (frames * bodies):.1f} B per body-frame)')
    if problems:
        print(f'  FAILED: {len(problems)} mismatches')
        for line in problems[:20]:
            print(f'    {line}')
        if len(problems) > 20:
            print(f'    ... and {len(problems) - 20} more')
        return 1
    print('  PASS: every recorded pose matches the capture exactly at float32 precision')
    return 0


if __name__ == '__main__':
    sys.exit(main())
