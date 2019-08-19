include <constants.scad>
use <top_cover.scad>

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

module placed_nut_holder() {
  translate([-size_x / 2 + thickness, size_y - screw_pocket_thickness - screw_head_height, thickness])
  nut_holder();
}

module top_side() {
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

}





top_side();
translate([0, size_y, top_cover_width/2 + thickness])
rotate([90,-90,0])
#top_cover();
