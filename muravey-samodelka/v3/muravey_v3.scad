$fn=128;
W=160.00000;
H=38.50394;
base_h=2.00;
relief_h=1.00;
hole_d=4.20;
hole_x=74.35;
ring_outer_d=9.20;
frame_w=1.75;
detail_print_boost=0.20;

// FLAT BASE revision:
// Z=0..2.00 mm is one uninterrupted substrate.
// The frame, rings, ant and lettering start exactly at Z=2.00 mm.
// Nothing decorative is recessed into the substrate.

module outline2d() {
  translate([-W/2,H/2]) scale([1,-1]) import("outline_v3.svg", convexity=20);
}
module frame2d() {
  difference() { outline2d(); offset(delta=-frame_w) outline2d(); }
}
module original_artwork2d() {
  mirror([1,0,0])
    translate([-W/2,H/2]) scale([1,-1]) import("details_v3.svg", convexity=20);
}
module details2d() {
  offset(delta=detail_print_boost) original_artwork2d();
}
module ring2d() {
  for(x=[-hole_x,hole_x])
    translate([x,0]) difference(){ circle(d=ring_outer_d); circle(d=hole_d+1.20); }
}
module silver_details2d() {
  union(){ frame2d(); ring2d(); details2d(); }
}
module holes3d(hh) {
  for(x=[-hole_x,hole_x]) translate([x,0,-0.1]) cylinder(h=hh+0.2,d=hole_d);
}

module black_part() {
  difference() {
    linear_extrude(height=base_h, convexity=10) outline2d();
    holes3d(base_h);
  }
}
module silver_part() {
  difference() {
    translate([0,0,base_h])
      linear_extrude(height=relief_h, convexity=20) silver_details2d();
    holes3d(base_h+relief_h);
  }
}
module combined() {
  difference() {
    union() {
      // Completely flat, uninterrupted substrate.
      linear_extrude(height=base_h, convexity=10) outline2d();
      // Raised details begin only on the finished top plane.
      translate([0,0,base_h])
        linear_extrude(height=relief_h, convexity=20) silver_details2d();
    }
    holes3d(base_h+relief_h);
  }
}

part="combined"; // combined | silver | black
if(part=="combined") combined();
else if(part=="silver") silver_part();
else if(part=="black") black_part();
