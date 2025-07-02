use <kumiko.scad>

// Dimensions
width = 175;
height = 46.6;
thickness = 8;
frame_thickness = 4;
angle = 15;

// M3 screw holder parameters
m3_hole_diameter = 3;
m3_head_diameter = 6;
m3_holder_extra_thickness = 2;
m3_holder_diameter = m3_head_diameter + m3_holder_extra_thickness;
m3_holder_radius = m3_holder_diameter / 2;
m3_hole_radius = m3_hole_diameter / 2;
m3_head_radius = m3_head_diameter / 2;
m3_head_holder_thickness = 3;
m3_hole_offset_x = 30;
m3_hole_offset_y = 16.5;

//stands parameters
stand_thiskness = frame_thickness; // thickness of the stand

back_stand_width = 50;
back_stand_height = sin(angle) * width;
back_stand_x_offset = sin(angle) * stand_thiskness;

// Reference point for the panel
back_stand_top_right_x =  width;
back_stand_top_right_y =  0;
back_stand_base_right_x =  -back_stand_height;
back_stand_base_right_y =  -back_stand_height;




// === MODULE: design the panel flat ===
module base_frame() {
    // Frame plate with hollow center
    difference() {
        plain_frame();
        whole_emptiness();
    }
    
}

module plain_frame() {
    // Frame plate with hollow center
   cube([width, height, thickness]);
   frame_back_stand();
}

module plain_frame_emptiness() {
    // Frame plate with hollow center
    translate([frame_thickness, frame_thickness, 0])
            cube([width - 2*frame_thickness, height - 2*frame_thickness, thickness]);
}

module whole_emptiness() {
    // The shape to be cut out from the frame
    union() {
        plain_frame_emptiness();
        x_length_to_cut = back_stand_width - stand_thiskness * 2; // length of the cut in the frame
        translate([width - x_length_to_cut - stand_thiskness, 0, 0]) {
            cube([x_length_to_cut, frame_thickness, thickness]); // to ensure the cut goes through
        }
        frame_back_stand_emptiness();
    }
}



// === MODULE: design the frame stands ===
module frame_back_stand() {
    translate([width - back_stand_width, -back_stand_height, 0]) {
        rotate_about_pt(-angle,0,[back_stand_width,back_stand_height,thickness]) cube([back_stand_width, back_stand_height, thickness]);                     
    }
}

module frame_back_stand_emptiness() {
    translate([width - back_stand_width + stand_thiskness, -back_stand_height + stand_thiskness, 0]) {
        rotate_about_pt(-angle,0,[back_stand_width - stand_thiskness,back_stand_height - stand_thiskness,thickness])
            cube([back_stand_width -2*stand_thiskness, back_stand_height - stand_thiskness, thickness]);                     
    }
}



// === MODULE: design the screw holders ===
module screw_holder(x, y) {
    translate([x, y, 0])
        difference() {
            cylinder(h = thickness, r = m3_holder_radius, $fn = 40);  // outer holder
            translate([0, 0, m3_head_holder_thickness]) {
                cylinder(h = thickness - m3_head_holder_thickness, r = m3_head_radius, $fn = 40); // head holder
            }
            cylinder(h = thickness, r = m3_hole_radius, $fn = 40); // hole
        }
}

module screw_holders() {
    screw_holder(m3_hole_offset_x, height - m3_hole_offset_y); // Left 
    screw_holder(width - m3_hole_offset_x, height - m3_hole_offset_y); // Right
}

module screw_holders_holes() {
    translate([m3_hole_offset_x, height - m3_hole_offset_y, 0]) {
      cylinder(h = thickness, r = m3_holder_radius, $fn = 40);
    }
    translate([width - m3_hole_offset_x, height - m3_hole_offset_y, 0]) {
      cylinder(h = thickness, r = m3_holder_radius, $fn = 40);
    }
}



// === MODULE: design the asanoha pattern with screw holes ===
module asanoha_pattern_with_scre_holes () {
    // difference(){
    //   translate([frame_thickness, frame_thickness, 0])
    //     difference() {
    //         whole_emptiness();
    //         translate([-2, -25, 0])
    //             linear_extrude(height = thickness)  // 2 units deep cut
    //                 asanoha(cellSize=16.65, widthInCells=15, heightInCells=16, strength=1.5, fillingStrength=2);  
           
    //     }
    //   screw_holders_holes();

       difference() {
            whole_emptiness();
            translate([-2, -40, 0])
                linear_extrude(height = thickness)  // 2 units deep cut
                    asanoha(cellSize=16.65, widthInCells=15, heightInCells=16, strength=1.5, fillingStrength=2);
            screw_holders_holes();
       }
    //}
}

// Final placement: rotate the entire part
rotate([0, 0, 0]) { // rotate around X to stand it up
        //intersection() {
        base_frame();
        asanoha_pattern_with_scre_holes();
        screw_holders();
}



// Helpers

module rotate_about_pt(z, y, pt) {
    translate(pt)
        rotate([0, y, z]) // CHANGE HERE
            translate(-pt)
                children();   
}



