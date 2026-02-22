// ============================================
// Nose Cone Collar with Threaded Plug & Sled
// ============================================
// A collar that epoxies inside a nose cone,
// with a screw-in plug and electronics sled.
// ============================================

// --- Configurable Parameters ---

// Outer diameter of the collar (match nose cone ID)
collar_od = 65;            // mm

// Wall thickness of the collar
wall_thickness = 2.5;      // mm

// Height of the collar
collar_height = 20;        // mm

// Height of the plug (threaded portion)
plug_height = 20;          // mm

// Thread pitch (distance between threads)
thread_pitch = 3;          // mm

// Thread depth/thickness (radial depth of each thread)
thread_thickness = 1.0;    // mm

// Thread angle (profile angle in degrees)
thread_angle = 45;

// Clearance between mating threads
thread_clearance = 0.3;    // mm

// Plug cap thickness (solid top of the plug)
plug_cap_thickness = 4;    // mm

// Plug cap extends beyond collar OD by this amount
plug_cap_overhang = 1;     // mm

// Number of grip flutes around the cap edge
grip_count = 60;

// Radius of each grip flute (controls width and depth of groove)
grip_radius = 0.25;         // mm

// Center hole diameter for steel eyelet
eyelet_hole_diameter = 5;  // mm

// --- Sled Parameters ---

// Width of the sled (must be less than thread diameter)
sled_width = 50;           // mm (thread diameter is ~2*thread_ir)

// Length of the sled
sled_length = 100;          // mm

// Thickness of the sled platform
sled_thickness = 3;        // mm

// Bevel radius on the protruding ends
sled_bevel_radius = 5;     // mm

// Height of the side lips (curved walls on sled edges)
sled_side_height = 2;      // mm

// Thickness of the side lips
sled_side_thickness = 2;   // mm

// Length of the side lips
sled_side_length = 95;     // mm

// Resolution
$fn = 120;

// --- Derived Values ---

collar_ir = collar_od / 2 - wall_thickness;
collar_or = collar_od / 2;
thread_or = collar_ir - thread_clearance;  // external thread outer radius
thread_ir = thread_or - thread_thickness;  // external thread inner radius (plug body)

// Collar bore radius: clears the plug body but not the threads
collar_bore_r = thread_ir + thread_clearance;

// --- Module: Single thread profile (triangle) ---
module thread_profile(inner_r, outer_r, pitch, angle) {
    depth = outer_r - inner_r;
    half_width = pitch * 0.35;  // thread takes ~70% of pitch
    polygon([
        [inner_r, -half_width],
        [outer_r, 0],
        [inner_r, half_width]
    ]);
}

// --- Module: Helical thread sweep ---
// Creates threads by stacking rotated profiles along Z
module threads(inner_r, outer_r, pitch, height, starts=1) {
    turns = height / pitch;
    steps_per_turn = 60;
    total_steps = floor(turns * steps_per_turn);
    dz = height / total_steps;
    d_angle = 360 / steps_per_turn;
    depth = outer_r - inner_r;
    half_width = pitch * 0.35;

    for (s = [0 : starts-1]) {
        start_angle = s * (360 / starts);
        for (i = [0 : total_steps - 1]) {
            z1 = i * dz;
            z2 = (i + 1) * dz;
            a1 = start_angle + i * d_angle;
            a2 = start_angle + (i + 1) * d_angle;

            hull() {
                rotate([0, 0, a1])
                    translate([0, 0, z1])
                    rotate([90, 0, 0])
                    linear_extrude(height=0.01, center=true)
                    polygon([
                        [inner_r, -half_width],
                        [outer_r, 0],
                        [inner_r, half_width]
                    ]);
                rotate([0, 0, a2])
                    translate([0, 0, z2])
                    rotate([90, 0, 0])
                    linear_extrude(height=0.01, center=true)
                    polygon([
                        [inner_r, -half_width],
                        [outer_r, 0],
                        [inner_r, half_width]
                    ]);
            }
        }
    }
}

// --- Module: Collar ---
// Outer tube with internal thread grooves cut into the wall
module collar() {
    difference() {
        // Outer cylinder wall
        cylinder(h=collar_height, r=collar_or);

        // Bore: clears the plug body between threads
        translate([0, 0, -0.1])
            cylinder(h=collar_height + 0.2, r=collar_bore_r);

        // Helical groove: cut into the wall to receive plug threads
        threads(
            inner_r = thread_ir,
            outer_r = thread_or + thread_clearance,
            pitch = thread_pitch,
            height = collar_height
        );
    }
}

// --- Module: Sled ---
// Vertical plate with curved side lips, extending upward from the plug
module sled() {
    br = sled_bevel_radius;
    hw = sled_width / 2;
    ht = sled_thickness / 2;

    // Flat sled plate with beveled top corners
    hull() {
        // Bottom edge: flat rectangle flush with attachment point at z=0
        translate([-hw, -ht, 0])
            cube([sled_width, sled_thickness, 0.01]);

        // Top-left corner: rounded
        translate([-hw + br, 0, sled_length - br])
            rotate([90, 0, 0])
            cylinder(r=br, h=sled_thickness, center=true);

        // Top-right corner: rounded
        translate([hw - br, 0, sled_length - br])
            rotate([90, 0, 0])
            cylinder(r=br, h=sled_thickness, center=true);
    }

    // Side lips along the left and right edges of the sled
    // Curved by intersecting with the plug cylinder
    intersection() {
        cylinder(r=thread_ir, h=sled_side_length);

        // Two thin walls at the sled edges
        for (side = [-1, 1]) {
            translate([side > 0 ? hw - sled_side_thickness : -hw,
                       -(ht + sled_side_height), 0])
                cube([sled_side_thickness, sled_thickness + 2 * sled_side_height, sled_side_length]);
        }
    }
}

// --- Module: Plug ---
// Cylindrical plug with cap at base, threads above, and sled extending upward
module plug() {
    difference() {
        union() {
            // Cap at the base
            cylinder(h=plug_cap_thickness, r=collar_or + plug_cap_overhang);

            // Plug body (solid core) above the cap
            translate([0, 0, plug_cap_thickness])
                cylinder(h=plug_height, r=thread_ir);

            // External threads above the cap
            translate([0, 0, plug_cap_thickness])
                intersection() {
                    cylinder(h=plug_height, r=thread_or);
                    threads(
                        inner_r = thread_ir,
                        outer_r = thread_or,
                        pitch = thread_pitch,
                        height = plug_height
                    );
                }

            // Sled extending upward from top of threads
            translate([0, 0, plug_cap_thickness + plug_height])
                sled();
        }

        // Grip flutes around the cap edge
        for (i = [0 : grip_count - 1]) {
            rotate([0, 0, i * 360 / grip_count])
                translate([collar_or + plug_cap_overhang, 0, plug_cap_thickness / 2])
                    cylinder(r=grip_radius, h=plug_cap_thickness + 0.2, center=true);
        }

        // Center hole for steel eyelet through cap and threads only
        translate([0, 0, -0.1])
            cylinder(h=plug_cap_thickness + plug_height + 0.2, d=eyelet_hole_diameter);
    }
}

// --- Assembly / Display ---

// Show collar on the left
translate([-collar_od * 0.8, 0, 0]) {
    color("SteelBlue", 0.8)
        collar();
}

// Show plug on the right
translate([collar_od * 0.8, 0, 0]) {
    color("OrangeRed", 0.9)
        plug();
}
