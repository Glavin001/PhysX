"""Compare current reverse actor scans with earliest-owner indexed retirement.
This models only actor-array replacement and release order, not PhysX behavior.
"""
from collections import defaultdict
from pathlib import Path
import argparse,hashlib,itertools,json,random,time
class World:
 def __init__(self,owners,pairs):
  self.owners=owners;self.pairs=pairs;self.arrays=defaultdict(list);self.positions={};self.live=set(range(len(pairs)));self.events=[];self.visits=0
  for i,(a,b,element) in enumerate(pairs):
   for actor in (owners[a],owners[b]):
    self.positions[(i,actor)]=len(self.arrays[actor]);self.arrays[actor].append(i)
 def release(self,pair,shape):
  assert pair in self.live
  a,b,element=self.pairs[pair];assert element and shape in (a,b)
  self.events.append((shape,pair))
  for actor in (self.owners[a],self.owners[b]):
   array=self.arrays[actor];index=self.positions.pop((pair,actor));assert array[index]==pair
   last=array.pop()
   if index<len(array):array[index]=last;self.positions[(last,actor)]=index
  self.live.remove(pair)
 def regular(self,bindings):
  for shape in bindings:
   actor=self.owners[shape];index=len(self.arrays[actor])
   while index:
    index-=1;pair=self.arrays[actor][index];self.visits+=1;a,b,element=self.pairs[pair]
    if element and shape in (a,b):self.release(pair,shape)
 def indexed(self,bindings):
  binding={shape:i for i,shape in enumerate(bindings)};lists=[[] for _ in bindings]
  # Build only after all scheduler/type changes, before any shape migration.
  for actor in dict.fromkeys(self.owners[s] for s in bindings):
   for pair in self.arrays[actor]:
    self.visits+=1;a,b,element=self.pairs[pair]
    if not element:continue
    first=min(binding.get(a,len(bindings)),binding.get(b,len(bindings)))
    if first<len(bindings) and self.owners[bindings[first]]==actor:lists[first].append(pair)
  for shape,selected in zip(bindings,lists):
   actor=self.owners[shape]
   # Earlier bindings mutate array indices via replace-with-last. Sort NOW.
   selected.sort(key=lambda pair:self.positions[(pair,actor)],reverse=True)
   for pair in selected:self.release(pair,shape)
  return sum(map(len,lists))
def check(name,owners,pairs,bindings):
 assert len(set(bindings))==len(bindings)
 assert all(owners[a]!=owners[b] for a,b,_ in pairs)
 a=World(owners,pairs);b=World(owners,pairs);a.regular(bindings);selected=b.indexed(bindings)
 assert a.events==b.events,(name,'release order',a.events,b.events)
 assert a.live==b.live and dict(a.arrays)==dict(b.arrays) and a.positions==b.positions,(name,'final arrays')
 return dict(case=name,shapes=len(owners),pairs=len(pairs),bindings=len(bindings),retired=selected,original_visits=a.visits,index_visits=b.visits)
def main():
 parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('output',type=Path);args=parser.parse_args()
 start=time.monotonic();rows=[];rng=random.Random(260912)
 # Exhaustive binding subsets/orders on mixed element/constraint interactions.
 owners=[0,0,1,1,2,2];pairs=[(0,2,True),(0,3,True),(1,2,False),(1,4,True),(2,4,True),(3,5,True),(1,5,True)]
 for length in range(7):
  for binds in itertools.permutations(range(6),length):rows.append(check('exhaustive-six',owners,pairs,binds))
 for i in range(1000):
  actors=rng.randrange(2,15);owners=[rng.randrange(actors) for _ in range(rng.randrange(2,90))]
  possible=[(a,b) for a in range(len(owners)) for b in range(a+1,len(owners)) if owners[a]!=owners[b]]
  chosen=rng.sample(possible,min(len(possible),rng.randrange(0,400)));pairs=[(a,b,rng.randrange(8)!=0) for a,b in chosen]
  rng.shuffle(pairs);bindings=rng.sample(range(len(owners)),rng.randrange(len(owners)+1));rows.append(check('random-'+str(i),owners,pairs,bindings))
 # Compound wall contacts distributed across many shapes, two-sided migration.
 owners=[0]*200+list(range(1,101));pairs=[(a,200+b,True) for a in range(200) for b in range(100) if (a+b)%17==0]
 for binds in [list(range(200)),list(reversed(range(200))),list(range(0,300,2)),rng.sample(range(300),300)]:rows.append(check('compound-wall',owners,pairs,binds))
 report={'status':'release_order_model_passed','scope':'Pure host model only: exact release sequence and remaining actor arrays under unregister/replace-with-last. Not a native physical, sanitizer, benchmark or runtime qualification. No GPU work.','cases':len(rows),'seconds':time.monotonic()-start,'invariants':['each pair assigned once to earliest migrating endpoint','sort by CURRENT actor-array index immediately before each binding','build after scheduler changes, before migration','no interaction creation or unrelated pair deletion during migration'],'compound_cases':rows[-4:],'all_results':rows,'source_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()}
 p=args.output;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps({k:report[k] for k in ['status','cases','seconds','compound_cases']}))
if __name__=='__main__':main()
