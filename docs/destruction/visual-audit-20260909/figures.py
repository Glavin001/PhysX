"""Small deterministic SVG + PNG drawing helpers for the standalone audit."""
from pathlib import Path
from html import escape
import math
from PIL import Image, ImageDraw, ImageFont
COLORS={'keep':'#147D64','opt':'#AD6800','replace':'#B84042','unknown':'#66778B','gpu':'#356EC9','ink':'#182A3A','muted':'#526477','bg':'#F6F8FB'}
FONT=Path('/usr/share/fonts/truetype/dejavu')
class Figure:
 def __init__(self,title,subtitle,height=800,width=1440):
  self.w,self.h=width,height;self.image=Image.new('RGB',(width,height),'white');self.draw=ImageDraw.Draw(self.image)
  self.svg=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}" role="img"><title>{escape(title)}</title><desc>{escape(subtitle)}</desc><rect width="100%" height="100%" fill="white"/>']
  self.text(36,24,title,30,bold=True);self.text(36,68,subtitle,17,color=COLORS['muted'])
 def text(self,x,y,text,size=19,color=None,bold=False):
  color=color or COLORS['ink'];font=ImageFont.truetype(str(FONT/('DejaVuSans-Bold.ttf' if bold else 'DejaVuSans.ttf')),size)
  self.draw.text((x,y),str(text),fill=color,font=font)
  self.svg.append(f'<text x="{x}" y="{y+size}" font-family="DejaVu Sans,sans-serif" font-size="{size}" font-weight="{700 if bold else 400}" fill="{color}">{escape(str(text))}</text>')
 def rect(self,x,y,w,h,fill,stroke=None):
  if w<=0 or h<=0:return
  self.draw.rectangle((x,y,x+w,y+h),fill=fill,outline=stroke)
  self.svg.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{fill}" stroke="{stroke or fill}"/>')
 def line(self,points,color=None,width=2):
  color=color or COLORS['muted'];self.draw.line(points,fill=color,width=width)
  self.svg.append(f'<polyline points="{" ".join(f"{x},{y}" for x,y in points)}" fill="none" stroke="{color}" stroke-width="{width}"/>')
 def arrow(self,points,color=None):
  color=color or COLORS['muted'];self.line(points,color,3);x,y=points[-1];u,v=points[-2];a=math.atan2(y-v,x-u)
  self.line([(x-10*math.cos(a-.45),y-10*math.sin(a-.45)),(x,y),(x-10*math.cos(a+.45),y-10*math.sin(a+.45))],color,3)
 def box(self,x,y,w,h,title,lines,status='keep'):
  self.rect(x,y,w,h,COLORS['bg']);self.rect(x,y,7,h,COLORS[status]);self.text(x+18,y+12,title,21,bold=True)
  for i,s in enumerate(lines):self.text(x+18,y+47+25*i,s,17)
 def save(self,directory,name):
  directory=Path(directory);directory.mkdir(parents=True,exist_ok=True)
  (directory/(name+'.svg')).write_text('\n'.join(self.svg+['</svg>']))
  self.image.save(directory/(name+'.png'),optimize=True)
