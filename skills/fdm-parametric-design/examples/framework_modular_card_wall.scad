// Framework Expansion Card Wall Mount – modular, stackable (v0.9)
// Modulare Wandhalterung für Framework-Erweiterungskarten
//
// Parts / Teile:
//   plate         wall plate, 2x 3.5 mm countersunk screws, hidden behind the top slot
//   plate_skadis  alternative plate with 2 hooks for IKEA SKÅDIS pegboard
//   slot_std      slot for standard cards (USB-C, USB-A, HDMI, DP, microSD, storage ...)
//   slot_eth      deeper slot for the Ethernet card, front flush (cannot be the top slot)
//   lid / lid_skadis   cover on top of the column
//   base          cover at the bottom
//
// How it works:
//   - The top slot (always a standard slot) slides down onto the plate from above and
//     hangs on the rail stop. Every further slot slides in from BEHIND into the slot above
//     (half dovetails on the side walls, closed at the front). On the wall the wall itself
//     keeps them in place, so the column is assembled on the table and then hung up.
//   - Pockets are open at the top: the "ceiling" above a card is the floor of the slot above
//     (or the lid) -> no long bridges when printing.
//   - Everything is sheared by `tilt` degrees: pockets slope down towards the wall, so cards
//     slide back on their own. Cards sit loose, so pulling a card never pulls the slot.
//
// Print: slots lying on their bottom, lid upside down, plate flat on its back,
//        SKÅDIS plate on its side. No supports needed.
//
// Card dimensions from Framework ExpansionCards/Mechanical/OpenSCAD/ExpansionCard.scad (CC BY 4.0)
// Koordinaten: X = links/rechts, Y = oben/unten, Z = aus der Wand heraus (Z=0 an der Wand)

/* [Print set] */
// What to generate
part = "print_set"; // [print_set:Print set (all parts laid out), wall:Preview on the wall, wall_explode:Preview exploded, plate:Wall plate (screws), plate_skadis:SKADIS plate, slot_std:Standard slot, slot_eth:Ethernet slot, lid:Lid, base:Bottom cover]
// Wall mount type for the print set
mount = "screw"; // [screw:Screws (hidden plate), skadis:IKEA SKADIS pegboard]
// Number of standard slots in the print set
n_std = 1; // [1:12]
// Number of Ethernet slots in the print set
n_eth = 1; // [0:12]

/* [Card] */
// Card width
card_w   = 30.0;
// Card height (measured 6.65-7.0)
card_h   = 6.8;
// Card length without USB-C plug
card_d   = 32.0;

/* [Ethernet card] */
// Total length
eth_d        = 49.2;
// Height of the RJ45 part
eth_h        = 13.0;
// Length of the thick RJ45 part
eth_front_l  = 16.5;
// How far the RJ45 part extends below the card bottom
eth_below    = 1.5;

/* [Slot] */
// Slope towards the wall in degrees (cards slide back)
tilt       = 15;
// Clearance per side around the card (card sits loose)
clr        = 0.5;
// How far all cards stick out at the front
stick_out  = 4.0;
// Width of the USB-C plug recess (full pocket height, card fits both ways up)
plug_w     = 14.0;
// Depth of the USB-C plug recess
plug_d     = 8.0;
// Side wall thickness (carries the dovetails)
wall       = 4.5;
// Material between dovetail groove and pocket
floor_t    = 1.4;
// Minimum back wall of the Ethernet slot
back_eth   = 3.0;
// Chamfer at the pocket opening
lead_in    = 0.8;
// Radius of the visible outer edges
round_r    = 1.5;

/* [Fit] */
// Clearance per side for all sliding joints (increase if too tight)
fit        = 0.4;
// Dovetail height
dt_h       = 2.5;
// Dovetail width at the root (inner flank 45 deg)
dt_root    = 2.5;
// Distance dovetail to outer side
dt_out     = 1.5;
// Dovetail groove closed at the front (material left at the front)
front_stop = 3.0;

