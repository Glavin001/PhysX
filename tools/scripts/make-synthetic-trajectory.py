#!/usr/bin/env python3
"""Write a synthetic TWSTATE1 trajectory for renderer scaling tests.

The renderer's cost should be flat in body count: every box is one instance of a
shared cube, so a frame is a couple of draw calls whether it holds sixty bodies
or sixty thousand. Proving that needs trajectories far larger than the physics
demo produces, and generating them here costs no GPU simulation time.

The motion is deliberately trivial (a settling tumble); this measures the
renderer, not physics, and the output must never be presented as a simulation.
"""
import argparse
import math
import struct
import sys
from pathlib import Path

MAGIC = b'TWSTATE1'
VERSION = 3
RECORD_ACTOR, RECORD_FRAME, RECORD_END = 1, 2, 255
SHAPE_BOX = 1
NO_GROUP = 0xFFFFFFFF


def vec3(out, x, y, z):
    out.write(struct.pack('<3f', x, y, z))


def transform(out, position, rotation):
    out.write(struct.pack('<7f', *position, *rotation))


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('output')
    parser.add_argument('--bodies', type=int, default=1000)
    parser.add_argument('--frames', type=int, default=120)
    parser.add_argument('--fps', type=int, default=60)
    parser.add_argument('--half', type=float, default=0.48)
    args = parser.parse_args()

    if args.bodies < 1 or args.frames < 1:
        print('bodies and frames must be positive', file=sys.stderr)
        return 1

    # A roughly cubical stack so the camera can frame the whole set.
    side = max(1, int(round(args.bodies ** (1 / 3))))
    pitch = args.half * 2.2
    destination = Path(args.output)
    if destination.exists():
        print(f'{destination} already exists', file=sys.stderr)
        return 1
    destination.parent.mkdir(parents=True, exist_ok=True)

    span = side * pitch
    eye = (span * 1.4, span * 0.9, -(span * 1.6 + 4))
    focus = (0.0, span * 0.35, 0.0)
    direction = [focus[i] - eye[i] for i in range(3)]
    length = math.sqrt(sum(c * c for c in direction)) or 1.0
    direction = [c / length for c in direction]

    with destination.open('wb') as out:
        out.write(MAGIC)
        out.write(struct.pack('<7I', VERSION, args.fps, args.frames, 1920, 1080, 1, 4))
        out.write(struct.pack('<2f', args.frames / args.fps, 0.0))
        for _ in range(4):
            vec3(out, *eye)
            vec3(out, *direction)
            out.write(struct.pack('<f', 55.0))

        for ident in range(args.bodies):
            out.write(struct.pack('<B', RECORD_ACTOR))
            out.write(struct.pack('<I', ident))
            out.write(struct.pack('<B', 0))
            out.write(struct.pack('<I', 1))
            out.write(struct.pack('<B', SHAPE_BOX))
            vec3(out, args.half, args.half, args.half)
            transform(out, (0.0, 0.0, 0.0), (0.0, 0.0, 0.0, 1.0))

        for frame in range(args.frames):
            out.write(struct.pack('<B', RECORD_FRAME))
            out.write(struct.pack('<2I', frame, args.bodies))
            t = frame / max(args.frames - 1, 1)
            for ident in range(args.bodies):
                x = (ident % side) - (side - 1) * 0.5
                y = (ident // side) % side
                z = (ident // (side * side)) - (side - 1) * 0.5
                # Each body drifts and spins a little so motion is visible.
                phase = ident * 0.7
                position = (x * pitch + 0.25 * math.sin(phase + t * 4.0),
                            y * pitch + args.half + 0.6 * t * math.sin(phase),
                            z * pitch + 0.25 * math.cos(phase + t * 4.0))
                angle = t * (0.6 + 0.4 * math.sin(phase))
                axis = (math.sin(phase), math.cos(phase * 1.3), math.sin(phase * 0.6))
                norm = math.sqrt(sum(a * a for a in axis)) or 1.0
                half = angle * 0.5
                s = math.sin(half) / norm
                rotation = (axis[0] * s, axis[1] * s, axis[2] * s, math.cos(half))
                out.write(struct.pack('<I', ident))
                transform(out, position, rotation)
                out.write(struct.pack('<B', 0))
                out.write(struct.pack('<I', ident % 8))
        out.write(struct.pack('<B', RECORD_END))

    size = destination.stat().st_size
    print(f'{destination}: {args.bodies} bodies x {args.frames} frames, {size} bytes '
          f'({size / (args.bodies * args.frames):.1f} B per body-frame)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
