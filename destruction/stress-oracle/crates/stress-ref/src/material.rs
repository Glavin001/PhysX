//! Per-material parameters and the closed-form material laws that depend only on
//! them: dynamic increase factor, sustained-load damage rate, Weibull sampling.
//!
//! Units are SI throughout (kg, m, s, Pa, J/m^2).

use serde::{Deserialize, Serialize};

/// How a bond softens after its strength is reached.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum BondKind {
    /// Concrete, masonry, mortar, glass: linear softening; the area under the
    /// traction-separation curve is the fracture energy.
    #[default]
    Brittle,
    /// Steel: holds its strength (a plateau) until the absorbed energy reaches the
    /// fracture energy, then snaps.
    Ductile,
}

/// Fracture energies per unit bond area (J/m^2) for each failure family.
#[derive(Clone, Copy, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct FractureEnergy {
    /// Mode I (opening).
    pub tension: f64,
    /// Mode II (sliding).
    pub shear: f64,
    /// Crushing.
    pub compression: f64,
}

/// Dynamic increase factor: strength multiplier as a function of strain rate.
///
/// Piecewise power law in the CEB-FIP form:
/// `1` below `reference_rate`, `(rate/reference)^exponent` up to `transition_rate`,
/// then continuing with `exponent_high`, clamped to `max`.
#[derive(Clone, Copy, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct DifParams {
    pub reference_rate: f64,
    pub exponent: f64,
    pub transition_rate: f64,
    pub exponent_high: f64,
    pub max: f64,
}

impl DifParams {
    pub fn factor(&self, strain_rate: f64) -> f64 {
        let r = strain_rate.abs();
        if r <= self.reference_rate {
            return 1.0;
        }
        let f = if r <= self.transition_rate {
            (r / self.reference_rate).powf(self.exponent)
        } else {
            (self.transition_rate / self.reference_rate).powf(self.exponent)
                * (r / self.transition_rate).powf(self.exponent_high)
        };
        f.clamp(1.0, self.max)
    }
}

/// Time-dependent damage under sustained overload ("creak, crack, give way").
///
/// While the actual stress ratio `s` (stress over the static strength) exceeds
/// `threshold`, a strength-loss variable `omega` grows at
/// `d omega/dt = ((s - threshold)/(1 - threshold))^exponent / time_constant`, and the
/// bond's strength is multiplied by `1 - omega`.
#[derive(Clone, Copy, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct SustainedLoadParams {
    pub threshold: f64,
    pub time_constant: f64,
    pub exponent: f64,
}

impl SustainedLoadParams {
    pub fn rate(&self, stress_ratio: f64) -> f64 {
        if stress_ratio <= self.threshold {
            return 0.0;
        }
        let x = (stress_ratio - self.threshold) / (1.0 - self.threshold).max(1e-12);
        x.powf(self.exponent) / self.time_constant
    }
}

#[derive(Clone, Debug, PartialEq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Material {
    /// kg/m^3.
    pub density: f64,
    /// Physical Young's modulus (Pa). The solver may scale it (see `SimDesc::stiffness_scale`);
    /// strengths and fracture energies are never scaled.
    pub youngs_modulus: f64,
    pub poisson_ratio: f64,
    /// Tension cutoff (Pa).
    pub tensile_strength: f64,
    /// Crushing strength (Pa).
    pub compressive_strength: f64,
    /// Mohr-Coulomb cohesion: shear strength at zero normal stress (Pa).
    pub cohesion: f64,
    /// Mohr-Coulomb friction coefficient (shear strength gain per unit compression);
    /// also the Coulomb friction of a cracked joint.
    pub friction: f64,
    /// Upper limit of the Mohr-Coulomb shear strength (Pa); `None` means unlimited.
    #[serde(default)]
    pub shear_cap: Option<f64>,
    pub fracture_energy: FractureEnergy,
    #[serde(default)]
    pub kind: BondKind,
    /// Weibull modulus of the bond strengths; `None` keeps strengths deterministic.
    #[serde(default)]
    pub weibull_modulus: Option<f64>,
    #[serde(default)]
    pub dif: Option<DifParams>,
    #[serde(default)]
    pub sustained: Option<SustainedLoadParams>,
    /// Fraction of critical damping of the bond dashpots (light; removes ringing).
    #[serde(default = "default_damping")]
    pub damping_ratio: f64,
}

