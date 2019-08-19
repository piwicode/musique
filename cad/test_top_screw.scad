include <constants.scad>
use <top_cover.scad>

intersection() {
  width = top_cover_width - top_screw_pocket_distance * 2;
  cube([width, width, 20], center=true);
  translate([top_screw_pocket_distance, top_screw_pocket_distance, 0])
  top_cover();
}