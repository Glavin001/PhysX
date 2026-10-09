//! Convex hull chunks: geometry, faces and mass properties.
//!
//! A hull chunk is the convex hull of up to [`MAX_HULL_VERTICES`] points given in the
//! chunk's frame, centred on its centre of mass. Faces are planar convex polygons
//! (coplanar triangles merged), wound counter-clockwise seen from outside.
//!
//! Construction is deliberately simple: every plane through three input points that
//! has all points on one side is a face plane; the face polygon is the 2-D convex hull
//! of the points on that plane. That is O(n^4) in the point count, which for at most 64
//! points is a few milliseconds per chunk, once, and has no degenerate-case logic to
//! get wrong. Mass properties integrate the polyhedron exactly (Mirtich's divergence
//! theorem form, as in Eberly, "Polyhedral Mass Properties").

use crate::math::{Mat3, Vec3};

/// PhysX cooks hulls with at most 64 vertices; the stress solver uses the same limit.
pub const MAX_HULL_VERTICES: usize = 64;

/// One planar face: `normal . x = offset` for points `x` on it, normal outward.
#[derive(Clone, Debug)]
pub struct HullFace {
    /// Vertex indices, counter-clockwise seen from outside.
    pub vertices: Vec<usize>,
    pub normal: Vec3,
    pub offset: f64,
    pub area: f64,
    pub centroid: Vec3,
}

#[derive(Clone, Debug)]
pub struct ConvexHull {
    /// Hull vertices (input points that are corners of the hull).
    pub vertices: Vec<Vec3>,
    pub faces: Vec<HullFace>,
}

/// Mass properties of a solid of unit density.
#[derive(Clone, Copy, Debug)]
pub struct UnitMass {
    pub volume: f64,
    pub centroid: Vec3,
    /// Inertia about the centroid, per unit density.
    pub inertia: Mat3,
}

impl ConvexHull {
    /// The convex hull of `points` (at least 4, not coplanar, at most
    /// [`MAX_HULL_VERTICES`]).
    pub fn new(points: &[Vec3]) -> Result<ConvexHull, String> {
        if points.len() < 4 {
            return Err(format!("a hull needs at least 4 points, got {}", points.len()));
        }
        if points.len() > MAX_HULL_VERTICES {
            return Err(format!("a hull has at most {MAX_HULL_VERTICES} points, got {}", points.len()));
        }
        let size = points.iter().map(|p| p.norm()).fold(0.0, f64::max).max(1e-12);
        let tol = 1e-9 * size;
        // Face planes: (outward normal, offset), each found once.
        let mut planes: Vec<(Vec3, f64)> = Vec::new();
        let n = points.len();
        for i in 0..n {
            for j in i + 1..n {
                for k in j + 1..n {
                    let normal = (points[j] - points[i]).cross(points[k] - points[i]);
                    if normal.norm() < 1e-12 * size * size {
                        continue;
                    }
                    let mut normal = normal.normalized();
                    let mut offset = normal.dot(points[i]);
                    let (lo, hi) = points.iter().fold((f64::INFINITY, f64::NEG_INFINITY), |(lo, hi), p| {
                        let d = normal.dot(*p) - offset;
                        (lo.min(d), hi.max(d))
                    });
                    if hi <= tol {
                        // All points behind: outward as computed.
                    } else if lo >= -tol {
                        normal = -normal;
                        offset = -offset;
                    } else {
                        continue;
                    }
                    if !planes.iter().any(|(m, o)| m.dot(normal) > 1.0 - 1e-9 && (o - offset).abs() <= tol) {
                        planes.push((normal, offset));
                    }
                }
            }
        }
        if planes.len() < 4 {
            return Err("hull points are coplanar".into());
        }
        // Keep only points that are corners of some face; index them.
        let mut vertices: Vec<Vec3> = Vec::new();
        let mut faces = Vec::with_capacity(planes.len());
        for (normal, offset) in planes {
            let on: Vec<Vec3> = points.iter().copied().filter(|p| (normal.dot(*p) - offset).abs() <= tol).collect();
            let polygon = convex_polygon(&on, normal);
            let ids: Vec<usize> = polygon
                .iter()
                .map(|p| match vertices.iter().position(|v| (*v - *p).norm() <= tol) {
                    Some(i) => i,
                    None => {
                        vertices.push(*p);
                        vertices.len() - 1
                    }
                })
                .collect();
            let (area, centroid) = polygon_area_centroid(&polygon, normal);
            faces.push(HullFace { vertices: ids, normal, offset, area, centroid });
        }
        Ok(ConvexHull { vertices, faces })
    }

