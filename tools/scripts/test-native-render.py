#!/usr/bin/env python3
"""Contract tests for the native trajectory + Metal render path.

These pin the properties that keep a fast renderer trustworthy: a trajectory
must carry exactly the poses its capture recorded, a corrupt one must be
refused rather than replayed as plausible garbage, output must stay inside the
repository roots, and an existing file must never be overwritten.

Pass --renderer to additionally exercise the built binary end to end; without
it, only the format-level tests run and no GPU is required.
"""
import argparse
import json
import struct
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

# The verifier's filename has hyphens, so load it by path rather than by import.
import importlib.util
_spec = importlib.util.spec_from_file_location('verify_native_trajectory',
                                               HERE / 'verify-native-trajectory.py')
verify_module = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(verify_module)

MAGIC = b'TWSTATE1'


def build_trajectory(path, bodies=3, frames=4, *, terminate=True, version=3):
    """A minimal well-formed trajectory, and the poses it should replay to."""
    expected = []
    with path.open('wb') as out:
        out.write(MAGIC)
        out.write(struct.pack('<7I', version, 60, frames, 1920, 1080, 1, 4))
        out.write(struct.pack('<2f', frames / 60.0, 0.0))
        for _ in range(4):
            out.write(struct.pack('<7f', 0, 2, -10, 0, 0, 1, 55))
        for ident in range(bodies):
            out.write(struct.pack('<B', 1))
            out.write(struct.pack('<I', ident))
            out.write(struct.pack('<B', 0))
            out.write(struct.pack('<I', 1))
            out.write(struct.pack('<B', 1))
            out.write(struct.pack('<3f', 0.5, 0.5, 0.5))
            out.write(struct.pack('<7f', 0, 0, 0, 0, 0, 0, 1))
        state = {}
        for frame in range(frames):
            # Deliberately update only some bodies, exercising delta retention.
            updates = [i for i in range(bodies) if (i + frame) % 2 == 0]
            out.write(struct.pack('<B', 2))
            out.write(struct.pack('<2I', frame, len(updates)))
            for ident in updates:
                pose = (float(ident), float(frame), 0.0, 0.0, 0.0, 0.0, 1.0)
                out.write(struct.pack('<I', ident))
                out.write(struct.pack('<7f', *pose))
                out.write(struct.pack('<B', 0))
                if version >= 3:
                    out.write(struct.pack('<I', ident))
                state[ident] = pose
            expected.append(dict(state))
        if terminate:
            out.write(struct.pack('<B', 255))
    return expected


def capture_for(expected, bodies):
    """A capture JSON that agrees with the trajectory above."""
    return {
        'bodies': [{'id': i, 'shape': 'box', 'half_extents': [0.5, 0.5, 0.5]} for i in range(bodies)],
        'frames': [
            {'frame': index,
             'bodies': [{'id': i, 'position': list(pose[:3]), 'rotation': list(pose[3:]), 'cluster_id': i}
                        for i, pose in sorted(state.items())]}
            for index, state in enumerate(expected)
        ],
    }


