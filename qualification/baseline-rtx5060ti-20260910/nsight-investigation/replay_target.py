import json
import os
import sys
import tempfile
from pathlib import Path

base = Path(__file__).resolve().parent
root = base.parents[1]
destination = Path(sys.argv[1])
output = Path(tempfile.mkdtemp(prefix='pass-',dir=destination))/'scene'
config = json.loads((base/'config.json').read_text())
case = next(c for c in config['cases'] if c['id']=='impacts-256')
binary = Path(os.environ.get('DESTRUCTION_PROFILE_BINARY',str(root/'out/destruction-sdk/reference/native_destruction_demo')))
args=[str(binary),*config['common'],*case['args'],'--seconds','3','--output',str(output),
      '--profile-phases','0','--profile-gpu','0']
(output.parent/'command.json').write_text(json.dumps(args,indent=2)+'\n')
os.execv(str(binary),args)
