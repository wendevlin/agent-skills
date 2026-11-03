#!/usr/bin/env python3
"""Interaktive 3D-Ansicht (three.js, eine HTML-Datei) aus STL-Teilen bauen – zum Veröffentlichen als Artifact.

python3 build_viewer.py out.html "Titel" "Untertitel" teil.stl:#3b82c4[:dx,dy,dz] ...
  Farbe pro Teil, optional Explosions-Richtung (mm bei 100 %).
  Koordinaten wie im Modell: Y nach oben (OpenSCAD-Teile ggf. vorher mit rotate([90,0,0]) exportieren
  oder Z-oben-Modelle mit --zup drehen lassen).
"""
import sys, os, json, base64, struct, argparse
sys.path.insert(0, os.path.dirname(__file__))
from make3mf import load
ap=argparse.ArgumentParser(); ap.add_argument('out'); ap.add_argument('title'); ap.add_argument('subtitle')
ap.add_argument('parts',nargs='+'); ap.add_argument('--zup',action='store_true')
a=ap.parse_args()
parts=[]
for spec in a.parts:
    bits=spec.split(':'); path=bits[0]; color=bits[1] if len(bits)>1 else '#3b82c4'
    ex=[float(v) for v in bits[2].split(',')] if len(bits)>2 else [0,0,0]
    t=load(path).reshape(-1,3)
    if a.zup: t=t[:,[0,2,1]]*[1,1,-1]
    parts.append({'name':os.path.splitext(os.path.basename(path))[0],'color':color,'explode':ex,
                  'data':base64.b64encode(struct.pack('<%df'%t.size,*t.ravel())).decode()})
tpl=open(os.path.join(os.path.dirname(__file__),'..','viewer','template.html')).read()
html=tpl.replace('__TITLE__',a.title).replace('__SUBTITLE__',a.subtitle).replace('__PARTS__',json.dumps(parts))
open(a.out,'w').write(html); print(a.out, len(html)//1024, 'KB')
