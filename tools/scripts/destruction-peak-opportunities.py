#!/usr/bin/env python3
"""Rank measured destruction peak costs; never infer hardware saturation or savings."""
import argparse
import gzip
import csv
import hashlib
import html
import json
import math
import statistics
from pathlib import Path

GROUPS = {
    'stress': ('🧮 Destruction submission and completion dependency', 'Our CUDA stress/load/topology pipeline; inspect CUDA stages below'),
    'ownership': ('🚚 Fragment ownership and lifecycle bridge', 'Our integration: allocation, registration, ownership, filtering and query mirrors'),
    'correction': ('⏪ Correction orchestration and repeated interaction', 'Optimize our work selection/reuse; keep NVIDIA collision/solve kernels'),
    'commit': ('📤 Accepted-state publication', 'Our correction completion and publication'),
    'checkpoint': ('💾 Checkpoint', 'Our checkpoint selection/submission'),
    'trial': ('🟰 Trial physics and unassigned scene tasks', 'Control/context; not a recommendation to rewrite NVIDIA kernels'),
    'commands': ('📥 Recorded commands', 'Command application including runtime insertion'),
    'completion': ('✅ Mandatory completion', 'Application completion/status boundary'),
}
OWNERSHIP = {
    'finishDetail.growMotionSlots', 'finishDetail.requestReadback',
    'finishDetail.allocateNativeBodies', 'finishDetail.uploadBindings',
    'compatibility.requestReadback', 'compatibility.allocateNativeBodies', 'compatibility.publishReservation',
    'finishDetail.publishReservation', 'finishDetail.reserveBodies.other',
    'finishAndReserve.other', 'initializeReserved', 'collisionBindings',
    'correctionBodies', 'validatePreparation', 'preparationCompletion', 'preparationCompletion.other', 'publishReservedMetadata', 'applyDetail.validateOwners',
    'applyDetail.scheduleOwners', 'migrateDetail.refilter',
    'migrateDetail.retireContacts', 'migrateDetail.registerOwner',
    'migrateDetail.actorLinks', 'migrateDetail.queryMirror',
    'applyDetail.migrateShapes.other', 'applyBindings.other',
}
COUNTERS = ['bodies', 'awake_bodies', 'logical_clusters', 'contacts_frame',
            'stress_active_nodes', 'stress_active_bonds', 'stress_islands',
            'stress_iterations', 'bonds_broken', 'resim_passes']

def require(ok, message):
    if not ok:
        raise ValueError(message)

def number(value):
    x = float(value)
    require(math.isfinite(x) and x >= 0, 'Nonfinite/negative measurement')
    return x

def complete(run):
    require(run['summary']['complete_timer_schema'] == 1, 'Complete timer required')
    values = []
    for frame in run['frames']:
        value = number(frame['complete_step_ms'])
        parts = sum(number(frame[k]) for k in ['command_ms', 'physics_step_ms', 'completion_ms'])
        require(abs(value-parts) < .0002, 'Complete timer does not close')
        values.append(value)
    require(values, 'Empty capture')
    return values

def group(key):
    if key in ('submit', 'finishDetail.waitForGpu'):
        return 'stress'
    if key in OWNERSHIP:
        return 'ownership'
    if key in ('restoreInstall', 'resetContactCaches', 'correctedCollisionSolve'):
        return 'correction'
    return {'acceptCorrection': 'commit', 'checkpoint': 'checkpoint', 'trial.other': 'trial'}.get(key)

