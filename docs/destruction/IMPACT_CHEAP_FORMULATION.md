# Can a cheap formulation reproduce the impact solve's answer?

Research note, 2026-10-08. This work used the CPU and FP64 only. No engine code changed. There
are two harnesses in vibe-land:

- `scripts/impact/cheap-contact-time.py` is the leading design, set out below.
- `scripts/impact/cheap-formulations.py` covers the earlier candidates, C1 to C4, further down.

Their outputs are in vibe-land `target/impact-diag/cheap-*`:

| File | Contents |
|---|---|
| `cheap-h.txt` | the h sweep |
| `cheap-patch.txt` | the patch study |
| `cheap-cannon.txt` | the C1-C4 table |
| `cheap-e-trace.txt` | E's contact impulse per solve |
| `cheap-e-nospin.*` | E without the impactor's angular load |

Everything below comes from one capture: the cannonball's first contact tick on the veneer house.
It is the only capture with an impact-level dump. The meteor and the truck need dumps from the GPU
replay, which was not run (CPU-only constraint).

## Summary

**The leading design is a linear implicit step over the contact duration h, with the impactor
coupled in and an exact event-to-event failure order.** It gets the right outcome class in the
right place:

- **Joints:** 30-40 break at h = 0.25-2 ms (E: 35).
- **Locality:** 90-100% are within 2 m (E: 86%). 77-84% of them sit within 0.3 m of an E joint.
- **Exact joints:** it does not break E's own joints. The joint-level Jaccard is 0.23-0.32,
  against at least 0.58 in E's own spread.
- **Momentum:** it delivers about 2x E's momentum to the impactor and 20x to the debris. That
  difference traces to E's contact law, not to the step (see below).
- **Solves and patch:** the failure order needs about 50 events, or 83-100 linear solves. A patch
  of 3 m (143 chunks) reproduces the full island exactly.
- **Cost:** about 11k warm-started PCG iterations over the ramp, or about 50 small dense
  factorisations. That is roughly 10-100 ms GPU as estimated (not measured), against E's 55 s.
  The 2 ms target is not met yet. A 1 m patch with dense solves on the GPU would come close
  (estimated), but it changes a quarter of the joints compared with the full island.

**None of the earlier one-tick candidates (C1-C3) reproduces E.** Over the frame dt the house is
quasi-static (k·dt² ≈ 180x the chunk mass), so a linear solve sends the load everywhere. That is
the reason h, not dt, is what makes the linear step local.

## Leading design: one implicit step over the contact duration h

### Formulation

The impactor is a node carrying its momentum. Its contact rows tie it rigidly to the struck chunks.
The rows are unilateral and stick until the Coulomb cone, then slide frictionless.

