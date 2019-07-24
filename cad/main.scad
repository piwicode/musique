include <constants.scad>
use <top_cover.scad>
use <back_cover.scad>
use <front_side.scad>


// Measure of screw fillet radius.
// This is not a functionnal adjustment.
hole_radius = 2.9 / 2 + lose / 2; 

front_side();

//---------------------------------
// Box bottom side.
translate([-size_x/2, 0, 0])
cube([size_x, thickness, size_z]);

translate([-size_x/2, 0, 0])
cube([thickness, size_y, size_z]);

translate([size_x/2 - thickness, 0, 0])
cube([thickness, size_y, size_z]);

// --------------------------------
// Box back side.

difference() {
  // Face.
  translate([-size_x / 2, 0, size_z])
  rotate([90, 0, 90]) 
  linear_extrude(size_x)
  polygon([
    [0, -case_depth], 
    [case_height + thickness, -case_depth], 
    [case_height + thickness + case_depth, 0],
    [size_y, 0],
    [size_y, -thickness],
    [case_height + thickness + case_depth, - thickness],  
    [case_height + thickness, -case_depth - thickness], 
    [0, -case_depth - thickness]]);
  
  translate_clone([[-get_hole_h_spacing,0,0], [0,0,0], [get_hole_h_spacing,0,0]])
  translate([-peg_hole_width / 2, 0, size_z - thickness - peg_hole_thickness - epsilon])
  cube([peg_hole_width, size_y, peg_hole_thickness]);
}

// Back nut holder
translate([0,0,0]) {
  nut_holder_thckness = 4;
  nut_holder_hole_height = 7;
  
  // computed
  nut_holder_size_x = nut_d_min + 2 * nut_holder_thckness;
  nut_holder_size_y = nut_holder_hole_height + hole_radius + 2;
  nut_holder_size_z = nut_height + 2 * nut_holder_thckness;
  
  yz_symetry_clone()
  // TODO: replace 7 with screw_pocked_distance
  translate([-size_x / 2 - nut_holder_size_x/2 +thickness + 7, thickness, size_z - nut_holder_size_z - thickness - screw_head_height - screw_pocket_thickness])
  difference() {
    cube([nut_holder_size_x, nut_holder_size_y, nut_holder_size_z]);
    translate([nut_holder_size_x/2, nut_holder_hole_height, +epsilon])
    linear_extrude(nut_holder_size_z + 2 * epsilon)
    square(hole_radius * 2, center = true);

    translate([nut_holder_size_x / 2, nut_holder_thckness, nut_holder_thckness])
    
    linear_extrude(nut_height)
    rotate([0, 0, 90])
    hull() {
      circle($fn=6, r=nut_d_max/2);
      translate([8, 0, 0])
      circle($fn=6, r=nut_d_max/2);
    }
  }
}

// ---------------------------------------
// Back cover

translate([0, thickness, size_z])
rotate([0,180, 0])
#back_cover();

// Back support
translate([-size_x / 2, 0, size_z - thickness * 2])
difference() {
  back_support_size = 2;
  // Body
  cube([size_x, size_z, thickness * 2]);
  translate([thickness + back_support_size, thickness + back_support_size, -epsilon])
  // Hole
  cube([size_x - thickness * 2 - back_support_size * 2, size_z, thickness * 2 + epsilon * 2]);
  //
  translate([thickness, thickness, thickness])
  cube([size_x - thickness * 2, size_z, thickness + epsilon]);
}
// ---------------------------------------------------
// Box top side


// Top plate
translate([0, size_y, size_z/2])
rotate([90, 0, 0])
linear_extrude(top_cover_thickness)
difference() {
  square([size_x, size_z], center=true);
  rounded_square(width=top_cover_width, radius=top_cover_corner_r);
}