fn default_damping() -> f64 {
    0.01
}

impl Material {
    pub fn shear_modulus(&self) -> f64 {
        self.youngs_modulus / (2.0 * (1.0 + self.poisson_ratio))
    }

    /// One-dimensional wave speed `sqrt(E/rho)` with the physical modulus.
    pub fn bar_wave_speed(&self) -> f64 {
        (self.youngs_modulus / self.density).sqrt()
    }

    pub fn validate(&self, name: &str) -> Result<(), String> {
        let positive = [
            ("density", self.density),
            ("youngs_modulus", self.youngs_modulus),
            ("tensile_strength", self.tensile_strength),
            ("compressive_strength", self.compressive_strength),
            ("fracture_energy.tension", self.fracture_energy.tension),
            ("fracture_energy.shear", self.fracture_energy.shear),
            ("fracture_energy.compression", self.fracture_energy.compression),
        ];
        for (field, v) in positive {
            if !(v.is_finite() && v > 0.0) {
                return Err(format!("material '{name}': {field} must be positive, got {v}"));
            }
        }
        if !(0.0..0.5).contains(&self.poisson_ratio) {
            return Err(format!("material '{name}': poisson_ratio must be in [0, 0.5)"));
        }
        if self.cohesion < 0.0 || self.friction < 0.0 || self.damping_ratio < 0.0 {
            return Err(format!("material '{name}': cohesion, friction and damping must be >= 0"));
        }
        if let Some(m) = self.weibull_modulus {
            if !(m > 0.0) {
                return Err(format!("material '{name}': weibull_modulus must be positive"));
            }
        }
        Ok(())
    }

    // ---- Presets. Values are typical handbook numbers; scenes may override any field. ----

    /// Normal-strength concrete (C30).
    pub fn concrete() -> Material {
        Material {
            density: 2400.0,
            youngs_modulus: 30e9,
            poisson_ratio: 0.2,
            tensile_strength: 3.0e6,
            compressive_strength: 30e6,
            cohesion: 4.5e6,
            friction: 0.75,
            shear_cap: None,
            fracture_energy: FractureEnergy { tension: 120.0, shear: 1200.0, compression: 20_000.0 },
            kind: BondKind::Brittle,
            weibull_modulus: None,
            dif: Some(DifParams {
                reference_rate: 1e-6,
                exponent: 0.018,
                transition_rate: 10.0,
                exponent_high: 1.0 / 3.0,
                max: 6.0,
            }),
            sustained: Some(SustainedLoadParams { threshold: 0.75, time_constant: 1.5, exponent: 2.0 }),
            damping_ratio: 0.01,
        }
    }

    /// Fired-clay brick (bulk).
    pub fn brick() -> Material {
        Material {
            density: 1900.0,
            youngs_modulus: 5e9,
            poisson_ratio: 0.15,
            tensile_strength: 1.0e6,
            compressive_strength: 15e6,
            cohesion: 1.5e6,
            friction: 0.7,
            shear_cap: None,
            fracture_energy: FractureEnergy { tension: 20.0, shear: 200.0, compression: 10_000.0 },
            kind: BondKind::Brittle,
            weibull_modulus: None,
            dif: None,
            sustained: None,
            damping_ratio: 0.01,
        }
    }

    /// Brick-mortar joint (effective joint properties of masonry).
    pub fn mortar() -> Material {
        Material {
            density: 1900.0,
            youngs_modulus: 3e9,
            poisson_ratio: 0.15,
            tensile_strength: 0.3e6,
            compressive_strength: 8e6,
            cohesion: 0.4e6,
            friction: 0.75,
            shear_cap: None,
            fracture_energy: FractureEnergy { tension: 10.0, shear: 100.0, compression: 5_000.0 },
            kind: BondKind::Brittle,
            weibull_modulus: None,
            dif: None,
            sustained: None,
            damping_ratio: 0.01,
        }
    }

    /// Soda-lime glass.
    pub fn glass() -> Material {
        Material {
            density: 2500.0,
            youngs_modulus: 70e9,
            poisson_ratio: 0.22,
            tensile_strength: 40e6,
            compressive_strength: 1000e6,
            cohesion: 40e6,
            friction: 0.2,
            shear_cap: None,
            fracture_energy: FractureEnergy { tension: 8.0, shear: 8.0, compression: 1000.0 },
            kind: BondKind::Brittle,
            weibull_modulus: None,
            dif: None,
            sustained: None,
            damping_ratio: 0.005,
        }
    }