/* [Wall plate] */
// Plate thickness
plate_t     = 5.0;
// Clearance plate <-> recess
plate_clr   = 0.3;
// Rail width at the plate (45 deg flanks)
rail_bot    = 8.0;
// Rail width at the tip
rail_top    = 14.0;
// Rail height
rail_h      = 3.0;
// Stop above the rail
stop_t      = 2.0;
// Screw hole diameter
screw_d     = 3.9;
// Countersunk head diameter (3.5 mm screw)
screw_head  = 7.2;
// Screw distance from the centre
screw_x     = 11.5;
// Margin left/right of the plate inside the slot
margin      = 3.5;
// Lid / bottom cover: material above/below the joint
lid_t       = 1.5;

/* [SKADIS] */
// Pegboard thickness (IKEA: 5 mm)
skadis_board = 5.0;
// Extra clearance for the hooks
skadis_clr   = 0.5;
// Hook width (holes are 5 mm wide)
hook_w       = 4.6;
// Hook leg length behind the board
hook_leg     = 6.0;
// Height of the lower hook tab above the plate bottom
hook_y0      = 3.0;

/* [Hidden] */
$fn = 48;
e = 0.01;
// SKÅDIS-Raster: Löcher 5 x 15 mm, 40 mm Raster, versetzte Reihen um 20/20 mm
skadis_dx = 20;
skadis_dy = 20;

// ---------- abgeleitete Maße ----------
ta = tan(tilt); sa = sin(tilt); ca = cos(tilt);
pocket_w = card_w + 2*clr;
pocket_h = card_h + 2*clr;
eth_pocket_h = eth_h + 2*clr;
block_w  = pocket_w + 2*wall;
g_h      = dt_h + fit;                 // Tiefe der Nut
pocket_y0 = g_h + floor_t;             // Taschenboden
plate_w  = block_w - 2*margin;
dt_z0    = plate_t + plate_clr + 0.5;  // Federn beginnen hinter der Wandplatte

function ph(type) = type == "eth" ? eth_pocket_h : pocket_h;
function slot_h(type) = pocket_y0 + ph(type) / ca;     // Oberkante = Unterkante Slot darüber
function card_len(type) = type == "eth" ? eth_d : card_d;
function card_yl(type) = clr + (type == "eth" ? eth_below : 0);   // Kartenunterseite über Taschenboden

// Tiefe aller Teile: so dass hinter der Ethernet-Steckeraussparung back_eth bleibt
D = (eth_d + plug_d - stick_out) * ca + (eth_below + pocket_h) * sa + back_eth;
s_front = D / ca + stick_out;                         // Kartenfront entlang der Kartenachse
function card_s(type) = s_front - card_len(type);     // Kartenrückseite

plate_l = slot_h("std") - stop_t;

// ---------- Transformationen ----------
module shear() multmatrix([[1, 0, 0, 0], [0, 1, ta, 0], [0, 0, 1, 0]]) children();
module card_frame() translate([0, pocket_y0, 0]) rotate([-tilt, 0, 0]) children();
// im Kartensystem platzieren und senkrecht nach oben durchziehen (Tasche oben offen)
module swept() hull() { card_frame() children(); translate([0, 60, 0]) card_frame() children(); }

// ---------- Profile ----------
module trap(b, t, h, grow = 0) {
    k = (t - b) / (2 * h);
    offset(delta = grow) polygon([[-b/2 + k, -1], [b/2 - k, -1], [t/2, h], [-t/2, h]]);
}
// halber Schwalbenschwanz rechts (x>0); Innenflanke 45°, Außenseite senkrecht
module half_dt(grow) {
    xo = block_w/2 - dt_out;
    xi = xo - dt_root;
    offset(delta = grow) polygon([[xi + 1, -1], [xo, -1], [xo, dt_h], [xi - dt_h, dt_h]]);
}
module dt_male() {
    for (m = [0, 1]) mirror([m, 0, 0])
        translate([0, 0, dt_z0]) linear_extrude(D - front_stop - 0.2 - dt_z0) half_dt(-fit/2);
}
module dt_female() {
    for (m = [0, 1]) mirror([m, 0, 0])
        translate([0, 0, -e]) linear_extrude(D - front_stop + e) half_dt(fit/2);
}
// Wandschiene: Profil X/Z (Fuß bei z=0), Länge entlang +Y
module rail(len, grow = 0) {
    rotate([-90, 0, 0]) mirror([0, 1, 0]) linear_extrude(len) trap(rail_bot, rail_top, rail_h, grow);
}

