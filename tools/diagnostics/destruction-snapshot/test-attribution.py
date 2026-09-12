#!/usr/bin/env python3
"""Accounting and kernel-inventory regression checks, independent of the GPU."""
import importlib.util,unittest,json,tempfile,copy
from pathlib import Path
def load(name,file):
    s=importlib.util.spec_from_file_location(name,Path(__file__).with_name(file));m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
kernel=load('kernel','profile-kernel-suite.py');accounting=kernel.profile.accounting
config=load('config','profile-config-suite.py')
dataflow=load('dataflow','report-dataflow-suite.py')
tiers=load('tiers','report-attribution-tiers.py')
counter_summary=load('counter_summary','summarize-counter-configs.py')
source_counter=load('source_counter','analyze-source-counters.py')
class AttributionTests(unittest.TestCase):
    def test_completed_capture_recovery_checks_workload_and_collection_contract(self):
        identity=dict(binary_sha256='binary',modules={'runtime.so':'module'})
        case=dict(prefix='/input',input_sha256={'/input.state':'input'},projectile_impulse=True)
        receipt=dict(status='complete',exit_code=0,binary_sha256='binary',modules={'/lib/runtime.so':'module'},
            snapshot_inputs=case['input_sha256'],kernel_fault_audit=dict(available=True,output=''),
            diagnostic_environment=dict(PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'),
            profiler=dict(tool='ncu',version='Version 2025.3.1.0',metric_mode='full',explicit_metrics=None,
                graph_profiling='node',apply_rules='no',replay_mode='kernel',kernel_selection=dict(
                    identifiers='expression',name_base='mangled',filter_mode='per-launch-config',count=100000)),
            command=['ncu','--profile-from-start','off','--set','full','--clock-control','none','--cache-control','all',
                '/binary','/capture','--replay','/input','--repetitions','2','--projectile-impulse'])
        def check(r,mode='application',reuse=True):
            return config.validate_completed_capture(r,identity,case,'expression',Path('/binary'),Path('/capture'),mode,reuse)
        self.assertEqual(check(receipt),'kernel')
        with self.assertRaises(AssertionError):check(receipt,reuse=False)
        mutations=[('status','running'),('binary_sha256','changed'),('snapshot_inputs',{}),
            ('kernel_fault_audit',dict(available=True,output='NVRM: Xid 120')),
            ('diagnostic_environment',dict(PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1',CUDA_LAUNCH_BLOCKING='1'))]
        for key,value in mutations:
            bad=copy.deepcopy(receipt);bad[key]=value
            with self.subTest(key=key),self.assertRaises(AssertionError):check(bad)
        bad=copy.deepcopy(receipt);bad['command'][-2]='20'
        with self.assertRaises(AssertionError):check(bad)
        bad=copy.deepcopy(receipt);bad['profiler']['kernel_selection']['count']=1
        with self.assertRaises(AssertionError):check(bad)
    def test_source_correlations_do_not_duplicate_instruction_counts(self):
        row={k:'10' for k in source_counter.KEYS};sass={'0x1':row,'0x2':row}
        result=source_counter.summarize(sass,[('0x1',('a.cuh','1'),row),('0x1',('a.cuh','2'),row)])
        self.assertEqual(result['totals'][source_counter.KEYS[0]],20)
        self.assertEqual(result['duplicate_correlations_removed'],1)
        self.assertEqual(result['unmapped_instructions'],1)
        bad=dict(row);bad[source_counter.KEYS[0]]='11'
        with self.assertRaises(AssertionError):source_counter.summarize(sass,[('0x1',('a.cuh','1'),bad)])
    def test_counter_ranges_preserve_units_and_reject_impossible_ratios(self):
        rows=[dict(metrics={'gpu__time_duration.sum':dict(value=250,unit='us'),'lts__t_sector_hit_rate.pct':dict(value=105,unit='%')}),
              dict(metrics={'gpu__time_duration.sum':dict(value=1,unit='ms'),'lts__t_sector_hit_rate.pct':dict(value=25,unit='%')}),dict(metrics={})]
        result=counter_summary.ranges(rows)
        self.assertEqual(result['gpu__time_duration.sum']['by_unit'],{'us':dict(min=250,max=250,count=1),'ms':dict(min=1,max=1,count=1)})
        self.assertEqual(result['lts__t_sector_hit_rate.pct']['by_unit'],{'%':dict(min=25,max=25,count=1)})
        self.assertEqual(len(result['lts__t_sector_hit_rate.pct']['invalid']),1)
        self.assertEqual(result['lts__t_sector_hit_rate.pct']['missing'],1)
    def test_resume_keeps_later_qualified_pilot_visible(self):
        with tempfile.TemporaryDirectory() as folder:
            path=Path(folder);common=dict(identity='same',coverage=.99,threshold_ms=.1)
            (path/'campaign-before-resume-1.json').write_text(json.dumps(dict(common,status='complete',scenarios=[dict(scenario='later-pilot',status='complete')])))
            (path/'campaign.json').write_text(json.dumps(dict(common,status='running',scenarios=[dict(scenario='first',status='running')])))
            result=tiers.campaign_view(path/'campaign.json')
            self.assertEqual([(r['scenario'],r['status']) for r in result['scenarios']],[('first','running'),('later-pilot','complete')])
    def test_transfer_overlap_is_not_removable_time(self):
        copies=[dict(start_ns=0,end_ns=1000000,ms=1,bytes=10,kind=1),dict(start_ns=500000,end_ns=1500000,ms=1,bytes=20,kind=2)]
        result=dataflow.census(copies,[dict(start_ns=250000,end_ns=1250000)])
        self.assertEqual(result['bytes'],30)
        self.assertEqual(result['copy_union_ms'],1.5)
        self.assertEqual(result['copy_kernel_overlap_ms'],1)
        self.assertEqual(result['copy_without_kernel_ms'],.5)
    def test_mixed_family_counts_graph_time_only_once(self):
        groups={'mixed':[dict(start=0,end=900000,graphId=1),dict(start=0,end=100000,graphId=None)],'tail':[dict(start=0,end=1000,graphId=None)]}
        names,coverage=config.significant_families(groups,.1,.99)
        self.assertEqual(names,['mixed']);self.assertAlmostEqual(coverage,1000/1001)
    def test_small_scene_gets_relative_configuration_coverage(self):
        groups={n:[dict(start=0,end=ns,graphId=g)] for n,ns,g in [('graph',10000,1),('a',60000,None),('b',29000,None),('tail',100,None)]}
        names,coverage=config.significant_families(groups,.1,.99)
        self.assertEqual(names,['a','b']);self.assertGreaterEqual(coverage,.99)
    def test_graph_coverage_does_not_hide_material_ordinary_family(self):
        groups={n:[dict(start=0,end=ns,graphId=g)] for n,ns,g in [('graph',1000000000,1),('ordinary',200000,None),('tail',100,None)]}
        names,_=config.significant_families(groups,.1,.99)
        self.assertEqual(names,['ordinary'])
    def test_representatives_keep_late_peak_at_same_grid(self):
        configs=[dict(invocations=[dict(ms=v) for v in [1,2,1,15]]),dict(invocations=[dict(ms=v) for v in [2,8]])]
        selected=config.representatives([dict(configs=configs)])
        self.assertEqual(selected,[1,2,4])
        self.assertIn(4,configs[0]['selected_ordinals'])
        self.assertEqual(configs[1]['selected_ordinals'],[1,2])
    def test_shared_config_excludes_driver_reservation(self):
        row=dict(name='kernel',launch={'Grid Size':'(10, 1, 1)','Block Size':'(256, 1, 1)'},metrics={
            'launch__shared_mem_per_block_static':dict(value=.576,unit='Kbyte/block'),
            'launch__shared_mem_per_block_dynamic':dict(value=128,unit='byte/block'),
            'launch__shared_mem_per_block_driver':dict(value=1024,unit='byte/block')})
        self.assertEqual(config.observed_key(row),('kernel',(10,1,1),(256,1,1),704))
    def test_stress_hierarchy_is_destruction_work(self):
        kind,_=accounting.classify('_ZN2Nv5Blast15StressHierarchy20constructMotionModesEv',{})
        self.assertEqual(kind,'stress hierarchy / preconditioner')
        kind,_=accounting.classify('Nv::Blast::StressHierarchy::construct',{})
        self.assertEqual(kind,'stress hierarchy / preconditioner')
    def test_overlap_is_not_added(self):
        gpu=[(0,5),(3,7)];cpu=[(2,6),(8,10)]
        both=accounting.length(accounting.intersect(gpu,cpu));g=accounting.length(gpu);c=accounting.length(cpu)
        self.assertEqual((both,g-both,c-both,10-g-c+both),(4,3,2,1))
    def test_nested_cpu_and_detached_wall(self):
        def row(name,a,b,cpu,detached=0):return dict(phase=name,start_ns=str(a),end_ns=str(b),thread_cpu_ms=str(cpu),thread='1',end_thread='1',detached=str(detached))
        result=accounting.exclusive_cpu([row('parent',0,100,10),row('child',10,50,4),row('detached',0,100,30,1),row('unmeasured',20,30,-1)])
        self.assertEqual(result,{'parent':6,'child':4})
    def test_selection_keeps_late_different_grids_and_correction(self):
        def k(name,ms,grid):return dict(name=name,mangled=name,ms=ms,grid=[grid,1,1],block=[256,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('stress',8,1),k('stress',3,64),k('stress',1,64),k('small',.005,1)]),.99,.1)
        self.assertEqual(plan['expected_launches'],3)
        self.assertEqual(len(plan['targets'][0]['configurations']),2)
        self.assertGreaterEqual(plan['coverage_fraction'],.99)
    def test_absolute_cost_survives_relative_cutoff(self):
        def k(n,ms):return dict(name=n,mangled=n,ms=ms,grid=[1,1,1],block=[1,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('huge',1000),k('material',.2),k('tail',.001)]),.99,.1)
        self.assertEqual([x['name'] for x in plan['targets']],['huge','material'])
    def test_one_hundred_percent_covers_all(self):
        def k(n,ms):return dict(name=n,mangled=n,ms=ms,grid=[1,1,1],block=[1,1,1],shared_bytes=0)
        plan=kernel.select(dict(kernels=[k('large',1000),k('tiny',.0001)]),1,.1)
        self.assertEqual(plan['expected_launches'],2)
if __name__=='__main__':unittest.main()
