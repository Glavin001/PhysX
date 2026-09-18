"""Challenge the ranking against a second archived control; never run physics."""
import csv
import gzip
import hashlib
import json
from pathlib import Path


def build(root, original, ideas, peak, steps):
    report = root / 'qualification/native-contact-properties-baseline-control/report.json.gz'
    sample_root = root / 'qualification/native-contact-properties-initial-comparison/samples/baseline'
    capture = json.loads(gzip.decompress(report.read_bytes()))
    assert capture['manifest']['status'] == 'complete'
    for suffix in ('libPhysXGpuActivity_64.so', 'libPhysXDestructionGpuRuntime_64.so', 'native_destruction_demo'):
        def artifact(manifest):
            matches = [v for k, v in manifest['artifacts'].items() if Path(k).name == suffix]
            assert len(matches) == 1
            return matches[0]
        assert artifact(capture['manifest']) == artifact(original['manifest'])
    profile = capture['phase_captures'][0]['profile']
    plain = []
    hashes = {str(report.relative_to(root)): hashlib.sha256(report.read_bytes()).hexdigest()}
    phase = None
    for path in sorted(sample_root.glob('*/native.frames.csv.gz')):
        with gzip.open(path, 'rt') as f:
            rows = list(csv.DictReader(f))
        summary_path = path.with_name('native.summary.json')
        summary = json.loads(summary_path.read_text())
        assert (summary['buildings'], summary['chunks'], summary['bonds'], summary['projectiles']) == (256, 113664, 229376, 256)
        assert summary['correction_limit'] == 1 and not summary['sleeping']
        assert len(rows) == 180
        peak.complete(dict(summary=summary, frames=rows))
        for source in (path, summary_path):
            hashes[str(source.relative_to(root))] = hashlib.sha256(source.read_bytes()).hexdigest()
        if '-plain-' in path.parent.name:
            plain.append(rows)
        else:
            assert phase is None
            phase = dict(summary=summary, frames=rows, profile=profile)
    assert len(plain) == 2 and phase is not None
    peak.rank(phase)
    baseline_peak = max(float(row['complete_step_ms']) for run in plain for row in run)
    def exposure(idea, step):
        basis = idea['basis']
        parts = profile['wall_partition'][step]
        if basis in peak.GROUPS:
            return sum(v for k, v in parts.items() if peak.group(k) == basis)
        if basis == 'stress_cuda':
            return profile['cuda_stages'][step]['stress']
        if basis == 'loads_materials':
            return sum(profile['cuda_stages'][step][k] for k in ('contactLoads', 'materials'))
        if basis == 'handoff_proxy':
            return sum(parts[k] for k in ('finishDetail.requestReadback', 'preparationCompletion', 'finishDetail.publishReservation'))
        assert basis == 'contact_proxy'
        return profile['detail']['detail.preallocateContactManagers']['observed_wall_ms'][step] + max(
            profile['detail'][k]['observed_wall_ms'][step] for k in (
                'detail.islandInsertion', 'detail.registerInteractions',
                'detail.registerSceneInteractions', 'detail.registerContactManagers'))
    results = []
    for idea in ideas:
        savings = []
        for fraction in idea['fraction']:
            projected = max(float(row['complete_step_ms']) - (
                exposure(idea, int(row['step'])) * fraction if int(row['step']) in steps else 0)
                for run in plain for row in run)
            savings.append(baseline_peak - projected)
        results.append(dict(id=idea['id'], title=idea['title'], original_rank=idea['rank'],
                            original_savings_ms=idea['conditional_observed_peak_savings_ms'],
                            second_control_savings_ms=savings))
    results.sort(key=lambda x: (-x['second_control_savings_ms'][0], -x['second_control_savings_ms'][1], x['id']))
    for rank, item in enumerate(results, 1):
        item['second_control_rank'] = rank
    lines = ['', '## Adversarial check: a second control capture', '',
             'Same 256-building / 113,664-chunk / 229,376-bond / 256-projectile fixture; two more untraced 180-step / 3-second runs plus a separate instrumented replay. Captured demo, PhysX GPU and destruction runtime hashes match the earlier control. No new simulation was run to generate this analysis.', '',
             f'The second control peaks at **{baseline_peak:.3f} ms**. Reapplying the same speculative removable fractions produces the following sensitivity result. The fractions remain unvalidated; matching binaries does not establish identical GPU conditions.', '',
             '| Idea | Earlier rank | Second-control rank | Earlier modeled peak saving ms | Second-control modeled peak saving ms |',
             '|---|---:|---:|---:|---:|']
    for item in results:
        fmt = lambda values: '–'.join(f'{value:.2f}' for value in values)
        lines.append(f"| {item['id']}: {item['title']} | {item['original_rank']} | {item['second_control_rank']} | {fmt(item['original_savings_ms'])} | {fmt(item['second_control_savings_ms'])} |")
    lines += ['', '**Decision:** use the ranking to choose experiments, not as a stable forecast. Ownership remains the leading architectural candidate; the relative order of stress and contact lifecycle depends on which impact step dominates. The earlier table does not prove that a sub-millisecond change is distinguishable from run variation.', '',
              'The initial contact-property migration comparison also does not establish a speedup: on this same fixture its two short candidate runs had a 58.068 ms worst advance versus 58.579 ms for these controls, while the second impact step became slower. This was an earlier WIP version, not the final guard revision. It removes one metadata dependency; it is not completion of GPU-owned contact or fragment lifecycle. See the [archived comparison](/root/workspace/physx-2/qualification/native-contact-properties-initial-comparison/comparison.md).', '']
    return dict(baseline_peak_ms=baseline_peak, results=results, provenance=hashes), lines
