#!/usr/bin/env python3
"""Build a self-contained, offline comparison from the verified local extraction."""
from pathlib import Path
import base64
import json

HERE=Path(__file__).resolve().parent
d=json.loads((HERE/'data/observations.json').read_text())
payload=dict(continuous=d['continuous'],restored=d['restored']['scenarios'],reports=d['live_reports'])
template=r'''<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Vibe and native PhysX — destruction comparison</title>
<style>
:root{--ink:#172b3a;--muted:#536777;--blue:#2563a6;--green:#19836e;--orange:#a95518;--line:#dce5eb}
*{box-sizing:border-box}body{margin:0;background:#f5f8fa;color:var(--ink);font:17px/1.6 system-ui,sans-serif}
main{max-width:1180px;margin:auto;padding:42px 25px 70px}h1{font-size:clamp(31px,4.5vw,51px);line-height:1.12;letter-spacing:-1.6px;max-width:1000px;margin:14px 0 20px}h2{font-size:26px;line-height:1.25;margin:0 0 15px}h3{font-size:20px;line-height:1.3;margin:0 0 10px}p{margin:0 0 16px}a{color:var(--blue)}.eyebrow{letter-spacing:2px;text-transform:uppercase;font-size:12px;font-weight:750;color:var(--green)}.lede{max-width:970px;font-size:21px;line-height:1.5}.muted,figcaption{color:var(--muted);font-size:14px}.callout{padding:17px 21px;border-left:4px solid var(--orange);background:#fff4e8;border-radius:0 9px 9px 0;margin:23px 0}
nav{display:flex;gap:10px;flex-wrap:wrap;margin:30px 0 24px}button,select{font:inherit}button{background:white;color:var(--ink);border:1px solid #b6c7d3;border-radius:8px;padding:10px 17px;cursor:pointer}button[aria-selected=true]{background:var(--ink);border-color:var(--ink);color:white}button:focus-visible,select:focus-visible,input:focus-visible{outline:3px solid #eaa056;outline-offset:3px}.panel[hidden]{display:none}section.card,article.card{background:white;border:1px solid var(--line);border-radius:14px;padding:25px;margin-bottom:22px}.grid{display:grid;grid-template-columns:1fr 1fr;gap:22px}.grid .card{margin:0}figure{margin:20px 0 30px}figure img{display:block;width:100%;height:auto;border-radius:8px;background:#fafbfc}figcaption{margin-top:10px}.tags{display:flex;gap:7px;flex-wrap:wrap;margin:15px 0}.tag{background:#edf2f5;border-radius:5px;font-size:12px;padding:4px 8px}.metric{font-size:29px;line-height:1.2;font-weight:750;letter-spacing:-.5px}.metrics{display:grid;grid-template-columns:repeat(3,1fr);gap:15px;margin:20px 0}.metric-label{font-size:12px;color:var(--muted);margin-top:6px}.metrics>div{border-left:3px solid var(--line);padding-left:12px}.native{border-top:4px solid var(--green)!important}.vibe{border-top:4px solid var(--blue)!important}label{font-size:15px;font-weight:650;display:block;margin:18px 0 6px}select{width:100%;padding:10px;border:1px solid #acbecb;border-radius:7px;background:white;color:var(--ink)}input[type=range]{width:100%;accent-color:var(--green)}table{width:100%;border-collapse:collapse;font-size:15px}th,td{border-bottom:1px solid var(--line);padding:12px 10px;text-align:left;vertical-align:top}th{font-weight:750;background:#f2f6f8}.scroll{overflow:auto}ul,ol{padding-left:24px}li{padding:4px 0}details{border-top:1px solid var(--line);padding:17px 0}summary{font-weight:650;cursor:pointer}details p{margin-top:12px}#trace{display:block;width:100%;height:auto}.small{font-size:14px}.work{padding:12px 14px;background:#f1f6f4;border-radius:7px;font-size:14px}footer{font-size:13px;color:var(--muted);margin-top:30px}.sr-only{position:absolute;width:1px;height:1px;padding:0;overflow:hidden;clip:rect(0,0,0,0)}
@media(max-width:750px){main{padding:27px 15px}.grid{grid-template-columns:1fr}.metrics{grid-template-columns:1fr 1fr}.metric{font-size:24px}section.card,article.card{padding:19px}nav button{font-size:14px;padding:9px 12px}.lede{font-size:18px}th,td{padding:9px 7px}}
@media print{nav{display:none}.panel[hidden]{display:block}body{background:white}section.card{break-inside:avoid}main{padding:10px}input{display:none}}
</style></head><body><main>
<div class="eyebrow">Source + evidence review · September 13, 2026</div>
<h1>Native integration is an advantage.<br>It is not a performance guarantee.</h1>
<p class="lede">Vibe can feel better in lighter scenes. Native removes a real CPU contact-processing route, but still pays for fragment bookkeeping and more demanding stress solves. Both systems slow substantially under heavy destruction.</p>
<div class="callout"><strong>No fair overall winner has been measured.</strong> Existing cohorts differ in scene, hardware, numerical policy, freeze behavior and timer scope. This comparison explains those differences without turning them into a speedup ratio.</div>
<nav role="tablist" aria-label="Comparison views">
<button role="tab" id="tab-explain" aria-controls="explain" aria-selected="true" data-panel="explain">How they differ</button>
<button role="tab" id="tab-explore" aria-controls="explore" aria-selected="false" data-panel="explore">Explore measurements</button>
<button role="tab" id="tab-decisions" aria-controls="decisions" aria-selected="false" data-panel="decisions">What follows</button>
</nav>
<div class="panel" id="explain" role="tabpanel" aria-labelledby="tab-explain">
<section class="card"><h2>Follow one physics tick</h2><p>The key improvement is who owns contact-to-load processing. Fracture still requires native CPU objects, shape ownership, contacts and query state to agree.</p>
<figure><img src="@@ownership@@" alt="Vibe downloads contacts for CPU routing then uploads stress loads; native keeps that chain on the GPU, but both retain CPU lifecycle work and conditional correction."><figcaption>Conceptual dependencies, not a measured timeline. Both already share a CUDA context and run iteration control on the GPU. Vibe's final game/encoding stage is outside native's physics benchmark.</figcaption></figure></section>
<div class="grid"><article class="card vibe"><h3>The older solver controls work per call</h3><p>The live Vibe configuration caps a solve at <strong>32 iterations</strong>, with tolerance <strong>1e−3</strong>. A completed API call may return a partial solution. Unconverged components can continue refining on later ticks.</p><p>Its node-space CGLS loop already uses CUDA graphs, component convergence checks, warm starts and settled reuse.</p></article>
<article class="card native"><h3>The native step requires convergence</h3><p>The selected native path uses preconditioned node-space CG, with accurate residual and stored-output checks. The driver uses <strong>1e−5</strong>; non-convergence fails the step.</p><p>Small components run within a GPU block; large ones use a cooperative multi-block solve. That is a materially different cost per iteration.</p></article></div>
<figure><img src="@@comparison-traps@@" alt="Native continuous idle takes about 1 to 2 ms versus about 61 ms after snapshot restoration. Vibe's larger iteration and changed topology settings produce both more destruction and higher median tick times."></figure>
<section class="card"><h2>What makes the subjective comparison tricky</h2>
<details open><summary>Rendering can remain smooth while physics slows</summary><p>Vibe interpolates debris and follows the measured server tick rate. One submitted report has a 23.59 ms client-frame point sample and a 235.51 ms rolling server-tick mean. These asynchronous metrics cannot be divided into an exact rate ratio, but the visual and simulation clocks are plainly different.</p></details>
<details><summary>“CPU ms” is not “how long the tick took”</summary><p>Older Vibe tables use process CPU time, excluding time blocked on the GPU. Its recorder also measures elapsed simulation time. Native's integrated physics field includes stress, correction and CPU work; its legacy zero stress field is a placeholder. Compare the complete wall-clock scope.</p></details>
<details><summary>A warm saved scene may have cold numerical caches</summary><p>Independent restoration is excluded from the native timer, but the next real solve rebuilds disposable execution state. A restored 61 ms idle solve and a continuous 1–2 ms idle tick are different workloads on the same build.</p></details>
<details><summary>More accurate solving may produce more future physics work</summary><p>Vibe P4's 32/whole-reset and 256/incremental configurations at strength 0.45 break 10,230 and 33,957 bonds. More fragments create more motion and contacts. This is a single-run configuration comparison, not an isolated iteration test or proof that either cap fully converges.</p></details>
<details><summary>Stricter convergence does not certify the entire physical model</summary><p>The held Vibe wrench correction exposed severe under-convergence on one large building. Native separately retains an unequal-mass column model failure: 27.746870 N versus 29.430000 N. Neither system can be called a universally validated physical reference from these reports.</p></details>
</section></div>
<div class="panel" id="explore" role="tabpanel" aria-labelledby="tab-explore" hidden>
<figure><img src="@@performance-context@@" alt="Six Vibe live reports grow from about 25 to 236 ms average ticks; separate native continuous heavy runs average about 51 ms and exceed the 60 Hz budget."></figure>
<section class="card vibe"><h2>Vibe: inspect the six submitted reports</h2><p class="muted">One evolving live session on September 6. Rolling 180-tick server windows overlap; client frames are point samples. Direct GPU, CUDA stress, 32 iterations, freeze on.</p>
<label for="vibeReport">Report snapshot</label><select id="vibeReport"></select><div id="vibeMetrics" class="metrics" aria-live="polite"></div><p id="vibeWork" class="work"></p></section>
<section class="card native"><h2>Native: inspect a continuous run</h2><p class="muted">Same selected N13+N20 build, 256 buildings / 113,664 chunks / 229,376 bonds. Idle has no projectiles; heavy has 256. No restores. First-use ticks included. Initialization is separate.</p>
<label for="nativeRun">Workload and independent process</label><select id="nativeRun"></select><div id="nativeMetrics" class="metrics"></div>
<svg id="trace" viewBox="0 0 1020 290" role="img" aria-label="Selected native run: all 600 complete tick times with 60 Hz budget and selected-tick marker"></svg>
<label for="tick">Inspect tick <output id="tickNumber">0</output> of 599</label><input id="tick" type="range" min="0" max="599" value="0"><p class="work" id="tickMetrics" aria-live="polite"></p></section>
<section class="card native"><h2>Native: inspect all 52 restored scenarios</h2><p class="muted">20 independent restored ticks in each A0/A1 group, identical selected build. Restore excluded; rebuilt execution state still affects the next tick. These are not continuous gameplay costs.</p>
<label for="restoredScenario">Saved physical scenario</label><select id="restoredScenario"></select><div id="restoredMetrics" class="metrics" aria-live="polite"></div><p class="work" id="restoredWork"></p><p class="small" id="restoredPurpose"></p></section>
<figure><img src="@@bottlenecks@@" alt="Vibe's host contact work averages 65 ms. Native tower is dominated by GPU stress; native debris has large scheduled CPU intervals. Profile timing is separate from production timing."></figure>
</div>
<div class="panel" id="decisions" role="tabpanel" aria-labelledby="tab-decisions" hidden>
<section class="card"><h2>The limiting work changes with the scene</h2><div class="scroll"><table><thead><tr><th>Regime</th><th>Evidence</th><th>Direction supported</th></tr></thead><tbody>
<tr><td>Intact continuous city</td><td>Native 1.27–1.70 ms mean; no 60 Hz misses in 2,400 ticks</td><td>Preserve exact reuse and correct invalidation.</td></tr>
<tr><td>Large connected tower</td><td>103.91 ms persistent stress kernel in a selected-build profile; tiny GPU-to-CPU copy</td><td>Reduce total time to convergence, including setup and preconditioning.</td></tr>
<tr><td>Heavy fragmented city</td><td>Native profile retains expensive shape migration and contact registration</td><td>Remove repeated native CPU lifecycle work and dependencies.</td></tr>
<tr><td>Repeated assets, early impact</td><td>Existing audits find shared operators and some exact duplicate solves</td><td>Prepare/reuse structure at asset lifetime; charge memory and fracture invalidation.</td></tr>
</tbody></table></div><p class="muted">These are hypotheses to implement and qualify, not speedup promises. Previous matching and multilevel variants include failed or mixed results. Large debris has almost no identical load vectors to exploit.</p></section>
<section class="card"><h2>What a fair next comparison needs</h2><ol><li>Use the same GPU and host, authored scene, physical inputs and observation period.</li><li>Run both actual product configurations to compare experience, with their differences explicit.</li><li>Separately reconcile convergence, mass/load model, material thresholds, sleeping/freeze and correction semantics before claiming equal-quality engine performance.</li><li>Measure complete physics ticks and complete game ticks separately, across intact idle, localized impact, broad collapse, late rubble and reactivation.</li><li>Count actual fragments, contacts, solver work and damage; equal chunk counts or shot tapes alone do not imply equal work.</li></ol>
<p>The existing attempted common-scene replay failed physical comparability: external idle spontaneously broke 15,034 bonds under the copied native settings. Its timing cannot declare a winner.</p></section>
<section class="card"><h2>Evidence status</h2><p><strong>7,480 archived ticks independently recomputed:</strong> 4,800 native continuous, 2,080 native restored and 600 deduplicated Vibe live-history ticks. Source sample hashes, native stage sums and profile partitions checked. P4 values come from the preserved report; its raw recordings were unavailable locally.</p><p>Native runtime <code>d5770a80…</code>, measured source <code>13b11af2…</code>. Vibe live game <code>a4685b3</code>, solver <code>bd71ce1b</code>, executable <code>7c5d0426…</code>. Current working files contain additional unqualified changes.</p><p>No new GPU run, runtime change, deployment or commit was made for this comparison.</p></section>
</div>
<footer><a href="README.md">Detailed report and source links</a> · <a href="provenance.json">Provenance</a> · <a href="verification.json">Verification</a><br>This HTML embeds its figures and explorer data. It needs no network connection. Linked detailed archives require the local workspace.</footer>
</main><script id="comparison-data" type="application/json">@@DATA@@</script><script>
'use strict';
const data=JSON.parse(document.getElementById('comparison-data').textContent);
const $=id=>document.getElementById(id), fmt=(x,n=2)=>Number(x).toLocaleString('en-US',{minimumFractionDigits:n,maximumFractionDigits:n});
const tabs=[...document.querySelectorAll('[role=tab]')];
function activate(b){tabs.forEach(t=>{const on=t===b;t.setAttribute('aria-selected',String(on));t.tabIndex=on?0:-1;$(t.dataset.panel).hidden=!on});}
tabs.forEach((b,i)=>{b.addEventListener('click',()=>activate(b));b.addEventListener('keydown',e=>{let j;if(e.key==='ArrowRight')j=(i+1)%tabs.length;if(e.key==='ArrowLeft')j=(i+tabs.length-1)%tabs.length;if(e.key==='Home')j=0;if(e.key==='End')j=tabs.length-1;if(j!==undefined){e.preventDefault();activate(tabs[j]);tabs[j].focus()}})});activate(tabs[0]);
function options(id,items,label){items.forEach((x,i)=>{let o=document.createElement('option');o.value=i;o.textContent=label(x);$(id).appendChild(o)})}
function metrics(id,items){$(id).innerHTML=items.map(([v,l])=>`<div><div class="metric">${v}</div><div class="metric-label">${l}</div></div>`).join('')}
options('vibeReport',data.reports,r=>`${r.captured_at.slice(11,19)} UTC · ${r.shots_fired} shots · ${fmt(r.awake_bodies,0)} awake bodies`);
function vibe(){const r=data.reports[+$('vibeReport').value],t=r.server_rolling_180_ticks_ms.total_ms;metrics('vibeMetrics',[[fmt(t.avg)+' ms','Server rolling mean'],[fmt(t.p95)+' ms','Server rolling p95'],[fmt(r.client_frame_point_sample.frameTotalMs)+' ms','Client-frame point sample']]);$('vibeWork').textContent=`${fmt(r.broken_bonds,0)} cumulative broken bonds · ${r.pending_input_frames} pending input frames · ${fmt(r.first_physics_pass_point_sample.contact_host_work_ms)} ms first-pass host contact work. Snapshots are asynchronous; do not sum these metrics.`}
$('vibeReport').addEventListener('change',vibe);vibe();
options('nativeRun',data.continuous,r=>r.name.replace('idle-256','Intact idle').replace('impacts-256','Heavy destruction'));
let currentRun;
function run(){currentRun=data.continuous[+$('nativeRun').value];const r=currentRun;metrics('nativeMetrics',[[fmt(r.mean_ms)+' ms','Mean complete tick'],[fmt(r.max_ms)+' ms','Observed maximum'],[`${r.misses_60hz} / ${r.n}`,'Ticks above 16.667 ms'],[fmt(r.sd_ms)+' ms','Tick standard deviation'],[fmt(r.initialization_ms/1000)+' s','Initialization, separate'],['600 ticks','10 simulated seconds']]);drawTrace();tick();}
function drawTrace(){let r=currentRun,max=Math.max(20,r.max_ms*1.08),sx=x=>55+x/599*940,sy=y=>240-y/max*205;
let s='<rect x="0" y="0" width="1020" height="290" fill="#fff"/>';
for(let i=0;i<=4;i++){let v=max*i/4,y=sy(v);s+=`<line x1="55" x2="995" y1="${y}" y2="${y}" stroke="#e4ebef"/><text x="44" y="${y+5}" text-anchor="end" fill="#536777" font-size="12">${fmt(v,0)}</text>`;}
s+=`<line x1="55" x2="995" y1="${sy(1000/60)}" y2="${sy(1000/60)}" stroke="#a95518" stroke-dasharray="5 5"/><text x="995" y="${sy(1000/60)-6}" text-anchor="end" font-size="12" fill="#a95518">60 Hz budget</text>`;
s+=`<polyline fill="none" stroke="#19836e" stroke-width="1.4" points="${r.frames.map(f=>`${sx(f.step)},${sy(f.complete_step_ms)}`).join(' ')}"/>`;
for(let x=0;x<=500;x+=100)s+=`<text x="${sx(x)}" y="264" text-anchor="middle" font-size="12">${x}</text>`;
s+='<text x="510" y="286" text-anchor="middle" font-size="12">Simulation tick (scale adjusts to selected run)</text><text x="14" y="20" font-size="12">ms</text>';
s+=`<line id="cursor" x1="55" x2="55" y1="25" y2="240" stroke="#172b3a" stroke-dasharray="3 4"/>`;$('trace').innerHTML=s;}
function tick(){const i=+$('tick').value,f=currentRun.frames[i];$('tickNumber').value=i;const x=55+i/599*940;$('cursor').setAttribute('x1',x);$('cursor').setAttribute('x2',x);$('tickMetrics').textContent=`Tick ${i}: ${fmt(f.complete_step_ms)} ms · ${fmt(f.contacts_frame,0)} contact records · ${fmt(f.bonds_broken,0)} new broken bonds · ${fmt(f.stress_iterations,0)} maximum stress iterations · ${f.resim_passes} correction. Iterations are a maximum across components, not total solver work.`}
$('nativeRun').addEventListener('change',run);$('tick').addEventListener('input',tick);run();
options('restoredScenario',data.restored,r=>r.scenario);
function restored(){const r=data.restored[+$('restoredScenario').value],a=r.A0,b=r.A1,w=r.representative_work;metrics('restoredMetrics',[[fmt(a.mean_ms)+' / '+fmt(b.mean_ms)+' ms','A0 / A1 means'],[fmt(Math.max(a.max_ms,b.max_ms))+' ms','Observed maximum across both groups'],[`${a.misses_60hz+b.misses_60hz} / ${a.n+b.n}`,'Ticks above 16.667 ms']]);$('restoredWork').textContent=`${fmt(r.chunks,0)} chunks / ${fmt(r.bonds,0)} bonds · representative output: ${fmt(w.output_clusters,0)} motion groups, ${fmt(w.stress_islands,0)} stress components, ${fmt(w.normal_contacts,0)} normal records + ${fmt(w.friction_anchors,0)} friction anchors; ${w.correction_passes} correction / ${w.stress_passes} stress passes; maximum ${w.stress_iterations} iterations.`;$('restoredPurpose').textContent=r.purpose;}
$('restoredScenario').addEventListener('change',restored);restored();
document.documentElement.dataset.ready='true';
</script></body></html>'''
for name in ['ownership','comparison-traps','performance-context','bottlenecks']:
    uri='data:image/svg+xml;base64,'+base64.b64encode((HERE/'figures'/f'{name}.svg').read_bytes()).decode()
    template=template.replace('@@'+name+'@@',uri)
template=template.replace('@@DATA@@',json.dumps(payload,separators=(',',':')).replace('</','<\\/'))
assert '@@' not in template
(HERE/'comparison.html').write_text(template)
print(f'Built self-contained comparison.html ({len(template):,} characters); 8 continuous runs, 52 restored scenarios, 6 Vibe reports.')