    /// Structural steel: ductile bond with a high fracture energy.
    pub fn steel() -> Material {
        Material {
            density: 7850.0,
            youngs_modulus: 200e9,
            poisson_ratio: 0.3,
            tensile_strength: 355e6,
            compressive_strength: 355e6,
            cohesion: 205e6,
            friction: 0.0,
            shear_cap: Some(205e6),
            fracture_energy: FractureEnergy { tension: 2.0e5, shear: 2.0e5, compression: 2.0e5 },
            kind: BondKind::Ductile,
            weibull_modulus: None,
            dif: None,
            sustained: None,
            damping_ratio: 0.005,
        }
    }

    /// A deterministic, rate-independent linear-elastic brittle material for analytic tests.
    pub fn analytic_test() -> Material {
        Material {
            density: 2000.0,
            youngs_modulus: 1e9,
            poisson_ratio: 0.25,
            tensile_strength: 1e6,
            compressive_strength: 10e6,
            cohesion: 1.5e6,
            friction: 0.6,
            shear_cap: None,
            fracture_energy: FractureEnergy { tension: 100.0, shear: 400.0, compression: 5000.0 },
            kind: BondKind::Brittle,
            weibull_modulus: None,
            dif: None,
            sustained: None,
            damping_ratio: 0.0,
        }
    }
}

/// Look up a preset by name.
pub fn preset(name: &str) -> Option<Material> {
    Some(match name {
        "concrete" => Material::concrete(),
        "brick" => Material::brick(),
        "mortar" => Material::mortar(),
        "glass" => Material::glass(),
        "steel" => Material::steel(),
        "analytic_test" => Material::analytic_test(),
        _ => return None,
    })
}

/// Gamma function (Lanczos, g = 7), accurate to ~1e-15 for positive arguments.
pub fn gamma(x: f64) -> f64 {
    const G: f64 = 7.0;
    const C: [f64; 9] = [
        0.999_999_999_999_809_9,
        676.520_368_121_885_1,
        -1_259.139_216_722_402_8,
        771.323_428_777_653_1,
        -176.615_029_162_140_6,
        12.507_343_278_686_905,
        -0.138_571_095_265_720_12,
        9.984_369_578_019_572e-6,
        1.505_632_735_149_311_6e-7,
    ];
    if x < 0.5 {
        std::f64::consts::PI / ((std::f64::consts::PI * x).sin() * gamma(1.0 - x))
    } else {
        let x = x - 1.0;
        let mut a = C[0];
        let t = x + G + 0.5;
        for (i, c) in C.iter().enumerate().skip(1) {
            a += c / (x + i as f64);
        }
        (2.0 * std::f64::consts::PI).sqrt() * t.powf(x + 0.5) * (-t).exp() * a
    }
}

/// Weibull strength multiplier with unit mean, from a uniform sample `u` in (0, 1).
pub fn weibull_unit_mean(modulus: f64, u: f64) -> f64 {
    let u = u.clamp(1e-300, 1.0 - 1e-16);
    (-(1.0 - u).ln()).powf(1.0 / modulus) / gamma(1.0 + 1.0 / modulus)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn gamma_known_values() {
        assert!((gamma(1.0) - 1.0).abs() < 1e-13);
        assert!((gamma(5.0) - 24.0).abs() < 1e-11);
        assert!((gamma(0.5) - std::f64::consts::PI.sqrt()).abs() < 1e-13);
    }

    #[test]
    fn dif_is_continuous_and_capped() {
        let d = Material::concrete().dif.unwrap();
        assert_eq!(d.factor(1e-7), 1.0);
        let below = d.factor(d.transition_rate * 0.999_999);
        let above = d.factor(d.transition_rate * 1.000_001);
        assert!((below - above).abs() < 1e-4);
        assert!(d.factor(1e9) <= d.max);
    }

    #[test]
    fn weibull_mean_is_one() {
        let n = 200_000;
        let mean: f64 = (0..n).map(|i| weibull_unit_mean(8.0, (i as f64 + 0.5) / n as f64)).sum::<f64>() / n as f64;
        assert!((mean - 1.0).abs() < 1e-3, "mean {mean}");
    }
}