    /// Exact volume, centroid and inertia (about the centroid) at unit density.
    pub fn unit_mass(&self) -> UnitMass {
        // Integrals of 1, x, y, z, x^2, y^2, z^2, xy, yz, zx over the solid, from the
        // faces fanned into triangles (Eberly's form of Mirtich's algorithm).
        let mut intg = [0.0f64; 10];
        for f in &self.faces {
            let v0 = self.vertices[f.vertices[0]];
            for w in f.vertices[1..].windows(2) {
                let (v1, v2) = (self.vertices[w[0]], self.vertices[w[1]]);
                let d = (v1 - v0).cross(v2 - v0);
                let sub = |a: f64, b: f64, c: f64| {
                    let t0 = a + b;
                    let f1 = t0 + c;
                    let t1 = a * a;
                    let t2 = t1 + b * t0;
                    let f2 = t2 + c * f1;
                    let f3 = a * t1 + b * t2 + c * f2;
                    (f1, f2, f3, f2 + a * (f1 + a), f2 + b * (f1 + b), f2 + c * (f1 + c))
                };
                let (f1x, f2x, f3x, g0x, g1x, g2x) = sub(v0.x, v1.x, v2.x);
                let (_, f2y, f3y, g0y, g1y, g2y) = sub(v0.y, v1.y, v2.y);
                let (_, f2z, f3z, g0z, g1z, g2z) = sub(v0.z, v1.z, v2.z);
                intg[0] += d.x * f1x;
                intg[1] += d.x * f2x;
                intg[2] += d.y * f2y;
                intg[3] += d.z * f2z;
                intg[4] += d.x * f3x;
                intg[5] += d.y * f3y;
                intg[6] += d.z * f3z;
                intg[7] += d.x * (v0.y * g0x + v1.y * g1x + v2.y * g2x);
                intg[8] += d.y * (v0.z * g0y + v1.z * g1y + v2.z * g2y);
                intg[9] += d.z * (v0.x * g0z + v1.x * g1z + v2.x * g2z);
            }
        }
        let k = [1.0 / 6.0, 1.0 / 24.0, 1.0 / 24.0, 1.0 / 24.0, 1.0 / 60.0, 1.0 / 60.0, 1.0 / 60.0, 1.0 / 120.0, 1.0 / 120.0, 1.0 / 120.0];
        for (v, k) in intg.iter_mut().zip(k) {
            *v *= k;
        }
        let volume = intg[0];
        let c = Vec3::new(intg[1], intg[2], intg[3]) * (1.0 / volume);
        let ixx = intg[5] + intg[6] - volume * (c.y * c.y + c.z * c.z);
        let iyy = intg[4] + intg[6] - volume * (c.z * c.z + c.x * c.x);
        let izz = intg[4] + intg[5] - volume * (c.x * c.x + c.y * c.y);
        let ixy = -(intg[7] - volume * c.x * c.y);
        let iyz = -(intg[8] - volume * c.y * c.z);
        let izx = -(intg[9] - volume * c.z * c.x);
        let inertia = Mat3 { m: [[ixx, ixy, izx], [ixy, iyy, iyz], [izx, iyz, izz]] };
        UnitMass { volume, centroid: c, inertia }
    }

    /// The hull moved by `-shift` (to put its centroid at the origin).
    pub fn translated(&self, shift: Vec3) -> ConvexHull {
        let vertices = self.vertices.iter().map(|v| *v - shift).collect();
        let faces = self
            .faces
            .iter()
            .map(|f| HullFace { offset: f.offset - f.normal.dot(shift), centroid: f.centroid - shift, ..f.clone() })
            .collect();
        ConvexHull { vertices, faces }
    }

