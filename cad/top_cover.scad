include <constants.scad>

module top_cover_plate() {
  corner_radius = 4;
  
  linear_extrude(top_cover_thickness) {
    offset(r=corner_radius) 
    square(top_cover_width - corner_radius * 2, center=true);
  }
}

module pocket(
  position=[0,0,0],
  pocket_radius = 15/2,
  depth = 8,
  hole_radius = 9/2,
  slope = 1,
  thickness=top_cover_thickness) {

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

pb_pocket_radius = 6.825; // 6.725 -> 6,825
pb_hole_radius = 5.91; // 5.91 =
pb_slope = .2;  // slope 0 -> .2
pb_depth = 1.2; // 1. - > 1.2 (to compensate slope)

// Layout buttons layout
delta_angle = 46;
d = 26;

screw_head_radius = 5.5 / 2; // Measure.
screw_head_height = 3.05; // Measure.
screw_fillet_radius =  2.9 / 2; // Measure.

module screw_pocket(position) {
  pocket(
    slope = .4, // Two rings.
    pocket_radius = 5.5 / 2, // Measure screw head radius.
    depth = 3.05, // Measure screw head height.
    hole_radius = 2.9 / 2, // Measure screw fillet radius.
    position = position,
    thickness = 1)
  children();
}

screw_pocked_distance = 38;

module top_cover() {
screw_pocket(position = [screw_pocked_distance, screw_pocked_distance])
screw_pocket(position = [-screw_pocked_distance, screw_pocked_distance])
screw_pocket(position = [-screw_pocked_distance, -screw_pocked_distance])
screw_pocket(position = [screw_pocked_distance, -screw_pocked_distance])
pocket(
  slope = pb_slope,
  pocket_radius = pb_pocket_radius,
  depth = 1.2,
  hole_radius = pb_hole_radius, 
  position = [cos(delta_angle*-1.5)*d, sin(delta_angle*-1.5)*d, 0])
pocket(
  slope = pb_slope,
  pocket_radius = pb_pocket_radius,
  depth = 1.2,
  hole_radius = pb_hole_radius, 
  position = [cos(delta_angle*-.5)*d, sin(delta_angle*-.5)*d, 0])
pocket(
  slope = pb_slope,
  pocket_radius = pb_pocket_radius,
  depth = 1.2,
  hole_radius = pb_hole_radius, 
  position = [cos(delta_angle*.5)*d, sin(delta_angle*.5)*d, 0])
pocket(
  slope = pb_slope,
  pocket_radius = pb_pocket_radius,
  depth = 1.2,
  hole_radius = pb_hole_radius, 
  position = [cos(delta_angle*1.5)*d, sin(delta_angle*1.5)*d, 0])

pocket(
  position = [0, 0, 0],
  pocket_radius = 8.2,  // knob radius 8 -> 8.2
  depth = 9, // depth 8 -> 9
  hole_radius = 4.7, // 4.5 -> 4.7
  slope = 1)
top_cover_plate();
}

top_cover();