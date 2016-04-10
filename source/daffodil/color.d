module daffodil.color;

import std.math;
import std.range;
import std.format;
import std.array;
import std.algorithm;

/**
 * RGBA floating point Color representation.
 * Uses largest hardware supported floating point size for maximum accuracy
 * Used by DIL for conversion between formats, especially external ones.
 */
struct Color {
    alias color_t = real;

    private color_t[4] colors = [0, 0, 0, 1];

    // Make sure a color never has any nan values
    invariant {
        foreach (color; colors) {
            assert(!isNaN(color));
        }
    }

    /// Construct a new color given rgb[a] values.
    this(color_t r, color_t g, color_t b, color_t a = 1) {
        colors = [r, g, b, a];
    }
    /// ditto
    this(color_t[3] c) {
        colors[0..3] = c;
    }
    /// ditto
    this(color_t[4] c) {
        colors = c;
    }

    private ref inout(color_t) prop(size_t i)() inout {
        return colors[i];
    }

    alias red   = prop!0;
    alias green = prop!1;
    alias blue  = prop!2;
    alias alpha = prop!3;

    ref inout(color_t) opIndex(size_t i) inout {
        return colors[i];
    }

    /**
     * Standard vector color operations
     */
    auto opBinary(string op, T)(T rhs) const {
        static if (op == "*") return Color(red * rhs, green * rhs, blue * rhs, alpha * rhs);
        else static if (op == "+") return Color(zip(colors[], rhs.colors[]).map!(a => a[0] + a[1]).array[0..4]);
        else static assert(0, "Operator "~op~" not implemented");
    }
    /// ditto
    auto opBinaryRight(string op, T)(T rhs) const {
        return opBinary!op(rhs);
    }

    string toString() const {
        return format("Color(%.2f, %.2f, %.2f, %.2f)", red, green, blue, alpha);
    }
}
