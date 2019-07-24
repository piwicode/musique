use <constants.scad>
use <top_cover.scad>

//Thickness of the wood.
thickness = 3;
e = 1;
epsilon = .01;

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

lose = .2;
tight = .1;

// Measure of screw fillet radius.
// This is not a functionnal adjustment.
hole_radius = 2.9 / 2 + lose / 2; 

nut_height = 1 + lose; // TO BE MEASURED
nut_d_min = 5.41 + tight;
nut_d_max = 6 + lose;

screw_head_radius = 5.5 / 2; // Measure.
screw_head_height = 3.05; // Measure.
screw_fillet_radius =  2.9 / 2; // Measure.

pocket_thickness = 1;

module clone(translations) {
  for(translation = translations) {
    translate(translation) children(); 
  }  
}

module yz_symetry_clone() {
  mirror([1, 0, 0]) children();
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


// Box front side.
union() {
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

//---------------------------------
// Box bottom side.
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
case_width = 62;
case_depth = 15 + /*margin=*/.5 + thickness;

// --------------------------------
// Box back side.

// Peg holes.
peg_hole_thickness = thickness * 1.5;
peg_hole_width = 10;
// TODO: rename peg_hole_h_spacing
get_hole_h_spacing = 25; // Distance between the two peg holes.

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
  
  clone([[-get_hole_h_spacing,0,0], [0,0,0], [get_hole_h_spacing,0,0]])
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
  translate([-size_x / 2 - nut_holder_size_x/2 +thickness + 7, thickness, size_z - nut_holder_size_z - thickness - screw_head_height - pocket_thickness])
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
      clone([[-get_hole_h_spacing,0,0], [0,0,0], [get_hole_h_spacing,0,0]])
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
translate([0, size_y, top_plate_width/2 + thickness])
rotate([90,-90,0])
#top_cover();

// Lilypad bounding shape.
lp_h = 18;
lp_r = 70 / 2;

%translate([0, size_y - top_plate_thickness, size_z / 2]) 
rotate([90, 0, 0])
cylinder(r1 = lp_r, r2 = lp_r, h = lp_h);


// Bateries holder bounding shape.
%translate([-61.9/2, thickness, size_z - case_depth])
cube([61.9, 57.2, 15.0]);

// Top nut holder

// Thicknes of the layer holding the nut.
screw_pocket_thickness = 1;

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

  hole_dist = 7; // Distance between the hole and the border.
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