def run(tests):
    failures = []
    for name, body in tests:
        try:
            body()
            print(f'  ok   {name}')
        except AssertionError as error:
            failures.append(name)
            print(f'  FAIL {name}: {error}')
        except Exception as error:  # noqa: BLE001 - surface the real fault
            failures.append(name)
            print(f'  ERROR {name}: {type(error).__name__}: {error}')
    return failures


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--renderer', help='path to native_wall_render for end-to-end checks')
    args = parser.parse_args()

    temp = tempfile.TemporaryDirectory()
    work = Path(temp.name)
    # Renderer output is confined to the repository roots by design, so its
    # scratch directory must sit inside one rather than in the system temp.
    physx_root = HERE.parent.parent
    inside = tempfile.TemporaryDirectory(dir=str(physx_root / 'out')) if args.renderer else None
    render_work = Path(inside.name) if inside is not None else work
    tests = []

    def test_roundtrip():
        path = work / 'good.twstate'
        expected = build_trajectory(path)
        capture = work / 'good.json'
        capture.write_text(json.dumps(capture_for(expected, 3)))
        _, checked, problems = verify_module.verify(capture, path, 0.0)
        assert not problems, f'unexpected mismatches: {problems[:3]}'
        # Frame 0 defines only two of the three bodies, so 2 + 3 + 3 + 3.
        assert checked == 11, f'expected 11 body-poses, compared {checked}'

    def test_delta_retention():
        # A body absent from a frame record must keep its previous pose, not
        # reset; this is the property the whole format depends on.
        path = work / 'delta.twstate'
        expected = build_trajectory(path, bodies=3, frames=4)
        trajectory = verify_module.read_trajectory(path)
        for index, state in enumerate(expected):
            recorded = trajectory['frames'][index]
            assert set(recorded) == set(state), f'frame {index} body set differs'
            for ident, pose in state.items():
                assert recorded[ident][0] == pose, f'frame {index} body {ident} pose drifted'

    def test_detects_mismatch():
        path = work / 'mismatch.twstate'
        expected = build_trajectory(path)
        capture = work / 'mismatch.json'
        data = capture_for(expected, 3)
        data['frames'][2]['bodies'][0]['position'][1] += 0.01
        capture.write_text(json.dumps(data))
        _, _, problems = verify_module.verify(capture, path, 0.0)
        assert problems, 'a perturbed pose was not detected'

    def test_rejects_truncation():
        path = work / 'truncated.twstate'
        build_trajectory(path)
        blob = path.read_bytes()
        path.write_bytes(blob[:len(blob) - 12])
        try:
            verify_module.read_trajectory(path)
        except ValueError:
            return
        raise AssertionError('a truncated trajectory was accepted')

    def test_rejects_foreign_file():
        path = work / 'foreign.twstate'
        path.write_bytes(b'NOTSTATE' + bytes(200))
        try:
            verify_module.read_trajectory(path)
        except ValueError:
            return
        raise AssertionError('a non-TWSTATE1 file was accepted')

    def test_unterminated_is_visible():
        path = work / 'partial.twstate'
        build_trajectory(path, terminate=False)
        trajectory = verify_module.read_trajectory(path)
        assert not trajectory['terminated'], 'an unfinalized trajectory looked complete'

    tests += [('trajectory round-trips against its capture', test_roundtrip),
              ('omitted bodies retain their previous pose', test_delta_retention),
              ('a perturbed pose is detected', test_detects_mismatch),
              ('a truncated trajectory is refused', test_rejects_truncation),
              ('a foreign file is refused', test_rejects_foreign_file),
              ('an unfinalized trajectory is visible as such', test_unterminated_is_visible)]

    if args.renderer:
        renderer = Path(args.renderer).resolve()

        def render(state, output, *extra):
            return subprocess.run([str(renderer), '--state', str(state), '--output', str(output),
                                   '--width', '320', '--height', '180', '--samples', '1', *extra],
                                  capture_output=True, text=True)

        def test_renders_every_frame():
            path = render_work / 'render.twstate'
            build_trajectory(path, bodies=4, frames=6)
            output = render_work / 'render.mp4'
            result = render(path, output)
            assert result.returncode == 0, result.stderr.strip()
            assert output.exists(), 'renderer produced no file'
            probe = subprocess.run(['ffprobe', '-v', 'error', '-count_frames', '-select_streams', 'v:0',
                                    '-show_entries', 'stream=nb_read_frames', '-of', 'csv=p=0', str(output)],
                                   capture_output=True, text=True)
            assert probe.stdout.strip() == '6', f'expected 6 encoded frames, got {probe.stdout.strip()!r}'

        def test_refuses_overwrite():
            path = render_work / 'render.twstate'
            output = render_work / 'existing.mp4'
            output.write_bytes(b'not a video')
            result = render(path, output)
            assert result.returncode != 0, 'renderer overwrote an existing file'

        def test_refuses_output_outside_roots():
            path = render_work / 'render.twstate'
            result = render(path, Path(temp.name) / 'outside.mp4')
            # The temporary directory is outside both repository roots.
            assert result.returncode != 0, 'renderer wrote outside the repository roots'

        tests += [('renderer encodes every trajectory frame', test_renders_every_frame),
                  ('renderer refuses to overwrite', test_refuses_overwrite),
                  ('renderer refuses output outside the roots', test_refuses_output_outside_roots)]

    print(f'native render contract: {len(tests)} checks')
    failures = run(tests)
    temp.cleanup()
    if inside is not None:
        inside.cleanup()
    if failures:
        print(f'{len(failures)} failed')
        return 1
    print('all checks passed')
    return 0


if __name__ == '__main__':
    sys.exit(main())
