// Small value used to clarify whenever a shape is inside or outside another.

epsilon = .01;
$fn = $preview ? 12 : 72;

// Adjustements
lose = .2;
tight = .1;

// Wall thickness of the faces.
thickness = 3;

// ----------------------------------------
// Top
top_cover_thickness = 2;

top_cover_width = 90;

// ----------------------------------------
// Common functions
module rounded_square(width, radius) {
  offset(r=radius) 
  square(width - radius * 2, center=true);
}