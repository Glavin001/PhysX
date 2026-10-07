// Bending and torsion stress of a bond against beam theory (host only).
//
// A cantilever of length L under a tip load P has, at its root, shear P and
// moment M = P L. The root bond's peak fibre stress is sigma = M c / I: for a
// b x h rectangle bending about the axis along b, 6 M / (b h^2). A 50 x 200 mm
// joist on edge and the same timber laid flat as a plank have equal area and
// a fourfold difference in sigma.
//
// extStressCalcBondStress (area-only: 6/sqrt(A), gain capped at bendGainMax)
// reads both alike; extStressCalcBondStressSection must match beam theory for
// each, and the polar torsion of the patch, and keep the square-patch fallback.
//
//   ./build_and_run_section.sh          exit 0 when every case passes
//   SECTION_TEST_LEGACY=1 ...           grades the capped formula instead (fails)

#include "NvBlastExtStressFormula.h"

#include <cmath>
#include <cstdio>
#include <cstdlib>

using namespace Nv::Blast;

namespace
{
int failures = 0;
const bool legacy = std::getenv("SECTION_TEST_LEGACY") != nullptr;

void expectNear(const char* what, double got, double want, double rel = 1e-5)
{
    const double err = std::fabs(got - want) / std::fmax(std::fabs(want), 1e-30);
    const bool ok = err <= rel;
    std::printf("%s %-46s got %.6e want %.6e (rel %.1e)\n", ok ? "ok  " : "FAIL", what, got, want, err);
    if (!ok) ++failures;
}

struct Stress { float normal, shear, bend; };

/// The bond at the cantilever's root: normal +x, load P down (-y) at x = L.
/// width b along z, depth h along y; section principal axes y and z.
Stress root(float P, float L, float b, float h, float twist = 0.0f, float live = 1.0f, bool withSection = true)
{
    const ExtStressVec3 normal{1, 0, 0};
    const ExtStressVec3 linear{0, -P, 0};           // shear across the root
    const ExtStressVec3 angular{twist, 0, -P * L};  // M about z (the solver's sign is immaterial)
    const float area = b * h;
    Stress s{};
    if (legacy)
    {
        extStressCalcBondStress(linear, angular, normal, area * live, 1.0f, 3.0f, s.normal, s.shear, s.bend);
        return s;
    }
    // Moduli at the authored area: about z (axis) the fibres run along y.
    const ExtStressVec3 axis{0, 0, 1};
    const float s0 = b * h * h / 6, s1 = h * b * b / 6;
    const float zt = b * h * std::sqrt(b * b + h * h) / 6;   // I_p / r_max
    extStressCalcBondStressSection(linear, angular, normal, area * live, area, axis,
        withSection ? s0 : 0.0f, withSection ? s1 : 0.0f, withSection ? zt : 0.0f, s.normal, s.shear, s.bend);
    return s;
}
}  // namespace

int main()
{
    const float P = 1000.0f, L = 2.0f;   // 1 kN at 2 m: M = 2 kN m
    const double M = double(P) * L;

    // 1. Joist on edge, 50 wide x 200 deep: sigma = 6 M / (b h^2) = 6 MPa.
    const Stress joist = root(P, L, 0.05f, 0.2f);
    expectNear("joist 50x200: bending = 6 M / (b h^2)", joist.bend, 6 * M / (0.05 * 0.2 * 0.2));
    expectNear("joist 50x200: shear = P / A", joist.shear, P / (0.05 * 0.2));

    // 2. The same timber flat, 200 wide x 50 deep: four times the stress.
    const Stress plank = root(P, L, 0.2f, 0.05f);
    expectNear("plank 200x50: bending = 6 M / (b h^2)", plank.bend, 6 * M / (0.2 * 0.05 * 0.05));
    expectNear("plank / joist bending = 4", plank.bend / joist.bend, 4.0);

    // 3. Biaxial: the moment on both principal axes, the corner fibre.
    {
        const ExtStressVec3 normal{1, 0, 0}, axis{0, 0, 1};
        const float b = 0.09f, h = 0.045f, My = 30.0f, Mz = 50.0f;
        float n, sh, be;
        if (legacy) extStressCalcBondStress({0, 0, 0}, {0, My, Mz}, normal, b * h, 1.0f, 3.0f, n, sh, be);
        else extStressCalcBondStressSection({0, 0, 0}, {0, My, Mz}, normal, b * h, b * h, axis,
            b * h * h / 6, h * b * b / 6, b * h * std::sqrt(b * b + h * h) / 6, n, sh, be);
        expectNear("biaxial 90x45: |Mz|/S_z + |My|/S_y", be, Mz / (b * h * h / 6.0) + My / (h * b * b / 6.0));
    }

    // 4. Twist: the patch as an interface, tau = T r_max / I_p.
    {
        const float b = 0.2f, h = 0.05f, T = 100.0f;
        const Stress t = root(0.0f, 0.0f, b, h, T);
        const double ip = double(b) * h * (b * b + h * h) / 12, rmax = 0.5 * std::sqrt(double(b) * b + h * h);
        expectNear("twist 200x50: tau = T r_max / I_p", t.shear, T * rmax / ip);
    }

    // 5. Damage: half the area left at full depth, twice the stress.
    {
        const Stress half = root(P, L, 0.05f, 0.2f, 0.0f, 0.5f);
        expectNear("joist at half its area: twice the bending", half.bend, 2 * joist.bend);
    }

    // 6. No section data: the square patch of the area, uncapped.
    if (!legacy)
    {
        const Stress square = root(P, L, 0.1f, 0.1f, 0.0f, 1.0f, false);
        expectNear("no section, 0.01 m^2: 6 M / a^3 (a square)", square.bend, 6 * M / (0.1 * 0.1 * 0.1));
        const Stress squareTwist = root(0.0f, 0.0f, 0.1f, 0.1f, 100.0f, 1.0f, false);
        expectNear("no section: twist of a square, 3 sqrt(2) T / a^3", squareTwist.shear, 3 * std::sqrt(2.0) * 100 / 1e-3);
    }

    std::printf("%s: %d failure(s)%s\n", failures ? "FAILED" : "passed", failures,
        legacy ? " (legacy capped formula)" : "");
    return failures ? 1 : 0;
}
