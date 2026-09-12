#!/usr/bin/env python3
"""Index completed attribution evidence and public recipes; exclude private recovery data."""
import argparse,hashlib,json
from pathlib import Path

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('root',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    root=a.root.resolve();output=a.output.resolve();destination=output/'artifact-index.json';items={}
    def add(path,digest=None,origin=None):
        path=Path(path).resolve()
        if not path.is_file():return
        if any('private' in part or part=='recovery' for part in path.parts):raise ValueError('Private recovery artifacts must not enter the public index')
        if digest is None:digest=hashlib.sha256(path.read_bytes()).hexdigest();origin='rehashed by index builder'
        items[str(path)]=dict(path=str(path),bytes=path.stat().st_size,sha256=digest,sha256_origin=origin)
    if destination.exists():
        for r in json.loads(destination.read_text()):
            path=Path(r['path'])
            # Existing collector archives are immutable and already hashed.
            add(path,r['sha256'],r.get('sha256_origin','previous preserved index'))
    for relative in ['probe/build.json','plain-build/build.json','scope-audit-after-reboot.json','tower-source-review.json']:
        add(root/relative)
    for folder in ['cpu-full','graphs-full','configs-full','warm','warm-reduced-sampling']:
        campaign=root/folder/'campaign.json'
        if not campaign.exists():continue
        data=json.loads(campaign.read_text())
        # Do not publish an immutable hash for an actively changing campaign.
        if data.get('status')=='complete':add(campaign)
        for row in data.get('scenarios',[]):
            if row.get('status')!='complete' or not row.get('path'):continue
            directory=Path(row['path'])
            for name in ['receipt.json','replay.json','physical-comparison.json','analysis.json']:
                add(directory/name)
            if row.get('report_sha256'):add(directory/'counters.ncu-rep',row['report_sha256'],'completed campaign counter audit')
    workspace=root.parents[1]
    for experiment in ['n20-requalification-20260912','n06-granularity-20260912','n15-anchored-20260912']:
        directory=workspace/'out'/experiment
        for name in ['preparation.json','candidate.patch','build-isolated.py','build-fresh-native-tests.py','build/build.json',
                     'fresh-native/build.json','existing-compile-command.json','existing-link-commands.json','existing-native-test-commands.json',
                     'run-native-gates.py','run-after-counters.py','run-in-counter-gap.py','matched-light-manifest.json',
                     'audit-device-code.py','device-code-audit.json','build-oracles.py','build-cpu-probes.py',
                     'run-structural-screen.py','run-cpu-attribution.py','run-cpu-attribution-v1.py','run-warm-screen.py',
                     'run-full-after-counter.py','confirmation-manifest.json','impact-repeat-manifest.json']:
            add(directory/name)
        for name in ['qualification-campaign.json','native-A/campaign.json','native-B/campaign.json','matched-light/report.json',
                     'matched-light-balanced/report.json','confirmation20/report.json','impact-reverse20/report.json',
                     'screen/campaign.json','screen/matched/report.json','warm600/campaign.json',
                     'cpu-probes/build.json','cpu-attribution-v2/campaign.json','oracles/build.json','full52/report.json']:
            path=directory/name
            if path.exists() and json.loads(path.read_text()).get('status') not in ['running','building']:add(path)
        cpu=directory/'cpu-attribution-v2'
        if cpu.exists():
            for stage in ['A-before','B','A-after']:
                campaign=cpu/stage/'campaign.json'
                if not campaign.exists():continue
                data=json.loads(campaign.read_text())
                if data.get('status')!='complete':continue
                add(campaign)
                for row in data['scenarios']:
                    if row['status']!='complete':continue
                    path=Path(row['path'])
                    for name in ['receipt.json','replay.json','attribution.json','physical-comparison.json']:add(path/name)
    destination.write_text(json.dumps(sorted(items.values(),key=lambda r:r['path']),indent=2)+'\n')
    print(len(items),'public evidence artifacts indexed')
if __name__=='__main__':main()
