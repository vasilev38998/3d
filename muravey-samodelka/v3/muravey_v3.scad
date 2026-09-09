$fn=128;
W=160.00000;
H=38.50394;
base_silver_h=2.00;
black_inlay_h=0.40;
relief_h=0.95;
frame_top_h=1.20;
hole_d=4.20;
hole_x=74.35;
ring_outer_d=9.20;

// Final print-safe artwork tuning for a 0.4 mm nozzle.
// IMPORTANT: there is only ONE subtitle. We preserve the original traced
// artwork exactly in its original location/orientation and only thicken it.
detail_print_boost=0.20;

module outline2d() {
  translate([-W/2,H/2]) scale([1,-1]) import("outline_v3.svg", convexity=20);
}
module panel2d() { offset(delta=-1.75) outline2d(); }
module frame2d() { difference() { outline2d(); offset(delta=-1.75) outline2d(); } }

module original_artwork2d() {
  // Correct orientation: ant on the LEFT, text readable left-to-right.
  mirror([1,0,0])
    translate([-W/2,H/2]) scale([1,-1]) import("details_v3.svg", convexity=20);
}

module details2d() {
  // A small uniform offset makes the original thin subtitle and fine ant
  // strokes robust for FDM printing, without adding/replacing any lettering.
  offset(delta=detail_print_boost) original_artwork2d();
}

module ring2d() {
  for(x=[-hole_x,hole_x])
    translate([x,0]) difference(){circle(d=ring_outer_d);circle(d=hole_d+1.20);}
}
module holes3d(hh) {
  for(x=[-hole_x,hole_x]) translate([x,0,-0.1]) cylinder(h=hh+0.2,d=hole_d);
}

module silver_part() {
  difference() {
    union() {
      linear_extrude(base_silver_h) outline2d();
      translate([0,0,base_silver_h]) linear_extrude(frame_top_h) union(){frame2d();ring2d();}
      translate([0,0,base_silver_h+black_inlay_h]) linear_extrude(relief_h) details2d();
    }
    holes3d(base_silver_h+frame_top_h+relief_h);
  }
}
module black_part() {
  difference() {
    translate([0,0,base_silver_h]) linear_extrude(black_inlay_h)
      difference() {
        panel2d();
        for(x=[-hole_x,hole_x]) translate([x,0]) circle(d=ring_outer_d+0.25);
      }
    holes3d(base_silver_h+black_inlay_h);
  }
}
module combined() {
  difference() {
    union() {
      linear_extrude(base_silver_h+black_inlay_h) outline2d();
      translate([0,0,base_silver_h+black_inlay_h-0.03])
        linear_extrude(relief_h+0.03)
          union(){ frame2d(); ring2d(); details2d(); }
    }
    holes3d(base_silver_h+black_inlay_h+relief_h);
  }
}

part = "combined"; // combined | silver | black
if(part=="combined") combined();
else if(part=="silver") silver_part();
else if(part=="black") black_part();
