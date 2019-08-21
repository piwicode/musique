include <constants.scad>
use <main.scad>
spkr_r = 35;
rotate([90,0,0])
intersection() {
  main();
  #translate([0,size_y /2, -20])
  cylinder(h = 40, r=spkr_r + 1);
}
