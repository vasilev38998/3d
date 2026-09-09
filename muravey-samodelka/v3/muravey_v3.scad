$fn=128;
W=160.00000;
H=38.50394;
base_h=2.00;
nominal_relief_h=1.00;
interface_gap=0.05;
relief_z=base_h+interface_gap;
relief_geom_h=nominal_relief_h-interface_gap;
hole_d=4.20;
hole_x=74.35;
ring_outer_d=9.20;
frame_w=1.75;
detail_print_boost=0.20;

// STRICT FLAT BASE revision.
// Layers up to Z=2.00 are a completely uninterrupted substrate.
// A deliberate 0.05 mm geometric separation (smaller than a 0.20 mm print
// layer) makes Z=2.00 a true full TOP surface in the slicer. The raised shell
// begins at Z=2.05 and is still printed on the immediately following layer.

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
    translate([0,0,relief_z])
      linear_extrude(height=relief_geom_h, convexity=20) silver_details2d();
    holes3d(base_h+nominal_relief_h);
  }
}
module strictflat() {
  // Two disconnected shells inside one model file. This is intentional:
  // the substrate top at Z=2.00 must remain an external surface everywhere
  // so the slicer prints a full uninterrupted top skin before the relief.
  difference() {
    union() {
      linear_extrude(height=base_h, convexity=10) outline2d();
      translate([0,0,relief_z])
        linear_extrude(height=relief_geom_h, convexity=20) silver_details2d();
    }
    holes3d(base_h+nominal_relief_h);
  }
}

part="combined"; // combined | strictflat | silver | black
if(part=="combined" || part=="strictflat") strictflat();
else if(part=="silver") silver_part();
else if(part=="black") black_part();
