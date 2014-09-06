use <MCAD/regular_shapes.scad>

// Constants.  Measurements are in millimeters.  I am not too many
// millimeters.
finger_radius = 9.16;
ring_radius = finger_radius * 1.25;

bolt_radius = 0.82 * ring_radius;
thread_radius = 1.02 * bolt_radius;

ring_height = finger_radius * 0.6;
inset_height = 0.2 * ring_height;
nut_height = (ring_height - inset_height) / 2;

taper_height = ring_height * 0.05;
taper_scale = 0.96;

num_threads = 32;

// Smooth out curves.
$fn = 180;

module taper() {
  difference() {
    linear_extrude(height = taper_height, scale = taper_scale)
        octagon(radius = ring_radius);
    cylinder(r = finger_radius, height = taper_height);
  }
}

module flat_nut_body() {
  difference() {
    octagon(radius = ring_radius);
    circle(r = finger_radius);
  }
}

module nut() {
  linear_extrude(height = nut_height - taper_height) flat_nut_body();
  translate(v = [0, 0, nut_height - taper_height]) taper();
  mirror([0, 0, 1]) taper();
}

module bolt() {
  difference() {
    cylinder(h = ring_height, r = bolt_radius);
    cylinder(h = ring_height, r = finger_radius);
  }
}

module thread_base() {
  linear_extrude(height = ring_height,
                 twist = -90,
                 center = true,
                 slices = 20) {
    translate(v = [0, thread_radius, 0]) square(0.5, center = true);
  }
}

module thread() {
  translate(v = [0, 0, ring_height / 2]) thread_base();
}

union() {
  bolt();
  for (i = [0 : num_threads]) {
    rotate(a = i * 360 / num_threads, v = [0, 0, 1]) thread();
  }
  nut();
  translate(v = [0, 0, ring_height - nut_height]) nut();
}
