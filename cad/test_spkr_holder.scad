include <constants.scad>
use <main.scad>
use <back_cover.scad>

rotate([90, 0, 0]) 
intersection() {
  translate([0, 0, 0]) {
    #main();
    // Back cover
    translate([0, thickness, size_z])
    rotate([0,180, 0])
    %back_cover();
  }
  cube([100,100,70], center=true);
}

