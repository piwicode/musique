include <constants.scad>

module front_side() {
  // Features:
  spkr_r = 35; // Radius of the spkr circular openning.
  spkr_c = 100; // Radius of curvature of the spkr.

  spkr_width = 78; // Measured.
  spkr_depth = 24;
  spkr_magnet_r = 20;
  spkr_adjustment = .2;
    
  h = sqrt(spkr_c * spkr_c - spkr_r * spkr_r);
  
  difference() {
    union() {
      // Front face plane.
      translate([-size_x / 2, 0, 0])
      linear_extrude(thickness)
      square([size_x, size_y]);

      intersection() {
        // Exterior sphere.
        translate([0, size_y / 2, h])
        sphere(r = spkr_c);
        // Restriction volume of the exterior shpere.
        translate([-size_x / 2, 0,  - spkr_c * 2 + thickness / 2])
        linear_extrude(spkr_c * 2)
        square([size_x, size_z]);
      }
    }
    // Interior sphere
    translate([0, size_y / 2, h])
    sphere(r = sqrt( (h - thickness) * (h - thickness) + spkr_r * spkr_r)); 
    
    // Holes
    translate([0, size_y / 2,  h - spkr_c - thickness])
    linear_extrude(spkr_c - h + thickness * 3)
    triangle_circular_pattern(r = spkr_r);
  }
  
  // Speaker face holder.
  //  _      _
  // | |    | |
  // | |    | |
  // | |____| |
  // |________|
  translate([-size_x/2, 0, thickness / 2])
  linear_extrude(thickness * 2)
  difference() {
    square(size = [size_x, 2/3 * size_y]);
    translate([(size_x - spkr_width) / 2, (size_y - spkr_width) / 2])
    square(size = [spkr_width, 2/3 * size_y]);
  }
  
  // Magnet fixation
  // With of the support
  mf_width = spkr_magnet_r * 2 + thickness * 2;
  mf_pocket_depth = 7;
  mf_back_thickness = thickness;
  mf_pin_r = 3;
  mf_pin_thickness = 3;
  translate([0, 0, thickness + spkr_depth - mf_pocket_depth])
  difference() {
    // Magnet support body.
    translate([-mf_width/2, 0, 0])
    cube([mf_width, size_y / 2, mf_pocket_depth + mf_back_thickness]);
   
    // Pocket holding the speaker magnet.
    translate([0, size_y / 2, -epsilon])
    linear_extrude(mf_pocket_depth + epsilon)
    circle(r = spkr_magnet_r);
    
    translate([0, size_y / 2, epsilon])
    linear_extrude(mf_pocket_depth + mf_back_thickness + epsilon)
    circle(r = spkr_magnet_r * 2 / 3);
  }
  
  // Speaker pin.
  translate([0, 0, thickness + spkr_depth]) {
    translate([-mf_pin_r, 0, 0])
    cube([mf_pin_r * 2, size_y / 2, mf_pin_thickness]);
    
    translate([0, size_y /2, 0]) {
      cylinder(r1=mf_pin_r, r2=mf_pin_r, h=mf_pin_thickness);
      translate([0, 0,-mf_pin_r/2])
      cylinder(r1=mf_pin_r/2, r2=mf_pin_r, h=mf_pin_r/2);
    }
  }  
}
front_side();