// ---------- Wandplatte ----------
module plate() {
    intersection() {
        shear() translate([-50, 0.3, -1]) cube([100, 100, 30]);   // Unterkante folgt der Schräge
        difference() {
            union() {
                translate([-plate_w/2, 0, 0]) cube([plate_w, plate_l, plate_t]);
                translate([0, 0, plate_t - 0.01]) rail(plate_l, -fit/2);
            }
            for (x = [-screw_x, screw_x]) translate([x, plate_l / 2, 0]) {
                translate([0, 0, -e]) cylinder(d = screw_d, h = plate_t + 2*e);
                translate([0, 0, plate_t - (screw_head - screw_d)/2])
                    cylinder(d1 = screw_d, d2 = screw_head + 0.4, h = (screw_head - screw_d)/2 + e);
            }
        }
    }
}
// Aussparung im Slot: Platte ganz durch, Schienen-Nut oben geschlossen (Anschlag)
module plate_cut(h) {
    translate([-plate_w/2 - plate_clr, -1, -e]) cube([plate_w + 2*plate_clr, h + D*ta + 10, plate_t + plate_clr + e]);
    translate([0, -1, plate_t]) rail(h - stop_t + 1, fit/2);
}

// ---------- SKÅDIS-Platte ----------
// Schiene seitlich gedruckt: Profil "schräg" (beide Flanken 45° in dieselbe Richtung),
// passt in die normale Nut und druckt auf der Seite liegend ohne Support.
module rail_slanted(len) {
    k = rail_h;   // 45°
    g = fit/2;
    rotate([-90, 0, 0]) mirror([0, 1, 0]) linear_extrude(len)
        polygon([[-rail_bot/2 + g - 1, -1], [rail_bot/2 - g - 1, -1],
                 [rail_bot/2 - g + k, rail_h - g], [-rail_bot/2 + g + k, rail_h - g]]);
}
skadis_l = hook_y0 + skadis_dy + 4.5 + 2;          // Höhe der SKÅDIS-Platte
module skadis_hook(ty) {
    t = skadis_board + skadis_clr;
    translate([-hook_w/2, ty, -t]) cube([hook_w, 4.5, t + 0.01]);                    // Lasche durch das Brett
    translate([-hook_w/2, ty + 4.5 - (hook_leg + 4.5), -t - 3]) cube([hook_w, hook_leg + 4.5, 3]); // Haken hinter dem Brett
}
module plate_skadis() {
    intersection() {
        shear() translate([-50, 0.3, -20]) cube([100, 100, 50]);
        union() {
            translate([-plate_w/2, 0, 0]) cube([plate_w, skadis_l, plate_t]);
            translate([0, 0, plate_t - 0.01]) rail_slanted(plate_l);
        }
    }
    // Haken: unten links, oben rechts (diagonal benachbarte SKÅDIS-Löcher)
    translate([-skadis_dx/2, 0, 0]) skadis_hook(hook_y0);
    translate([ skadis_dx/2, 0, 0]) skadis_hook(hook_y0 + skadis_dy);
}
// Durchgang für die SKÅDIS-Platte im Deckel
module plate_notch(h) {
    translate([-plate_w/2 - plate_clr, -1, -e]) cube([plate_w + 2*plate_clr, h + D*ta + 10, plate_t + plate_clr + e]);
}

