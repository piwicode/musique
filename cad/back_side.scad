include <constants.scad>
use <back_cover.scad>

module back_side() {
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
}

back_side();

translate([0, thickness, size_z])
rotate([0,180, 0])
#back_cover();
