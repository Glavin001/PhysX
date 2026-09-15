# V19 snapshot correctness by scenario

Normal public export/import path; diagnostic seeding disabled. **27/28 pass**.
Ten correlated continuation ticks per passing case; the failing case stops after one.
Timings are complete simulate/fetch scopes on the shared GPU, exclude export/import/setup,
and are neither independent repetitions nor an A/B performance qualification.
Current source is unaccepted N14 + snapshot WIP; retained N13 results are separate.

| Scenario | Chunks | Prefix ticks | Pass | Source mean / max ms | Restored mean / max ms | Max chunk position error mm |
|---|---:|---:|---|---:|---:|---:|
|bridge64-cold|768|0|yes|2.120 / 8.745|1.974 / 8.173|0.000000|
|bridge64-warm|768|5|yes|1.417 / 1.807|1.483 / 3.196|0.000000|
|building-cold|444|0|yes|1.527 / 5.685|1.575 / 4.746|0.000000|
|building-fragmented|444|16|no|4.095 / 4.095|7.712 / 7.712|8.871512|
|building-warm|444|5|yes|1.529 / 1.960|1.647 / 3.088|0.000000|
|cantilever64-cold|64|0|yes|2.113 / 8.180|1.960 / 7.154|0.000000|
|cantilever64-warm|64|5|yes|1.278 / 1.593|1.507 / 2.904|0.000000|
|chain256-cold|256|0|yes|2.042 / 7.461|1.971 / 7.106|0.000000|
|chain256-warm|256|5|yes|1.182 / 1.786|1.226 / 2.854|0.000000|
|chain32-cold|32|0|yes|1.221 / 2.502|1.170 / 2.210|0.000000|
|chain32-warm|32|5|yes|1.114 / 1.487|1.345 / 2.795|0.000000|
|dense12-cold|1728|0|yes|4.667 / 32.303|4.619 / 32.291|0.000000|
|dense12-warm|1728|5|yes|1.514 / 1.854|1.616 / 3.384|0.000000|
|destruction-cold|2|0|yes|1.909 / 5.019|1.720 / 3.206|0.000000|
|destruction-damaged|2|5|yes|1.381 / 1.720|1.429 / 2.747|0.000000|
|destruction-fractured|2|20|yes|2.493 / 3.291|2.795 / 5.426|0.000000|
|destruction-intact|2|5|yes|1.269 / 1.431|1.437 / 3.057|0.000000|
|destruction-onset|2|1|yes|3.544 / 12.384|3.661 / 12.105|0.000000|
|destruction-stimulus|2|1|yes|3.486 / 12.050|3.510 / 11.803|0.000000|
|flying|0|5|yes|1.403 / 1.730|1.416 / 2.059|0.000000|
|ladder128-cold|288|0|yes|1.845 / 5.547|1.822 / 5.392|0.000000|
|ladder128-warm|288|5|yes|1.100 / 1.859|1.078 / 1.602|0.000000|
|panel32-cold|1024|0|yes|3.588 / 21.953|3.470 / 22.304|0.000000|
|panel32-warm|1024|5|yes|0.948 / 1.099|1.264 / 2.781|0.000000|
|resting|0|180|yes|0.563 / 0.700|0.626 / 1.253|0.000000|
|sliding|0|5|yes|1.341 / 1.722|1.409 / 3.226|0.000000|
|tower64-cold|2368|0|yes|12.504 / 115.439|12.676 / 116.779|0.000000|
|tower64-warm|2368|5|yes|1.588 / 1.886|1.765 / 3.956|0.000000|
