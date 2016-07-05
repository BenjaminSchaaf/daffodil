/**
 * This module contains the implementation for the internal color storage
 * mechanisms.
 */
module daffodil.color;

import std.conv;
import std.math;
import std.array;
import std.format;
import std.traits;
import std.algorithm;

import daffodil.util.types;

/**
 * A group of functions describing the operations for a :d:struct:`Pixel`.
 */
struct ColorSpace(V) if (isColorValue!V) {
    void function(const V[], const real, V[]) opScalarMul;
    void function(const V[], const V[], V[]) opColorAdd;
    string function(const V[]) toString;
}

/**
 * The storage struct for a color.
 */
struct Pixel(V) if (isColorValue!V) {
    /// The type used to store individual values for a color
    alias Value = V;

    /// The values of the color
    Value[] values;

    /// The color space used for operations with the color
    const ColorSpace!V* colorSpace;

    alias values this;

    ///
    this(Value[] values, const ColorSpace!V* colorSpace) {
        this.values = values;
        this.colorSpace = colorSpace;
    }

    /// Ditto
    this(size_t size, const ColorSpace!V* colorSpace) {
        this(new Value[size], colorSpace);
    }

    ///
    Pixel!V opBinary(string op : "*")(const real other) const {
        auto ret = Pixel!V(this.length, colorSpace);
        colorSpace.opScalarMul(values, other, ret.values);
        return ret;
    }

    ///
    Pixel!V opBinary(string op : "+")(const Pixel!V other) const {
        // TODO: Check other.colorSpace
        auto ret = Pixel!V(this.length, colorSpace);
        colorSpace.opColorAdd(values, other, ret.values);
        return ret;
    }

    ///
    void opOpAssign(string op : "*")(const real other) {
        colorSpace.opScalarMul(values, other, values);
    }

    ///
    void opOpAssign(string op : "+")(const Pixel!V other) {
        colorSpace.opColorAdd(values, other, values);
    }

    ///
    void opAssign(const Pixel!V other) {
        assert(other.length == this.length);
        foreach (index; 0..this.length) {
            this[index] = other[index];
        }
    }

    /// Clear all the color values to 0
    void clear() {
        foreach (index; 0..this.length) {
            this[index] = 0;
        }
    }

    /// Return a duplicate color in the same color space
    @property auto dup() {
        return Pixel!V(values.dup, colorSpace);
    }
}

/// A color space implementation for RGB colors
@property auto RGB(V)() if (isColorValue!V) {
    static cache = ColorSpace!V(
        (const V[] self, const real other, V[] target) {
            assert(self.length == target.length);

            foreach (index; 0..self.length) {
                target[index] = cast(V)(self[index] * other);
            }
        },
        (const V[] self, const V[] other, V[] target) {
            assert(self.length == target.length);
            assert(self.length == other.length);
            foreach (index; 0..self.length) {
                target[index] = cast(V)min(self[index] + other[index], V.max);
            }
        },
        (const V[] self) {
            string output = "(";
            foreach (index; 0..self.length) {
                if (index == 0) output ~= ", ";
                output ~= realFromColorValue(self[index]).to!string;
            }
            return output ~ ")";
        },
    );

    return &cache;
}

template isColorValue(V) {
    enum isColorValue = isFloatingPoint!V ||
                        isIntegral!V && isUnsigned!V ||
                        isCustomColorValue!V;
}

@("isColorValue")
unittest {
    assert(isColorValue!ubyte);
    assert(isColorValue!uint);
    assert(isColorValue!ulong);
    assert(!isColorValue!int);
    assert(isColorValue!float);
}

template isCustomColorValue(V) {
    enum isCustomColorValue = is(typeof(
        (inout int = 0) {
            V v = V.init;
            v = V.fromReal(cast(real)1.0);
            real r = v.toReal();
        }
    ));
}

version(unittest) {
    private struct IntColorValue {
        int value = 0;

        static auto fromReal(real v) {
            return IntColorValue(cast(int)(v / int.max));
        }

        real toReal() {
            return cast(real)value / int.max;
        }
    }
}

@("isCustomColorValue")
unittest {
    assert(isCustomColorValue!IntColorValue);
    assert(isColorValue!IntColorValue);
}

V colorValueFromReal(V)(real value) if (isColorValue!V) {
    static if (isFloatingPoint!V) {
        return value;
    } else static if (isIntegral!V) {
        return cast(V)(V.max * value.clamp(0, 1));
    } else {
        return V.fromReal(value);
    }
}

real realFromColorValue(V)(V value) if (isColorValue!V) {
    static if (isFloatingPoint!V) {
        return value;
    } else static if (isIntegral!V) {
        return cast(real)value / V.max;
    } else {
        return value.toReal();
    }
}
