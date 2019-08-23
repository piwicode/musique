include <constants.scad>
use <main.scad>
spkr_r = 36;

rotate([90,0,0])
difference() {
  main();
  #translate([0,size_y /2, -20])
  cylinder(h = 40, r=spkr_r + 1);
}
// expect 58 actual 3 +50 + 5 = 58
// 64, actual 68
// 17, actual 17.5