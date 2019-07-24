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

screw_pocket_thickness = 1; // Thickness of the botton of a screw pocket.

nut_height = 1 + lose; // TO BE MEASURED
nut_d_min = 5.41 + tight;
nut_d_max = 6 + lose;

// ----------------------------------------
// Battery case.
// LR6 Battery diameter is 14,2 mm
// 4 LR6 case: 61.9 mm x 57.2 mm x 15 mm
case_height = 58;
case_width = 62;
case_depth = 15 + /*margin=*/.5 + thickness;

// ----------------------------------------
// Peg holes.
peg_hole_thickness = thickness * 1.5;
peg_hole_width = 10;
// TODO: rename peg_hole_h_spacing
get_hole_h_spacing = 25; // Distance between the two peg holes.

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

// hw: horizontal width of a hole.
// bw: bars widh of the separation between the holes.
module triangle_circular_pattern(bw = 2, hw = 5, r = 80) {
  //        delta_x
  //        :<-->:
  //  ..... :    :________
  //  ^    / \   \       /
  //  |   /   \   \     /
  //  v  /     \   \   /
  //  ../_______\   \./
  //  
  delta_x = bw / sin(60);  // horizontal offset between triangles.
  triangle_height = hw * sin(60);   
  circular_pattern(r = r, 
                   xi = hw + delta_x * 2, 
                   yi = triangle_height + bw, 
                   stride = [0, hw /2 + delta_x]) {
    polygon([[0, 0], 
             [hw / 2, triangle_height],
             [- hw / 2, triangle_height]]);
    polygon([[delta_x, 0], 
             [delta_x + hw, 0],
             [delta_x + hw / 2, triangle_height]]);
  }
}

module pocket(position, pocket_radius, depth, hole_radius, slope, thickness) {
  difference() {
    union() {
      children();
      translate(position)
      cylinder(r1=pocket_radius + thickness + depth * .2, 
               r2=pocket_radius + thickness,
               h=depth + thickness);
    }

    translate(position)
    rotate_extrude(convexity=10) {
      polygon(points = [
        [0, -epsilon],
        [0, depth + thickness + epsilon],
        [hole_radius ,depth + thickness + epsilon],
        [hole_radius, depth],
        [pocket_radius, depth - slope], 
        [pocket_radius, -epsilon],
      ]);
    }
  }    
}

module screw_pocket(position) {
  pocket(
    slope = .4, // Two pint layers.
    pocket_radius = 5.5 / 2, // Measure screw head radius.
    depth = 3.05, // Measure screw head height.
    hole_radius = 2.9 / 2, // Measure screw fillet radius.
    position = position,
    thickness = screw_pocket_thickness)
  children();
}