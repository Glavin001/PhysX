#!/usr/bin/env python3
"""Process-paired uncertainty and fixed-count planning; never bootstrap individual ticks."""
import argparse
from functools import lru_cache
import json
import math
from pathlib import Path
import statistics as st


def beta_fraction(a, b, x):
    # Continued fraction for the regularized incomplete beta function.
    tiny = 1e-300
    c = 1.0
    d = 1-(a+b)*x/(a+1)
    if abs(d) < tiny:
        d = tiny
    d = 1/d
    h = d
    for m in range(1, 201):
        for numerator in [m*(b-m)*x/((a+2*m-1)*(a+2*m)),
                          -(a+m)*(a+b+m)*x/((a+2*m)*(a+2*m+1))]:
            d = 1+numerator*d
            if abs(d) < tiny:
                d = tiny
            c = 1+numerator/c
            if abs(c) < tiny:
                c = tiny
            d = 1/d
            delta = c*d
            h *= delta
        if abs(delta-1) < 1e-13:
            return h
    raise ArithmeticError('Incomplete beta did not converge')


def beta(a, b, x):
    if x <= 0:
        return 0.0
    if x >= 1:
        return 1.0
    factor = math.exp(math.lgamma(a+b)-math.lgamma(a)-math.lgamma(b)+a*math.log(x)+b*math.log1p(-x))
    if x < (a+1)/(a+b+2):
        return factor*beta_fraction(a, b, x)/a
    return 1-factor*beta_fraction(b, a, 1-x)/b


@lru_cache(maxsize=None)
def critical(df, alpha):
    def cdf(t):
        return 1-.5*beta(df/2, .5, df/(df+t*t))
    lo, hi = 0.0, 1.0
    while cdf(hi) < 1-alpha/2:
        hi *= 2
    for _ in range(60):
        mid = (lo+hi)/2
        if cdf(mid) < 1-alpha/2:
            lo = mid
        else:
            hi = mid
    return (lo+hi)/2


def interval(values, alpha=.05):
    if len(values) < 2:
        raise ValueError('At least two independent pairs required')
    mean = st.mean(values)
    radius = critical(len(values)-1, alpha)*st.stdev(values)/math.sqrt(len(values))
    return [mean-radius, mean+radius]


def decision(bounds, margin):
    lo, hi = bounds
    if lo > margin:
        return 'meaningfully_faster'
    if hi < -margin:
        return 'meaningfully_slower'
    if lo > -margin and hi < margin:
        return 'equivalent_within_margin'
    return 'more_measurement_required_no_promotion'


def planned_pairs(sd, margin, alpha=.05, power=.8):
    # Planning approximation under centered normal pair effects, using pilot SD.
    # For equivalence at true zero, P(|mean| < margin - halfwidth) is targeted.
    z = st.NormalDist().inv_cdf((1+power)/2)
    def enough(n):
        return (critical(n-1, alpha)+z)*sd/math.sqrt(n) < margin
    hi = 4
    while not enough(hi) and hi < 1048576:
        hi *= 2
    if not enough(hi):
        return None
    lo = 3
    while hi-lo > 1:
        mid = (lo+hi)//2
        if enough(mid):
            hi = mid
        else:
            lo = mid
    # Balanced AB/BA order requires an even fixed sample count.
    return hi+(hi % 2)