// ---------- Grundkörper mit runden Kanten ----------
// Grundriss (X/Z): vordere senkrechte Kanten gerundet, hinten (Wand) eckig
module outline(inset = 0) {
    r = round_r;
    offset(delta = -inset) hull() {
        translate([-block_w/2, 0]) square([block_w, e]);
        for (sx = [-1, 1]) translate([sx * (block_w/2 - r), D - r]) circle(r = r, $fn = 32);
    }
}
// Grundriss senkrecht von y0 bis y1 extrudiert
module slab(y0, y1, inset = 0) {
    translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) outline(inset);
}
// Block der Höhe h; top/bottom = obere/untere Außenkanten zusätzlich rund
module block(h, top = false, bottom = false) {
    r = min(round_r, h);
    n = 8;
    hull() {
        slab(bottom ? r : 0, top ? h - r : h);
        if (top)    for (k = [1 : n]) let(a = 90 * k / n)
            slab(h - r + r * sin(a) - 0.01, h - r + r * sin(a), r * (1 - cos(a)));
        if (bottom) for (k = [1 : n]) let(a = 90 * k / n)
            slab(r - r * sin(a), r - r * sin(a) + 0.01, r * (1 - cos(a)));
    }
}

// ---------- Deckel / Abdeckung ----------
module lid(skadis = false) {
    difference() {
        shear() difference() {
            block(g_h + lid_t, top = true);
            dt_female();
        }
        if (skadis) plate_notch(g_h + lid_t);
    }
}
module base() {
    shear() union() {
        block(lid_t, bottom = true);
        translate([0, lid_t, 0]) dt_male();
    }
}

// ---------- Slot ----------
module pocket(type) {
    s0 = card_s(type);
    yb = type == "eth" ? eth_below : 0;      // Boden des hinteren (Standard-)Teils
    swept() translate([-pocket_w/2, yb, s0]) cube([pocket_w, pocket_h, 200]);
    swept() translate([-plug_w/2, yb, s0 - plug_d]) cube([plug_w, pocket_h, plug_d + e]);
    if (type == "eth")
        swept() translate([-pocket_w/2, 0, s_front - eth_front_l]) cube([pocket_w, eth_pocket_h, 200]);
}
// Fase an der Öffnung (Boden + Seiten)
module mouth() {
    y0 = pocket_y0 + D * ta;
    hull() {
        translate([-pocket_w/2, y0, D - lead_in]) cube([pocket_w, 60, e]);
        translate([-pocket_w/2 - lead_in, y0 - lead_in, D + 0.01]) cube([pocket_w + 2*lead_in, 60, e]);
    }
}

module slot(type = "std") {
    h = slot_h(type);
    difference() {
        shear() difference() {
            union() {
                block(h);
                translate([0, h, 0]) dt_male();
            }
            dt_female();
        }
        pocket(type);
        mouth();
        if (type == "std") plate_cut(h);
    }
}

// ---------- Vorschau ----------
plug_cz_viz = 4.83;
module dummy_card(type) {
    l = card_len(type);
    color("silver") translate([-card_w/2, 0, 0]) cube([card_w, card_h, l]);
    if (type == "eth")
        color("silver") translate([-card_w/2, -eth_below, l - eth_front_l]) cube([card_w, eth_h, eth_front_l]);
    color("dimgray") translate([-4.25, plug_cz_viz - 1.3, -6.6]) cube([8.5, 2.6, 6.6]);
    color("black") translate([0, type == "eth" ? eth_h/2 - eth_below - 0.5 : card_h/2, l])
        cube(type == "eth" ? [15, 11, 0.6] : [9, 3.2, 0.6], center = true);
}

module slot_with_card(type, cards) {
    color(type == "eth" ? "#e8743b" : "#3b82c4") slot(type);
    if (cards) card_frame() translate([0, card_yl(type), card_s(type)]) dummy_card(type);
}

function sum_h(types, n) = n <= 0 ? 0 : slot_h(types[n - 1]) + sum_h(types, n - 1);

// Spalte: Oberkante oberster Slot bei y = 0. Der oberste Slot muss ein normaler sein.
//   pull = so weit ist der unterste Slot noch nach HINTEN herausgezogen (Einschieben von hinten)
module column(types, cards = true, pull = 0, m = mount) {
    n = len(types);
    color("#9aa3ad") lid(m == "skadis");
    color("#c0503a") translate([0, -stop_t - plate_l, 0]) { if (m == "skadis") plate_skadis(); else plate(); }
    for (i = [0 : n - 1])
        translate([0, -sum_h(types, i + 1), 0])
            translate(i == n - 1 ? [0, -pull * ta, -pull] : [0, 0, 0])
                slot_with_card(types[i], cards);
    color("#9aa3ad") translate([0, -sum_h(types, n) - lid_t, 0])
        translate([0, -pull * ta, -pull]) base();
}

