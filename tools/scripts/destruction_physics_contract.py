"""Representation-independent physical comparisons shared by regression checkers."""
import math

POSITION_M = 1e-3  # Existing continuous wall position/COM gate.
VELOCITY_M_S = 1e-4  # Existing restored-tick motion gate.
ANGULAR_RAD_S = 1e-4
ORIENTATION_DOT_ERROR = 1e-5


def canonical_partition(labels, invalid=0xffffffff):
    """Authored member order is fixed; internal component labels are arbitrary."""
    first = {}
    return [invalid if label == invalid else first.setdefault(label, i)
            for i, label in enumerate(labels)]


def quaternion_error(a, b):
    if len(a) != 4 or len(b) != 4:
        raise ValueError('Malformed quaternion')
    norms = [math.sqrt(sum(v*v for v in q)) for q in (a, b)]
    if any(not math.isfinite(n) or abs(n-1) > 1e-3 for n in norms):
        raise ValueError('Nonfinite or non-unit quaternion')
    # q and -q represent the same orientation. Normalization removes harmless
    # FP32 norm drift, not an angular difference.
    return max(0.0, 1-abs(sum(x*y for x,y in zip(a,b))/(norms[0]*norms[1])))


def full_motion_error(a, b):
    """Compare accepted cluster orientation and COM velocities in trace units."""
    required = ('qx','qy','qz','qw','vx','vy','vz','wx','wy','wz')
    if any(k not in row for row in (a,b) for k in required):
        raise ValueError('Missing full motion fields; historical position-only traces cannot qualify')
    for row in (a,b):
        if any(not math.isfinite(float(row[k])) for k in required):
            raise ValueError('Non-finite full motion')
    return dict(
        orientation_dot_error=quaternion_error([float(a['q'+k]) for k in 'xyzw'], [float(b['q'+k]) for k in 'xyzw']),
        linear_m_s=math.dist([float(a['v'+k]) for k in 'xyz'], [float(b['v'+k]) for k in 'xyz']),
        angular_rad_s=math.dist([float(a['w'+k]) for k in 'xyz'], [float(b['w'+k]) for k in 'xyz']))
