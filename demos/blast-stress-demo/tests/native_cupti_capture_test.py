"""Exact conditional-kernel census and a deliberately undersized-buffer control."""
import collections,csv,gzip,json,shutil,subprocess,sys,tempfile
from pathlib import Path
work=Path(tempfile.mkdtemp(prefix='physx-cupti-capture-'));overflow='--overflow' in sys.argv
try:
    with (work/'run.log').open('w') as log:
        result=subprocess.run([sys.argv[1],str(work),'1000','16' if overflow else '512'],stdout=log,stderr=subprocess.STDOUT,timeout=120)
    status=json.loads((work/'native.activity.status.json').read_text())
    assert status['cupti_header_version']==status['cupti_runtime_version']>=130202
    assert status['invalid_timestamps']==0
    if overflow:
        assert result.returncode!=0 and not status['complete'] and status['dropped']>0
        assert '1000 conditional graph executions correct' in (work/'run.log').read_text(), 'Collector overflow corrupted the CUDA workload'
    else:
        assert result.returncode==0 and status['complete'] and status['dropped']==0
        counts=collections.Counter()
        names=dict(line.split('\t',1) for line in (work/'native.activity.names.tsv').read_text().splitlines())
        for row in csv.DictReader(gzip.open(work/'native.activity.csv.gz','rt')):
            if row['kind']=='K':
                assert 0<int(row['start_ns'])<int(row['end_ns'])
                counts[names[row['name_id']]]+=1
        assert counts=={'_Z3addPi':1024000,'_Z4nextPiy':256000,'_Z4initPi':1000},counts
    print('PASS: overflow rejected without corrupting workload' if overflow else 'PASS: exact census of 1,281,000 kernels, zero dropped/invalid records')
except BaseException:
    print((work/'run.log').read_text());print('Failure retained:',work);raise
shutil.rmtree(work)
