#!/usr/bin/env bash
# PNG-Vorschau mit Farben (OpenSCAD-Preview, headless).
# render.sh <file.scad> <out.png> <eye_x,eye_y,eye_z,center_x,center_y,center_z> [extra openscad args, z.B. -D 'part="wall"']
set -e
scad=$1; out=$2; cam=$3; shift 3
xvfb-run -a openscad "$@" --camera="$cam" --viewall --autocenter --imgsize=1400,1100 \
  --colorscheme=Tomorrow -o "$out" "$scad" >/dev/null 2>&1
echo "$out"
