module daffodil.color;

import std.conv;
import std.math;
import std.array;
import std.format;
import std.algorithm;

import daffodil.util.types;

interface ColorSpace(size_t bpc) {
    alias Value = Integer!bpc;

    void channelopScalarMul(const Value[], const real, Value[]) const;
    void channelopColorAdd(const Value[], const Value[], Value[]) const;
    string channelToString(const Value[]) const;
}

struct Pixel(size_t bpc) {
    alias Value = Integer!bpc;

    Value[] values;
    const ColorSpace!bpc colorSpace;

    alias values this;

    this(Value[] values, const ColorSpace!bpc colorSpace) {
        this.values = values;
        this.colorSpace = colorSpace;
    }

    this(size_t size, const ColorSpace!bpc colorSpace) {
        this(new Value[size], colorSpace);
    }

    Pixel!bpc opBinary(string op : "*")(const real other) const {
        auto ret = Pixel!bpc(this.length, colorSpace);
        colorSpace.channelopScalarMul(values, other, ret.values);
        return ret;
    }

    Pixel!bpc opBinary(string op : "+")(const Pixel!bpc other) const {
        // TODO: Check other.colorSpace
        auto ret = Pixel!bpc(this.length, colorSpace);
        colorSpace.channelopColorAdd(values, other, ret.values);
        return ret;
    }

    void opOpAssign(string op : "*")(const real other) {
        colorSpace.channelopScalarMul(values, other, values);
    }

    void opOpAssign(string op : "+")(const Pixel!bpc other) {
        colorSpace.channelopColorAdd(values, other, values);
    }

    void opAssign(const Pixel!bpc other) {
        assert(other.length == this.length);
        foreach (index; 0..this.length) {
            this[index] = other[index];
        }
    }

    void clear() {
        foreach (index; 0..this.length) {
            this[index] = 0;
        }
    }

    @property auto dup() {
        return Pixel!bpc(values.dup, colorSpace);
    }
}

class RGB(size_t bpc) : ColorSpace!bpc {
    alias Value = Integer!bpc;

    override void channelopColorAdd(const Value[] self, const Value[] other, Value[] target) const {
        assert(self.length == target.length);
        assert(self.length == other.length);
        foreach (index; 0..self.length) {
            target[index] = cast(Value)min(self[index] + other[index], Value.max);
        }
    }

    override void channelopScalarMul(const Value[] self, const real other, Value[] target) const {
        assert(self.length == target.length);

        foreach (index; 0..self.length) {
            target[index] = cast(Value)(self[index] * other);
        }
    }

    override string channelToString(const Value[] self) const {
        real maxValue = pow(2, bpc);
        string output = "(";
        foreach (index; 0..self.length) {
            if (index == 0) output ~= ", ";
            output ~= (self[index] / maxValue).to!string;
        }
        return output ~ ")";
    }
}
