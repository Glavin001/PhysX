# Offline screen of captured peak stress problems

Actual native equations, warm bond state and loads are captured before iteration. This independent FP64 model uses the captured acceptance threshold. Its iteration counts differ from the native mixed-precision recurrence. **These are not GPU timings, end-to-end speedups or a physics qualification.**

Each IC0 factorization is rebuilt for this assessment. Factorization products and triangular dependency depth remain costs that a CUDA implementation must pay; fewer iterations alone do not imply faster simulation. No production solver or physical setting was changed.

## Solve 50, component 49348: 360 dynamic nodes, 657 incident live bonds

Native captured updates: 176; independent warm-residual scaled discrepancy: 0.

| Method | FP64 updates | True gradient² / threshold | Precondition block products | Sequential level visits | Factor block products |
|---|---:|---:|---:|---:|---:|
| polynomial | 176 | 0.827 | 352,100 | 350 | 0 |
| ic0-natural | 105 | 0.726 | 209,248 | 5,200 | 646 |
| ic0-rcm | 110 | 0.729 | 219,308 | 5,014 | 646 |
| ic0-color | 164 | 0.534 | 327,956 | 1,304 | 646 |

## Solve 50, component 20932: 361 dynamic nodes, 662 incident live bonds

Native captured updates: 175; independent warm-residual scaled discrepancy: 0.

| Method | FP64 updates | True gradient² / threshold | Precondition block products | Sequential level visits | Factor block products |
|---|---:|---:|---:|---:|---:|
| polynomial | 175 | 0.565 | 351,828 | 348 | 0 |
| ic0-natural | 103 | 0.68 | 206,244 | 5,100 | 650 |
| ic0-rcm | 107 | 0.812 | 214,332 | 4,876 | 650 |
| ic0-color | 162 | 0.735 | 325,542 | 1,288 | 650 |

## Solve 51, component 5836: 324 dynamic nodes, 515 incident live bonds

Native captured updates: 357; independent warm-residual scaled discrepancy: 0.

| Method | FP64 updates | True gradient² / threshold | Precondition block products | Sequential level visits | Factor block products |
|---|---:|---:|---:|---:|---:|
| polynomial | 357 | 0.638 | 594,520 | 712 | 0 |
| ic0-natural | 199 | 0.709 | 330,660 | 9,900 | 511 |
| ic0-rcm | 182 | 0.856 | 302,270 | 10,136 | 511 |
| ic0-color | 332 | 0.513 | 552,770 | 2,648 | 511 |

## Solve 51, component 24484: 321 dynamic nodes, 521 incident live bonds

Native captured updates: 342; independent warm-residual scaled discrepancy: 0.

| Method | FP64 updates | True gradient² / threshold | Precondition block products | Sequential level visits | Factor block products |
|---|---:|---:|---:|---:|---:|
| polynomial | 341 | 0.997 | 569,840 | 680 | 0 |
| ic0-natural | 188 | 0.279 | 313,412 | 9,350 | 517 |
| ic0-rcm | 173 | 0.979 | 288,272 | 9,632 | 517 |
| ic0-color | 309 | 0.513 | 516,208 | 2,464 | 517 |
