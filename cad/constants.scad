// Small value used to clarify whenever a shape is inside or outside another.

epsilon = .01;
$fn = $preview ? 12 : 72;

// Adjustements
lose = .2;
tight = .1;

// Exterior dimensions of the box.
size_x = 96;
size_y = 96;
size_z = 96;
// Wall thickness of the faces.
thickness = 3;

// ----------------------------------------
screw_head_radius = 5.5 / 2; // Measure.
screw_head_height = 3.05; // Measure.
screw_fillet_radius =  2.9 / 2; // Measure.
// ----------------------------------------
// Top
top_cover_thickness = 2;
top_support_width = 2;

// Dimmension for the square shaped top cover
top_cover_width = 90;
top_cover_corner_r = 4;
// Distance from the center of the plate to the screw hole
// horizontally and vertically.
top_screw_pocket_distance = 38;

// ----------------------------------------
// Common functions

module rounded_square(width, radius) {
  offset(r=radius) 
  square(width - radius * 2, center=true);
}

module translate_clone(translations) {
  for(translation = translations) {
    translate(translation) children(); 
  }  
}

module yz_symetry_clone() {
  mirror([1, 0, 0]) children();
  children();   
}

// xr = [start, increment, end ]
// yr = [start, increment, end ]
module pattern(xr, yr, stride) {
  for(y = [yr[0]: yr[1] * len(stride) : yr[2]]) {
    for(si = [0 : len(stride)]) {
      for(x = [xr[0] - stride[si] : xr[1] : xr[2]]) {
        translate([x, y + si * yr[1]]) {
          children();
        }
      }
    }
  }
}

module circular_pattern(r, xi, yi, stride) {
  intersection(){
    circle(r);
    pattern(xr = [-r, xi, r], yr = [-r, yi, r], stride=stride)
    children();
  }
}