include <constants.scad>
use <main.scad>

rotate([90, 0, 0]) 
intersection() {
  translate([size_x / 2, -size_y, 0])
  main();
  cube([40,40,40], center=true);
}

