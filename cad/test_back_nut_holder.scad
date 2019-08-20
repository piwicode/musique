include <constants.scad>
use <main.scad>
use <back_cover.scad>

rotate([90, 0, 0]) 
intersection() {
  translate([size_x / 2, 0, -size_z]) {
    main();
    // Back cover
    translate([0, thickness, size_z])
    rotate([0,180, 0])
    %back_cover();
  }
  cube([40,40,40], center=true);
}