def rank(run, count=10):
    times = complete(run)
    p = run['profile']
    partitions = p['wall_partition']
    require(len(partitions) == len(times), 'Missing phase rows')
    grouped = []
    for i, partition in enumerate(partitions):
        values = {key: 0. for key in GROUPS}
        for key, value in partition.items():
            owner = group(key)
            require(owner is not None, 'Unclassified scope: '+key)
            values[owner] += number(value)
        # Existing accounting retains timestamp bookends in this partition.
        bookends = p['timestamp_bookend_ms']
        delta = sum(values.values())-number(run['frames'][i]['physics_step_ms'])
        require(number(bookends['min'])-1e-7 <= delta <= number(bookends['max'])+1e-7,
                'Phase partition does not close within recorded bookends')
        values['commands'] = number(run['frames'][i]['command_ms'])
        values['completion'] = number(run['frames'][i]['completion_ms'])
        grouped.append(values)
    selected = sorted(range(len(times)), key=lambda i: (-times[i], i))[:count]
    peak = selected[0]
    rows = []
    for key, (label, owner) in GROUPS.items():
        rows.append(dict(key=key, label=label, owner=owner,
            peak_ms=grouped[peak][key],
            top_mean_ms=statistics.mean(grouped[i][key] for i in selected),
            all_mean_ms=statistics.mean(v[key] for v in grouped)))
    rows.sort(key=lambda row: (-row['top_mean_ms'], row['key']))
    return dict(peak_step=int(run['frames'][peak]['step']), peak_complete_ms=times[peak],
                top_steps=[int(run['frames'][i]['step']) for i in selected], rows=rows,
                peak_work={k: run['frames'][peak][k] for k in COUNTERS},
                peak_cuda_stages=p['cuda_stages'][peak])

def overview(run):
    values = complete(run)
    peak = max(range(len(values)), key=lambda i: values[i])
    return dict(steps=len(values), mean_ms=statistics.mean(values), peak_ms=values[peak],
                peak_step=int(run['frames'][peak]['step']),
                missed_8ms=sum(x > 8 for x in values), missed_60hz=sum(x > 1000/60 for x in values))

def load(path, capture_root=None):
    raw = path.read_bytes()
    payload = json.loads(gzip.decompress(raw) if path.suffix == '.gz' else raw)
    manifest = payload['manifest']
    require(manifest['status'] == 'complete', 'Campaign is incomplete')
    require('runs' in payload, 'Timing runs required')
    if isinstance(payload['runs'], list):
        # Gate reports retain summaries, with raw samples identified by the
        # capture manifest. Normalize them to the existing analysis structure.
        runs = {}
        for record in manifest['runs']:
            if record['mode'] not in ('plain', 'phases'):
                continue
            require(record.get('exit_code') == 0, 'Failed capture cannot be ranked')
            command = record['command']
            source = (capture_root / record['name'] if capture_root else
                      Path(command[command.index('--output')+1]))
            blobs = {}
            for name in ('native.frames.csv.gz', 'native.summary.json'):
                target = source / name
                require(target.is_file(), 'Raw sample missing; supply --capture-root for an archived campaign: '+str(target))
                blob = target.read_bytes()
                require(hashlib.sha256(blob).hexdigest() == record['files'][name], 'Sample hash mismatch: '+str(target))
                blobs[name] = blob
            frames = list(csv.DictReader(gzip.decompress(blobs['native.frames.csv.gz']).decode().splitlines()))
            summary = json.loads(blobs['native.summary.json'])
            require(summary.get('status') == 'completed', 'Incomplete sample summary')
            require(len(frames) == summary['frames'], 'Missing frame rows')
            require([int(f['step']) for f in frames] == list(range(len(frames))), 'Step sequence changed')
            require(all(int(f['stress_converged']) == 1 and 0 <= int(f['resim_passes']) <= 1
                        and int(f['correction_status']) == 0 for f in frames), 'Incomplete solve or correction')
            value = dict(summary=summary, frames=frames)
            complete(value)
            if record['mode'] == 'phases':
                profiles = [c['profile'] for c in payload.get('phase_captures', []) if c['case'] == record['case']]
                require(len(profiles) == 1, 'Missing or ambiguous phase capture')
                value['profile'] = profiles[0]
                rank(value)
            runs.setdefault(record['case'], dict(plain=[], phases=[]))[record['mode']].append(value)
        require(runs, 'No measured runs')
        payload['runs'] = runs
    require(isinstance(payload['runs'], dict), 'Unsupported timing report format')
    return payload, hashlib.sha256(raw).hexdigest()

