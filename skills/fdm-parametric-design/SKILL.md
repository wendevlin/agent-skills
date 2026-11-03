---
name: fdm-parametric-design
description: Design functional 3D-printable (FDM) parts as parametric OpenSCAD models in the cloud container - holders, mounts, organizers, brackets, slide-together or stackable modular systems, pegboard/SKADIS/Gridfinity adapters - and deliver print-ready 3MF/STL with concrete slicer settings (including supports), screenshots, an interactive 3D viewer and a MakerWorld/Printables publishing package. Use when the user wants something to 3D print, a holder or mount for a device, a Bambu Studio file, or to publish a model.
---

# Parametric FDM design (OpenSCAD)

Distilled from a real project (a modular wall mount for Framework laptop expansion cards) that
took nine versions and several failed prints. Most failures came from three things:

- avoiding supports out of principle
- fits that were too tight
- claiming something was printable without a test print

The rules below exist to stop those.

## 0. Setup (once per session)

```bash
bash scripts/setup.sh          # openscad + xvfb + numpy (≈1 min if not in the environment's setup script)
```

- Scripts live next to this file (the skill folder, e.g. `~/.claude/skills/fdm-parametric-design/`; run them with that path): `render.sh`, `check.sh`, `printcheck.py`, `make3mf.py`,
  `build_viewer.py`.
- `examples/` holds a finished project and a fit test coupon.
- Work in the scratchpad. Keep every version (`v1/`, `v2/` …) so you can go back.
- Keep a short changelog per version, listing what changed **per part**. The user always asks
  "what do I have to reprint?"

## 1. Before modelling

- **Real dimensions from the source.** Use official CAD or drawings first (clone the repo, read the
  numbers), then community measurements. List which numbers are unverified and ask the user to
  measure those. Credit the source and its license.
- **Orientation-ambiguous objects** (which side is up? where is the plug?): ask the user, or make the
  holder work both ways. A plug recess at the "wrong" height made a card fit only upside down.
- **Existing models:** search Printables, MakerWorld and Thingiverse. Tell the user honestly what
  already exists.
- **Ask about printer, material and bed** (e.g. Bambu + wood PLA + smooth PEI). Filled or wood PLA
  strings more and needs more clearance than plain PLA.
- Ask only what changes the design. For everything else, pick a default and say which.

## 2. Orientation and supports (decide per part, before drawing)

Choose each part's print orientation by **function first, then printability**:

1. **Functional surfaces** (sliding faces, fits, visible front) should come out clean: on the
   bed, or vertical walls.
2. **Strength:** layer lines must not run along the main load (a hook or rail loaded in shear across
   layers snaps).
3. **Bed contact:** height / √(contact area) must stay below ~2.5, or the part detaches or the
   nozzle knocks it over. A recess in the bed face reduces the contact. Check it.
4. **Then** decide supports.

**Supports are a normal tool, not a failure.** Do not optimise them away at the cost of function.
Use supports when:

- a feature starts in mid-air (an island, e.g. a dovetail printed sideways)
- a bridge is longer than ~10 mm
- **any** bridge or overhang lies on a functional surface (grooves, rails, pockets, sliding faces).
  Bridge sag and strings there block the fit. Supported, it comes out clean.

Design *for* supports:

- Leave room to reach in and remove them: open ends, no closed channels.
- Put support-contact faces where a slightly rough surface doesn't matter.
- Use a 0.2 mm Z-gap (it breaks off cleanly).

Give the user **concrete slicer settings** (Bambu Studio / Orca naming):

- Support: on, Type: **tree (auto)**, threshold angle **30°**
- Top Z distance **0.2 mm**, interface layers **2**, interface pattern rectilinear
- "On build plate only" **off** when grooves, pockets or rails need support
- Supports only in a few places: tell them to use **paint-on supports** or support blockers, and
  say exactly where
- Plain 3MF files cannot carry slicer settings. Write them out, and ask the user to check the
  **support preview** in the slicer before printing.

**Never tell the user "no supports needed" as a fact.** `printcheck.py` is a coarse pre-check. The
slicer preview and the test print decide. If unsure, recommend supports and say why.

## 3. Design rules (FDM, 0.4 mm nozzle)

| Feature | Rule |
| --- | --- |
| Overhangs | ≤ 45° from vertical **and starting from material below**. A 45° face whose lowest point hangs in the air is an island and needs support. |
| Sliding fit | Start with **0.4 mm per side** (perpendicular to the surface, `offset(delta=±fit/2)` on the 2D profile). 0.1–0.2 mm only goes together by force and never comes apart. **Calibrate with the fit coupon** before the real part. |
| Loose fit (drop-in parts) | 0.5 mm per side plus a 0.8 mm lead-in chamfer. |
| Detents / snap bumps | Avoid unless verified on a coupon. An untested bump plus a tight fit jammed. Prefer geometry: gravity plus a slope, a hard stop, a closed groove end. |
| Dovetails / rails | 45° flanks. Half dovetails (one 45° flank plus one straight outer side, two mirrored) fit on thin walls. Rail and plate thickness: generous (rail ≥ 3 mm high, plate ≥ 5 mm, walls beside it ≥ 3 mm). Users notice "why is this so thin". |
| Walls | ≥ 1.2 mm next to grooves, ≥ 2 mm elsewhere. Put material where the load is. |
| Screws | Countersunk 3.5 mm: hole 3.9, head 7.2, 90°. Hidden behind a part that slides over the plate. |
| Pegboard (IKEA SKÅDIS) | Slots 5 × 15 mm, 40 mm grid with rows offset 20/20, board 5 mm. Hooks 4.6 mm wide. **Print one hook and test it on the board** before publishing. |
| Visible edges | Round a little (r ≈ 1.5). Keep wall-side and mating edges square. |

