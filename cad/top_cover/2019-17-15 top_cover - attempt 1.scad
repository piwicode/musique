$fn = 40;
thickness = 2;
e = 1;

module top_cover() {
  width = 80;
  corner_radius = 4;
  
  linear_extrude(thickness) {
    offset(r=corner_radius) 
    square(width - corner_radius * 2, center=true);
  }
}

module pocket(
  position=[0,0,0],
  pocket_radius = 15/2,
  depth = 8,
  hole_radius = 9/2,
  slope = 1) {

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
        [0, -e],
        [0, depth + thickness + e],
        [hole_radius ,depth + thickness + e],
        [hole_radius, depth],
        [pocket_radius, depth - slope], 
        [pocket_radius, -e],
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
  position=[0, 0, 0],
  pocket_radius = 8.2,  // knob radius 8 -> 8.2
  depth = 9, // depth 8 -> 9
  hole_radius = 4.7, // 4.5 -> 4.7
  slope = 1)
top_cover();