module wall_view(cards = true, types = ["std", "eth", "std", "std"], pull = 0, m = mount) {
    rotate([90, 0, 0]) column(types, cards, pull, m);
    total = sum_h(types, len(types));
    if (pull == 0) {
        if (m == "skadis") skadis_board_viz(total);
        else color("#efe9df") translate([-45, 0, -total - 25]) cube([90, 2, total + 45]);
    }
}
// SKÅDIS-Brett für die Vorschau (Löcher passend zu den Haken)
module skadis_board_viz(total) {
    y_plate = -stop_t - plate_l;                         // Platten-Unterkante (Spalten-Koordinaten)
    x0 = -skadis_dx/2; y0 = y_plate + hook_y0;           // unteres Loch: Unterkante = Lasche unten
    color("#d9c7a7") rotate([90, 0, 0]) difference() {
        translate([-70, -total - 40, -skadis_board]) cube([140, total + 90, skadis_board]);
        for (i = [-4 : 4], j = [-6 : 3]) {
            hx = x0 + i * skadis_dx;
            hy = y0 + j * skadis_dy;
            if ((i + j) % 2 == 0)
                translate([hx, hy + 15/2, -skadis_board - 1]) hull() for (d = [-5, 5]) translate([0, d, 0]) cylinder(d = 5, h = skadis_board + 2, $fn = 20);
        }
    }
}

// ---------- Druckset: alle Teile in Druckausrichtung nebeneinander ----------
module on_bottom() rotate([180 - (90 - tilt), 0, 0]) children();          // Unterseite (geschert) aufs Bett
module on_top(h) rotate([-(90 - tilt), 0, 0]) translate([0, -h, 0]) children();  // Oberseite aufs Bett
module print_set(m = mount, ns = n_std, ne = n_eth) {
    px = block_w + 6;          // Raster X
    py = D * ca + 12;          // Raster Y (Länge eines liegenden Slots + Abstand)
    cols = 5;
    // Wandplatte (links oben)
    if (m == "skadis")
        translate([0, 0, plate_w/2]) rotate([0, -90, 0]) plate_skadis();    // seitlich, -X unten
    else
        plate();
    // Slots, Deckel, Abdeckung im Raster (alle erstrecken sich von ihrer Zeile aus nach -Y)
    n = ns + ne + 2;
    for (i = [0 : n - 1]) {
        c = (i + 1) % cols;
        r = floor((i + 1) / cols);
        translate([px * c, -py * r, 0]) {
            if (i < ns)           on_bottom() slot("std");
            else if (i < ns + ne) on_bottom() slot("eth");
            else if (i == ns + ne) translate([0, -D * ca - 2, 0]) on_top(g_h + lid_t) lid(m == "skadis");
            else                  on_bottom() base();
        }
    }
}

if (part == "print_set") print_set();
else if (part == "wall") wall_view();
else if (part == "wall_empty") wall_view(false);
else if (part == "wall_explode") wall_view(true, ["std", "eth", "std", "std"], 40);
else if (part == "wall_mount") {
    rotate([90, 0, 0]) {
        color("#c0503a") translate([0, -stop_t - plate_l, 0]) plate();
        translate([0, 25 - slot_h("std"), 0]) slot_with_card("std", true);
    }
    color("#efe9df") translate([-45, 0, -45]) cube([90, 2, 95]);
}
else if (part == "plate") plate();
else if (part == "plate_skadis") plate_skadis();
else if (part == "slot_std") slot("std");
else if (part == "slot_eth") slot("eth");
else if (part == "lid") lid(mount == "skadis");
else if (part == "lid_skadis") lid(true);
else if (part == "base") base();