    /// Half extents of the axis-aligned box about the origin that contains the hull.
    pub fn half_extents(&self) -> Vec3 {
        self.vertices.iter().fold(Vec3::ZERO, |h, v| h.component_max(v.abs()))
    }

    /// Distance of `p` (hull frame) outside the hull's nearest face plane, and that
    /// face: negative inside (minus the depth to the nearest face).
    pub fn signed_distance(&self, p: Vec3) -> (f64, usize) {
        self.faces
            .iter()
            .enumerate()
            .map(|(i, f)| (f.normal.dot(p) - f.offset, i))
            .fold((f64::NEG_INFINITY, 0), |a, b| if b.0 > a.0 { b } else { a })
    }

    /// Contact sample points (hull frame): the corners pulled 10% towards the centre
    /// plus the face centroids, as for boxes.
    pub fn sample_points(&self) -> Vec<Vec3> {
        self.vertices.iter().map(|v| *v * 0.9).chain(self.faces.iter().map(|f| f.centroid)).collect()
    }
}

/// The contact patch shared by two touching chunks: where a face of `a` and a face of
/// `b` lie in one plane facing each other, the overlap of the two face polygons.
#[derive(Clone, Copy, Debug)]
pub struct Patch {
    pub centroid: Vec3,
    /// Unit normal from `a` towards `b`.
    pub normal: Vec3,
    pub area: f64,
    /// Principal in-plane direction and the widths of the rectangle with the patch's
    /// area-moments about its principal axes (`width[0]` along `tangent`).
    pub tangent: Vec3,
    pub width: [f64; 2],
}

/// The patch between hull `a` at `pa` and hull `b` at `pb` (same orientation, world
/// offsets), for faces within `gap` of each other and facing along `normal` (a to b).
pub fn contact_patch(a: &ConvexHull, pa: Vec3, b: &ConvexHull, pb: Vec3, normal: Vec3, gap: f64) -> Option<Patch> {
    let u = normal.any_perpendicular().normalized();
    let v = normal.cross(u);
    let mut best: Option<Patch> = None;
    for fa in a.faces.iter().filter(|f| f.normal.dot(normal) > 0.995) {
        for fb in b.faces.iter().filter(|f| f.normal.dot(-normal) > 0.995) {
            let (oa, ob) = (fa.offset + fa.normal.dot(pa), fb.offset + fb.normal.dot(pb));
            if (oa + ob).abs() > gap {
                continue;
            }
            let flat = |h: &ConvexHull, f: &HullFace, p: Vec3| -> Vec<(f64, f64)> {
                let mut poly: Vec<(f64, f64)> = f.vertices.iter().map(|&i| ((h.vertices[i] + p).dot(u), (h.vertices[i] + p).dot(v))).collect();
                if signed_area(&poly) < 0.0 {
                    poly.reverse();
                }
                poly
            };
            let overlap = clip(&flat(a, fa, pa), &flat(b, fb, pb));
            let Some((area, cu, cv, iuu, ivv, iuv)) = moments(&overlap) else { continue };
            if best.is_some_and(|p| p.area >= area) {
                continue;
            }
            // Principal axes of the in-plane second moments.
            let angle = 0.5 * (2.0 * iuv).atan2(iuu - ivv);
            let (c, s) = (angle.cos(), angle.sin());
            let i0 = iuu * c * c + 2.0 * iuv * c * s + ivv * s * s;
            let i1 = iuu * s * s - 2.0 * iuv * c * s + ivv * c * c;
            let plane = 0.5 * (oa - ob);
            best = Some(Patch {
                centroid: u * cu + v * cv + normal * plane,
                normal,
                area,
                tangent: (u * c + v * s).normalized(),
                width: [(12.0 * i0.max(0.0) / area).sqrt(), (12.0 * i1.max(0.0) / area).sqrt()],
            });
        }
    }
    best
}

