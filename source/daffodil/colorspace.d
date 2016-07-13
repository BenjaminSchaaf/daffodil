module daffodil.colorspace;

import std.conv;
import std.string;
import std.algorithm;

/**
 * A group of functions describing the operations for a :d:struct:`Pixel`.
 */
struct ColorSpace {
    void function(const real[], const real, real[]) opScalarMul;
    void function(const real[], const real[], real[]) opColorAdd;
    string function(const real[]) toString;
}

/// Standard RGB color space
const RGB = ColorSpace(
    (const real[] self, const real other, real[] target) {
        assert(self.length == target.length);

        foreach (index; 0..self.length) {
            target[index] = cast(real)(self[index] * other);
        }
    },
    (const real[] self, const real[] other, real[] target) {
        assert(self.length == target.length);
        assert(self.length == other.length);
        foreach (index; 0..self.length) {
            target[index] = cast(real)min(self[index] + other[index], real.max);
        }
    },
    (const real[] self) {
        auto values = self.map!(to!string);
        return "(" ~ values.join(", ") ~ ")";
    }
);