translate([0, size_y - top_cover_thickness, 0])
union() {
  // Left support.
  translate([size_x / 2, 0, 0]) {
    d = (size_x - top_cover_width) / 2 + top_support_width;
    t = thickness;
    linear_extrude(size_z) polygon([[0, 0], [-d, 0], [-d, -t], [0, -d - t]]);
  }
  // Right support.
  translate([-size_x / 2 , 0, 0]) {
    d = (size_x - top_cover_width) / 2 + top_support_width;
    t = thickness;
    linear_extrude(size_z) polygon([[0, 0], [d, 0], [d, -t], [0, -d - t]]);
  }
  // Front support.
  translate([-size_x / 2, 0, 0]) {
    d = (size_z - top_cover_width) / 2 + top_support_width;
    t = thickness;
    rotate([0, 90, 0])
    linear_extrude(size_x) polygon([[0, 0], [-d, 0], [-d, -t], [-t , -d], [0, -d]]);
  }
  // Back support.
  translate([-size_x / 2, 0, size_z]) {
    d = (size_z - top_cover_width) / 2 + top_support_width;
    t = thickness;
    rotate([0, 90, 0])
    linear_extrude(size_x) polygon([[0, 0], [d, 0], [d, -t], [0, -d - t]]); 
  }
}
translate([0, size_y, top_cover_width/2 + thickness])
rotate([90,-90,0])
#top_cover();

// Lilypad bounding shape.
lp_h = 18;
lp_r = 70 / 2;

%translate([0, size_y - top_cover_thickness, size_z / 2]) 
rotate([90, 0, 0])
cylinder(r1 = lp_r, r2 = lp_r, h = lp_h);


// Bateries holder bounding shape.
%translate([-61.9/2, thickness, size_z - case_depth])
cube([61.9, 57.2, 15.0]);

// Top nut holder

module placed_nut_holder() {
  translate([-size_x / 2 + thickness, size_y - screw_pocket_thickness - screw_head_height, thickness])
  nut_holder();
}
placed_nut_holder();
mirror([1,0,0])
placed_nut_holder();

translate([0,0,size_y])
mirror([0,0,1])
placed_nut_holder();
translate([0,0,size_y])
mirror([0,0,1])
mirror([1,0,0])
placed_nut_holder();

module nut_holder() {

  hole_dist = size_x / 2 - thickness - top_screw_pocket_distance; // Distance between the hole and the border.
  thickness = 1; // Thickness of the layer on top of the nut.
  translate([0, -nut_height - thickness, 0])
  rotate([90, 0, 0])
  union() { 
    // Top layer inner band 
    support_width = hole_dist + nut_d_min / 2 + 1;
    translate([0, 0, -nut_height - thickness])
    cube([hole_dist - hole_radius, support_width, thickness]);
    // Top layer outer band
    translate([support_width, 0, -nut_height])
    rotate([0,180,0])
    cube([support_width - hole_radius - hole_dist, support_width, thickness]);
    
    difference() {
      // Pyramid and nud body holder.
      union() {
        linear_extrude(height = support_width, scale = [0, 1])
        square(support_width);

        translate([0, 0, -nut_height])
        linear_extrude(height=nut_height)
        square(support_width);
      }

      // Screw hole.
      translate([hole_dist, hole_dist, -nut_height-1])
      cylinder(r1 = hole_radius, r2 = hole_radius, h = hole_dist + nut_height + 1);

      // Nut placement.
      translate([0,0,-nut_height - 1])
      linear_extrude(height=nut_height + 1)
      hull() {
        translate([hole_dist, hole_dist, 0])circle($fn=6, r=nut_d_max/2);
        translate([hole_dist + 3, hole_dist, 0])circle($fn=6, r=nut_d_max/2);
      }
    }
  }
}


// Testcase
module test_case_1() {
  nut_holder();
  
  translate([-thickness, -20 + thickness, -thickness])
  difference(){
    cube([20,20,20]);
    translate([thickness, thickness, thickness])
    cube([20,20,20]);
  }
}