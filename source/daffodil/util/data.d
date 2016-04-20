/**
 * Provides common data manipulation functions.
 */
module daffodil.util.data;

import std.math;
import std.meta;
import std.stdio;
import std.typecons;
import std.algorithm;
import core.bitop;

import daffodil;
import daffodil.util.types;
import daffodil.util.range;
import daffodil.util.errors;

private const FILE_CHUNK_SIZE = 4096;

/**
  * Converts any sort of possible input/location into a forward ubyte range.
  * Useful for providing simple overloading of load functions for a variety of inputs.
  */
DataRange dataLoad(File file) {
    return file.byChunk(FILE_CHUNK_SIZE).joiner.inputRangeObject;
}
/// Ditto
DataRange dataLoad(string path) {
    return dataLoad(File(path, "r"));
}

alias Loadeable = AliasSeq!(File, string);

template isLoadeable(E) {
    enum isLoadeable = staticIndexOf!(E, Loadeable) != -1;
}

/**
 * Converts any sort of possible output into a output range.
 * Useful for providing simple overloading of save functions  for a variety of outputs.
 */
OutRange dataSave(File file) {
    struct F {
        File f;
        this(File f) { this.f = f; }
        void put(ubyte data) { f.write(data); }
    }
    return F(file).outputRangeObject!ubyte;
}
/// Ditto
OutRange dataSave(string path) {
    return dataSave(File(path, "w"));
}

alias Saveable = AliasSeq!(File, string);

template isSaveable(E) {
    enum isSaveable = staticIndexOf!(E, Saveable) != -1;
}

struct PixelData {
    size_t x, y;
    real[] data;
}

/**
 * Documentation
 */
auto maskedRasterLoad(R, T)(
        R data,
        T[] mask,
        size_t bpp,
        ptrdiff_t _width,
        ptrdiff_t _height,
        size_t padding = 1) if (isInputRange!R &&
                                is(ElementType!R == ubyte)) {
    // currently don't support non multiples of 8
    assert(bpp % 8 == 0);

    struct Range {
        R range;
        size_t x = 0;
        size_t y = 0;
        size_t channelCount;
        real[] loadBuffer;

        this(R range) {
            this.range = range;
            this.channelCount = mask.length;
            this.loadBuffer = new real[channelCount];
        }

        @property bool empty() {
            return y >= height;
        }

        @property PixelData front() {
            // TODO: Make this happen in popFront
            maskedLoad(loadBuffer, data, mask, bpp);

            // Adjust for negative heights
            auto yReal = _height < 0 ? height - y - 1 : y;
            return PixelData(x, yReal, loadBuffer);
        }

        private void popPadding() {
            auto bitRowPos = (x + 1) * bpp;
            auto paddingBits = padding * 8;
            auto bitRowSize = ((bitRowPos + paddingBits - 1) / paddingBits) * paddingBits;
            auto pad = (bitRowSize - bitRowPos) / 8;
            range.popFrontExactly(pad);
        }

        void popFront() {
            if (x + 1 < _width) x++;
            else {
                // perform padding (next multiple of padding for x)
                popPadding();
                x = 0;
                y++;
            }
        }

        @property size_t width() { return _width; }
        @property size_t height() { return abs(_height); }
    }

    return Range(data);
}

void maskedLoad(R, T)(real[] target, R range, T[] masks, size_t bpp) {
    auto data = range.take(bpp / 8).array;
    enforce!UnexpectedEndOfData(data.length == bpp / 8);

    foreach (maskIndex, mask; masks) {
        auto bitStart = T.sizeof * 8 - bsr(mask) - 1;
        auto bitEnd = T.sizeof * 8 - bsf(mask);

        auto max = pow(2f, bitEnd - bitStart) - 1f;
        target[maskIndex] = 0;
        // TODO: Optimise
        foreach (index, value; data) {
            target[maskIndex] += (value >> (bitStart - index * 8)) / max;
        }
    }
}