- **The step:** (M + h² B K Bᵀ) Δu = λ f, with f = m_imp v / h on the impactor.
- **Joint forces:** J = J₀ + ΔJ, with ΔJ = −k h² Bᵀ Δu (J₀ is the dump's near-rest state).
  Velocities are Δu·h.

**Failure order (no heuristic).** Between events the system is linear, so each joint's critical
load factor along the current increment is exact: the root of util(J + δ·ΔJ) = 1, where util is
convex. Each step:

1. Advance to the smallest critical factor.
2. Apply that event:
   - a brittle joint breaks, and its force is released as a load at the same λ (re-solved,
     cascading while anything is over capacity);
   - a ductile joint yields: it leaves the operator and keeps its force;
   - a contact separates or starts to slide.
3. Re-solve, and repeat to λ = 1.

**Passes, for comparison.** Everything over capacity at λ = 1 breaks (ductile joints take a secant
yield), and the step is re-solved, 2 or 4 times.

### h per impact

| Impact | Derivation | h |
|---|---|---|
| Cannonball, steel, r 0.69 m, 60 m/s | wave round trip in the impactor, 2·(2r)/c_steel (5170 m/s) = 0.53 ms; struck brick depth / speed = 0.1 m / 60 m/s = 1.7 ms | **0.5-2 ms** |
| Meteor, basalt, r 2 m, 140 m/s | 2·(2r)/c_rock (4260 m/s) = 1.9 ms; brick depth / speed = 0.7 ms | 1-2 ms (not run) |
| Truck, 5 t, 21.7 m/s | EN 1991-1-7 crush spring (k = 300 kN/m): stopping time π/2·√(m/k) ≈ 0.2 s, at most 0.84 MN | **longer than a tick**: h = dt per tick, load capped by the crush force (≤ 14 kN·s per tick of its 1.1e5 N·s) (not run) |

For the cannonball, the median joint's hop time √(m/k) is 1.2 ms. At h ≈ 1 ms a single solve
therefore reaches about one chunk.

### Results against E (cannonball)

**nearF1** is the share of each set within 0.3 m of a joint of the other (harmonic mean). It asks
"the same place" rather than "the same joint". E's own spread is 0.91-0.97 (ramp start, spin);
E's own spread in Jaccard is 0.58-0.87. The momentum columns are what the impactor loses and what
the debris (groups no longer tied to an anchor) carries.

| Model (full island) | Joints | Jaccard | nearF1 | Within 2 m | Median / max (m) | Impactor Δp (N·s) | Debris p (N·s) / mass | Solves | PCG/solve (cold, rtol 1e-4) |
|---|---|---|---|---|---|---|---|---|---|
| **E (Clarabel)** | 35 | 1 | 1 | 30 | 1.13 / 8.6 | 147 | 12 / 42 kg | 21 (GPU 1.1e5 ADMM steps) | n/a |
| events, h 0.25 ms | 30 | 0.23 | 0.80 | 29 | 0.80 / 2.3 | 308 | 267 / 138 kg | 95 (52 events) | 37 |
| events, h 0.5 ms | 30 | 0.23 | 0.78 | 30 | 0.80 / 1.3 | 285 | 266 / 138 kg | 95 (53) | 45 |
| **events, h 1 ms** | 40 | 0.23 | 0.77 | 36 | 0.93 / 2.7 | 276 | 265 / 180 kg | 100 (57) | 47 |
| events, h 2 ms | 39 | 0.32 | 0.81 | 35 | 0.88 / 2.4 | 271 | 262 / 138 kg | 86 (49) | 63 |
| events, h 4 ms | 52 | 0.30 | 0.73 | 39 | 0.94 / 2.7 | 260 | 278 / 290 kg | 97 (53) | 109 |
| events, h = dt 16.7 ms | 85 | 0.25 | 0.60 | 55 | 1.23 / 2.7 | 149 | 192 / 316 kg | 94 (50) | 280 |
| 2 passes, h 0.25 ms | 61 | 0.17 | 0.67 | 48 | 1.12 / 3.3 | 314 | 268 / 263 kg | 3 | 37 |
| 2 passes, h 1 ms | 126 | 0.12 | 0.47 | 78 | 1.63 / 3.3 | 311 | 268 / 741 kg | 4 | 47 |
| 4 passes, h 1 ms | 126 | 0.12 | 0.47 | 78 | 1.63 / 3.3 | 290 | 268 / 741 kg | 6 | 47 |
| 2 passes, h 16.7 ms | 869 | 0.03 | 0.14 | 127 | 4.98 / 10.2 | 342 | 259 / 6.8 t | 5 | 280 |

**Patch at h = 1 ms (event ramp).** Every node outside the patch is held as boundary. The struck
chunks are always inside. PCG over the ramp is warm-started from the last unit solve; release
solves start cold; all stop at rtol 1e-4. Contacts count as stiff springs in the PCG figures.

| Patch radius | Chunks | DOF | Joints (vs E: Jaccard / nearF1) | Jaccard vs full island | Impactor Δp error vs full | PCG over the ramp | CPU dense solve |
|---|---|---|---|---|---|---|---|
| 0.75 m | 19 | 114 | 29 (0.31 / 0.82) | 0.68 | 0.3% | 3.1k in 83 solves | 0.12 ms |
| 1 m | 27 | 162 | 31 (0.29 / 0.81) | 0.73 | 0.3% | 4.9k in 86 | 0.14 ms |
| 1.5 m | 42 | 252 | 34 (0.30 / 0.84) | 0.76 | 0.3% | 6.1k in 86 | 0.28 ms |
| 2 m | 70 | 420 | 37 (0.24 / 0.80) | 0.88 | 8.9% | 7.9k in 93 | 0.85 ms |
| **3 m** | 143 | 858 | 39 (0.23 / 0.78) | **0.97** | 0.0% | 11.3k in 98 | 4.7 ms |
| 5 m | 366 | 2196 | 40 | 1.00 | 0.0% | 12.0k in 100 | n/a |
| full | 997 | 5982 | 40 | 1 | 0 | 12.1k in 100 | n/a |

### What this says

1. **h localises the step as predicted, and the answer is insensitive to h in the physical
   range.** From 0.25 to 2 ms the event ramp breaks 30-40 joints, all within 2.7 m, with nearF1
   about 0.8. At h = dt it spreads to 85 joints. Cold PCG iterations rise with h, from 37 to 280,
   but not to about 10: the block-Jacobi preconditioner leaves the stiff joints (k·h² up to 8e4 kg
   at h = 1 ms) poorly conditioned.
2. **The failure order needs the events. Passes are not equivalent.** Breaking everything over at
   full load breaks 2-3x E's joints at h ≤ 1 ms, and 20x at h = dt, with nearF1 0.14-0.67.
   Re-solving more passes changes nothing (2 and 4 passes are the same): the first pass has already
   broken the joints that an ordered ramp would have spared by releasing their neighbours.
3. **The events are not "a few".** About 50 events (one per failing joint, plus contact
   separations and slides) and 83-100 solves, including the release re-solves. Joints rarely fail
   simultaneously, so each event is a solve.
4. **Patch.** The reach is set by the damage extent, not by c·h. The cascade carries the front
   about one hop per event, out to about 2.5 m here. A 3 m patch (143 chunks) matches the full
   island (Jaccard 0.97, momentum exact). A 1-1.5 m patch keeps the impactor's momentum (0.3%) and
   the outcome class, but changes a quarter of the joints.
5. **Momentum: the step and E disagree, and the disagreement is in E's contact law.** In E's
   reference solution the contact rows carry compression while their normal relative velocity is
   6-28 m/s (`cheap-eref.pkl`; this is how a convex Coulomb cone dilates). As a result:
   - E: 12 of 13 struck chunks stay attached and the ball slides past them (impactor Δp 147 N·s,
     debris 12 N·s in 42 kg);
   - the step: the rigid contact pushes the knocked-out bricks ahead of the ball (Δp about
     275 N·s, debris 265 N·s in 138-180 kg).

   The step looks closer to a 10 t ball through veneer, but **that is the owner's call**. If E's
   momentum is the target, the contact law is what has to change, not the structure solve.
6. **Cost against the 2 ms target (estimated, not measured):**
   - **PCG route:** 5-12k iterations over the ramp. At the measured 30-65 µs per iteration
     (house-size) that is 0.15-0.8 s. On a patch, the per-iteration GPU cost is not measured; even
     at about 5 µs it is 25-60 ms.
   - **Dense route on the patch:** one factorisation per event with two back-substitutions
     (unit load and release), about 50 per impact. On the CPU (numpy) that is about 7 ms at 1 m and
     about 0.25 s at 3 m. On the GPU, a batched dense Cholesky of 160-860 DOF would be about
     20-500 µs each, so about 1-25 ms.
   - **Rank updates:** each event changes at most 6 columns, so rank updates (Woodbury) in place
     of re-factorising cut the 3 m patch to roughly O(n²) per event.

   So the target is in reach for a 1-1.5 m patch, and the 3 m patch is a few ms to tens of ms. None
   of this is measured on the GPU.

### Recommendation (leading design)

Build it as the impact solve's fast path:

- impactor coupled as a node;
- h from the impact (the larger of the impactor's wave round trip and the struck layer's
  traversal time; the tick for crushing impactors, with the crush-force cap);
- an exact event ramp;
- a dense patch solve with rank updates;
- a patch of about 3 m, or grown until no event lands within one hop of the boundary. That check
  is the truncation error test, and it is cheap.

Keep E as the oracle. Two questions are open for the owner:

1. **The contact law.** Should E's rows really dilate? This decides the momentum.
2. **Is "same place" (nearF1 about 0.8) enough?** The step does not reach E's joint-level match
   (Jaccard 0.2-0.3), and no cheap formulation tried here does.

Before generalising, the meteor and the truck need impact-level dumps.

---

# Earlier candidates: one step over the frame dt (C1-C4)

The candidates below solve one step over the frame dt, with the impactor fed in as a load. They are
kept for the record. Their conclusion: none of them reproduces E, because over dt the house is
quasi-static.

## Setup

- **Capture:** the cannonball into the veneer house. `cannon-island1443` has 997 nodes and
  3066 links (3053 joints and 13 rigid contact rows). The impactor is 10,650 kg at 60.1 m/s, a
  momentum of 6.4e5 N·s. This is the only capture with an impact-level dump (`IMPACT_DUMP`: B,
  M, k, capacity sets, rows, ramp state and centroids). The meteor and truck exist only as
  `.impc` captures. Dumping them needs the GPU replay, which was out of scope, so this note
  covers one impact.
- **Reference E:** oracle-ramp.py variant C, re-implemented in the harness and reproducing that
  run exactly (35 joints). The impactor's load is its pre-tick momentum m v / dt. Chunks 2217
  and 2218 (the depenetration pair) keep their base load. Every candidate starts from the same
  state as E: the dump's level 5, with its J as the trial, its motion r and its live set.
- **Breaking rule, the same for every model:** a brittle joint breaks at utilisation ≥ 1 − band.
  A ductile joint yields; in the linear models this is a secant stiffness that carries its
  capacity. A ductile joint breaks when its slip exceeds its ultimate slip at the full load.

### The candidates

- **C1, elastic plus inertia.** E's level problem with the capacity sets removed:
  (M + B k dt² Bᵀ) u = q + B T, which is (B K Bᵀ + M/dt²) x = f with x = u dt². The impactor
  node is included. Its rigid contacts are kept exactly (a KKT block) and unilaterally (an active
  set: rows in tension are released, rows past friction slide). The model solves, breaks, and
  re-solves.
- **C2, bounded impactor load.** The impactor node and its contacts are removed. Each struck
  chunk (one per contact row) gets a bounded impulse through its centroid. Two bounds were tested:
  - **cap:** Σ of its live joints' capacity along v times dt, plus m_chunk·|v_imp|. This is the
    bound as the task specified it.
  - **inertia:** m_chunk·(v_imp·n), along the row normal. This is the momentum that moves a free
    chunk out of the ball's path.
  - **oracle (diagnostic):** E's own final contact impulse on each row, applied through the
    row's frame. With the load made exact, only the structural response can differ from E.
- **C3:** C2 under a four-level ramp of the bounded load (1/8, 1/4, 1/2, 1), with up to 4
  re-solves per level.
- **C4:** E itself, with its ramp started at the level nearest the bounded load. That is level 11
  for the cap bound (0.029 of the momentum) and level 7 for the inertia bound (0.002).

## How close is close enough

E is path-dependent, so the tolerance comes from E's own spread under choices it treats as free:

| E variant | Joints | Jaccard vs E | Within 2 m | Impulse (N·s) |
|---|---|---|---|---|
| E, reference (ramp from the dump's level 5) | 35 | 1 | 30 (86%) | 147 |
| E, impactor's angular load zeroed | 36 | 0.87 | 30 (83%) | 158 |
| E, ramp started at level 11 (C4 cap) | 31 | 0.83 | 25 (81%) | 236 |
| E, ramp started at level 7 (C4 inertia) | 22 | 0.58 | 18 (82%) | 131 |

A cheap model counts as giving **the same answer** if it meets all of these:

- Jaccard with E ≥ 0.5. That is the floor of E's own spread; below it, the model breaks
  different joints for different reasons.
- Joint count within ±50% of E (18 to 53).
- At least 75% of broken joints within 2 m of the hit.
- Delivered impulse within 2x of E's.
- The ball passes through.
- The tick is dissipative: the impactor's lost energy is at least the house's kinetic plus
  strain energy gained.

Separately, the **same outcome class** means the same count, locality, pass-through and
dissipation, without the joint-level match.

## Results (cannonball, first contact tick)

"Dissipated" is the impactor's kinetic energy lost minus the house's kinetic and strain energy
gained. A negative value means the model created energy.

| Model | Joints | Jaccard | Within 2 m | Median / max dist. (m) | Impulse to impactor (N·s) | Dissipated (J) | Solves | PCG iterations (rtol 1e-3 / 1e-6) |
|---|---|---|---|---|---|---|---|---|
| **E reference** | 35 | 1 | 30 | 1.13 / 8.6 | 147 | +5.8e3 | 21 Clarabel (GPU: 35 solves, 1.1e5 ADMM steps) | n/a |
| C1, 1 round | 890 | 0.03 | 125 | 5.0 / 10.2 | 8.7e4 (ball slowed to 54 m/s) | +3.7e6 | 3 (KKT) | n/a |
| C1, converged | 924 | 0.03 | 132 | 5.1 / 10.2 | 208 | +3.6e3 | 9 (KKT) | n/a |
| C2 cap, 1 solve | 391 | 0.04 | 104 | 3.2 / 10.2 | 1.9e4 | +1.1e6 | 1 | 271 / 525 |
| C2 cap, converged | 445 | 0.06 | 131 | 3.2 / 10.2 | 8.9e3 | +2.6e5 | 10 | 3.4k / 7.6k |
| C3 cap, ramp | 202 | 0.12 | 111 | 1.8 / 7.8 | 9.0e3 | +2.7e5 | 16 | 5.7k / 12.6k |
| **C2 inertia, 1 solve** | **30** | **0.25** | **24 (80%)** | 1.2 / 2.4 | 705 | +3.7e4 | **1** | **272 / 528** |
| C2 inertia, 4 rounds | 74 | 0.22 | 48 | 1.2 / 3.3 | 705 | +2.6e4 | 4 | 1.2k / 2.2k |
| C2 inertia, converged | 85 | 0.24 | 58 | 1.2 / 3.3 | 705 | +2.1e4 | 43 | 13.5k / 23.8k |
| C3 inertia, ramp | 64 | 0.21 | 40 | 1.2 / 3.3 | 705 | +2.3e4 | 16 | 4.5k / 8.3k |
| C2 oracle (E's loads), 1 solve | 9 | 0.19 | 9 | 0.8 / 1.2 | 147 | +8.0e3 | 1 | 271 / 529 |
| C2 oracle, converged | 22 | 0.24 | 20 | 0.9 / 2.2 | 147 | +7.5e3 | 26 | 7.6k / 13.7k |
| **C4: E from level 11** | 31 | **0.83** | 25 | 1.1 / 9.0 | 236 | +6.7e3 | 15 Clarabel (vs 21) | n/a |
| C4: E from level 7 | 22 | 0.58 | 18 | 1.1 / 9.0 | 131 | +5.4e3 | 18 Clarabel | n/a |

**Cost.** The PCG figures are measured with a 6x6 block-Jacobi preconditioner (the GPU's) on the
same 5976-DOF systems. At 30-65 µs per iteration:

| Model | Estimated GPU time |
|---|---|
| One linear solve | 8-34 ms |
| C2 inertia, converged | 0.4-1.5 s |
| C3 | 0.14-0.8 s |
| E | 1.1e5 steps × 0.5 ms ≈ 55 s (measured) |

C1's KKT systems were solved directly. Their PCG cost would be similar per solve.

A sparse LU on the CPU takes 64 ms to factor this system and 0.8 ms per re-solve. That would be
the way to bring a single linear solve down to a few ms.

## What the numbers say

1. **Inertia does not localise a tick (C1).** Over 1/60 s, a joint's stiffness k·dt² is about
   1,840 kg-equivalent at the median (800 kg at P10, 9e4 kg at P90). The median chunk is 10 kg.
   An elastic wave crosses the house several times within a tick. The elastic-plus-inertia tick is
   therefore effectively the static model A again: the rigid contacts stop the ball against an
   effectively rigid house, and about 900 joints break with a median distance of 5 m. Breaking and
   re-solving cannot undo this, because the first solve has already overloaded the whole wall.
2. **The load bound decides the scale of the damage, and the "capacity" bound is far too
   high.** E's struck chunks are not stripped of all their joints and carried at the ball's
   speed. They end at 1-8 m/s. Most of them (12 of 13) are still attached after the tick, and the
   ball slides past. The cap bound (Σ capacity·dt + m·v) asks for 1.9e4 N·s, 125x E, and breaks
   about 400 joints. The inertia bound asks for 1,265 N·s; 705 N·s is delivered once applied
   through the centroids. That puts it in the right range.
3. **Even an exact load leaves the structural answer wrong (C2 oracle).** With E's own contact
   impulses on the same chunks, the linear model breaks 9-22 joints that overlap E's in only 7-11
   (Jaccard 0.19-0.24). E's joints fail at intermediate ramp levels, where its contact impulse
   peaks at 659 N·s (level 9, about 4.5x its final 147 N·s; see `cheap-e-trace.txt`). Its
   capacity cones then cap each yielding joint and push the load onto its neighbours. A linear
   solve has neither the cap nor the path. It concentrates force by stiffness, so it picks
   different joints. More rounds make it worse (30 → 85 joints for C2 inertia), because a linear
   cascade has no plastic plateau to stop it.
4. **A short ramp does not recover the failure order (C3).** Jaccard stays at 0.12-0.21. The
   ramp only orders the linear overloads; it does not add the redistribution.
5. **Energy.** E is dissipative: 7.8 kJ in, 2.0 kJ to the house. In early versions of C2 the
   house gained more energy than the impactor lost. The bounded impulse was applied at the
   contact point of a chunk set free in the same solve, and nothing limited its spin (200-300
   rad/s). Applying the bound through the centroid fixed this, and every C2/C3 row above is
   dissipative. C2 still over-dissipates by about 5x: 37 kJ against E's 7.8 kJ, because it
   delivers 4.8x the impulse.
6. **C4 keeps E's answer but saves little.** Starting at the cap-bound level (11) gives Jaccard
   0.83, inside E's own spread, with 15 solves instead of 21. Starting lower, at level 7, drifts
   further (0.58). The solves saved are the low-load levels. In the GPU logs those levels take
   tens to hundreds of ADMM steps each (levels 0-3: 17-51 steps). The 1.1e5 steps sit in the
   near-capacity and full-level cascade solves, which C4 still runs. Estimate: 5-40% fewer steps,
   so about 35-50 s instead of 55 s. That is not a real-time change. This estimate is not
   measured: it needs per-level step counts from the GPU, which were not run.

## Recommendation (earlier candidates)

- **Within the "same answer" tolerance:** only C4 qualifies, and it is E. No near-linear
  formulation reproduces E's broken set. The linear model's error is in the structural response,
  not only in the load: it fails even with E's exact loads.
- **The time has to come out of E itself.** The useful saving here is to start the ramp at the
  bounded (cap) level, which costs nothing. The rest lies on the BACKLOG's levers:
  - conditioning of near-mechanisms;
  - an error certificate for termination;
  - fewer full-level re-solves, for example by breaking several joints per cascade solve when
    they are independent.
- **Within the "same outcome class" tolerance:** only C2 with the inertia bound and **one
  solve** qualifies. It breaks 30 joints, 80% within 2 m, the ball passes through, the tick is
  dissipative, and it costs 8-34 ms GPU or about 1 ms CPU direct after factorisation. It meets
  the outcome-class bar but not the joint-level bar.

### What C2 (inertia bound, one solve) misses physically

- **Different joints (Jaccard 0.25).** It has no plasticity, so ductile joints cannot hold their
  capacity while their neighbours take the rest.
- **No failure order.** Its single solve stands in for E's ramp.
- **4.8x E's impulse.** Its bound assumes each struck chunk is pushed free at the ball's normal
  speed, while E's chunks mostly stay attached and slide.
- **A lucky stopping point.** Iterating it to convergence breaks 2.4x E's joints. The single
  solve is a truncation, not a converged answer.

Under the project's "physics first, no heuristics" rule, C2 is a fallback for when the impact
solve cannot run within budget. It is not a replacement for E.

**Caveat on scope:** this note covers one capture: the cannonball's first contact tick on the
veneer house. The meteor and the truck need impact-level dumps, which come from the GPU replay,
before these conclusions can be generalised.
