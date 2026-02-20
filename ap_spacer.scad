// ============================================
// AP Spacer
// ============================================

// --- Configurable Parameters ---

// Width of the spacer
spacer_width = 100;         // mm

// Length of the spacer
spacer_length = 50;        // mm

// Thickness of the spacer
spacer_thickness = 5;      // mm

// Corner radius
corner_radius = 3;         // mm

// --- Bolt Hole Parameters ---

// Bolt hole diameter
hole_diameter = 5;         // mm

// Distance from top edge to top hole center
hole_edge_distance = 10;   // mm

// Distance between hole centers
hole_spacing = 80;         // mm

// Countersink diameter
countersink_diameter = 10; // mm

// Countersink depth
countersink_depth = 2;     // mm

// --- Center Hole Parameters ---

// Center hole diameter
center_hole_diameter = 35; // mm

// Distance from top edge to center hole
center_hole_distance = 50; // mm

// Resolution
$fn = 60;

// --- Spacer ---

module spacer() {
    difference() {
        // Base plate with rounded corners
        linear_extrude(height=spacer_thickness)
            offset(r=corner_radius)
            square([spacer_length - 2 * corner_radius,
                    spacer_width - 2 * corner_radius], center=true);

        // Top hole: pinned to edge distance
        top_hole_y = spacer_width / 2 - hole_edge_distance;
        // Bottom hole: spaced from top hole
        bottom_hole_y = top_hole_y - hole_spacing;

        // Center hole
        translate([0, spacer_width / 2 - center_hole_distance, -0.1])
            cylinder(h=spacer_thickness + 0.2, d=center_hole_diameter);

        for (y = [top_hole_y, bottom_hole_y]) {
            // Through hole
            translate([0, y, -0.1])
                cylinder(h=spacer_thickness + 0.2, d=hole_diameter);

            // Countersink from the top
            translate([0, y, spacer_thickness - countersink_depth])
                cylinder(h=countersink_depth + 0.1, d=countersink_diameter);
        }
    }
}

spacer();
