// Small value used to clarify whenever a shape is inside or outside another.

epsilon = .01;
$fn = $preview ? 12 : 72;

// Adjustements
lose = .2;
tight = .1;

// Exterior dimensions of the box.
size_x = 96;
size_y = 96;
size_z = 96;
// Wall thickness of the faces.
thickness = 3;

// ----------------------------------------
// Top
top_cover_thickness = 2;

// Dimmension for the square shaped top cover
top_cover_width = 90;
top_cover_corner_r = 4;
// Distance from the center of the plate to the screw hole
// horizontally and vertically.
top_screw_pocket_distance = 38;

// ----------------------------------------
// Common functions
module rounded_square(width, radius) {
  offset(r=radius) 
  square(width - radius * 2, center=true);
}