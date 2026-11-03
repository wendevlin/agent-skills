#!/usr/bin/env python3
"""Druckbarkeits-Check für eine STL in DRUCKAUSRICHTUNG (z = nach oben, Bett bei z=min).

Voxelisiert das Teil und meldet:
  - Höhe, Bettauflage (mm²) und Verhältnis Höhe/√Auflage (> ~2.5: kippt/löst sich leicht)
  - jede Schicht mit Material ohne Stütze darunter (auch nicht diagonal 45°):
    das sind Brücken, waagrechte Überhänge ODER schwebende Inseln.
    Pro Fund: z-Höhe, Fläche, kürzeste Spannweite (≈ Brückenlänge) und ob es eine Insel ist.

python3 printcheck.py teil.stl [--cell 0.4]
Das ist eine GROBE Vorprüfung (Voxel, 0.4 mm), kein Slicer. Sie findet die typischen Fehler früh,
aber sie entscheidet NICHT, ob Support nötig ist – das entscheiden Slicer-Vorschau und Testdruck.
Empfehlungen, die das Skript ausgibt:
  INSEL                       -> Support nötig (oder anders ausrichten)
  Brücke > 10 mm              -> Support empfehlen (sonst hängende Fäden), oder bewusst akzeptieren
  Brücke über Funktionsfläche -> Support (Fäden in Nut/Tasche/Gleitfläche stören die Passung)
"""
import sys, argparse, numpy as np

def load(f):
    raw=open(f,'rb').read()
    if raw[:5]==b'solid' and b'facet' in raw[:300]:
        v=[[float(x) for x in l.split()[1:]] for l in raw.decode(errors='ignore').splitlines() if l.strip().startswith('vertex')]
        return np.array(v).reshape(-1,3,3)
    import struct
    n=struct.unpack('<I',raw[80:84])[0]
    a=np.frombuffer(raw[84:84+n*50],dtype=np.dtype([('n','<3f4'),('v','<9f4'),('a','<u2')]))
    return a['v'].reshape(-1,3,3).astype(float)

def voxelize(t, c):
    lo=t.reshape(-1,3).min(0); hi=t.reshape(-1,3).max(0)
    t=t-lo; size=hi-lo
    nx,ny,nz=(np.ceil(size/c).astype(int)+1)
    xs=(np.arange(nx)+0.5)*c; ys=(np.arange(ny)+0.5)*c
    hits=[[[] for _ in range(ny)] for _ in range(nx)]
    for tri in t:
        a,b,d=tri
        x0,x1=min(a[0],b[0],d[0]),max(a[0],b[0],d[0]); y0,y1=min(a[1],b[1],d[1]),max(a[1],b[1],d[1])
        i0,i1=int(np.ceil(x0/c-0.5)),int(np.floor(x1/c-0.5)); j0,j1=int(np.ceil(y0/c-0.5)),int(np.floor(y1/c-0.5))
        if i1<i0 or j1<j0: continue
        den=(b[1]-d[1])*(a[0]-d[0])+(d[0]-b[0])*(a[1]-d[1])
        if abs(den)<1e-12: continue
        for i in range(max(i0,0),min(i1,nx-1)+1):
            px=xs[i]
            for j in range(max(j0,0),min(j1,ny-1)+1):
                py=ys[j]
                l1=((b[1]-d[1])*(px-d[0])+(d[0]-b[0])*(py-d[1]))/den
                l2=((d[1]-a[1])*(px-d[0])+(a[0]-d[0])*(py-d[1]))/den
                l3=1-l1-l2
                if l1>=-1e-9 and l2>=-1e-9 and l3>=-1e-9:
                    hits[i][j].append(l1*a[2]+l2*b[2]+l3*d[2])
    vox=np.zeros((nx,ny,nz),bool); zc=(np.arange(nz)+0.5)*c
    for i in range(nx):
        for j in range(ny):
            h=sorted(set(np.round(hits[i][j],6)))
            for k in range(0,len(h)-1,2):
                vox[i,j,(zc>h[k])&(zc<h[k+1])]=True
    return vox, size

def label2d(m):
    lab=np.zeros(m.shape,int); n=0
    for idx in zip(*np.nonzero(m)):
        if lab[idx]: continue
        n+=1; st=[idx]; lab[idx]=n
        while st:
            i,j=st.pop()
            for di,dj in ((1,0),(-1,0),(0,1),(0,-1)):
                a,b=i+di,j+dj
                if 0<=a<m.shape[0] and 0<=b<m.shape[1] and m[a,b] and not lab[a,b]:
                    lab[a,b]=n; st.append((a,b))
    return lab,n

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('stl'); ap.add_argument('--cell',type=float,default=0.4)
    a=ap.parse_args(); c=a.cell
    t=load(a.stl); vox,size=voxelize(t,c)
    base=vox[:,:,0].sum()*c*c
    print(f"{a.stl}: {size[0]:.1f} x {size[1]:.1f} x {size[2]:.1f} mm | Auflage ≈ {base:.0f} mm² | H/√A = {size[2]/max(np.sqrt(base),1e-6):.2f}")
    if size[2]/max(np.sqrt(base),1e-6) > 2.5: print("  ! hoch und schmal: Gefahr dass es sich löst/umfällt -> anders legen oder Brim")
    rows={}   # (z, kind) -> [anzahl, fläche, max spannweite]
    for k in range(1,vox.shape[2]):
        below=vox[:,:,k-1]
        sup=below.copy()                                   # direkt oder diagonal (45°) gestützt
        sup[1:,:]|=below[:-1,:]; sup[:-1,:]|=below[1:,:]; sup[:,1:]|=below[:,:-1]; sup[:,:-1]|=below[:,1:]
        un=vox[:,:,k]&~sup
        if not un.any(): continue
        lab,n=label2d(un); llab,_=label2d(vox[:,:,k])
        for r in range(1,n+1):
            m=lab==r; area=m.sum()*c*c
            ii,jj=np.nonzero(m); span=min(np.ptp(ii)+1,np.ptp(jj)+1)*c
            comp=llab[m][0]; island=not below[llab==comp].any()
            if not island and span <= 2*c: continue        # Rauschen an Schrägen
            key=(round(k*c,1),"INSEL – braucht Support" if island else "Brücke/Überhang")
            e=rows.setdefault(key,[0,0.0,0.0]); e[0]+=1; e[1]+=area; e[2]=max(e[2],span)
    if not rows:
        print("  keine ungestützten Stellen gefunden (grob). Trotzdem Slicer-Vorschau prüfen."); return
    need=False
    for (z,kind),(cnt,area,span) in sorted(rows.items()):
        rec=""
        if "INSEL" in kind: rec="-> SUPPORT NÖTIG"; need=True
        elif span>10: rec="-> Support empfohlen (lange Brücke)"; need=True
        elif span>2: rec="-> Brücke; liegt sie in einer Nut/Gleitfläche: Support"
        print(f"  z={z:5.1f} mm  {kind:24s} {cnt:3d}x  Fläche {area:6.1f} mm²  Spannweite ≈ {span:4.1f} mm  {rec}")
    print("  => " + ("Support verwenden (siehe oben) – Einstellungen siehe SKILL.md 'Supports'" if need
                     else "kurze Brücken – meist ohne Support ok; bei Fäden an Funktionsflächen Support einschalten"))

if __name__=='__main__': main()