fn signed_area(p: &[(f64, f64)]) -> f64 {
    0.5 * (0..p.len()).map(|i| p[i].0 * p[(i + 1) % p.len()].1 - p[(i + 1) % p.len()].0 * p[i].1).sum::<f64>()
}

/// Intersection of two counter-clockwise convex polygons (Sutherland-Hodgman).
fn clip(subject: &[(f64, f64)], window: &[(f64, f64)]) -> Vec<(f64, f64)> {
    let mut out = subject.to_vec();
    for i in 0..window.len() {
        let (e0, e1) = (window[i], window[(i + 1) % window.len()]);
        let side = |p: (f64, f64)| (e1.0 - e0.0) * (p.1 - e0.1) - (e1.1 - e0.1) * (p.0 - e0.0);
        let input = std::mem::take(&mut out);
        for j in 0..input.len() {
            let (p, q) = (input[j], input[(j + 1) % input.len()]);
            let (sp, sq) = (side(p), side(q));
            if sp >= 0.0 {
                out.push(p);
            }
            if (sp >= 0.0) != (sq >= 0.0) {
                let t = sp / (sp - sq);
                out.push((p.0 + t * (q.0 - p.0), p.1 + t * (q.1 - p.1)));
            }
        }
        if out.is_empty() {
            break;
        }
    }
    out
}

/// Area, centroid and second moments about the centroid (`int u^2`, `int v^2`,
/// `int uv`) of a counter-clockwise polygon; `None` if degenerate.
fn moments(p: &[(f64, f64)]) -> Option<(f64, f64, f64, f64, f64, f64)> {
    if p.len() < 3 {
        return None;
    }
    let (mut a, mut cx, mut cy, mut ixx, mut iyy, mut ixy) = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    for i in 0..p.len() {
        let ((x0, y0), (x1, y1)) = (p[i], p[(i + 1) % p.len()]);
        let cr = x0 * y1 - x1 * y0;
        a += cr;
        cx += (x0 + x1) * cr;
        cy += (y0 + y1) * cr;
        ixx += (x0 * x0 + x0 * x1 + x1 * x1) * cr;
        iyy += (y0 * y0 + y0 * y1 + y1 * y1) * cr;
        ixy += (x0 * y1 + 2.0 * x0 * y0 + 2.0 * x1 * y1 + x1 * y0) * cr;
    }
    a *= 0.5;
    if a <= 1e-12 {
        return None;
    }
    let (cx, cy) = (cx / (6.0 * a), cy / (6.0 * a));
    let (ixx, iyy, ixy) = (ixx / 12.0 - a * cx * cx, iyy / 12.0 - a * cy * cy, ixy / 24.0 - a * cx * cy);
    Some((a, cx, cy, ixx, iyy, ixy))
}

/// Counter-clockwise (about `normal`) convex polygon through the coplanar `points`.
fn convex_polygon(points: &[Vec3], normal: Vec3) -> Vec<Vec3> {
    let u = normal.any_perpendicular().normalized();
    let v = normal.cross(u);
    let mut pts: Vec<(f64, f64, Vec3)> = points.iter().map(|p| (p.dot(u), p.dot(v), *p)).collect();
    pts.sort_by(|a, b| a.0.total_cmp(&b.0).then(a.1.total_cmp(&b.1)));
    pts.dedup_by(|a, b| (a.2 - b.2).norm() < 1e-12);
    let cross = |o: &(f64, f64, Vec3), a: &(f64, f64, Vec3), b: &(f64, f64, Vec3)| (a.0 - o.0) * (b.1 - o.1) - (a.1 - o.1) * (b.0 - o.0);
    // Andrew's monotone chain: lower then upper hull, collinear points dropped.
    let mut hull: Vec<(f64, f64, Vec3)> = Vec::new();
    for pass in 0..2 {
        let start = hull.len();
        let iter: Box<dyn Iterator<Item = &(f64, f64, Vec3)>> = if pass == 0 { Box::new(pts.iter()) } else { Box::new(pts.iter().rev()) };
        for p in iter {
            while hull.len() >= start + 2 && cross(&hull[hull.len() - 2], &hull[hull.len() - 1], p) <= 1e-18 {
                hull.pop();
            }
            hull.push(*p);
        }
        hull.pop();
    }
    hull.into_iter().map(|p| p.2).collect()
}

