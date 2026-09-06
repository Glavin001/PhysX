#!/usr/bin/env python3
"""Label a GPU cluster-color recording with measured counts and timing.

Only annotates pixels. Does not recolor geometry or alter the simulation.
"""
import argparse
import csv
import json
import math
from pathlib import Path
import subprocess
import tempfile


def stamp(seconds):
    cs=round(seconds*100);hours,cs=divmod(cs,360000);minutes,cs=divmod(cs,6000);seconds,cs=divmod(cs,100)
    return f'{hours}:{minutes:02}:{seconds:02}.{cs:02}'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path);p.add_argument('video',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--group-observations',type=Path,help='Optional exact membership observations from the same physical fixture')
    args=p.parse_args()
    summary=json.loads((args.capture/'native.summary.json').read_text())
    assert summary['status']=='completed' and summary['color_by_cluster']
    frames=list(csv.DictReader((args.capture/'native.frames.csv').open()))
    assert len(frames)==summary['frames']
    history={}
    if args.group_observations:
        current={};last=None;last_frame=-1
        for row in csv.DictReader(args.group_observations.open()):
            frame=int(row['step'])
            if frame!=last_frame:
                if current and current!=last:history[last_frame]=current.copy();last=current.copy()
                current={};last_frame=frame
            current[int(row['root'])]=(int(row['cluster_chunks']),int(row['supported']))
        if current!=last:history[last_frame]=current
    header='''[Script Info]
ScriptType: v4.00+
PlayResX: 960
PlayResY: 540
[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Top,DejaVu Sans,18,&H00FFFFFF,&H00FFFFFF,&H00101820,&H00101820,0,0,0,0,100,100,0,0,3,1,0,7,12,12,8,1
Style: Bottom,DejaVu Sans,16,&H00FFFFFF,&H00FFFFFF,&H00101820,&H00101820,0,0,0,0,100,100,0,0,3,1,0,1,12,12,8,1
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
'''
    broken=0;cumulative=[]
    for row in frames:broken+=int(row['bonds_broken']);cumulative.append(broken)
    events=[]
    for part in range(math.ceil(summary['seconds']*4)):
        start=part/4;end=min(summary['seconds'],start+.25);i=min(len(frames)-1,int(start*60));row=frames[i]
        top=(f"CONNECTED CLUSTERS | Same color = same rigid group | White = projectile"
            rf"\NProjectile {summary['projectile_mass_kg']:g} kg | {summary['chunks']} chunks / {summary['bonds']} bonds | t = {start:.2f} s"
            rf"\N{row['logical_clusters']} connected groups | {cumulative[i]} broken bonds | correction {row['resim_passes']}/1")
        groups='Colors stay with stable cluster identity; splitting creates new group colors.'
        if history:
            sample=history[max(k for k in history if k<=i)]
            supported=sum(n for n,s in sample.values() if s);detached=sum(n for n,s in sample.values() if not s)
            assert sum(n for n,s in sample.values())==summary['chunks']
            groups=f'{supported} chunks connected to support | {detached} detached chunks'
        bottom=(groups+rf"\NSimulation ms: avg {summary['physics_ms_mean']:.2f} | min {summary['physics_ms_min']:.2f} | max {summary['physics_ms_max']:.2f}"
            rf"\NOffline playback; observation/render/encoding excluded. Material/solver settings unchanged.")
        for style,text in [('Top',top),('Bottom',bottom)]:events.append(f'Dialogue: 0,{stamp(start)},{stamp(end)},{style},,0,0,0,,{text}\n')
    with tempfile.TemporaryDirectory(prefix='native-cluster-labels-') as work:
        (Path(work)/'labels.ass').write_text(header+''.join(events))
        subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-n','-i',str(args.video.resolve()),'-vf','ass=labels.ass','-c:v','libx264','-preset','veryfast','-crf','19','-pix_fmt','yuv420p',str(args.output.resolve())],cwd=work,check=True)


if __name__=='__main__':main()
