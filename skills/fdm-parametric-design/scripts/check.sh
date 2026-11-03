#!/usr/bin/env bash
# Clash/clearance test: renders an OpenSCAD expression with CGAL and reports whether it is empty.
# check.sh <file.scad> '<openscad code>'   (the file is included with part="none";
#   its dispatch must draw nothing for unknown part values)
# Example: check.sh model.scad 'intersection(){ a(); translate([0,-10,0]) b(); }'
# Output: EMPTY (no overlap) or SOLID (overlap). Touching faces (zero volume) count as EMPTY.
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
