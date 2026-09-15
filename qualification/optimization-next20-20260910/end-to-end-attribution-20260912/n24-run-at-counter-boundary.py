"""Wait for this build and an owned safe GPU boundary, then screen one candidate."""
import json
import os
from pathlib import Path
import subprocess
import sys
import time

base=Path(__file__).resolve().parent
root=base.parents[1]
counter=root/'out/end-to-end-attribution-20260912'
pause=counter/'counter-pause'
receipt=base/'orchestration.json'
record=dict(status='waiting_for_oracles_and_counter_boundary',pid=os.getpid(),
            candidate_commit=json.loads((base/'preparation.json').read_text())['commit'])
def save():receipt.write_text(json.dumps(record,indent=2)+'\n')
assert not pause.exists()
pause.write_text('Owned pause for n24-component-multilevel-20260912; finish current capture before yielding.\n')
save()
try:
    deadline=time.monotonic()+7200
    while True:
        os.kill(390717,0)
        assert b'profile-config-suite.py' in Path('/proc/390717/cmdline').read_bytes()
        state=json.loads((counter/'configs-full/campaign.json').read_text())
        build=json.loads((base/'oracles/build.json').read_text())
        assert build['status'] in ['building','built_not_gpu_qualified'],build['status']
        assert state['status'] in ['running','paused'],state['status']
        if state['status']=='paused' and build['status']=='built_not_gpu_qualified':break
        assert time.monotonic()<deadline,'Build/counter boundary watchdog expired'
        time.sleep(5)
    record.update(status='screen_running',counter_completed=sum(s['status']=='complete' for s in state['scenarios']))
    save()
    with (base/'screen-driver.log').open('w') as log:
        result=subprocess.run([sys.executable,str(base/'run-screen.py')],cwd=root,stdout=log,stderr=subprocess.STDOUT)
    record.update(status='screen_complete_pending_review' if result.returncode==0 else 'screen_failed',exit_code=result.returncode)
finally:
    save()
    if pause.exists() and 'n24-component-multilevel' in pause.read_text():pause.unlink()
