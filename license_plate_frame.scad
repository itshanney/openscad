// License Plate Frame
// Configurable parameters

// Outer frame dimensions
frame_length   = 315;   // mm
frame_width    = 160;   // mm
frame_thick    = 10;    // mm
corner_radius  = 12.5;     // mm

// Mounting holes
hole_dia      = 9;     // mm
hole_spacing  = 180;    // mm, center to center
hole_from_top = 20;     // mm, from top edge to hole center

// Plate dimensions
plate_length  = 305;    // mm
plate_width   = 153;    // mm
plate_depth   = 6;      // mm

// Retaining lip (plate slides in from top)
lip_overhang    = 4;    // mm, how far lip extends over the plate edge
lip_side_height = 50;   // mm, how far up each side the lip extends
lip_thick       = 3;    // mm, thickness of the lip

// Derived border widths
border_x = (frame_length - plate_length) / 2;
border_y = (frame_width  - plate_width)  / 2;

union() {
    difference() {
        // Base rectangle with rounded corners
        hull() {
            translate([corner_radius, corner_radius, 0])
                cylinder(r=corner_radius, h=frame_thick, $fn=64);
            translate([frame_length - corner_radius, corner_radius, 0])
                cylinder(r=corner_radius, h=frame_thick, $fn=64);
            translate([corner_radius, frame_width - corner_radius, 0])
                cylinder(r=corner_radius, h=frame_thick, $fn=64);
            translate([frame_length - corner_radius, frame_width - corner_radius, 0])
                cylinder(r=corner_radius, h=frame_thick, $fn=64);
        }

        // Mounting holes (top edge, centered horizontally)
        for (x_offset = [-hole_spacing/2, hole_spacing/2]) {
            translate([frame_length/2 + x_offset, frame_width - hole_from_top, -1])
                cylinder(d=hole_dia, h=frame_thick + 2, $fn=32);
        }

        // License plate pocket (centered, recessed from top face, matching corner radius)
        translate([border_x, border_y, frame_thick - plate_depth])
            hull() {
                translate([corner_radius, corner_radius, 0])
                    cylinder(r=corner_radius, h=plate_depth + 1, $fn=64);
                translate([plate_length - corner_radius, corner_radius, 0])
                    cylinder(r=corner_radius, h=plate_depth + 1, $fn=64);
                translate([corner_radius, plate_width - corner_radius, 0])
                    cylinder(r=corner_radius, h=plate_depth + 1, $fn=64);
                translate([plate_length - corner_radius, plate_width - corner_radius, 0])
                    cylinder(r=corner_radius, h=plate_depth + 1, $fn=64);
            }
    }

    // Retaining lip — sits at top of frame, extends over plate pocket edges
    // Bottom strip (full length)
    translate([0, 0, frame_thick - lip_thick])
        cube([frame_length, border_y + lip_overhang, lip_thick]);

    // Left side strip
    translate([0, 0, frame_thick - lip_thick])
        cube([border_x + lip_overhang, lip_side_height, lip_thick]);

    // Right side strip
    translate([frame_length - border_x - lip_overhang, 0, frame_thick - lip_thick])
        cube([border_x + lip_overhang, lip_side_height, lip_thick]);
}
