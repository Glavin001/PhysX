#!/usr/bin/env python3
"""Check production motion expansion arithmetic against Python exact rationals.

Compile the actual private device header for the host, replacing only CUDA type
and intrinsic declarations. This is an arithmetic oracle, not GPU qualification.
The native vehicle regression separately executes the compiled GPU consumer.
"""
import ctypes as C
from fractions import Fraction as F
from pathlib import Path
import random
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
HEADER = ROOT / 'blast/source/sdk/extensions/stressgpu/detail/StressMotionPair.cuh'
PREFIX = r'''
#include <cmath>
#include <algorithm>
using std::isfinite;
#define __device__
#define __forceinline__ inline
#define __noinline__ __attribute__((noinline))
struct double3 { double x,y,z; };
inline double __dmul_rn(double a,double b){return a*b;}
inline double __dadd_rn(double a,double b){return a+b;}
inline double __dsub_rn(double a,double b){return a-b;}
namespace Nv { namespace Blast { using StressReal=float; }}
'''
SUFFIX = r'''
using namespace Nv::Blast::StressHierarchy;
extern "C" {
int sum(const MotionExact* a,const MotionExact* b,MotionExact* out){
    bool exact=true;*out=motionExactAdd(*a,*b,exact);return exact;
}
int difference(float a,float b,MotionExact* out){
    bool exact=true;*out=motionExactDifference(a,b,exact);return exact;
}
int product(const MotionExact* a,const MotionExact* b,const MotionExact* c,const MotionExact* d){
    return motionProductEqual(*a,*b,*c,*d);
}
int greater(const MotionExact* a,const MotionExact* b){return motionGreater(*a,*b);}
}
'''
A = C.c_float * 8
rng = random.Random(918272)
checks = 0

def f32(v):
    return struct.unpack('f', struct.pack('f', v))[0]

def value(a):
    return sum((F(float(x)) for x in a), F(0))

def require(condition, message):
    global checks
    checks += 1
    if not condition:
        raise AssertionError(message)

def expansion():
    # Nonoverlapping components, with both signs and broad exponent gaps.
    exponent = rng.randint(-12, 48)
    terms = []
    for _ in range(rng.randint(1, 3)):
        terms.append(f32(rng.choice([-1, 1]) * rng.uniform(1, 2) * 2.0 ** exponent))
        exponent -= rng.randint(26, 44)
    return A(*(terms + [0] * (8-len(terms))))

with tempfile.TemporaryDirectory(prefix='motion-exact-') as folder:
    folder = Path(folder)
    source = folder / 'test.cc'
    production = HEADER.read_text().replace('#include "StressHierarchyKernels.cuh"', '').replace('#pragma once', '')
    source.write_text(PREFIX + production + SUFFIX)
    lib = folder / 'oracle.dylib'
    subprocess.run(['c++', '-std=c++17', '-O2', '-ffp-contract=off', '-fno-fast-math',
                    '-shared', '-fPIC', str(source), '-o', str(lib)], check=True)
    api = C.CDLL(str(lib))
    api.sum.argtypes = [C.POINTER(A)] * 3
    api.product.argtypes = [C.POINTER(A)] * 4
    api.greater.argtypes = [C.POINTER(A)] * 2
    api.difference.argtypes = [C.c_float, C.c_float, C.POINTER(A)]
    def product(a, b, c, d):
        result = bool(api.product(C.byref(a), C.byref(b), C.byref(c), C.byref(d)))
        require(result == (value(a) * value(b) == value(c) * value(d)),
                f'product mismatch: {list(a)}, {list(b)}, {list(c)}, {list(d)}')
    # The exact value cannot fit binary64, but two binary32 terms suffice.
    for tiny in [1e-18, -1e-18, 2.0**-90, -2.0**-90]:
        out = A()
        require(api.difference(1, tiny, C.byref(out)) == 1, 'tiny COM offset rejected')
        require(value(out) == F(1) - F(f32(tiny)), 'tiny COM offset discarded')
        # Double conversion would say these unequal products are equal.
        product(out, A(1, 0, 0), A(1, 0, 0), A(1, 0, 0))
        back = A()
        require(api.sum(C.byref(out), C.byref(A(-1, 0, 0)), C.byref(back)) == 1,
                'exact cancellation rejected')
        require(value(back) == -F(f32(tiny)), 'cancellation lost low term')
    # Full model tours combine more than three terms; preserve the fourth too.
    out = A()
    require(api.sum(C.byref(A(1, 2.0**-28, 2.0**-56)), C.byref(A(2.0**-84, 0, 0)), C.byref(out)) == 1,
            'fourth nonzero term rejected')
    require(value(out) == F(1) + F(2.0**-28) + F(2.0**-56) + F(2.0**-84), 'fourth term discarded')
    for invalid in [float('inf'), float('nan'), 2.0**70, 2.0**-110]:
        require(api.difference(invalid, 0, C.byref(out)) == 0, 'unsupported value accepted')
    accepted = 0
    for _ in range(10000):
        a, b, c, d = [expansion() for _ in range(4)]
        if api.sum(C.byref(a), C.byref(b), C.byref(out)):
            accepted += 1
            require(value(out) == value(a) + value(b), 'accepted sum is not exact')
        product(a, b, c, d)
        product(a, b, b, a)  # exact equality with differently ordered products
        product(a, A(2, 0, 0), A(*(x*2 for x in a)), A(1, 0, 0))
        positive_a = A(*(x if a[0] >= 0 else -x for x in a))
        positive_b = A(*(x if b[0] >= 0 else -x for x in b))
        require(bool(api.greater(C.byref(positive_a), C.byref(positive_b))) == (value(positive_a) > value(positive_b)),
                'exact magnitude ordering mismatch')
    # Long Euler-tour-like walks must preserve low terms across metre-scale
    # cancellation. These exercise the wide addition path (more than 3 terms).
    wide = 0
    for _ in range(100):
        terms = [f32(rng.choice([-1, 1]) * rng.uniform(1, 2) * 2.0**rng.randint(-70, 20)) for _ in range(100)]
        current, rational = A(), F(0)
        for term in terms + [-x for x in reversed(terms)]:
            target = A()
            require(api.sum(C.byref(current), C.byref(A(term)), C.byref(target)) == 1,
                    'bounded tour sum rejected')
            rational += F(term)
            require(value(target) == rational, 'bounded tour lost a low term')
            wide += sum(x != 0 for x in target) > 3
            current = target
        require(value(current) == 0, 'reversed tour failed to close exactly')
    require(wide > 100, 'wide-addition path was not exercised')
    require(accepted > 100, 'random corpus failed to exercise accepted sums')
    print(f'PASS: {checks} exact-rational checks; {accepted} accepted random sums; fixed seed 918272')