def document(payload, case, source_hash):
    runs = payload['runs'][case]
    require(runs['plain'] and runs['phases'], 'Untraced and scoped captures required')
    s = runs['plain'][0]['summary']
    result = dict(schema=1, source_sha256=source_hash, case=case,
        workload={k: s[k] for k in ['buildings','chunks','bonds','projectiles','seconds','correction_limit','sleeping']},
        untraced=[overview(r) for r in runs['plain']],
        scoped=[rank(r) for r in runs['phases']])
    text = ['# 🎯 Destruction peak opportunities', '',
        f"Workload: {s['buildings']} buildings, {s['chunks']:,} chunks, {s['bonds']:,} bonds, "
        f"{s['projectiles']} projectiles; {s['seconds']} simulated seconds per run; "
        f"correction limit {s['correction_limit']}; sleeping {s['sleeping']}.", '',
        'Source: validated timing-report snapshot (SHA-256 '+source_hash+'). '
        'This analysis checks timer closure; it does not independently revalidate the raw CUPTI trace. '
        'No simulation or profiling is run during report generation.', '',
        '| Untraced run | Steps | Mean complete ms | Peak complete ms | Peak step | >8 ms | >1/60 s |',
        '|---|---:|---:|---:|---:|---:|---:|']
    for i, row in enumerate(result['untraced'], 1):
        text.append(f"| {i} | {row['steps']} | {row['mean_ms']:.3f} | {row['peak_ms']:.3f} | {row['peak_step']} | {row['missed_8ms']} | {row['missed_60hz']} |")
    for i, scoped in enumerate(result['scoped'], 1):
        text += ['', f'## Separate scoped capture {i}: rank by its ten worst complete steps', '',
            'All steps remain eligible, including startup. The selected steps are: '+str(scoped['top_steps'])+'. '
            'This ranking is measured elapsed exposure, not a promised saving. '
            'Submission and completion wait are grouped because GPU work can execute inside either host scope. '
            'Rows form a disjoint partition apart from small recorded timestamp bookends.', '',
            '| Responsibility | Mean of selected peaks ms | At this capture’s worst step ms | All-step mean ms | Optimization owner |',
            '|---|---:|---:|---:|---|']
        for row in scoped['rows']:
            text.append(f"| {row['label']} | {row['top_mean_ms']:.3f} | {row['peak_ms']:.3f} | {row['all_mean_ms']:.3f} | {row['owner']} |")
        text += ['', f"Scoped worst complete step: {scoped['peak_step']}, {scoped['peak_complete_ms']:.3f} ms."]
        text += ['', '| Work at that step | Count |', '|---|---:|']
        text += [f'| {key} | {value} |' for key,value in scoped['peak_work'].items()]
        text += ['', 'Contacts are reports, awake bodies are CPU scheduling counts, retained stress bonds are not bond-iterations. '
            'The stress iteration counter is not a resimulation count.', '',
            '| CUDA stream interval at scoped peak (overlaps table above) | ms |', '|---|---:|']
        text += [f'| {key} | {number(value):.3f} |' for key,value in scoped['peak_cuda_stages'].items()]
    text += ['', '## Evidence required before choosing an optimization', '',
        '| Question | Evidence available without privileged counters | Decision |', '|---|---|---|',
        '| Where is the peak spent? | Disjoint CPU timeline + CUDA events + CUPTI execution unions | Rank critical elapsed regions; never sum overlapping waits and kernels |',
        '| Why does stress get expensive? | Add per-component node/bond iterations, iteration distribution and preconditioner/reduction phase clocks | Separate too much work from slow execution or a few long-running components |',
        '| Why does correction get expensive? | Count new fragments, ownership changes, pair invalidations, regenerated constraints and correction participants | Remove our unnecessary lifecycle/rebuild work; keep NVIDIA solver kernels |',
        '| Would more parallel work help? | Fixed-input component batching and block-size experiments; per-block duration distributions | Compare same physical work and end-to-end peaks, not utilization percentages |',
        '| Is memory or arithmetic limiting? | Static operation counts, standalone bandwidth/arithmetic controls, controlled layout/reuse experiments | Supporting evidence only; do not claim a measured roofline or occupancy without counters |',
        '| Did the change actually help? | Interleaved A/B runs with identical recorded commands, settings and quality audits | Require repeatable complete-step peak reduction; preserve every spike |',
        '', '## Repeatable decision loop', '',
        '1. Freeze inputs, iteration policy, binaries, CUDA settings and quality requirements. Capture the entire impact sequence, not a synthetic idle fragment.',
        '2. Rank peak exposure above. Investigate our largest stages first. Use a PhysX-only run only as a control; removing destruction changes the workload and cannot establish a production speedup.',
        '3. State one falsifiable hypothesis and change one implementation responsibility. Use diagnostic builds for counters/probes, separate from untraced performance builds.',
        '4. Interleave baseline/candidate runs to expose clock and host scheduling drift. Match event windows as well as absolute worst steps. Record all physical counters and flag trajectory differences.',
        '5. Run physical quality gates; counts alone are insufficient. Report result as verified improvement, inconclusive noise, regression, or changed workload—not simply a faster mean.',
        '6. Only qualifying candidates proceed to five 60-second runs and endurance. Re-rank after every accepted change.',
        '', '## Current limitations', '',
        'Hardware counters unavailable: memory saturation, occupancy and instruction stalls remain unmeasured. '
        'Existing solver-row counters are incomplete. Per-component weighted iteration work and exact correction invalidation counts remain instrumentation TODOs. '
        'A capped cross-frame iteration policy must be compared separately from mandatory within-step convergence; changing that policy is not an implementation-only A/B test. '
        'Short diagnostic campaigns do not establish 60 Hz or the 8 ms gate.', '',
        '## Reproduce', '',
        'Run `python3 tools/scripts/destruction-peak-opportunities.py REPORT_JSON_GZ --case '+case+' --output OUTPUT_DIRECTORY` against a full timing report. The output is deterministic and includes a source hash.', '']
    return '\n'.join(text), result

