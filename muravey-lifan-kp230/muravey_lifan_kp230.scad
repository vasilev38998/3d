$fn=128;

// Муравей / Lifan KP230 — SOLID100 v9
// One single manifold model. No separate bodies, no gaps, no hidden support.
// The relief overlaps the base internally by 0.01 mm before CGAL union so the
// exported STL has one continuous solid without a coincident interface plane.
// Recommended slicing profile is fixed 0.20 mm, 100% infill, bottom shell
// thickness 2.00 mm / 10 layers, top shell layers 0, Classic wall generator.

W=160;
center_r=28.5;
base_h=2.00;
relief_h=1.00;
join_overlap=0.01;
hole_d=4.6;
hole_x=73.8;
ring_od=9.2;
frame_w=1.75;
font_main="DejaVu Sans Condensed:style=Bold Oblique";
font_right="DejaVu Sans Condensed:style=Bold Oblique";

module wing_left_raw(){
    polygon(points=[[-80,0],[-73.2,16.8],[-31,16.8],[-26,20.6],[-22,20.6],[-22,-20.6],[-26,-20.6],[-31,-16.8],[-73.2,-16.8]]);
}
module plaque_raw2d(){ union(){ circle(r=center_r); wing_left_raw(); mirror([1,0,0]) wing_left_raw(); } }
module plaque2d(){ offset(r=0.9) offset(delta=-0.9) plaque_raw2d(); }
module frame2d(){ difference(){ plaque2d(); offset(delta=-frame_w) plaque2d(); } }
module capsule(p1,p2,d=1.4){ hull(){ translate(p1) circle(d=d); translate(p2) circle(d=d); } }
module polyline(points,d=1.4){ for(i=[0:len(points)-2]) capsule(points[i],points[i+1],d); }

module gear2d(){
    difference(){
        union(){
            difference(){ circle(r=22.1); circle(r=18.25); }
            for(a=[0:30:330]) rotate(a) translate([22.5,0]) square([6,5.2],center=true);
        }
        circle(r=18.25);
    }
}
module ant2d(){
    difference(){
        union(){
            translate([-8.6,-0.4]) scale([1.35,1]) circle(r=4.65);
            translate([-2,0.1]) circle(r=3);
            capsule([-5.2,0],[-2,0.1],1.8);
            translate([4,3.2]) scale([1.15,0.92]) circle(r=3.55);
            capsule([0.2,1],[2.3,2.4],1.8);
            polyline([[-2.8,-1.1],[-6.3,-4.5],[-10,-7.2]],1.35);
            polyline([[-1.7,-1.8],[-3,-6.2],[-5.4,-9.2]],1.35);
            polyline([[-0.2,-1.7],[1.2,-6.2],[3.6,-9.7]],1.35);
            polyline([[0.2,-1.1],[4,-4.2],[7.8,-7.4]],1.35);
            polyline([[0.6,0.1],[4.7,-0.7],[8.2,-3.1]],1.35);
            polyline([[-2.4,0.9],[-5.5,2.7],[-8.5,3.4]],1.35);
            polyline([[5.6,5.3],[7,9.7],[11,10.6]],1.35);
            polyline([[6.3,5],[9.3,8],[12,6.6]],1.35);
        }
        translate([5,3.7]) circle(d=1.35);
    }
}
module stripe_pair(side=1){ x1=32*side; x2=68.5*side; for(y=[12.2,14.55,-12.2,-14.55]) capsule([x1,y],[x2,y],1.05); }
module left_text2d(){ translate([-49.5,-0.2]) scale([0.47,1]) offset(delta=0.12) text("МУРАВЕЙ",size=12.6,font=font_main,halign="center",valign="center",spacing=0.96); }
module right_text2d(){ translate([48.8,-0.25]) scale([0.42,1]) offset(delta=0.18) text("Lifan KP230",size=11.7,font=font_right,halign="center",valign="center",spacing=0.92); }
module hole_rings2d(){ for(x=[-hole_x,hole_x]) translate([x,0]) difference(){ circle(d=ring_od); circle(d=hole_d+1.10); } }
module details2d(){ union(){ frame2d(); gear2d(); ant2d(); stripe_pair(-1); stripe_pair(1); left_text2d(); right_text2d(); hole_rings2d(); } }
module through_holes(hh){ for(x=[-hole_x,hole_x]) translate([x,0,-0.2]) cylinder(h=hh+0.4,d=hole_d); }

module single_solid(){
    render(convexity=30)
    difference(){
        union(){
            linear_extrude(height=base_h,convexity=10) plaque2d();
            translate([0,0,base_h-join_overlap])
                linear_extrude(height=relief_h+join_overlap,convexity=20) details2d();
        }
        through_holes(base_h+relief_h);
    }
}

part="solid100"; // solid100 | preview
if(part=="solid100") single_solid();
else if(part=="preview") color([0.25,0.25,0.25]) single_solid();
