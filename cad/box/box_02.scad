//module plate(
//Thickness of the wood.
thickness = 3;
e = 1;

// Exterior dimensions of the box.
size_x = 96;
size_y = 96;
size_z = 96;

// Features:
spkr_r = 35; // Radius of the spkr circular openning.
spkr_c = 100; // Radius of curvature of the spkr.

spkr_width = 78; // Measured.
spkr_depth = 24;
spkr_magnet_r = 20;
spkr_adjustment = .2;

front = [[0, thickness, 0 ], [90, 0, 0]];
back =  [[size_x, size_y - thickness, 0], [90, 0, 180]];
top =   [[0, 0, size_z - thickness], [0, 0, 0]];
bottom = [[size_x, 0, thickness],[0, 180, 0]];
left =  [[thickness, size_y, 0], [90, 0, 270]];
right = [[size_x - thickness, 0, 0], [90, 0, 90]];


module plate(
  offset=[0,0,0], 
  face=[[0,0,0], [0,0,0]]) {
  echo("totot");

  translate(offset)
  translate(face[0])
  rotate(face[1])
  color("red")
  children();
}

// xr = [start, increment, end ]
// yr = [start, increment, end ]
module pattern(xr, yr, stride) {
  for(y = [yr[0]: yr[1] * len(stride) : yr[2]]) {
    for(si = [0 : len(stride)]) {
      for(x = [xr[0] - stride[si] : xr[1] : xr[2]]) {
        translate([x, y + si * yr[1]]) {
          children();
        }
      }
    }
  }
}


module circular_pattern(r, xi, yi, stride) {
  intersection(){
    circle(r);
    pattern(xr = [-r, xi, r], yr = [-r, yi, r], stride=stride)
    children();
  }
}

// hw: horizontal width of a hole.
// bw: bars widh of the separation between the holes.
module triangle_pattern(bw = 2, hw = 5, r = 80) {
  //        delta_x
  //        :<-->:
  //  ..... :    :________
  //  ^    / \   \       /
  //  |   /   \   \     /
  //  v  /     \   \   /
  //  ../_______\   \./
  //  
  delta_x = bw / sin(60);  // horizontal offset between triangles.
  triangle_height = hw * sin(60);   
  circular_pattern(r = r, 
                   xi = hw + delta_x * 2, 
                   yi = triangle_height + bw, 
                   stride = [0, hw /2 + delta_x]) {
    polygon([[0, 0], 
             [hw / 2, triangle_height],
             [- hw / 2, triangle_height]]);
    polygon([[delta_x, 0], 
             [delta_x + hw, 0],
             [delta_x + hw / 2, triangle_height]]);
  }
}

module hexagon_pattern(bw = 1, hw = 6) {
  delta_x = bw / sin(60);  // horizontal offset between triangles.
  triangle_height = hw * sin(60);
  yi = triangle_height + bw; // y increment.
  xi = hw + delta_x * 2; // x increment.
    
  circular_pattern(r = 60, xi = xi, yi = yi, stride = [0, hw / 2]) {
    circle(r= hw/2, $fn = 6);
  }
}


// Front face.
union() {
  $fn = 20; // 80 for final
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
        #sphere(r = spkr_c);
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
    triangle_pattern(r = spkr_r);
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
    translate([0, size_y / 2, -e])
    linear_extrude(mf_pocket_depth + e)
    circle(r = spkr_magnet_r);
    
    translate([0, size_y / 2, e])
    linear_extrude(mf_pocket_depth + mf_back_thickness + e)
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

// Bottom side.
translate([-size_x/2, 0, 0])
cube([size_x, thickness, size_z]);

translate([-size_x/2, 0, 0])
cube([thickness, size_y, size_z]);

translate([size_x/2 - thickness, 0, 0])
cube([thickness, size_y, size_z]);

// Battery case.
// LR6 Battery diameter is 14,2 mm
// 4 LR6 case: 61.9 mm x 57.2 mm x 15 mm
case_height = 58;
case_depth = 15 + /*margin=*/.5 + thickness;

// Case back.
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


top_plate_width = /*80*/ size_x - 2 * thickness;
top_plate_thickness = 2;
top_support = 2;
top_corner_r = 4;

// Top plate
translate([0, size_y, size_z/2])
rotate([90, 0, 0])
linear_extrude(top_plate_thickness)
difference() {
  square([size_x, size_z], center=true);
  offset(r=top_corner_r) 
  square(top_plate_width - top_corner_r * 2, center=true);
}

translate([0, size_y - top_plate_thickness, 0])
union() {
  // Left support.
  translate([size_x / 2, 0, 0]) {
    d = (size_x - top_plate_width) / 2 + top_support;
    t = thickness;
    linear_extrude(size_z) polygon([[0, 0], [-d, 0], [-d, -t], [0, -d - t]]);
  }
  // Right support.
  translate([-size_x / 2 , 0, 0]) {
    d = (size_x - top_plate_width) / 2 + top_support;
    t = thickness;
    linear_extrude(size_z) polygon([[0, 0], [d, 0], [d, -t], [0, -d - t]]);
  }
  // Front support.
  translate([-size_x / 2, 0, 0]) {
    d = (size_z - top_plate_width) / 2 + top_support;
    t = thickness;
    rotate([0, 90, 0])
    linear_extrude(size_x) polygon([[0, 0], [-d, 0], [-d, -t], [-t , -d], [0, -d]]);
  }
  // Back support.
  translate([-size_x / 2, 0, size_z]) {
    d = (size_z - top_plate_width) / 2 + top_support;
    t = thickness;
    rotate([0, 90, 0])
    linear_extrude(size_x) polygon([[0, 0], [d, 0], [d, -t], [0, -d - t]]); 
  }
}

// Lilypad bounding shape.
lp_h = 18;
lp_r = 70 / 2;


color("Violet")
translate([0, size_y - top_plate_thickness, size_z / 2]) 
rotate([90, 0, 0])
cylinder(r1 = lp_r, r2 = lp_r, h = lp_h);


// Bateries holder bounding shape.
color("Violet")
translate([-61.9/2, thickness, size_z - case_depth])
cube([61.9, 57.2, 15.0]);