def render_html(text):
    # Only the headings, paragraphs and tables generated above; no raw HTML.
    blocks = []
    for block in text.split('\n\n'):
        lines = block.splitlines()
        if not lines:
            continue
        if lines[0].startswith('|'):
            rows = [[html.escape(cell.strip()) for cell in line.strip('|').split('|')] for line in lines]
            head = '<tr>'+''.join('<th>'+x+'</th>' for x in rows[0])+'</tr>'
            body = ''.join('<tr>'+''.join('<td>'+x+'</td>' for x in row)+'</tr>' for row in rows[2:])
            blocks.append('<div class="scroll"><table>'+head+body+'</table></div>')
        elif lines[0].startswith('#'):
            level = len(lines[0])-len(lines[0].lstrip('#'))
            blocks.append(f'<h{level}>'+html.escape(lines[0][level:].strip())+f'</h{level}>')
        else:
            blocks.append('<p>'+html.escape(block).replace('\n','<br>')+'</p>')
    css = 'body{font:16px system-ui;max-width:1400px;margin:2em auto;padding:0 20px;color:#182a3b}p{line-height:1.6}.scroll{overflow:auto}table{border-collapse:collapse;width:100%;font-size:14px}td,th{padding:10px;border-bottom:1px solid #ccd;text-align:left}th{background:#123851;color:white}tr:nth-child(even){background:#eff5f8}'
    return '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>Destruction peak opportunities</title><style>'+css+'</style>'+''.join(blocks)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('report',type=Path);parser.add_argument('--case',required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--capture-root',type=Path,help='Archived campaign directory containing the original run folders')
    args=parser.parse_args()
    payload,digest=load(args.report,args.capture_root);text,data=document(payload,args.case,digest)
    args.output.mkdir(parents=True,exist_ok=True)
    (args.output/'report.md').write_text(text)
    (args.output/'report.json').write_text(json.dumps(data,indent=2,sort_keys=True)+'\n')
    (args.output/'report.html').write_text(render_html(text))
    print(args.output/'report.md')

if __name__=='__main__':
    main()
