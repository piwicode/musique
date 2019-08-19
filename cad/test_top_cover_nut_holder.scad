include <constants.scad>
use <top_side.scad>

nut_holder();

translate([-thickness, -20 + thickness, -thickness])
difference(){
  cube([20,20,20]);
  translate([thickness, thickness, thickness])
  cube([20,20,20]);
}
