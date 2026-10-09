//! Multi-level pre-fracture: replace a coarse chunk by its finer children on demand.
//!
//! The children take over the coarse chunk's rigid displacement and velocity field
//! (`u + theta x d`, `v + w x d`), which conserves its momentum and kinetic energy
//! when the children partition it. Every bond that touched the coarse chunk is
//! replaced by the finer bonds across the same interface; where the neighbour is
//! still coarse, the fine bond is re-attached to it (geometry, stiffness and
//! strength re-derived for the new chunk spacing) and inherits the damage history of
//! the coarse bond it replaces, so a refined crack keeps its state.

use std::collections::HashMap;

use crate::bond::BondGeometry;
use crate::joint::JointState;
use crate::solver::{ReferenceSolver, RtBond, SolverEvent};
use crate::structure::{bond_physics, reduced_mass};

impl ReferenceSolver {
    /// Active chunk representing chunk `c` (itself or its nearest active ancestor).
    pub fn active_representative(&self, s: usize, mut c: usize) -> Option<usize> {
        loop {
            if self.chunks[s][c].active {
                return Some(c);
            }
            c = self.structures[s].chunks[c].parent?;
        }
    }

    /// Refine active chunk `p` of structure `s` into its children. Returns false if it has none.
    pub fn refine_chunk(&mut self, s: usize, p: usize) -> bool {
        let children = self.structures[s].chunks[p].children.clone();
        if children.is_empty() || !self.chunks[s][p].active {
            return false;
        }
        let ci = self.chunks[s][p].cluster;
        let ps = self.chunks[s][p];
        for &c in &children {
            let d = self.structures[s].chunks[c].center - self.structures[s].chunks[p].center;
            let st = &mut self.chunks[s][c];
            st.u = ps.u + ps.th.cross(d);
            st.th = ps.th;
            st.v = ps.v + ps.w.cross(d);
            st.w = ps.w;
            st.active = true;
            st.removed = false;
            st.cluster = ci;
        }
        self.chunks[s][p].active = false;

        // Retire the coarse bonds, remembering their history per neighbour.
        let mut inherited: HashMap<usize, JointState> = HashMap::new();
        for &bi in &self.chunk_bonds[s][p].clone() {
            let b = &mut self.bonds[s][bi];
            if !b.alive {
                continue;
            }
            let other = if b.geometry.a == p { b.geometry.b } else { b.geometry.a };
            b.alive = false;
            let mut st = b.joint.clone();
            st.plastic = Default::default();
            st.rebar_plastic = 0.0;
            st.rebar_slip = [0.0; 2];
            inherited.insert(other, st);
        }

        // Create the finer bonds that now have two distinct active representatives.
        let child_level = self.structures[s].chunks[children[0]].level;
        let child_set: std::collections::HashSet<usize> = children.iter().copied().collect();
        let existing: std::collections::HashSet<(usize, usize, usize)> = self.bonds[s]
            .iter()
            .filter(|b| b.alive)
            .map(|b| (b.source, b.geometry.a, b.geometry.b))
            .collect();
        for (si, sb) in self.structures[s].bonds.clone().iter().enumerate() {
            if sb.level != child_level {
                continue;
            }
            let (x, y) = (sb.geometry.a, sb.geometry.b);
            if !child_set.contains(&x) && !child_set.contains(&y) {
                continue;
            }
            let (Some(rx), Some(ry)) = (self.active_representative(s, x), self.active_representative(s, y)) else {
                continue;
            };
            if rx == ry || existing.contains(&(si, rx, ry)) {
                continue;
            }
            if self.chunks[s][rx].cluster != self.chunks[s][ry].cluster {
                continue;
            }
            let st = &self.structures[s];
            let g = &sb.geometry;
            let geometry = BondGeometry::new(
                rx,
                ry,
                st.chunks[rx].center,
                st.chunks[ry].center,
                g.centroid,
                g.normal,
                g.t1,
                g.area,
                g.width,
            );
            let mred = reduced_mass(&st.chunks[rx], &st.chunks[ry]);
            let (stiffness, strength, rebar, damping) =
                bond_physics(&geometry, &sb.material, sb.buckling_length, sb.rebar_spec.as_ref(), st.stiffness_scale, mred);
            // Interface with the outside inherits the coarse bond's history.
            let outside = if child_set.contains(&x) { ry } else { rx };
            let outside_parent = if child_set.contains(&x) { y } else { x };
            let joint = if child_set.contains(&x) && child_set.contains(&y) {
                JointState::new()
            } else {
                inherited
                    .get(&outside)
                    .or_else(|| self.structures[s].chunks[outside_parent].parent.and_then(|q| inherited.get(&q)))
                    .cloned()
                    .unwrap_or_else(JointState::new)
            };
            self.bonds[s].push(RtBond {
                source: si,
                geometry,
                stiffness,
                strength,
                rebar,
                weibull: sb.weibull,
                damping,
                level: sb.level,
                alive: true,
                joint,
                force: Default::default(),
                measures: Default::default(),
                stored: 0.0,
            });
        }
        self.rebuild_adjacency(s);
        self.refresh_cluster_membership(ci);
        self.events.push(SolverEvent::Refined { time: self.time, structure: s, chunk: p });
        // Refinement can expose a crack that already disconnects the children.
        self.split_cluster(ci);
        true
    }
}
