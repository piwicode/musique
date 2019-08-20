include <constants.scad>
use <main.scad>
use <top_cover.scad>

rotate([90, 0, 0]) {
  
intersection() {
  
  translate([size_x / 2, -size_y, 0]) {
    main();

    #translate([0, size_y, top_cover_width/2 + thickness])
    rotate([90,-90,0])
    top_cover();
  }
  cube([40,40,40], center=true);
}
}
