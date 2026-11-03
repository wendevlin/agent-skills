// Fit test coupon: ONE short print (~15 min) shows which clearance works on THIS printer
// with THIS filament - before printing the real part.
// A block with 4 dovetail grooves (clearance 0.2 / 0.3 / 0.4 / 0.5 mm per side) plus 4 tongues.
// Number of engraved dots on block and tongue = variant 1..4.
// Copy the real part's profile (height, widths, flanks) here so the test means something.
// Prints without supports: block flat with the grooves open at the top, tongues on their base plate.

/* [Coupon] */
// Clearance per side for the 4 variants
fits = [0.2, 0.3, 0.4, 0.5];
// Dovetail height
dt_h = 3.0;
// Dovetail width at the root (narrow side)
dt_bot = 7.0;
// Dovetail width at the tip (dt_bot + 2*dt_h = 45 deg)
dt_top = 13.0;
// Length of the test pieces
len = 20;
// What to print
part = "all"; // [all, block, tongues]

/* [Hidden] */
$fn = 24;
pitch = dt_top + 8;
bh = dt_h + 2.5;          // block height
// Profile in (u, v): v = 0 root (narrow), v = dt_h tip (wide); extended to v = -1 for clean unions
module prof(grow) {
    k = (dt_top - dt_bot) / (2 * dt_h);
    offset(delta = grow) polygon([[-dt_bot/2 + k, -1], [dt_bot/2 - k, -1], [dt_top/2, dt_h], [-dt_top/2, dt_h]]);
}
// n dots engraved 0.6 mm deep into a surface at height `top`
module dots(n, top) for (i = [0 : n - 1]) translate([i * 2.2 - (n - 1) * 1.1, 0, top - 0.6]) cylinder(d = 1.4, h = 1);

// Block: groove mouth (narrow) at the top, widening downwards (v -> -z)
module block() difference() {
    translate([-pitch/2, 0, 0]) cube([pitch * len(fits), len, bh]);
    for (i = [0 : len(fits) - 1]) {
        translate([i * pitch, -1, bh]) rotate([-90, 0, 0]) linear_extrude(len + 2) prof(fits[i] / 2);
        translate([i * pitch + dt_top/2 + 2, len / 2, 0]) rotate([0, 0, 90]) dots(i + 1, bh);
    }
}
// Tongue: base plate on the bed, root at z = 2, widening upwards (v -> +z)
module tongue(i) difference() {
    union() {
        translate([-pitch/2 + 1, 0, 0]) cube([pitch - 2, len, 2]);
        translate([0, len, 2 - 0.01]) rotate([90, 0, 0]) linear_extrude(len) prof(-fits[i] / 2);
    }
    translate([-pitch/2 + 3, len / 2, 0]) rotate([0, 0, 90]) dots(i + 1, 2);
}
// Only draw for known values, so `part="none"` (used by check.sh) draws nothing
if (part == "all" || part == "block") block();
if (part == "all" || part == "tongues") for (i = [0 : len(fits) - 1]) translate([i * pitch, len + 8, 0]) tongue(i);
