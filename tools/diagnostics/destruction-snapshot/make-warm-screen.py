#!/usr/bin/env python3
"""Create explicit A0/B/A1 warm-window plan, or A0/A1 same-build calibration."""
import argparse,json
from pathlib import Path
root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
p.add_argument('--binary',type=Path,required=True);p.add_argument('--profile-binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
p.add_argument('--candidate-binary',type=Path);p.add_argument('--candidate-profile-binary',type=Path);p.add_argument('--candidate-artifacts',type=Path)
p.add_argument('--suite',type=Path,default=root/'tools/profiles/destruction-warm-suite.json');p.add_argument('--repetitions',type=int,default=2)
a=p.parse_args()
if any([a.candidate_binary,a.candidate_profile_binary,a.candidate_artifacts]) and not all([a.candidate_binary,a.candidate_profile_binary,a.candidate_artifacts]):p.error('Supply all three candidate paths')
if not 2<=a.repetitions<=1000:p.error('Repetitions must be 2..1000')
if a.output.exists():p.error('Output exists')
suite=json.loads(a.suite.read_text());cases=suite['cases'];candidate=bool(a.candidate_binary)
plan=dict(scope='Matched warm-window application screen' if candidate else 'Same-build warm-window calibration',binary=str(a.binary.resolve()),profile_binary=str((a.candidate_profile_binary or a.profile_binary).resolve()),artifacts=str(a.artifacts.resolve()),jobs=[])
for arm in (('A0','B','A1') if candidate else ('A0','A1')):
    for case in (reversed(cases) if arm=='A1' else cases):
        job=dict(case,name=case['name']+'-'+arm,prefix=str(root/case['prefix']),repetitions=a.repetitions)
        if arm!='A0':job['compare_to']=case['name']+'-A0'
        if arm=='B':job.update(binary=str(a.candidate_binary.resolve()),artifacts=str(a.candidate_artifacts.resolve()))
        plan['jobs'].append(job)
for profile in ('nsys','ncu'):
    case=next(c for c in cases if c['name']==suite['default_profile_case'])
    plan['jobs'].append(dict(case,name=case['name']+'-'+profile,prefix=str(root/case['prefix']),repetitions=a.repetitions,profiler=profile,artifacts=str((a.candidate_artifacts or a.artifacts).resolve()),compare_to=case['name']+('-B' if candidate else '-A0')))
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(plan,indent=2)+'\n')
print(a.output)
