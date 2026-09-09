#!/usr/bin/env python3
"""Accounting tests: peak selection, asynchronous scope movement, missing evidence."""
import copy
import csv
import gzip
import hashlib
import io
import json
import tempfile
import importlib.util
import unittest
from pathlib import Path
spec=importlib.util.spec_from_file_location('peak',Path(__file__).with_name('destruction-peak-opportunities.py'))
p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)

def fixture():
    frames=[];partitions=[]
    for i in range(12):
        # The first step is the peak; quiet steps have a different dominant stage.
        stress,correction=(5,10) if i==0 else (3,0)
        frame={k:'0' for k in p.COUNTERS}
        frame.update(step=str(i),complete_step_ms=stress+correction+2,
                     command_ms=1,completion_ms=1,physics_step_ms=stress+correction)
        frames.append(frame)
        partitions.append({'submit':stress,'finishDetail.waitForGpu':0,'correctedCollisionSolve':correction})
    return dict(summary={'complete_timer_schema':1},frames=frames,
                profile={'wall_partition':partitions,'cuda_stages':[{'stress':3}]*12,
                         'timestamp_bookend_ms':{'min':0,'max':0}})

class PeakAccounting(unittest.TestCase):
    def test_startup_retained_and_top_count(self):
        result=p.rank(fixture(),1)
        self.assertEqual(result['peak_step'],0)
        self.assertEqual(result['top_steps'],[0])
        self.assertEqual(result['rows'][0]['key'],'correction')
        self.assertEqual(sum(row['peak_ms'] for row in result['rows']),17)

    def test_async_movement_does_not_change_ranking(self):
        a=fixture();b=copy.deepcopy(a)
        for row in b['profile']['wall_partition']:
            row['finishDetail.waitForGpu']=row['submit'];row['submit']=0
        self.assertEqual(p.rank(a),p.rank(b))

    def test_deferred_compatibility_preserves_ownership_accounting(self):
        a=fixture();b=copy.deepcopy(a)
        a['profile']['wall_partition'][0]={'finishDetail.allocateNativeBodies':5,'correctedCollisionSolve':10}
        b['profile']['wall_partition'][0]={'compatibility.allocateNativeBodies':3,
            'compatibility.requestReadback':1,'compatibility.publishReservation':.25,
            'validatePreparation':.25,'preparationCompletion.other':.25,'publishReservedMetadata':.25,'correctedCollisionSolve':10}
        self.assertEqual(p.rank(a),p.rank(b))

    def test_overlapping_cuda_is_not_added(self):
        a=fixture();a['profile']['cuda_stages'][0]={'stress':1000}
        self.assertEqual(sum(row['peak_ms'] for row in p.rank(a)['rows']),17)

    def test_unknown_or_missing_phase_fails(self):
        a=fixture();a['profile']['wall_partition'][0]['new_scope']=1
        with self.assertRaisesRegex(ValueError,'Unclassified'):p.rank(a)
        a=fixture();a['profile']['wall_partition'].pop()
        with self.assertRaisesRegex(ValueError,'Missing phase'):p.rank(a)

    def test_missing_time_and_nonfinite_fail(self):
        a=fixture();a['profile']['wall_partition'][0]['submit']=4
        with self.assertRaisesRegex(ValueError,'does not close'):p.rank(a)
        a=fixture();a['frames'][0]['complete_step_ms']=float('nan')
        with self.assertRaisesRegex(ValueError,'Nonfinite'):p.rank(a)

    def test_gate_keeps_all_steps(self):
        r=p.overview(fixture())
        self.assertEqual(r['steps'],12);self.assertEqual(r['missed_8ms'],1)
        self.assertEqual(r['missed_60hz'],1);self.assertEqual(r['peak_ms'],17)

    def gate_capture(self, root):
        value=fixture();value['summary'].update(status='completed',frames=12)
        for row in value['frames']:row.update(stress_converged='1',correction_status='0')
        records=[]
        for mode in ('plain','phases'):
            folder=root/mode;folder.mkdir()
            stream=io.StringIO();writer=csv.DictWriter(stream,fieldnames=value['frames'][0])
            writer.writeheader();writer.writerows(value['frames'])
            (folder/'native.frames.csv.gz').write_bytes(gzip.compress(stream.getvalue().encode(),mtime=0))
            (folder/'native.summary.json').write_text(json.dumps(value['summary']))
            records.append(dict(mode=mode,name=mode,case='fixture',exit_code=0,command=['demo','--output','/missing/original/'+mode],
                files={f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in folder.iterdir()}))
        payload=dict(manifest=dict(status='complete',runs=records),runs=[],phase_captures=[dict(case='fixture',profile=value['profile'])])
        report=root/'report.json';report.write_text(json.dumps(payload))
        return report,payload

    def test_current_gate_archive_preserves_peak(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);report,_=self.gate_capture(root)
            result,_=p.load(report,root)
            self.assertEqual(p.overview(result['runs']['fixture']['plain'][0]),p.overview(fixture()))
            self.assertEqual(p.rank(result['runs']['fixture']['phases'][0]),p.rank(fixture()))

    def test_gate_rejects_mutated_raw_sample(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);report,_=self.gate_capture(root)
            with (root/'plain/native.frames.csv.gz').open('ab') as f:f.write(b'changed')
            with self.assertRaisesRegex(ValueError,'Sample hash mismatch'):p.load(report,root)

    def test_gate_rejects_incomplete_solve_even_with_valid_hash(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);report,payload=self.gate_capture(root)
            source=root/'plain/native.frames.csv.gz'
            records=list(csv.DictReader(gzip.decompress(source.read_bytes()).decode().splitlines()))
            records[0]['stress_converged']='0'
            stream=io.StringIO();writer=csv.DictWriter(stream,fieldnames=records[0]);writer.writeheader();writer.writerows(records)
            source.write_bytes(gzip.compress(stream.getvalue().encode(),mtime=0))
            payload['manifest']['runs'][0]['files'][source.name]=hashlib.sha256(source.read_bytes()).hexdigest()
            report.write_text(json.dumps(payload))
            with self.assertRaisesRegex(ValueError,'Incomplete solve'):p.load(report,root)

    def test_gate_rejects_missing_phase_and_missing_raw(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);report,payload=self.gate_capture(root)
            with self.assertRaisesRegex(ValueError,'Raw sample missing'):p.load(report)
            payload['phase_captures']=[];report.write_text(json.dumps(payload))
            with self.assertRaisesRegex(ValueError,'Missing or ambiguous phase'):p.load(report,root)

    def test_html_escapes_and_renders_tables(self):
        result=p.render_html('# Title\n\n| Key | Value |\n|---|---|\n| <unsafe> | 10 |')
        self.assertIn('<table>',result);self.assertIn('&lt;unsafe&gt;',result)
        self.assertNotIn('<unsafe>',result)

if __name__=='__main__':unittest.main()
