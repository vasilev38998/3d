$fn=128;

// Муравей / Lifan KP230 — SURFACEFIX 0.20 v6
// Workaround for Bambu Studio raised-detail top-surface artifacts.
//
// BASE: full independent solid Z=0.00..2.00 mm.
// RELIEF component:
//   hidden inset support core Z=2.00..2.10 mm (half of a 0.20 mm layer)
//   full visible relief          Z=2.10..3.00 mm
//
// The support core is inset from every decorative edge by ~one extrusion
// line. It gives the first visible relief layer something to bond to while
// keeping the base top recognized as a continuous top surface by the slicer.

W = 160;
center_r = 28.5;
base_h = 2.00;
layer_h = 0.20;
support_h = 0.10;
support_inset = 0.35;
relief_main_z = base_h + support_h;
relief_main_h = 0.90;
hole_d = 4.6;
hole_x = 73.8;
ring_od = 9.2;
frame_w = 1.75;

font_main = "DejaVu Sans Condensed:style=Bold Oblique";
font_right = "DejaVu Sans Condensed:style=Bold Oblique";

module wing_left_raw() {
    polygon(points=[
        [-80.0,0.0],[-73.2,16.8],[-31.0,16.8],[-26.0,20.6],[-22.0,20.6],
        [-22.0,-20.6],[-26.0,-20.6],[-31.0,-16.8],[-73.2,-16.8]
    ]);
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
            for(a=[0:30:330]) rotate(a) translate([22.5,0]) square([6.0,5.2],center=true);
        }
        circle(r=18.25);
    }
}

module ant2d(){
    difference(){
        union(){
            translate([-8.6,-0.4]) scale([1.35,1.0]) circle(r=4.65);
            translate([-2.0,0.1]) circle(r=3.0);
            capsule([-5.2,0],[-2.0,0.1],1.8);
            translate([4.0,3.2]) scale([1.15,0.92]) circle(r=3.55);
            capsule([0.2,1.0],[2.3,2.4],1.8);
            polyline([[-2.8,-1.1],[-6.3,-4.5],[-10.0,-7.2]],1.35);
            polyline([[-1.7,-1.8],[-3.0,-6.2],[-5.4,-9.2]],1.35);
            polyline([[-0.2,-1.7],[1.2,-6.2],[3.6,-9.7]],1.35);
            polyline([[0.2,-1.1],[4.0,-4.2],[7.8,-7.4]],1.35);
            polyline([[0.6,0.1],[4.7,-0.7],[8.2,-3.1]],1.35);
            polyline([[-2.4,0.9],[-5.5,2.7],[-8.5,3.4]],1.35);
            polyline([[5.6,5.3],[7.0,9.7],[11.0,10.6]],1.35);
            polyline([[6.3,5.0],[9.3,8.0],[12.0,6.6]],1.35);
        }
        translate([5.0,3.7]) circle(d=1.35);
    }
}

module stripe_pair(side=1){
    x1=32.0*side; x2=68.5*side;
    for(y=[12.2,14.55,-12.2,-14.55]) capsule([x1,y],[x2,y],1.05);
}
module left_text2d(){
    translate([-49.5,-0.2]) scale([0.47,1.0]) offset(delta=0.12)
        text("МУРАВЕЙ",size=12.6,font=font_main,halign="center",valign="center",spacing=0.96);
}
module right_text2d(){
    translate([48.8,-0.25]) scale([0.42,1.0]) offset(delta=0.18)
        text("Lifan KP230",size=11.7,font=font_right,halign="center",valign="center",spacing=0.92);
}
module hole_rings2d(){
    for(x=[-hole_x,hole_x]) translate([x,0]) difference(){ circle(d=ring_od); circle(d=hole_d+1.10); }
}
module details2d(){
    union(){ frame2d(); gear2d(); ant2d(); stripe_pair(-1); stripe_pair(1); left_text2d(); right_text2d(); hole_rings2d(); }
}

// Hidden footprint under the visible relief. Thin details may disappear after
// this inward offset; that is intentional. The remaining core is only a bond
// aid and is entirely concealed by the full detail above it.
module support_core2d(){ offset(delta=-support_inset) details2d(); }

module through_holes(hh){ for(x=[-hole_x,hole_x]) translate([x,0,-0.2]) cylinder(h=hh+0.4,d=hole_d); }

module base_part(){
    difference(){
        linear_extrude(height=base_h,convexity=10) plaque2d();
        through_holes(base_h);
    }
}
module support_part(){
    difference(){
        translate([0,0,base_h]) linear_extrude(height=support_h,convexity=20) support_core2d();
        through_holes(base_h+support_h);
    }
}
module visible_relief_part(){
    difference(){
        translate([0,0,relief_main_z]) linear_extrude(height=relief_main_h,convexity=20) details2d();
        through_holes(3.0);
    }
}
module relief_component(){ union(){ support_part(); visible_relief_part(); } }

part="preview"; // base | support | reliefmain | relief | preview
if(part=="base") base_part();
else if(part=="support") support_part();
else if(part=="reliefmain") visible_relief_part();
else if(part=="relief") relief_component();
else if(part=="preview") { color([0.04,0.04,0.04]) base_part(); color([0.75,0.76,0.78]) relief_component(); }
