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
      peg_width = peg_hole_width - lose * 2;
      translate_clone([[-get_hole_h_spacing,0,0], [0,0,0], [get_hole_h_spacing,0,0]])
      translate([cover_size_x / 2 - peg_width / 2 + lose, 
      cover_size_y - cover_thickness * 2, 0])
      rotate([45, 0 ,0])
      cube([peg_width - lose * 2, 7, thickness]);

      // Adjustement.
      adj = lose;
      translate([adj, 0, 0])
      difference() {
        // Back cover Body.
        intersection() {
          cube([cover_size_x-adj * 2, cover_size_y, thickness]);
          translate([cover_size_x / 2 - adj, cover_size_x/2, -epsilon])
          linear_extrude(thickness + epsilon * 2)
          rounded_rectangle([cover_size_x - adj * 2, cover_size_x], top_cover_corner_r);
        }
        
        // 45 deg cut on the top edge.
        translate([-epsilon, cover_size_y - thickness - epsilon, + thickness + epsilon])
        rotate([-45, 0, 0])
        cube([cover_size_x + 2 * epsilon, thickness * 2, thickness]);
      }
    }
  }
}

back_cover();