# Rejected intermediate implementation — invalid contact lifecycle

These timings are **not valid performance results**. The intermediate change stopped CPU teardown for retained owners but still stamped them for broad-phase pair recreation. Existing pairs could therefore be duplicated. A new retained-contact regression reproduces the duplicate shape-pair failure when that rule is restored.

The corrected implementation stamps only migrating shapes for pair recreation. All affected shapes still receive GPU ownership installation, complete motion correction and contact/friction cache invalidation. See the `retained-owner-*` captures and validation instead. These original captures remain unchanged as rejected experimental evidence.