/// Area and centroid of a planar convex polygon.
fn polygon_area_centroid(poly: &[Vec3], normal: Vec3) -> (f64, Vec3) {
    let o = poly[0];
    let (mut area, mut c) = (0.0, Vec3::ZERO);
    for w in poly[1..].windows(2) {
        let a = 0.5 * (w[0] - o).cross(w[1] - o).dot(normal);
        area += a;
        c += (o + w[0] + w[1]) * (a / 3.0);
    }
    (area, c * (1.0 / area))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn box_points(h: Vec3) -> Vec<Vec3> {
        (0..8).map(|i| Vec3::new(if i & 1 == 0 { -h.x } else { h.x }, if i & 2 == 0 { -h.y } else { h.y }, if i & 4 == 0 { -h.z } else { h.z })).collect()
    }

    #[test]
    fn box_hull_has_six_quads_and_exact_mass_properties() {
        let h = Vec3::new(0.3, 0.2, 0.1);
        let hull = ConvexHull::new(&box_points(h)).unwrap();
        assert_eq!(hull.faces.len(), 6);
        assert!(hull.faces.iter().all(|f| f.vertices.len() == 4));
        let m = hull.unit_mass();
        let v = 8.0 * h.x * h.y * h.z;
        assert!((m.volume - v).abs() < 1e-12 * v);
        assert!(m.centroid.norm() < 1e-12);
        let ixx = v * (4.0 * h.y * h.y + 4.0 * h.z * h.z) / 12.0;
        assert!((m.inertia.m[0][0] - ixx).abs() < 1e-12 * ixx);
        assert!(m.inertia.m[0][1].abs() < 1e-15);
        let total: f64 = hull.faces.iter().map(|f| f.area).sum();
        assert!((total - 8.0 * (h.x * h.y + h.y * h.z + h.z * h.x)).abs() < 1e-12);
    }

    #[test]
    fn stacked_boxes_share_their_full_face_as_the_patch() {
        let lower = ConvexHull::new(&box_points(Vec3::new(0.3, 0.2, 0.1))).unwrap();
        let upper = ConvexHull::new(&box_points(Vec3::new(0.2, 0.2, 0.1))).unwrap();
        // Upper box offset by 0.1 in x: overlap is x in [-0.1, 0.3] x y in [-0.2, 0.2].
        let p = contact_patch(&lower, Vec3::ZERO, &upper, Vec3::new(0.1, 0.0, 0.2), Vec3::Z, 1e-9).unwrap();
        assert!((p.area - 0.4 * 0.4).abs() < 1e-12, "{}", p.area);
        assert!((p.centroid - Vec3::new(0.1, 0.0, 0.1)).norm() < 1e-12, "{:?}", p.centroid);
        let w = [p.width[0].max(p.width[1]), p.width[0].min(p.width[1])];
        assert!((w[0] - 0.4).abs() < 1e-9 && (w[1] - 0.4).abs() < 1e-9, "{w:?}");
        assert!(contact_patch(&lower, Vec3::ZERO, &upper, Vec3::new(0.0, 0.0, 0.25), Vec3::Z, 1e-3).is_none());
    }

    #[test]
    fn tetrahedron_and_interior_points() {
        let mut pts = vec![Vec3::ZERO, Vec3::X, Vec3::Y, Vec3::Z];
        pts.push(Vec3::splat(0.1)); // interior: dropped
        let hull = ConvexHull::new(&pts).unwrap();
        assert_eq!((hull.vertices.len(), hull.faces.len()), (4, 4));
        let m = hull.unit_mass();
        assert!((m.volume - 1.0 / 6.0).abs() < 1e-12);
        assert!((m.centroid - Vec3::splat(0.25)).norm() < 1e-12);
        let (d, _) = hull.signed_distance(Vec3::splat(0.2));
        assert!(d < 0.0);
        assert!(hull.signed_distance(Vec3::splat(1.0)).0 > 0.0);
    }
}
