include <constants.scad>

module back_cover() {
  // Parameters
  cover_thickness = thickness;
  cover_size_x = size_x - thickness * 2;
  cover_size_y = case_height + case_depth + thickness - thickness;
  // Computed parameters
  translate([-cover_size_x/2, 0, 0]) {
    screw_pocked_distance = 7; // distance to the border.
    screw_pocket(position=[screw_pocked_distance, screw_pocked_distance])
    screw_pocket(position=[cover_size_x - screw_pocked_distance, screw_pocked_distance]) union(){
      // 3 Pegs on the top edge.
      translate_clone([[-get_hole_h_spacing,0,0], [0,0,0], [get_hole_h_spacing,0,0]])
      translate([cover_size_x / 2 - peg_hole_width / 2 + lose, 
      cover_size_y - cover_thickness * 2, 0])
      rotate([45, 0 ,0])
      cube([peg_hole_width - lose * 2, 7, thickness]);

      difference() {
        // Back cover Body.
        cube([cover_size_x, cover_size_y, thickness]);
        
        // 45 deg cut on the top edge.
        translate([-epsilon, cover_size_y - thickness - epsilon, + thickness + epsilon])
        rotate([-45, 0, 0])
        cube([cover_size_x + 2 * epsilon, thickness * 2, thickness]);
      }
    }
  }
}

back_cover();