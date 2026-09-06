#!/usr/bin/env python3
"""Verify a recorded native GPU wall-penetration fixture from committed observations.

This reads audit output after simulation; it never supplies loads or fracture decisions.
"""
import argparse
import csv
import importlib.util
import json
from pathlib import Path


def verify(capture):
    summary=json.loads((capture/'native.summary.json').read_text())
    frames=list(csv.DictReader((capture/'native.frames.csv').open()))
    assert summary['status']=='completed' and summary['shot_path']=='through-wall'
    assert summary['chunks']==444 and summary['bonds']==896
    assert summary['correction_limit']==1 and summary['motion_audit_enabled']
    assert summary['max_motion_position_error']<=1e-3
    assert summary['max_cluster_com_error']<=1e-3
    assert len(frames)==summary['frames'] and len(frames)>=121
    assert all(int(r['resim_passes'])<=1 and int(r['stress_converged'])==1 for r in frames)
    corrected=[int(r['step']) for r in frames if int(r['resim_passes'])]
    broken=[int(r['step']) for r in frames if int(r['bonds_broken'])]
    assert corrected and broken and int(frames[broken[0]]['contacts_frame'])>0
    assert all(int(r['bonds_broken'])==0 for r in frames[:broken[0]])
    assert sum(int(r['bonds_broken']) for r in frames)==summary['broken_bonds']
    assert len(corrected)==summary['corrections']
    spec=importlib.util.spec_from_file_location('motion',Path(__file__).with_name('analyze-native-motion.py'))
    motion=importlib.util.module_from_spec(spec);spec.loader.exec_module(motion)
    ball=motion.projectile(capture/'native.twstate',444)
    assert ball[0,2]+.75 < -3.98, 'projectile was not outside the front wall'
    exits=[i for i,p in enumerate(ball) if p[2]-.75>3.98]
    assert exits and exits[0]>broken[0], 'no verified rear-wall clearance after fracture'
    # Frames store accepted end-of-step state, so index 0 is t=1/60, not t=0.
    exit_step=exits[0]
    initial={};at_two_seconds={};final={}
    for row in csv.DictReader((capture/'native.motion.csv').open()):
        step=int(row['step']);chunk=int(row['chunk'])
        if step==0:initial[chunk]=row
        if step==119:at_two_seconds[chunk]=row
        if step==len(frames)-1:final[chunk]=row
    assert len(initial)==len(at_two_seconds)==len(final)==444
    groups={int(r['root']):(int(r['cluster_chunks']),int(r['supported'])) for r in final.values()}
    assert sum(n for n,s in groups.values())==444
    largest=max(n for n,s in groups.values());supported=sum(n for n,s in groups.values() if s)
    assert largest>=.85*444 and supported>=.85*444, 'building did not retain its main connected structure'
    # Both faces have actual displaced collision chunks, not an apparent passage
    # caused by renderer reparenting or a projectile crossing intact geometry.
    holes={}
    for side,z in [('entry',-3.5),('exit',3.5)]:
        ids=[]
        for chunk,r in initial.items():
            x,y,cz=(float(r['physics_'+k]) for k in 'xyz')
            if abs(x)<1 and 5.9<y<7.9 and abs(cz-z)<1e-4:
                after=at_two_seconds[chunk]
                displacement=sum((float(after['physics_'+k])-float(r['physics_'+k]))**2 for k in 'xyz')**.5
                assert int(after['supported'])==0 and displacement>1.0
                ids.append(chunk)
        assert len(ids)==4
        holes[side]=ids
    return dict(projectile_clearance_step=exit_step,projectile_clearance_seconds=(exit_step+1)/60,
                projectile_position_at_clearance=ball[exit_step].tolist(),
                corrected_steps=corrected,fracture_steps=broken,corrections_per_step_max=1,
                largest_connected_cluster=largest,supported_chunks=supported,
                detached_chunks=444-supported,final_cluster_count=len(groups),
                displaced_wall_chunks=holes,broken_bonds=summary['broken_bonds'],
                all_stress_steps_converged=True,max_render_collision_position_error=summary['max_motion_position_error'],
                max_cluster_com_error=summary['max_cluster_com_error'],
                physics_ms={k:summary['physics_ms_'+k] for k in ['min','mean','p50','p95','p99','max']})


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture',type=Path);parser.add_argument('--output',type=Path)
    args=parser.parse_args();result=verify(args.capture)
    text=json.dumps(result,indent=2)+'\n'
    if args.output:args.output.write_text(text)
    print(text)


if __name__=='__main__':main()
