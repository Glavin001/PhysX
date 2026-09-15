#!/usr/bin/env python3
"""Negative controls for event selection/statistics and authored graph checks."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
import csv

ROOT=Path(__file__).resolve().parents[2]
def load(name):
    spec=importlib.util.spec_from_file_location(name,Path(__file__).with_name(name+'.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module
runner=load('run-destruction-semantic-suite')
reporter=load('report-destruction-semantic-suite')
frames_reporter=load('report-destruction-semantic-frames')


class SemanticEvidence(unittest.TestCase):
    def test_raw_trajectory_manifest_preserves_semantic_gates_and_stages(self):
        fields='contacts_frame bonds_broken post_correction_bonds_broken resim_passes stress_passes stress_iterations stress_active_nodes stress_active_bonds stress_islands bodies awake_bodies projectiles_active stress_converged'.split()
        row={k:1 for k in fields};row.update(step=82,complete_step_ms=10,command_ms=1,physics_step_ms=8,completion_ms=1)
        manifest=dict(scenarios=[dict(id='fracture',case='heavy',step=82,predicates={'bonds_broken':{'gt':0}})])
        runs=dict(status='complete',runs=[])
        with tempfile.TemporaryDirectory() as folder:
            root=Path(folder)
            for stage in ['A-before','B','A-after']:
                directory=root/stage/'native';directory.mkdir(parents=True)
                with (directory/'native.frames.csv').open('w') as f:
                    writer=csv.DictWriter(f,fieldnames=list(row));writer.writeheader();writer.writerow(row)
                runs['runs'].append(dict(name=stage,case='heavy',stage=stage,status='complete'))
            result=frames_reporter.report(root,manifest,runs)
            sample=result['scenarios'][0]['arms']['B']['runs'][0]
            self.assertEqual(sample['complete_step_ms'],10)
            self.assertEqual(sample['stages_ms'],dict(command_ms=1,physics_step_ms=8,completion_ms=1))
            self.assertEqual(result['whole_trajectory_measurements'],str(root/'campaign.json'))
            manifest['scenarios'][0]['predicates']['bonds_broken']['gt']=1
            with self.assertRaises(ValueError):frames_reporter.report(root,manifest,runs)
            runs['runs'][0]['status']='failed'
            with self.assertRaises(ValueError):frames_reporter.report(root,manifest,runs)

    def test_missing_event_is_not_relabelled(self):
        scenarios=[dict(id='impact',selection=dict(first=True,where={'breaks':{'gt':0}})),
                   dict(id='later',selection=dict(first=True,after_scenario='impact',where={}))]
        found=runner.select([{'step':'0','breaks':'0'}],scenarios)
        self.assertEqual(found['impact']['status'],'predicate_not_observed')
        self.assertEqual(found['later']['status'],'missing_dependency')

    def test_selection_uses_events_not_timing(self):
        rows=[{'step':str(i),'breaks':str(i%2),'complete_step_ms':str(100-i)} for i in range(4)]
        scenarios=[dict(id='impact',selection=dict(first=True,where={'breaks':{'gt':0}}))]
        self.assertEqual(runner.select(rows,scenarios)['impact']['step'],1)
        rows[3]['complete_step_ms']='10000'
        self.assertEqual(runner.select(rows,scenarios)['impact']['step'],1)

    def test_no_uncertainty_claim_with_two_samples(self):
        self.assertIsNone(reporter.interval([1,2]))

    def test_sign_randomization_controls(self):
        self.assertEqual(reporter.permutation_p([0]*10),1)
        self.assertEqual(reporter.permutation_p([1]*10),2/1024)
        self.assertGreater(reporter.permutation_p([1,-1]*5),.9)
        self.assertEqual(reporter.permutation_p([1,-1]*5,[1,-1]*5),1)
        self.assertAlmostEqual(reporter.permutation_p([1]*10,[1,-1]*5),2/252)
        self.assertEqual(reporter.holm({'a':.001,'b':.02},24),{'a':.024,'b':.46})

    def test_budget_boundary_is_strict(self):
        result=reporter.distribution([8.,8.001])
        self.assertEqual(result['budget_misses']['8ms']['count'],1)

    def test_catalogue_coverage(self):
        suite=json.loads((ROOT/'tools/profiles/destruction-semantic-suite.json').read_text())
        cases=suite['scenarios']
        self.assertEqual(len(cases),24)
        self.assertEqual(len({s['id'] for s in cases}),24)
        self.assertEqual(sum(s['origin']=='synthetic physical structure' for s in cases),8)
        self.assertEqual(suite['requirements']['solver_tolerance'],1e-5)

    def test_geometry_independent_counts_and_connectivity(self):
        # Compile the actual authoring header, then independently traverse its graph.
        expected={'building':(444,896),'chain32':(32,31),'chain256':(256,255),
                  'cantilever64':(64,63),'dense12':(1728,4752),'tower64':(2368,None),
                  'panel32':(1024,1984),'bridge64':(768,1524),'ladder128':(288,318)}
        source='''#include "native_scenario_geometry.h"
#include <iostream>
int main(int argc,char** argv){blast_demo::NativeScenarioGeometry g(argv[1]);
for(int y=0;y<g.ny;++y)for(int z=0;z<g.nz;++z)for(int x=0;x<g.nx;++x)
if(g.present(x,y,z))std::cout<<x<<' '<<y<<' '<<z<<' '<<g.supported(x,y,z)<<'\\n';}
'''
        census={}
        with tempfile.TemporaryDirectory() as temporary:
            path=Path(temporary);(path/'main.cpp').write_text(source)
            subprocess.run(['/usr/bin/clang++','-std=c++17','-I'+str(ROOT/'demos/blast-stress-demo'),str(path/'main.cpp'),'-o',str(path/'geometry')],check=True)
            for name,(node_count,bond_count) in expected.items():
                rows=[tuple(map(int,r.split())) for r in subprocess.check_output([str(path/'geometry'),name],text=True).splitlines()]
                nodes={r[:3]:r[3] for r in rows}
                neighbors={p:[] for p in nodes}
                for p in nodes:
                    for axis in range(3):
                        q=list(p);q[axis]+=1;q=tuple(q)
                        if q in nodes:neighbors[p].append(q);neighbors[q].append(p)
                edges=sum(map(len,neighbors.values()))//2
                self.assertEqual(len(nodes),node_count)
                if bond_count is not None:self.assertEqual(edges,bond_count)
                seen=set();stack=[next(iter(nodes))]
                while stack:
                    p=stack.pop()
                    if p in seen:continue
                    seen.add(p);stack.extend(neighbors[p])
                self.assertEqual(len(seen),node_count)
                unknown={p for p,s in nodes.items() if not s}
                unseen=set(unknown);components=0
                while unseen:
                    components+=1;stack=[unseen.pop()]
                    while stack:
                        for p in neighbors[stack.pop()]:
                            if p in unseen:unseen.remove(p);stack.append(p)
                unknown_edges=sum(sum(q in unknown for q in neighbors[p]) for p in unknown)//2
                boundary=sum(sum(q not in unknown for q in neighbors[p]) for p in unknown)
                self.assertGreater(sum(nodes.values()),0)
                census[name]=dict(nodes=node_count,bonds=edges,support_nodes=sum(nodes.values()),
                                  unknown_nodes=len(unknown),unknown_components=components,
                                  unknown_edges=unknown_edges,boundary_edges=boundary,
                                  unknown_cycle_rank=unknown_edges-len(unknown)+components,
                                  degree_max=max(map(len,neighbors.values())))
        print('AUTHORING_CENSUS='+json.dumps(census,sort_keys=True))


if __name__=='__main__':
    unittest.main()
