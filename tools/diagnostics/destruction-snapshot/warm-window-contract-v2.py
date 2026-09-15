"""V2 admission: destruction frame is inactive for ordinary scenes; physical gates unchanged."""
import math
WORK=('broken_bonds','correction_passes','stress_passes','output_clusters','stress_islands','stress_active_nodes','stress_active_bonds','normal_contacts','friction_anchors')
def require(ok,msg):
    if not ok:raise ValueError(msg)
def validate(r):
    require(r.get('contract')=='physical-warm-window-v1','Wrong warm contract')
    w,m,n=r['warmup_ticks'],r['measure_ticks'],r['repetitions']
    require(0<=w<=10000 and 1<=m<=10000 and 2<=n<=1000,'Invalid window schedule')
    require(r['steps_per_restore']==w+m and r['warmup_advances_physics'] is True,'Invalid physical advancement')
    require(r['profile_tick_offset']==w,'Wrong profiling boundary')
    require(r['impulse_tick_offset']==(w if r['projectile_impulse'] else -1),'Wrong stimulus boundary')
    require(r['passed'] and r['gpu_healthy'] and r['repeatability_passed'],'Unqualified warm trajectory')
    require(len(r['trajectories'])==n and len(r['samples'])==n*m,'Incomplete trajectories')
    samples=[]
    for i,t in enumerate(r['trajectories']):
        require(t['repeat']==i and t['repeatability_passed'],'Unqualified repeat')
        require(len(t['ticks'])==w+m,'Missing warmup/measured tick')
        for j,v in enumerate(t['ticks']):
            require((v['repeat'],v['tick_offset'],v['measured'])==(i,j,j>=w),'Wrong tick selection')
            if t['ticks'][0]['stress_passes']:
                require(v['frame']==t['ticks'][0]['frame']+j,'Nonconsecutive destruction frames')
            else:
                require(v['frame']==0 and all(v[k]==0 for k in WORK), 'Inactive destruction stage has nonzero work')
            fields=('command_ms','simulate_fetch_ms','completion_ms','complete_step_ms')
            require(all(math.isfinite(v[k]) and v[k]>=0 for k in fields),'Invalid timings')
            require(abs(sum(v[k] for k in fields[:3])-v['complete_step_ms'])<1e-6,'Timing partition mismatch')
            if j>=w:samples.append(v)
    require(samples==r['samples'],'Selected measurements differ from recorded trajectory')
    return (w,m,r['projectile_impulse'])
def schedule(r):
    if r.get('contract')=='physical-warm-window-v1':return validate(r)
    require(r['passed'] and r['steps_per_restore']==1,'Unqualified cold replay')
    return (0,1,r['projectile_impulse'])
def first_history(r):
    return r['trajectories'][0]['ticks'] if r.get('contract')=='physical-warm-window-v1' else r['samples'][:1]
