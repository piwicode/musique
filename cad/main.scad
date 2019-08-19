include <constants.scad>
use <top_cover.scad>
use <back_cover.scad>
use <back_side.scad>
use <front_side.scad>
use <top_side.scad>
front_side();

//---------------------------------
// Box bottom left and right sides.
translate([-size_x/2, 0, 0])
cube([size_x, thickness, size_z]);

translate([-size_x/2, 0, 0])
cube([thickness, size_y, size_z]);

translate([size_x/2 - thickness, 0, 0])
cube([thickness, size_y, size_z]);

back_side();
top_side();

// ---------------------------------------
// Back cover
translate([0, thickness, size_z])
rotate([0,180, 0])
#back_cover();

// ---------------------------------------
// Top cover
translate([0, size_y, top_cover_width/2 + thickness])
rotate([90,-90,0])
#top_cover();

// ---------------------------------------
// Lilypad bounding shape.
lp_h = 18;
lp_r = 70 / 2;

%translate([0, size_y - top_cover_thickness, size_z / 2]) 
rotate([90, 0, 0])
cylinder(r1 = lp_r, r2 = lp_r, h = lp_h);

// ---------------------------------------
// Bateries holder bounding shape.
%translate([-61.9/2, thickness, size_z - case_depth])
cube([61.9, 57.2, 15.0]);
