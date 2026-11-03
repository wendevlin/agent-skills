#!/usr/bin/env bash
# Kollisions-/Spieltest: rendert einen OpenSCAD-Ausdruck mit CGAL und sagt, ob er leer ist.
# check.sh <file.scad> '<openscad code>'      (die Datei wird per include geladen, part="none")
# Beispiel: check.sh model.scad 'intersection(){ a(); translate([0,-10,0]) b(); }'
# Ausgabe: EMPTY (keine Überschneidung) oder SOLID (Überschneidung). Nullvolumen-Berührung zählt als EMPTY.
set -e
scad=$(readlink -f "$1"); expr=$2
tmp=$(mktemp -d); trap 'rm -rf $tmp' EXIT
printf 'include <%s>\npart="none";\n%s\n' "$scad" "$expr" > $tmp/c.scad
log=$(openscad -o $tmp/c.stl $tmp/c.scad 2>&1 || true)
if echo "$log" | grep -q "top level object is empty"; then echo EMPTY; exit 0; fi
if echo "$log" | grep -q "ERROR"; then echo "$log" | grep ERROR; exit 2; fi
python3 - "$tmp/c.stl" <<'PY'
import sys, numpy as np
v=[[float(x) for x in l.split()[1:]] for l in open(sys.argv[1]) if l.strip().startswith('vertex')]
if not v: print("EMPTY"); sys.exit()
t=np.array(v).reshape(-1,3,3)
vol=abs(np.einsum('ij,ij->i',t[:,0],np.cross(t[:,1],t[:,2])).sum()/6)
print("EMPTY" if vol < 1e-3 else "SOLID (%.2f mm³)" % vol)
PY
