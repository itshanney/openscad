/* PARAMETRIC ROCKET NOSE CONE
    A script to generate a hollow nose cone with an 
    adjustable shoulder (collar) for body tube fitment.
    Updated with Ogive (curved) geometry and a rounded internal attachment post.
*/

// --- PARAMETERS ---

// 1. General Smoothness
$fn = 120;              

// 2. Main Cone Dimensions
cone_height = 60;       // Height of the aerodynamic section
body_outer_dia = 29;    // Matches the outside of your rocket tube

// 3. Shoulder (Collar) Dimensions
shoulder_dia = 27.5;    // Adjust this to fit the INSIDE of your tube
shoulder_length = 15;   // How far it slides into the tube

// 4. Manufacturing Params
wall_thickness = 1.6;   // Thickness of the skin (e.g., 2 perimeters)

// 5. Attachment Post Params
post_diameter = 6.0;    // The diameter of the rounded bar

// --- MATH FOR OGIVE ---
R_base = body_outer_dia / 2;
rho = (pow(R_base, 2) + pow(cone_height, 2)) / (2 * R_base);

// --- CONSTRUCTION ---

module nose_cone() {
    union() {
        // --- MAIN HOLLOW BODY ---
        difference() {
            // OUTER SHAPE
            union() {
                // The Ogive Section (Curved)
                translate([0, 0, shoulder_length])
                rotate_extrude()
                intersection() {
                    translate([-(rho - R_base), 0])
                        circle(r = rho);
                    square([R_base, cone_height]);
                }
                
                // The Shoulder (Collar)
                cylinder(h = shoulder_length, d = shoulder_dia);
                
                // Transition Ring (The "Lip")
                translate([0, 0, shoulder_length - 0.1])
                    cylinder(h = 0.1, r1 = shoulder_dia / 2, r2 = body_outer_dia / 2);
            }

            // INNER VOID (Hollowing)
            union() {
                // Hollow out the ogive
                translate([0, 0, shoulder_length])
                    cylinder(
                        h = cone_height - wall_thickness, 
                        r1 = (body_outer_dia / 2) - wall_thickness, 
                        r2 = 0
                    );
                
                // Hollow out the shoulder
                translate([0, 0, -1])
                    cylinder(
                        h = shoulder_length + 1, 
                        r = (shoulder_dia / 2) - wall_thickness
                    );
            }
        }
        
        // --- CENTERED ROUNDED ATTACHMENT POST ---
        // A cylindrical bar that spans the inner diameter of the shoulder
        intersection() {
            // Limit the bar to the inner diameter of the shoulder
            cylinder(h = post_diameter, r = (shoulder_dia / 2));
            
            // The actual rounded bar (rotated 90 degrees)
            translate([0, 0, post_diameter / 2])
                rotate([0, 90, 0])
                    cylinder(h = shoulder_dia, d = post_diameter, center = true, $fn=60);
        }
    }
}

// Call the module
nose_cone();