def analyze(data):
    if data['status'] != 'complete':
        raise ValueError('Cannot qualify an incomplete calibration')
    same = data['same_build_calibration']
    policy = data.get('decision_policy', {})
    if not same and set(policy.get('margins_ms', {})) != {r['scenario'] for r in data['scenarios']}:
        raise ValueError('Candidate conclusions require margins frozen in the run record')
    output = dict(schema=1, status='complete', wall_seconds=data['wall_seconds'],
                  independent_unit='Difference of two fresh-process full-step means, in randomized balanced AB/BA order',
                  method='Student-t interval on independent pair differences; normal/stable pair-effect assumption. Bonferroni simultaneous intervals across the predeclared mean outcomes.',
                  limits='Six pairs provide a pilot variance estimate, not validated coverage under arbitrary VM drift. Sample-size and future seconds estimates are projections, not measured guarantees. Maxima and deadline misses remain separate guardrails.',
                  same_build_calibration=same, scenarios=[])
    family = policy.get('family_size', len(data['scenarios']))
    for row in data['scenarios']:
        pairs = row['pairs']
        if len(pairs) != data['pairs'] or any(p.get('physical') != 'passed' for p in pairs):
            raise ValueError('Missing completed physical pair')
        values = [p['saved_ms'] for p in pairs]
        raw = [p['runs'][arm]['mean_ms'] for p in pairs for arm in ['A', 'B']]
        mean = st.mean(raw)
        bounds = interval(values)
        simultaneous = interval(values, .05/family)
        # Application latency resolution, not a relaxation of physics tolerances.
        margin = policy.get('margins_ms', {}).get(row['scenario'], max(.1, .01*mean))
        durations = [cmd['seconds'] for cmd in data['commands']
                     if any(Path(x).name.startswith(row['scenario']+'-') and not x.endswith('.json') for x in cmd['command'])]
        pair_seconds = sum(durations)/len(pairs)+st.mean(p['physical_check_seconds'] for p in pairs)
        r = dict(scenario=row['scenario'], mode=row['mode'], pairs=len(pairs),
                 process_mean_ms=mean, paired_saved_ms=values, mean_saved_ms=st.mean(values),
                 pair_sd_ms=st.stdev(values), ci95_ms=bounds, family95_ci_ms=simultaneous,
                 family_size=family, proposed_equivalence_margin_ms=margin,
                 decision=decision(simultaneous, margin),
                 equivalent_margin_supported_ms=max(abs(x) for x in simultaneous),
                 measured_seconds_per_pair=pair_seconds,
                 order_effect_means_ms={order:st.mean(p['saved_ms'] for p in pairs if ''.join(p['order'])==order)
                                        for order in ['AB', 'BA']},
                 first_half_saved_ms=st.mean(values[:len(values)//2]),
                 last_half_saved_ms=st.mean(values[len(values)//2:]),
                 process_means_ms=[{arm:p['runs'][arm]['mean_ms'] for arm in ['A','B']} for p in pairs],
                 process_maxima_ms=[{arm:p['runs'][arm]['max_ms'] for arm in ['A','B']} for p in pairs],
                 misses_60hz=[{arm:p['runs'][arm]['over_60hz'] for arm in ['A','B']} for p in pairs],
                 projected_fixed_confirmation=[])
        for label, target in ([('0.1ms', .1), ('0.5ms', .5), ('1ms', 1.0), ('1percent', mean*.01), ('2percent', mean*.02)] if same else []):
            n = planned_pairs(r['pair_sd_ms'], target, .05/family)
            r['projected_fixed_confirmation'].append(dict(resolution=label, margin_ms=target, pairs=n,
                seconds=None if n is None else n*pair_seconds,
                assumption='80% planning probability of equivalence at true zero, stable normal pair variance equal to this six-pair pilot; not a guarantee'))
        # Positive/negative controls for the inference pipeline only; no simulated runtime gain.
        shift = 2*max(abs(x) for x in simultaneous)+margin
        r['decision_software_controls'] = dict(shift_ms=shift,
            positive=decision(interval([x+shift for x in values],.05/family),margin),
            negative=decision(interval([x-shift for x in values],.05/family),margin))
        output['scenarios'].append(r)
    return output


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('calibration', type=Path)
    p.add_argument('output', type=Path)
    a = p.parse_args()
    result = analyze(json.loads(a.calibration.read_text()))
    a.output.write_text(json.dumps(result, indent=2)+'\n')
    for row in result['scenarios']:
        print(row['scenario'], row['decision'], row['family95_ci_ms'], row['measured_seconds_per_pair'])


if __name__ == '__main__':
    main()
