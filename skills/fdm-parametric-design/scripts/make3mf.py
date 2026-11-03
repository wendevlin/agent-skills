#!/usr/bin/env python3
"""Rotate parts into print orientation and save them as one 3MF plate (separate objects) plus STLs.

python3 make3mf.py out.3mf teil.stl[:nx,ny,nz] ...  [--stl-dir DIR] [--bed 240]
  nx,ny,nz = OUTWARD normal (model coordinates) of the face that goes on the bed.
             Omit it to keep the orientation (only moved to z=0).
  Examples:   slot.stl:0,-1,0.268   (sheared bottom face down)
              plate.stl              (already oriented)
              lid.stl:0,1,-0.268     (top face down)
Plain 3MF: Bambu Studio / PrusaSlicer / Orca open it directly, each part stays a separate object.
Slicer settings (supports etc.) cannot be stored in it - write them out for the user.
"""
import sys, os, zipfile, argparse, numpy as np

def load(f):
    raw=open(f,'rb').read()
    if raw[:5]==b'solid' and b'facet' in raw[:300]:
        v=[[float(x) for x in l.split()[1:]] for l in raw.decode(errors='ignore').splitlines() if l.strip().startswith('vertex')]
        return np.array(v).reshape(-1,3,3)
    import struct
    n=struct.unpack('<I',raw[80:84])[0]
    a=np.frombuffer(raw[84:84+n*50],dtype=np.dtype([('n','<3f4'),('v','<9f4'),('a','<u2')]))
    return a['v'].reshape(-1,3,3).astype(float)

def rot_to(n, target=np.array([0,0,-1.0])):
    n=np.asarray(n,float); n/=np.linalg.norm(n); v=np.cross(n,target); c=n@target
    if np.linalg.norm(v)<1e-9: return np.eye(3) if c>0 else np.diag([1,-1,-1.0])
    vx=np.array([[0,-v[2],v[1]],[v[2],0,-v[0]],[-v[1],v[0],0]])
    return np.eye(3)+vx+vx@vx/(1+c)

def contact(t,tol=0.05):
    z0=t[:,:,2].min(); m=np.all(np.abs(t[:,:,2]-z0)<tol,axis=1); tt=t[m]
    return 0.5*np.abs(np.cross(tt[:,1]-tt[:,0],tt[:,2]-tt[:,0])[:,2]).sum()

def write_stl(t,path,name):
    with open(path,'w') as f:
        f.write(f'solid {name}\n')
        for tri in t:
            n=np.cross(tri[1]-tri[0],tri[2]-tri[0]); L=np.linalg.norm(n); n=n/L if L else n
            f.write(' facet normal %g %g %g\n  outer loop\n'%tuple(n)+''.join('   vertex %g %g %g\n'%tuple(p) for p in tri)+'  endloop\n endfacet\n')
        f.write(f'endsolid {name}\n')

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('out'); ap.add_argument('parts',nargs='+')
    ap.add_argument('--stl-dir'); ap.add_argument('--bed',type=float,default=240); ap.add_argument('--gap',type=float,default=8)
    a=ap.parse_args(); objs=[]; x=y=rowh=0
    for spec in a.parts:
        path,_,nrm=spec.partition(':'); name=os.path.splitext(os.path.basename(path))[0]
        t=load(path)
        if nrm: t=t@rot_to([float(v) for v in nrm.split(',')]).T
        t-=t.reshape(-1,3).min(0); sz=t.reshape(-1,3).max(0)
        if a.stl_dir: os.makedirs(a.stl_dir,exist_ok=True); write_stl(t,os.path.join(a.stl_dir,name+'.stl'),name)
        if x+sz[0]>a.bed: x=0; y+=rowh+a.gap; rowh=0
        objs.append((name,t+[x+8,y+8,0])); x+=sz[0]+a.gap; rowh=max(rowh,sz[1])
        print(f'  {name:20s} {sz[0]:6.1f} x {sz[1]:6.1f} x {sz[2]:6.1f} mm  bed contact {contact(t):6.0f} mm²')
    xml=['<?xml version="1.0" encoding="UTF-8"?>','<model unit="millimeter" xml:lang="en-US" xmlns="http://schemas.microsoft.com/3dmanufacturing/core/2015/02">','<resources>']
    for i,(name,t) in enumerate(objs,1):
        v=t.reshape(-1,3).round(4); uv,inv=np.unique(v,axis=0,return_inverse=True); f=inv.reshape(-1,3)
        f=f[(f[:,0]!=f[:,1])&(f[:,1]!=f[:,2])&(f[:,0]!=f[:,2])]
        xml.append(f'<object id="{i}" name="{name}" type="model"><mesh><vertices>')
        xml+=['<vertex x="%g" y="%g" z="%g"/>'%tuple(p) for p in uv]
        xml.append('</vertices><triangles>'); xml+=['<triangle v1="%d" v2="%d" v3="%d"/>'%tuple(q) for q in f]
        xml.append('</triangles></mesh></object>')
    xml.append('</resources><build>'); xml+=[f'<item objectid="{i}"/>' for i in range(1,len(objs)+1)]; xml.append('</build></model>')
    with zipfile.ZipFile(a.out,'w',zipfile.ZIP_DEFLATED) as z:
        z.writestr('[Content_Types].xml','<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/></Types>')
        z.writestr('_rels/.rels','<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Target="/3D/3dmodel.model" Id="rel0" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/></Relationships>')
        z.writestr('3D/3dmodel.model','\n'.join(xml))
    print(a.out)

if __name__=='__main__': main()
