#!/usr/bin/env python3
"""dispatchers.py <file.metal>: MSL functions CuMetal lowered through its per-lane CFG dispatcher."""
import re,sys
lines=open(sys.argv[1]).read().split('\n');sig=None;hits=[]
for l in lines:
    if l and not l[0].isspace() and '(' in l and not l.startswith(('#','//')):sig=l
    if 'uint cm_block_state' in l:
        m=re.search(r'(\w+)\s*\(',sig or '');hits.append(m.group(1) if m else '?')
for h in hits:print(h[:130])
