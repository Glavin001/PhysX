#!/usr/bin/env python3
"""Burn per-frame perf stats from native.frames.csv into a demo video (ASS subtitles)."""
import csv,subprocess,sys
src,frames,dst,title=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4];footer=sys.argv[5] if len(sys.argv)>5 else ""
rows=list(csv.DictReader(open(frames)))

def fps_windows(held, wall_secs):
    """held: list of frame hold times (s) in order; returns (fps over last 0.5 s, fps over last 1 s)."""
    def over(w):
        t=0.0;n=0
        for d in reversed(held):
            t+=d;n+=1
            if t>=w: break
        return min(60.0, n/t) if t>0 else 60.0
    return over(0.5), over(1.0)

fps=60.0
def ts(t): h=int(t//3600);m=int(t//60%60);s=t%60;return f"{h}:{m:02d}:{s:05.2f}"
lines=["[Script Info]","ScriptType: v4.00+","PlayResX: 1920","PlayResY: 1080","","[V4+ Styles]",
 "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding",
 "Style: Stats,DejaVu Sans Mono,30,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,3,2,0,7,24,24,20,1",
 "Style: Title,DejaVu Sans,34,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,3,2,0,3,24,24,24,1",
 "Style: Footer,DejaVu Sans,24,&H00DDDDDD,&H000000FF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,3,2,0,1,24,24,24,1",
 "","[Events]","Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"]
window=[];cum=0;cumb=0;held=[]
for i,r in enumerate(rows):
    ms=float(r['physics_step_ms']);window.append(ms);window=window[-60:];held.append(max(1/60,ms/1000));held=held[-120:];f05,f10=fps_windows(held,0);cumb+=int(float(r.get('bonds_broken',0) or 0))
    avg=sum(window)/len(window);mx=max(window)
    awake=r.get('awake_bodies','?');bonds=r.get('bonds_broken','?');contacts=r.get('contacts_frame',r.get('contacts_total','?'))
    corr=r.get('resim_passes','0');stress=float(r.get('stress_solve_ms',0) or 0)
    t0=i/fps;t1=(i+1)/fps
    txt=(f"tick {i:4d}   t={float(r['simulation_seconds']):5.2f}s\\N"
         f"FPS {f05:4.1f} (0.5 s avg)   {f10:4.1f} (1 s avg)   as a game would run it: frame = max(16.7 ms, tick)\\N"
         f"physics {ms:6.2f} ms   (1 s avg {avg:5.2f}, max {mx:5.1f})\\N"
         f"stress solve {stress:5.2f} ms   corrected pass {'yes' if corr not in ('0','') else 'no '}\\N"
         f"awake bodies {awake}   bonds broken {cumb} (+{bonds})   contacts {contacts}\\N"
         f"60 Hz budget 16.7 ms  {'OVER' if ms>16.67 else 'ok'}")
    lines.append(f"Dialogue: 0,{ts(t0)},{ts(t1)},Stats,,0,0,0,,{txt}")
lines.append(f"Dialogue: 0,{ts(0)},{ts(len(rows)/fps)},Title,,0,0,0,,{title}")
if footer: lines.append(f"Dialogue: 0,{ts(0)},{ts(len(rows)/fps)},Footer,,0,0,0,,{footer}")
ass=dst+'.ass';open(ass,'w').write('\n'.join(lines)+'\n')
subprocess.check_call(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',src,'-vf',f"ass={ass}:fontsdir=/usr/share/fonts/truetype/dejavu",'-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p',dst])
print("wrote",dst)
