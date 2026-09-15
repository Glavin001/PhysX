## Exact graph census

All degree counts include fixed chunks. Support-hop statistics exclude them. Paths are unweighted: one bond = one hop.

| Asset / generated variant | Chunks | Bonds | Supports | Stress components | Degree min / mean / max | Support hops mean / p95 / max |
|---|---:|---:|---:|---:|---|---|
| Authored 3-floor frame | 64 | 132 | 4 | 1 | 1 / 4.125 / 6 | 5.000 / 9 / 9 |
| Native penetration building | 444 | 896 | 64 | 1 | 3 / 4.036 / 5 | 6.295 / 11 / 11 |
| Authored downtown | 24,105 | 74,543 | 445 | 27 | 1 / 6.185 / 20 | 15.956 / 47 / 60 |
| Synthetic height: 8 chunk rows | 296 | 588 | 64 | 1 | 3 / 3.973 / 5 | 4.241 / 7 / 7 |
| Synthetic height: 40 chunk rows | 1,480 | 3,052 | 64 | 1 | 3 / 4.124 / 5 | 20.356 / 38 / 39 |

Every intact asset above has a support path for every dynamic chunk. None has self-bonds or duplicate endpoint pairs. Synthetic height variants change only graph generation; no physics quality or timing is asserted.

### Complete degree histograms

| Bonds per chunk | Native 444-chunk building | Authored 64-chunk frame | Downtown 24,105 chunks |
|---:|---:|---:|---:|
| 1 | 0 | 4 | 125 |
| 2 | 0 | 0 | 298 |
| 3 | 32 | 0 | 334 |
| 4 | 364 | 48 | 2816 |
| 5 | 48 | 4 | 6246 |
| 6 | 0 | 8 | 6828 |
| 7 | 0 | 0 | 1865 |
| 8 | 0 | 0 | 2021 |
| 9 | 0 | 0 | 1970 |
| 10 | 0 | 0 | 1036 |
| 11 | 0 | 0 | 343 |
| 12 | 0 | 0 | 148 |
| 13 | 0 | 0 | 45 |
| 14 | 0 | 0 | 14 |
| 15 | 0 | 0 | 9 |
| 16 | 0 | 0 | 1 |
| 17 | 0 | 0 | 4 |
| 19 | 0 | 0 | 1 |
| 20 | 0 | 0 | 1 |

### Downtown degree by authored role

| Chunk role | Count | Degree min | Mean | Max |
|---|---:|---:|---:|---:|
| column | 7,384 | 2 | 4.709 | 8 |
| foundation | 445 | 1 | 2.121 | 5 |
| slab | 9,116 | 5 | 7.158 | 15 |
| wall | 7,160 | 2 | 6.720 | 20 |

### Intact dynamic-component sizes

| Dynamic nodes per component | Downtown component count | Current CUDA route |
|---:|---:|---|
| 148 | 8 | Block-local |
| 324 | 5 | Block-local |
| 648 | 5 | Block-local |
| 1,060 | 2 | Cooperative large-component |
| 1,296 | 5 | Cooperative large-component |
| 3,080 | 1 | Cooperative large-component |
| 5,936 | 1 | Cooperative large-component |

### Controlled graph cuts: not a simulated fracture verdict

A 2×2 square of four wall chunks at x=0, y=5–6, z=2–3 has eight bonds to the rest of the building. Its four internal bonds form a loop.

| Illustrative state | Removed bonds | Remaining bonds | Connected component sizes | Unsupported dynamic chunks |
|---|---:|---:|---|---:|
| Intact | 0 | 896 | 444 × 1 | 0 |
| Only one external bond left | 7 | 889 | 444 × 1 | 0 |
| Last external bond removed | 8 | 888 | 4 × 1, 440 × 1 | 4 |

### Reproduction and provenance

Run `python3 graph-shape.py` from this directory. It reads authored assets, validates graph identities and produces this census and two figures. No physics or GPU benchmark runs. The 444-chunk graph is checked against the actual playable asset: endpoint pairs, node order, fixed-support flags and positions up to their documented translation. The four-building tile is checked to have four 380-node dynamic components.

Nearest-rank percentiles; BFS starts from all fixed chunks at distance zero. Component discovery excludes fixed chunks for stress partitioning. Graph degree, component and path identities are checked internally. [Machine-readable counts and input SHA-256 hashes](graph-shape-data.json).
