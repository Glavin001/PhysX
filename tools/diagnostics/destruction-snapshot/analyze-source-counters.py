#!/usr/bin/env python3
"""Audit one kernel's source counters against its complete SASS export."""
import argparse,collections,csv,hashlib,json,math
from pathlib import Path
KEYS=['Warp Stall Sampling (Not-issued Samples)','stall_barrier (Not Issued)',
      'stall_long_sb (Not Issued)','stall_short_sb (Not Issued)','stall_wait (Not Issued)',
      'stall_math (Not Issued)','stall_no_inst (Not Issued)',
      'L2 Theoretical Sectors Local','Instructions Executed']
def number(value):
    n=float(value.replace(',','')) if value not in ['','-'] else 0
    assert math.isfinite(n) and n>=0
    return n
def summarize(sass,correlations):
    groups=collections.defaultdict(lambda:dict(instructions=0,metrics={k:0 for k in KEYS}))
    locations=collections.defaultdict(set);duplicates=0
    for address,location,metrics in correlations:
        assert address in sass
        for key in KEYS:assert number(metrics[key])==number(sass[address][key]),(address,key)
        if locations[address]:duplicates+=1
        locations[address].add(location)
    for address,row in sass.items():
        key=tuple(sorted(locations[address] or {('(unmapped)','?')}));g=groups[key];g['instructions']+=1
        for k in KEYS:g['metrics'][k]+=number(row[k])
    return dict(unique_instructions=len(sass),duplicate_correlations_removed=duplicates,
        unmapped_instructions=sum(not locations[address] for address in sass),
        totals={k:sum(number(row[k]) for row in sass.values()) for k in KEYS},
        ranked_source_locations=[dict(locations=k,**v) for k,v in sorted(groups.items(),key=lambda item:-item[1]['metrics'][KEYS[0]])])
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('source_csv',type=Path);p.add_argument('sass_csv',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    assert len(json.loads((a.capture/'analysis.json').read_text()))==1,'Export one kernel record at a time'
    sass={};headers=None;kernel_headers=0
    for row in csv.reader(a.sass_csv.open()):
        if row[0]=='Kernel Name':kernel_headers+=1;continue
        if row[0]=='Address':headers=row;continue
        if row[0].startswith('0x'):
            assert headers and row[0] not in sass
            sass[row[0]]=dict(zip(headers,row))
    assert kernel_headers==1 and sass
    correlations=[];file=line=headers=None
    for row in csv.reader(a.source_csv.open()):
        if row[0]=='File Path':file=row[1];continue
        if row[0]=='Line No':headers=row;continue
        if len(row)<4 or headers is None:continue
        if row[0]:line=row[0]
        if row[2].startswith('0x'):correlations.append((row[2],(file,line),dict(zip(headers,row))))
    result=summarize(sass,correlations)
    result.update(scope='Unique instruction-address counts, not milliseconds. Ambiguous source locations remain grouped; unmapped instructions stay explicit. Local sectors are theoretical source-view counts, not DRAM traffic.',
        sources={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in [a.capture/'counters.ncu-rep',a.source_csv,a.sass_csv]},
        correlated_source_sha256={str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in {Path(c[1][0]) for c in correlations} if f.is_file()})
    a.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:result[k] for k in ['unique_instructions','duplicate_correlations_removed','unmapped_instructions','totals']},indent=2))
if __name__=='__main__':main()
