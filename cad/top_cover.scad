include <constants.scad>

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
    slope = .4, // Two rings.
    pocket_radius = 5.5 / 2, // Measure screw head radius.
    depth = 3.05, // Measure screw head height.
    hole_radius = 2.9 / 2, // Measure screw fillet radius.
    position = position,
    thickness = screw_pocket_thickness)
  children();
}

module push_button_pocket(position) {
  pocket(
    slope = .2,  // slope 0 -> .2
    pocket_radius = 6.825, // 6.725 -> 6,825
    depth = 1.2, // 1. - > 1.2 (to compensate slope)
    hole_radius = 5.91, // 5.91 =
    thickness=top_cover_thickness,
    position = position)
  children();
}

module top_cover() {
  // Layout buttons layout
  delta_angle = 46;
  d = 26;

  screw_pocket(position = [top_screw_pocket_distance, top_screw_pocket_distance])
  screw_pocket(position = [-top_screw_pocket_distance, top_screw_pocket_distance])
  screw_pocket(position = [-top_screw_pocket_distance, -top_screw_pocket_distance])
  screw_pocket(position = [top_screw_pocket_distance, -top_screw_pocket_distance])

  push_button_pocket(position = [cos(delta_angle*-1.5)*d, sin(delta_angle*-1.5)*d, 0])
  push_button_pocket(position = [cos(delta_angle*-.5)*d, sin(delta_angle*-.5)*d, 0])
  push_button_pocket(position = [cos(delta_angle*.5)*d, sin(delta_angle*.5)*d, 0])
  push_button_pocket(position = [cos(delta_angle*1.5)*d, sin(delta_angle*1.5)*d, 0])

  pocket(
    position = [0, 0, 0],
    pocket_radius = 8.2,  // knob radius 8 -> 8.2
    depth = 9, // depth 8 -> 9
    hole_radius = 4.7, // 4.5 -> 4.7
    thickness=top_cover_thickness,
    slope = 1)
  linear_extrude(top_cover_thickness) 
  rounded_square(width=top_cover_width, radius=top_cover_corner_r);
}

top_cover();