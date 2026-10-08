// The FP64 reference of impact_projection_fuzz.cu, built as plain host C++
// (the CUDA translation unit's host side lost its candidates: its compiler's
// floating-point assumptions). One capacity set and a point, in plain values.
#pragma once
struct ProjectionCase {
    bool contact;                 // a contact row's cone (mu), else a joint's sets
    double capC,capT,capS,gb,gt,g0,g1,h0,h1,mu;
    double x[6];                  // (N, V1, V2, T, M0, M1)
    double m[4];                  // the metric: forces, twist, bending about t1, t2
};
// The exact projection of c.x onto c's set in diag(m0,m0,m0,m1,m2,m3) into ref.
void projectionReference(const ProjectionCase& c,double* ref);
