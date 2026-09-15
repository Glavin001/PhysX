# Six-channel fine operator — RTX 5060 Ti, 2026-09-10

Implemented the private GPU fine operator, supported/inelastic RHS, full 6×6
block Cholesky action and per-bond wrench/energy recovery specified in sections
3–4 of the new solver plan. This remains independent of the production engine
backend. It is a mathematical foundation, not a measured speedup.

The initial standalone test passed and Compute Sanitizer memcheck reported zero
errors and zero leaks. Fixtures cover analytical six-channel compliance; a
six-node, eight-bond cyclic graph with coupled stiffness and rotated frames;
supported, free, deleted-bond and fully prescribed variants; and 129 replicated
graphs (774 nodes, 1,032 bonds). They check every reduced matrix column, response,
energy, force/moment balance and all six rigid modes. Invalid stiffness, frames,
geometry and adjacency are rejected.

Initial captures remain in `out/six-channel-operator-20260910/`, including the
then-current source/binary hashes, actual loaded modules, test and memcheck logs.
The subsequent projected-PCG work extracted only the shared test fixture/oracle
into `ElasticTestFixture.h`; it did not change `StressElasticOperator.cuh`.
Both current standalone targets were rebuilt and tested. Use the
[current source patch, receipt and validation](../six-channel-pcg-20260910/README.md)
for the latest reproducible state.

See the [implementation contract](../../docs/destruction/elastic-operator-contract.md)
for units, signs, ownership, test tolerances and integration requirements. No
new physical-equivalence, material, transaction, endurance or game-consumer
qualification follows from these isolated checks.
