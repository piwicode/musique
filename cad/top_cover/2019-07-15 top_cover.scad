$fn = 40;
thickness = 1.5;
e = 1;

module top_cover() {
  width = 80;
  corner_radius = 4;
  
  linear_extrude(thickness) {
    offset(r=corner_radius) 
    square(width - corner_radius * 2, center=true);
  }
}

module rotary(
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

module push_button(
  pocket_radius,
  depth,
  hole_radius,
  position=[0,0,0],
  slope = 0) {

  difference() {
    union() {
      children();     
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

pb_pocket_radius = 13.25 / 2;
pb_hole_radius = 11.62 / 2;
inc = .1;
push_button(
  pocket_radius = pb_pocket_radius - inc,
  depth = 1,
  hole_radius = pb_hole_radius - inc, 
  position = [20, -20, 0])
push_button(
  pocket_radius = pb_pocket_radius,
  depth = 1,
  hole_radius = pb_hole_radius, 
  position = [20, 20, 0])
push_button(
  pocket_radius = pb_pocket_radius + inc,
  depth = 1,
  hole_radius = pb_hole_radius + inc, 
  position = [20, 0, 0])

push_button(
  pocket_radius = pb_pocket_radius + 2*inc,
  depth = 1,
  hole_radius = pb_hole_radius + 2*inc, 
  position = [0, -20, 0])
push_button(
  pocket_radius = pb_pocket_radius + 3*inc,
  depth = 1,
  hole_radius = pb_hole_radius + 3*inc,
  position = [0, 20, 0])
push_button(
  pocket_radius = pb_pocket_radius + 4*inc,
  depth = 1,
  hole_radius = pb_hole_radius + 4*inc, 
  position = [0, 0, 0])

rotary(
  position=[-20, -20, 0],
  pocket_radius = 15/2,
  depth = 8,
  hole_radius = 9/2,
  slope = 0)
rotary(
  position=[-20, 0, 0],
  pocket_radius = 15/2,
  depth = 8,
  hole_radius = 9/2,
  slope = 1)
rotary(
  position=[-20, 20, 0],
  pocket_radius = 15/2,
  depth = 8,
  hole_radius = 9/2,
  slope = 2)
top_cover();
