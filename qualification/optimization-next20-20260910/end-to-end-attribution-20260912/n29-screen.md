# N29 initial screen: exact duplicate solves removed, not promoted

Isolated commit `91c27a12b5ea5ec308cfe9187a40a84f1b978bd6` passes the18 exact eligibility/collision/scatter cases, original analytical/3D/motion tests,3D and exact-reuse memcheck/initcheck/synccheck, and12 normal asynchronous restored ticks across flying/initial-impact/large-debris in both arms. All seven light A/B/A physical comparisons pass120 ticks, with unchanged quality gates.

The initial restored city256 idle mean is58.179ms versus69.089/67.488 controls. This is promising, not promoted. City25 impact41.416ms versus41.336/40.308 is unchanged/slightly worse; debris370.126ms is between382.805/365.574 controls and is not a verified gain. Other scenarios, maxima, stage means, setup, sample counts and misses are all in [the light report](n29-light.md).

A balanced20-sample-per-arm follow-up is running across all seven light cases plus city256 initial impact. Original gates and workloads remain fixed. Full52 and continuous warm qualification are still required for a finalist. The temporary desktop stop is restored automatically by the exclusive runner. No main runtime or installed SDK change.

[Structured checks, source commit and evidence hashes](n29-screen.json).
