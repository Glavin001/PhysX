#!/usr/bin/env python3
"""Re-time a recorded demo video to real time: each tick's frame is held for max(1/60 s, its physics step time),
so heavy ticks slow the playback exactly as a game running this physics would. Stats overlay on the wall clock."""
import csv,os,shutil,subprocess,sys,tempfile
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

budget=1/60
tmp=tempfile.mkdtemp(prefix='rt-',dir=os.path.dirname(os.path.abspath(dst)))
subprocess.check_call(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',src,'-vsync','0',os.path.join(tmp,'f%05d.png')])
n=len([f for f in os.listdir(tmp) if f.endswith('.png')]); assert n>=len(rows)-1, (n,len(rows))
def ts(t): h=int(t//3600);m=int(t//60%60);s=t%60;return f"{h}:{m:02d}:{s:05.2f}"
concat=[];lines=["[Script Info]","ScriptType: v4.00+","PlayResX: 1920","PlayResY: 1080","","[V4+ Styles]",
 "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding",
 "Style: Stats,DejaVu Sans Mono,30,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,3,2,0,7,24,24,20,1",
 "Style: Slow,DejaVu Sans Mono,30,&H004040FF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,3,2,0,7,24,24,20,1",
 "Style: Title,DejaVu Sans,34,&H00FFFFFF,&H000000FF,&H00000000,&H80000000,1,0,0,0,100,100,0,0,3,2,0,3,24,24,24,1",
 "Style: Footer,DejaVu Sans,24,&H00DDDDDD,&H000000FF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,3,2,0,1,24,24,24,1",
 "","[Events]","Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"]
wall=0.0;window=[];cumb=0;over=0;held=[]
for i,r in enumerate(rows[:n]):
    ms=float(r['physics_step_ms']);d=max(budget,ms/1000);window.append(ms);window=window[-60:]
    cumb+=int(float(r.get('bonds_broken',0) or 0));slow=ms/1000>budget;over+=slow;held.append(d);held=held[-120:];f05,f10=fps_windows(held,0)
    avg=sum(window)/len(window);mx=max(window);speed=budget/d
    stress=float(r.get('stress_solve_ms',0) or 0);corr=r.get('resim_passes','0')
    concat.append(f"file '{os.path.join(tmp,f'f{i+1:05d}.png')}'\nduration {d:.6f}")
    txt=(f"wall {wall:6.2f}s   sim {float(r['simulation_seconds']):6.2f}s   tick {i:4d}   playback x{speed:4.2f}\\N"
         f"FPS {f05:4.1f} (0.5 s avg)   {f10:4.1f} (1 s avg)\\N"
         f"physics {ms:6.2f} ms   (1 s avg {avg:5.2f}, max {mx:5.1f})   frame held {d*1000:5.1f} ms\\N"
         f"stress solve {stress:5.2f} ms   corrected pass {'yes' if corr not in ('0','') else 'no '}\\N"
         f"awake bodies {r.get('awake_bodies','?')}   bonds broken {cumb} (+{r.get('bonds_broken','?')})   contacts {r.get('contacts_frame','?')}\\N"
         f"60 Hz budget 16.7 ms  {'OVER - slowed' if slow else 'ok'}   ticks over budget so far {over}")
    lines.append(f"Dialogue: 0,{ts(wall)},{ts(wall+d)},{'Slow' if slow else 'Stats'},,0,0,0,,{txt}")
    wall+=d
concat.append(f"file '{os.path.join(tmp,f'f{n:05d}.png')}'")
lines.append(f"Dialogue: 0,{ts(0)},{ts(wall)},Title,,0,0,0,,{title}")
if footer: lines.append(f"Dialogue: 0,{ts(0)},{ts(wall)},Footer,,0,0,0,,{footer}")
lst=os.path.join(tmp,'list.txt');open(lst,'w').write('\n'.join(concat)+'\n')
ass=dst+'.ass';open(ass,'w').write('\n'.join(lines)+'\n')
subprocess.check_call(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',lst,'-vf',f"ass={ass}:fontsdir=/usr/share/fonts/truetype/dejavu",'-vsync','cfr','-r','60','-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p',dst])
shutil.rmtree(tmp)
print(f"wrote {dst}: sim {rows[n-1]['simulation_seconds']} s -> wall {wall:.2f} s, ticks over budget {over}/{n}")
