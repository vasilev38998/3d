$fn=128;
W=160.00000;
H=38.50394;
base_silver_h=2.00;
black_inlay_h=0.40;
relief_h=0.80;
frame_top_h=1.20;
hole_d=4.20;
hole_x=74.35;
ring_outer_d=9.20;

// Readability-tuned subtitle for a 0.4 mm nozzle.
subtitle_text="САМОДЕЛКА";
subtitle_font="DejaVu Sans:style=Bold";
subtitle_size=6.20;
subtitle_spacing=1.10;
subtitle_x=31.5;
subtitle_y=-14.25;
subtitle_stroke_boost=0.14;

module outline2d() {
  translate([-W/2,H/2]) scale([1,-1]) import("outline_v3.svg", convexity=20);
}
module panel2d() { offset(delta=-1.75) outline2d(); }
module frame2d() { difference() { outline2d(); offset(delta=-1.75) outline2d(); } }

module legacy_details2d() {
  // SVG coordinates come from the image extraction. Flip Y for OpenSCAD,
  // then mirror X around the badge center so the ant stays on the LEFT
  // and the Cyrillic main title reads normally from left to right.
  mirror([1,0,0])
    translate([-W/2,H/2]) scale([1,-1]) import("details_v3.svg", convexity=20);
}

module artwork_without_old_subtitle2d() {
  // Remove only the thin traced subtitle. The ant, main title and divider
  // remain exactly as in the reference artwork.
  difference() {
    legacy_details2d();
    translate([31.5,-14.65]) square([62.0,8.1], center=true);
  }
}

module readable_subtitle2d() {
  // Bold native vector text + a small offset gives robust strokes that
  // slice as multiple extrusion lines instead of fragile single-line glyphs.
  translate([subtitle_x,subtitle_y])
    offset(delta=subtitle_stroke_boost)
      text(subtitle_text,
           size=subtitle_size,
           font=subtitle_font,
           halign="center",
           valign="center",
           spacing=subtitle_spacing);
}

module details2d() {
  union() {
    artwork_without_old_subtitle2d();
    readable_subtitle2d();
  }
}

module ring2d() { for(x=[-hole_x,hole_x]) translate([x,0]) difference(){circle(d=ring_outer_d);circle(d=hole_d+1.20);} }
module holes3d(hh) { for(x=[-hole_x,hole_x]) translate([x,0,-0.1]) cylinder(h=hh+0.2,d=hole_d); }

module silver_part() {
  difference() {
    union() {
      linear_extrude(base_silver_h) outline2d();
      translate([0,0,base_silver_h]) linear_extrude(frame_top_h) union(){frame2d();ring2d();}
      translate([0,0,base_silver_h+black_inlay_h]) linear_extrude(relief_h) details2d();
    }
    holes3d(base_silver_h+frame_top_h);
  }
}
module black_part() {
  difference() {
    translate([0,0,base_silver_h]) linear_extrude(black_inlay_h)
      difference() { panel2d(); for(x=[-hole_x,hole_x]) translate([x,0]) circle(d=ring_outer_d+0.25); }
    holes3d(base_silver_h+black_inlay_h);
  }
}
module combined() {
  difference() {
    union() {
      linear_extrude(base_silver_h+black_inlay_h) outline2d();
      translate([0,0,base_silver_h+black_inlay_h-0.03]) linear_extrude(relief_h+0.03)
        union(){ frame2d(); ring2d(); details2d(); }
    }
    holes3d(base_silver_h+black_inlay_h+relief_h);
  }
}

part = "combined"; // combined | silver | black
if(part=="combined") combined();
else if(part=="silver") silver_part();
else if(part=="black") black_part();
