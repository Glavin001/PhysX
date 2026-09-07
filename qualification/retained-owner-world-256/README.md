# Rejected intermediate implementation

These captures are not a valid performance improvement. The implementation preserved retained contact managers but did not mark restored GPU bounds dirty. The heavy 256-building contact audit detected duplicate live persistent shape pairs after separation and re-entry. The final implementation propagates restored bounds through the existing GPU update flags; see ../retained-owner-final-scaling/report.html and ../retained-owner-validation.json. Do not use these intermediate timings as a qualified speedup.
