$fn=96;
nominal_width = 160.4;
target_width = 160;
base_thickness = 2.4;
relief_height = 0.9;
hole_diameter = 4.2;
xy_scale = target_width / nominal_width;

module plaque2d() {
  offset(r=1.2) polygon(points=[
    [-77,-15.3],[-79,-7.0],[-78,7.5],[-74,13.7],[-9,21.4],[0,22.0],[9,21.4],[74,13.7],[78,7.5],[79,-7.0],[77,-15.3],[9,-21.0],[0,-21.6],[-9,-21.0]
  ]);
}
module frame2d() {
  difference(){
    offset(delta=-1.1) plaque2d();
    offset(delta=-3.0) plaque2d();
  }
}
module nominal_badge(){
  difference(){
    union(){
      linear_extrude(height=base_thickness) plaque2d();
      translate([0,0,base_thickness]) linear_extrude(height=relief_height) union(){
        frame2d();
        translate([-80,-22.5]) import("details.svg", convexity=20);
        for (x=[-73.35,73.35]) difference(){ circle(d=9.0); circle(d=5.6); }
      }
    }
    for (x=[-73.35,73.35]) translate([x,0,-0.1]) cylinder(h=base_thickness+relief_height+0.2,d=hole_diameter);
  }
}
scale([xy_scale,xy_scale,1]) nominal_badge();
