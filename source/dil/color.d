module dil.color;

import std.format;

/**
 * RGBA floating point Color representation.
 * Uses largest hardware supported floating point size for maximum accuracy
 * Used by DIL for conversion between formats, especially external ones.
 */
struct Color {
    real red   = 0;
    real green = 0;
    real blue  = 0;
    real alpha = 1;

    this(real r, real g, real b, real a) {
        red   = r;
        green = g;
        blue  = b;
        alpha = a;
    }

    string toString() {
        return format("(%.2f, %.2f, %.2f, %.2f)", red, green, blue, alpha);
    }
}
