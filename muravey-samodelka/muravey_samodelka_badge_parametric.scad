$fn=128;
W=160.00000;
H=45.32348;
base_thickness=2.4;
relief_height=0.85;
hole_diameter=4.2;
hole_x=74.0;

module plaque_raw() {
  polygon(points=[
    [0,H/2],
    [73.3,13.35],[75.7,12.0],[79.35,3.0],[80,0],[79.35,-3.2],[75.7,-12.3],[73.3,-13.5],
    [0,-H/2],
    [-73.3,-13.5],[-75.7,-12.3],[-79.35,-3.2],[-80,0],[-79.35,3.0],[-75.7,12.0],[-73.3,13.35]
  ]);
}
module plaque2d() {
  // Round only the corners while keeping the long edges perfectly straight.
  offset(r=0.75) offset(delta=-0.75) plaque_raw();
}
module frame2d() {
  difference() {
    offset(delta=-0.45) plaque2d();
    offset(delta=-1.90) plaque2d();
  }
}
module details2d() {
  translate([-W/2,-H/2]) import("details_v2.svg", convexity=20);
}
module hole_rings2d() {
  for (x=[-hole_x,hole_x])
    translate([x,0]) difference() { circle(d=9.0); circle(d=5.8); }
}

difference() {
  union() {
    linear_extrude(height=base_thickness, convexity=10) plaque2d();
    translate([0,0,base_thickness])
      linear_extrude(height=relief_height, convexity=20)
        union() { frame2d(); details2d(); hole_rings2d(); }
  }
  for (x=[-hole_x,hole_x])
    translate([x,0,-0.2]) cylinder(h=base_thickness+relief_height+0.4,d=hole_diameter);
}
