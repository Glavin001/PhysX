#!/usr/bin/env python3
"""Inspect a committed native wall capture without rendering it.

Two read-only reports over the immutable capture JSON:

  penetration  15-axis oriented-box SAT between chunks of DIFFERENT clusters,
               per frame, plus every audited bond pair that is geometrically
               overlapping yet carries no CPU contact interaction. The latter is
               the signature of the final-pass collision-ownership defect; a
               large inter-cluster penetration with no contacts is the symptom
               a capture must not have.

  composition  What the damage looks like: the authored inputs, the fracture
               frames, and a final-frame grid of which chunks stayed attached to
               the foundation cluster and which moved.

No GPU work, no Blender, no simulation. Numbers come only from the capture, so
they describe that recorded run and nothing else. The 5 cm penetration threshold
used for counting is descriptive, not an acceptance tolerance.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path

# Descriptive reporting threshold, not a physics acceptance tolerance.
SIGNIFICANT_PENETRATION_M = 0.05


def dot(a, b):
    return sum(x * y for x, y in zip(a, b))


def sub(a, b):
    return [x - y for x, y in zip(a, b)]


def cross(a, b):
    return [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]]


def norm(a):
    return math.sqrt(dot(a, a))


def axes(q):
    """Body axes from a quaternion [x, y, z, w]."""
    n = norm(q)
    if n < 1e-12:
        raise ValueError("degenerate rotation in capture")
    x, y, z, w = [v / n for v in q]
    return [[1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w)],
            [2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w)],
            [2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y)]]


def sat(a, b):
    """Oriented-box overlap. Returns (depth, axis) or None when separated.

    Same 15-axis test as the original wall overlap audit: 3 + 3 face normals and
    their 9 cross products. A non-positive gap on any axis proves separation.
    """
    ac, aa, ah = a
    bc, ba, bh = b
    delta = sub(bc, ac)
    best, best_axis = 1e99, None
    for axis in aa + ba + [cross(x, y) for x in aa for y in ba]:
        n = norm(axis)
        if n < 1e-12:
            continue
        axis = [x / n for x in axis]
        gap = (sum(h * abs(dot(axis, x)) for h, x in zip(ah, aa))
               + sum(h * abs(dot(axis, x)) for h, x in zip(bh, ba))
               - abs(dot(axis, delta)))
        if gap <= 0:
            return None
        if gap < best:
            best, best_axis = gap, axis
    return best, best_axis


def self_test():
    """The SAT must reject separated boxes and measure a known penetration."""
    identity = axes([0, 0, 0, 1])
    half = [.48] * 3
    assert sat(([0, 0, 0], identity, half), ([1, 0, 0], identity, half)) is None
    touching = sat(([0, 0, 0], identity, half), ([.9, 0, 0], identity, half))
    assert touching is not None and abs(touching[0] - .06) < 1e-12
    turned = axes([0, 0, math.sin(math.pi / 8), math.cos(math.pi / 8)])
    assert sat(([0, 0, 0], identity, half), ([1.3, 0, 0], turned, half)) is None


def penetration(capture):
    """Deepest inter-cluster overlap per frame, and overlapping pairs with no contact."""
    definitions = {b['id']: b for b in capture['bodies']}
    deepest = None
    per_frame = []
    significant_frames = 0
    overlapping_audited = 0
    missing_contacts = []
    for frame in capture['frames']:
        bodies = {b['id']: b for b in frame['bodies']}
        boxes = [b for b in frame['bodies'] if definitions[b['id']]['shape'] == 'box']
        worst = 0.0
        for index, a in enumerate(boxes):
            for b in boxes[index + 1:]:
                # Chunks of one cluster are one rigid body; overlap is meaningless.
                if a['cluster_id'] == b['cluster_id']:
                    continue
                hit = sat((a['position'], axes(a['rotation']), definitions[a['id']]['half_extents']),
                          (b['position'], axes(b['rotation']), definitions[b['id']]['half_extents']))
                if hit is None:
                    continue
                worst = max(worst, hit[0])
                if deepest is None or hit[0] > deepest['depth_m']:
                    deepest = {'frame': frame['frame'], 'pair': [a['id'], b['id']], 'depth_m': hit[0]}
        per_frame.append(worst)
        significant_frames += worst > SIGNIFICANT_PENETRATION_M

        # A pair that actually overlaps must own a live contact interaction.
        # Absent gpu_state_audit these stay zero: a capture recorded without
        # --audit-gpu-state cannot answer this and must not look like a pass.
        for pair in frame.get('gpu_state_audit', {}).get('contact_pairs', []):
            first, second = pair['chunks']
            if first not in bodies or second not in bodies:
                continue
            a, b = bodies[first], bodies[second]
            hit = sat((a['position'], axes(a['rotation']), definitions[first]['half_extents']),
                      (b['position'], axes(b['rotation']), definitions[second]['half_extents']))
            if hit is None:
                continue
            overlapping_audited += 1
            if not pair['same_cpu_owner'] and not pair['interactions']:
                missing_contacts.append({'frame': frame['frame'], 'chunks': [first, second],
                                         'shape_ids': pair.get('shape_ids'),
                                         'depth_m': hit[0]})
    return {'deepest_intercluster_overlap': deepest,
            'frames_over_threshold': significant_frames,
            'threshold_m': SIGNIFICANT_PENETRATION_M,
            'per_frame_max_m': per_frame,
            'audited_overlapping_pairs': overlapping_audited,
            'overlapping_pairs_without_contact': missing_contacts}


def composition(capture):
    """Authored inputs, fracture timeline and the final-frame damage grid."""
    meta = capture['metadata']
    width, height = meta['width'], meta['height']
    chunks = width * height
    first = capture['frames'][0]['bodies']
    last = capture['frames'][-1]['bodies']

    # A chunk is supported when its cluster still contains a foundation chunk
    # (the bottom row); that is the same rule the capture's own summary uses.
    roots = {b['id']: b['cluster_id'] for b in last[:chunks]}
    foundation = {roots[i] for i in range(width)}
    rows = []
    for y in range(height - 1, -1, -1):
        row = ''
        for x in range(width):
            index = y * width + x
            moved = math.dist(first[index]['position'], last[index]['position'])
            row += '#' if roots[index] in foundation else ('o' if moved < 0.5 else 'x')
        rows.append(row)

    displacement = sorted(((math.dist(first[c]['position'], last[c]['position']), c)
                           for c in range(chunks)), reverse=True)
    return {'authored': {k: meta[k] for k in (
                'width', 'height', 'projectile_mass', 'projectile_speed', 'material_strength',
                'foundation_strength_multiplier', 'correction_limit', 'solver') if k in meta},
            'summary': capture['summary'],
            'status': capture['status'],
            'grid_rows_top_first': rows,
            'projectile': {'start': first[-1]['position'], 'end': last[-1]['position']},
            'largest_displacements_m': [{'chunk': c, 'moved_m': d} for d, c in displacement[:5]],
            'fracture_frames': [{'frame': f['frame'],
                                 'broken_bonds': f['status']['broken_bonds'],
                                 'post_correction_broken_bonds':
                                     f['status'].get('post_correction_broken_bonds')}
                                for f in capture['frames'] if f['status']['broken_bonds']]}


def render_text(report):
    out = []
    c, p = report['composition'], report['penetration']
    a = c['authored']
    s = c['summary']
    out.append(f"{report['capture']}")
    out.append(f"  sha256 {report['capture_sha256'][:16]}…  status={c['status']}")
    out.append("  authored: " + " ".join(f"{k}={v}" for k, v in a.items()))
    out.append(f"  result: {s['broken_bonds']}/{s['bonds']} bonds broken, "
               f"{s['detached_chunks']} detached (peak {s['peak_detached_chunks']}), "
               f"localized={s['localized_damage']}")
    out.append("")
    out.append("  composition — '#' attached to foundation, 'o' detached in place, 'x' moved >=0.5 m")
    for row in c['grid_rows_top_first']:
        out.append("    " + row)
    moved = ", ".join(f"chunk {d['chunk']} {d['moved_m']:.2f} m" for d in c['largest_displacements_m'])
    out.append(f"    largest displacements: {moved}")
    out.append("    fracture frames: " + (", ".join(
        f"{f['frame']} (broken {f['broken_bonds']}"
        + (f", post-correction {f['post_correction_broken_bonds']}"
           if f['post_correction_broken_bonds'] is not None else "") + ")"
        for f in c['fracture_frames']) or "none"))
    out.append("")
    deepest = p['deepest_intercluster_overlap']
    if deepest is None:
        out.append("  penetration — no inter-cluster overlap in any frame")
    else:
        out.append(f"  penetration — deepest {deepest['depth_m']:.4f} m at frame {deepest['frame']} "
                   f"between chunks {deepest['pair'][0]}/{deepest['pair'][1]}; "
                   f"{p['frames_over_threshold']}/{len(p['per_frame_max_m'])} frames over "
                   f"{p['threshold_m']*100:.0f} cm")
    missing = p['overlapping_pairs_without_contact']
    if not p['audited_overlapping_pairs']:
        out.append("    contacts: capture has no GPU audit — rerun with --audit-gpu-state 1 to check")
    elif missing:
        worst = max(missing, key=lambda m: m['depth_m'])
        out.append(f"    contacts: {len(missing)} of {p['audited_overlapping_pairs']} overlapping "
                   f"audited pairs have NO contact interaction (worst {worst['depth_m']*1000:.1f} mm "
                   f"at frame {worst['frame']}, chunks {worst['chunks'][0]}/{worst['chunks'][1]})")
    else:
        out.append(f"    contacts: all {p['audited_overlapping_pairs']} overlapping audited pairs "
                   f"have a live contact interaction")
    return "\n".join(out)


def check(path):
    data = json.loads(path.read_text())
    for key in ('metadata', 'bodies', 'frames', 'summary'):
        if key not in data:
            raise SystemExit(f"{path}: not a native wall capture (missing '{key}')")
    return {'capture': str(path),
            'capture_sha256': hashlib.sha256(path.read_bytes()).hexdigest(),
            'composition': composition(data),
            'penetration': penetration(data)}


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('captures', nargs='+', type=Path)
    parser.add_argument('--json', action='store_true', help='emit the full report as JSON')
    args = parser.parse_args()

    self_test()
    reports = [check(p) for p in args.captures]
    if args.json:
        print(json.dumps(reports if len(reports) > 1 else reports[0], indent=2))
    else:
        print("\n\n".join(render_text(r) for r in reports))


if __name__ == '__main__':
    main()
