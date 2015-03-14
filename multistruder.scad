//Configuration

//bowden tube dimensions
	//uncomment these for 1.75mm filament
	fil_dia = 1.75;
	tube_od = 4;
	tube_id = 2;

	//uncomment these for 2.85mm filament
	//fil_dia = 2.85;
	//tube_od = 5;
	//tube_id = 3;

tube_len = 10; //amount of tubing that passes up out of the hotend and into the block
tube_tol = 0.5; //extra space around bowden tube on all sides so fit isn't too tight

pneufit_d = 9; //size of pneumatic fitting screw
pneufit_depth = 5; //depth of pneumatic fitting hole

filament_tol = 1; //extra diameter in filament path

manifold_angle = 11;
input_count = 4;
input_len = 14;


testing=false; //if true, the mount part is left off


include <MCAD/nuts_and_bolts.scad>

difference() {
mount() {
	difference() {
		//outer shell
		union() {
			//vertical part coming up from the base
			cylinder(d1=15,d2=15,h=tube_len+4);
			
			translate([0,0,tube_len+4]) {
				sphere(d=10);

				//filament path shell
				for(i = [0:input_count]) { //iterate through filament inputs
					rotate([0,0,(360/input_count) * i]) {
						rotate([manifold_angle,0,0]) {
							cylinder(d=15,h=input_len);
							//second "segment"
							translate([0,0,input_len]) {
								sphere(d=15);
								rotate([manifold_angle,0,0]) {
									difference() {
										cylinder(d=15,h=input_len + pneufit_depth + 2);
										//hole for pneumatic fitting
										translate([0,0,input_len + 2])
											cylinder(d = pneufit_d, h = pneufit_depth + 1);
										//hole for bowden tube to go further in
										translate([0,0,input_len - 2]) {
											$fn = 20;
											cylinder(d = tube_od + tube_tol * 2, h = 4.1);
											//fillet the hole a little
											translate([0,0,-1]) cylinder(d1 = tube_id + filament_tol, d2 = tube_od + tube_tol * 2, h = 1.01);
										}
									}
								}
							}
						}
					}
				}
				
				//left filament path
				//rotate([manifold_angle,0,0]) cylinder(d=10,h=input_len);
				//right path
				//rotate([-manifold_angle,0,0]) cylinder(d=10,h=input_len);
			}
		}
		
		//inner tube
		cylinder(h=tube_len, d=tube_od + tube_tol*2, $fn=20);
		//bare filament path
		cylinder(h=tube_len + 4, d=tube_id + filament_tol, $fn=20);

		translate([0,0,tube_len+4]) {
			$fn=20;
			sphere(d=tube_id + filament_tol);
			
			//remove the "point" in the path
			if (input_count >= 3)
				translate([0,0,input_len/2 - 2]) cylinder(d=tube_id + filament_tol, h=3.9);
			if (input_count >= 4)
				translate([0,0,input_len/2 - 2]) cylinder(d=tube_id + filament_tol, h=5.9);

			//filament path
			for(i = [0:input_count]) {
				rotate([0,0,(360/input_count) * i]) {
					rotate([manifold_angle,0,0]) {
						cylinder(d=tube_id + filament_tol,h=input_len);
						//second "segment"
						translate([0,0,input_len]) {
							sphere(d=tube_id + filament_tol);
							rotate([manifold_angle,0,0]) {
								cylinder(d=tube_id + filament_tol, input_len + 1);
							}
						}
					}
				}
			}
		}
		
		//vent holes?
		//translate([0,0,tube_len/2]) rotate([0,90,0]) cylinder(h=20, d=tube_od - 1, center=true);
		//translate([0,0,tube_len/2]) rotate([90,0,0]) cylinder(h=20, d=tube_od - 1, center=true);
	}
}

//cutaway so you can see what's going on inside
*translate([10, -1,-1]) cube([100,100,100]);

if(testing==true) {
	translate([-1,-1,-1]) cube([100,100,20]);
}
}

module mount(groovemount=true) {
	//mounting dimensions
	hole_dist = 50;
	base_thick=10;
	base_w = 20;
	base_l = 60;

	//hotend dimensions – standard groovemount (http://reprap.org/wiki/Groove_Mount)
	hotend_d = 16.2;
	hotend_above_mount = 4.8; //thickness of the part of the hotend that sticks above the mounting plate
	hotend_groove_d = 12;
	hotend_groove_thick = 4.75;

	hotend_tol = 0.1;
	
	difference() {
		//base rectangle
		cube([base_w, base_l, base_thick]);

		//bolt holes
		translate([base_w / 2, base_l / 2, 0]) {
			translate([0, -hole_dist / 2, 0]) {
				boltHole(size = 4, length = base_thick);
				translate([0,0,base_thick - METRIC_NUT_THICKNESS[4]]) nutHole(size = 4);
			}
			translate([0, hole_dist / 2, 0]) {
				boltHole(size = 4, length = base_thick);
				translate([0,0,base_thick - METRIC_NUT_THICKNESS[4]]) nutHole(size = 4);
			}
		}
	
		//space for upper part of hotend if using normal groovemount
		if(groovemount == true) {
			translate([base_w / 2, base_l / 2, -0.01]) {
				cylinder(d = hotend_d + hotend_tol*2, h = hotend_above_mount + hotend_tol);
			}
		}

		//filament path
		translate([base_w/2, base_l/2, -0.01]) {
			cylinder(d = tube_od + tube_tol*2, h = base_thick + 0.02, $fn=20);
		}
	}

	translate([base_w / 2, base_l / 2, base_thick]) {
		children();
	}
}
