"""Sequential diagnostic capture at an owned, completed counter boundary."""
import csv
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time

base = Path(__file__).resolve().parent
root = base.parents[1]
counter = root/'out/end-to-end-attribution-20260912'
pause = counter/'counter-pause'
output = base/'campaign'
output.mkdir(exist_ok=False)
record = dict(status='waiting_for_verified_counter_boundary', pid=os.getpid(),
              diagnostic_only=True, runs=[], comparisons=[],
              scope='Intrusive component-work evidence only, never application timing. '
                    'Same selected N13 policy and N20 CPU baseline. Native physical/work/iteration '
                    'histories must match the same executable with uninstrumented runtime. '
                    'This does not replace full physical state or normal asynchronous memory qualification.')
prep = json.loads((base/'preparation.json').read_text())
record['commit'] = prep['commit']
build = json.loads((base/'build/build.json').read_text())
assert build['status'] == 'built_not_gpu_qualified'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
binary = root/'out/selected-n13-n20-20260912/build/B/native_destruction_demo'
record['binary'] = dict(path=str(binary), sha256=sha(binary))
spec = importlib.util.spec_from_file_location('compare', root/'tools/scripts/compare-destruction-candidates.py')
compare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compare)
fields = compare.FIELDS + ['stress_iterations','stress_passes','post_correction_bonds_broken','correction_status']


def save():
    (output/'campaign.json').write_text(json.dumps(record, indent=2)+'\n')


def run(case, args, diagnostic=False, sanitizer=None):
    name = case + ('-diagnostic' if diagnostic else '-control') + ('-'+sanitizer if sanitizer else '')
    dest = output/name
    argv = output/(name+'-args.json')
    argv.write_text(json.dumps(args, indent=2)+'\n')
    artifacts = base/'build/B' if diagnostic else binary.parent
    cmd = [sys.executable, str(root/'tools/diagnostics/destruction-snapshot/run-probe.py'),
           str(dest), '--binary', str(binary), '--artifacts', str(artifacts),
           '--native-args-json', str(argv), '--watchdog-seconds', '900']
    if sanitizer:
        cmd += ['--sanitizer',sanitizer]
    work = output/(name+'-work.jsonl')
    env = dict(os.environ)
    env.pop('PHYSX_COMPONENT_WORK_OUTPUT', None)
    if diagnostic:
        env['PHYSX_COMPONENT_WORK_OUTPUT'] = str(work)
    row = dict(name=name, command=cmd, status='running', diagnostic=diagnostic,
               work_output=str(work) if diagnostic else None)
    record['runs'].append(row)
    save()
    with (output/(name+'.log')).open('w') as log:
        proc = subprocess.run(cmd, cwd=root, env=env, stdout=log, stderr=subprocess.STDOUT, timeout=1000)
    row['exit_code'] = proc.returncode
    row['status'] = 'passed' if proc.returncode == 0 else 'failed'
    save()
    assert proc.returncode == 0, name
    frames = list(csv.DictReader((dest/'native/native.frames.csv').open()))
    summary = json.loads((dest/'native/native.summary.json').read_text())
    assert summary['sleeping'] and not summary['direct_gpu_mode'] and summary['correction_limit'] == 1
    assert len(frames) == 180 and all(f['stress_converged']=='1' and int(f['resim_passes'])<=1 for f in frames)
    if diagnostic:
        row['work_sha256'] = sha(work)
        subprocess.run([sys.executable, str(base/'summarize-work.py'), str(work),
                        str(dest/'native/native.frames.csv'), str(output/(name+'-work-summary.json'))], check=True)
    save()
    return frames


save()
try:
    assert pause.exists() and 'removal-work-census' in pause.read_text()
    while True:
        os.kill(390717, 0)
        assert b'profile-config-suite.py' in Path('/proc/390717/cmdline').read_bytes()
        state = json.loads((counter/'configs-full/campaign.json').read_text())
        if state['status'] == 'paused':
            break
        if state['status'] != 'running':
            raise RuntimeError('Counter changed state before yielding: '+state['status'])
        time.sleep(5)
    record['status'] = 'running'
    record['counter_boundary'] = dict(pid=390717, completed=sum(s['status']=='complete' for s in state['scenarios']))
    for path, digest in build['outputs'].items():
        assert sha(Path(path)) == digest
    assert sha(binary) == record['binary']['sha256']
    save()
    for grid, case in [(1,'pilot'), (16,'idle'), (16,'impacts'), (5,'impacts'), (8,'impacts')]:
        source = counter/('idle-256-warm-args.json' if case=='idle' else 'impacts-256-warm-args.json')
        args = json.loads(source.read_text())
        args[args.index('--grid')+1] = str(grid)
        args[args.index('--profile-phases')+1] = '0'
        label = f'{case}-{grid*grid}'
        control = run(label, args)
        observed = run(label, args, True)
        diffs = [dict(step=i, field=k, control=a[k], diagnostic=b[k])
                 for i,(a,b) in enumerate(zip(control,observed)) for k in fields if a[k]!=b[k]]
        record['comparisons'].append(dict(case=label, differences=diffs, fields=fields))
        save()
        assert not diffs, label+' diagnostic changes physical/work history'
        if case == 'pilot':
            run(label,args,True,'memcheck')
    record['status'] = 'complete_diagnostic_work_qualified'
except BaseException as exc:
    record.update(status='failed', error=repr(exc))
    raise
finally:
    save()
    if pause.exists() and 'removal-work-census' in pause.read_text():
        pause.unlink()