Patterns that worked:

- **Sloped bodies** (e.g. 15° so items slide back): shear the whole body with
  `multmatrix([[1,0,0,0],[0,1,tan(a),0],[0,0,1,0]])` so stacked interfaces stay flat. Place the items
  with a real rotation. Make "open upwards" cuts vertical in world space (hull with a translated
  copy), never in the rotated frame.
- **Open-top pockets** where the next stacked part forms the ceiling: no long bridge at all.
- **Modular systems:** identical modules wherever possible. A special variant only where geometry
  forces it, and say clearly which module can't go where. Think through the assembly order ("slides
  in from the back" = assemble on the table, then hang).

## 4. Model structure

One `.scad` in OpenSCAD-Customizer syntax (MakerWorld turns it into a "Customize" button):

```scad
/* [Print set] */  part = "print_set"; // [print_set:Print set, wall:Preview, ...]
/* [Fit] */        // Clearance per side for sliding joints
                   fit = 0.4;
/* [Hidden] */     $fn = 48;
```

- Every number is a named parameter with a one-line comment above it.
- `part="print_set"` lays out every part in print orientation on a 256 mm bed. Add preview parts
  (`wall`, `wall_explode`) with coloured dummy contents.
- **The dispatch must draw nothing for unknown `part` values.** Use `if (part=="a") … else if …`,
  never `if (part != "x")`. `check.sh` sets `part="none"`.
- Put the coordinate convention in the header.

## 5. Verify before showing anything

Clash and clearance (`check.sh` uses volume, so touching faces count as EMPTY):

```bash
scripts/check.sh model.scad 'intersection(){ a(); translate([0,-h,0]) b(); }'
```

For every mating pair, run three checks:

1. Assembled: EMPTY.
2. Shifted by less than the fit: EMPTY. This proves the clearance.
3. Shifted past it, or along the escape direction: SOLID. This proves it locks, hangs or stops.

Also check the contents (card, device) against their part and against the part above.

Printability, per part, exported in print orientation:

```bash
python3 scripts/printcheck.py part_oriented.stl
```

It reports contact area, H/√A, islands and bridges, with a support recommendation each. Treat its
"ok" as "probably ok". Report what you checked and what only the slicer or a print can confirm.

## 6. Test small, then iterate

- **Fit coupon first** (`examples/fit_coupon.scad`). Copy the real joint profile in. One 15-minute
  print tells which clearance (0.2–0.5) works on this printer and filament. Then set `fit`.
- **Test slices instead of full parts:** `intersection()` the part with a box around the joint, and
  print just that. Change one thing per test print when possible.
- **Screenshots after the first draft** (`render.sh`, SendUserFile): context view (on the wall or
  board), empty and with contents, exploded. Ask "am I on the right track?"
- **Interactive viewer** when the shape is hard to read or the user asks:
  `python3 scripts/build_viewer.py out.html "Name" "subtitle" part.stl:#hex:dx,dy,dz ... [--zup]`.
  Publish it as an Artifact (load artifact-design first), and republish the same file per version.
- **The user's test print is the ground truth.** Ask for a photo when something fails. If they push
  back, re-check honestly, say plainly where you were wrong, and change the approach. Don't defend
  an earlier claim or re-argue it.

## 7. Deliver

```bash
python3 scripts/make3mf.py set.3mf part1.stl:0,-1,0.27 part2.stl ... --stl-dir stl/
```

- `:nx,ny,nz` is the outward normal of the face that goes on the bed.
- The plain 3MF opens in Bambu Studio, Prusa and Orca with separate objects.

Always send it together with:

- the slicer settings (layer height, walls, infill, **supports: where and which settings**, brim
  for which part)
- what to print first (coupon or test slice)
- which parts changed since the last version

## 8. Publishing (MakerWorld / Printables)

Package contents:

- `3mf/`: one set per variant, each with one of every module type, so users duplicate what they need
- `stl/`: print-oriented
- the `.scad`: the Customize button
- `images/`: renders
- `MAKERWORLD.md`: title, summary, description (EN, optional DE), what to print, assembly, print
  settings **including supports**, credits, tags, license suggestion (CC BY 4.0 if the source is CC BY)

Tell the user what only they can do:

- take real print photos (required for print profiles; the cover should be a real photo)
- save a Bambu Studio project with their printer, filament and supports
- upload, and choose the license
- answer the AI-assistance question honestly
- **test-print every variant before publishing it**

## Reference

`examples/framework_modular_card_wall.scad` is the finished project. Reusable patterns:

- `shear()` for sloped bodies
- `half_dt()`, `dt_male()` and `dt_female()` for half dovetails closed at the front
- `rail()` and `plate_cut()` for a hidden wall plate with a stop
- `swept()` for open-top pockets
- `block()` for rounded edges
- `print_set()` for laying out every part in print orientation
- `skadis_hook()` for SKÅDIS hooks

`examples/fit_coupon.scad` is a clearance test coupon (0.2/0.3/0.4/0.5), verified with `check.sh`.
