/**
 * Provides common data manipulation functions.
 */
module dil.util.data;

import std.math;
import std.meta;
import std.stdio;
import std.typecons;
import std.algorithm;

import dil;
import dil.util.range;

private const FILE_CHUNK_SIZE = 4096;

/**
  * Converts any sort of possible input/location into a forward ubyte range.
  * Useful for providing simple overloading of load functions for a variety of inputs.
  */
DataRange dataLoad(File file) {
    return file.byChunk(FILE_CHUNK_SIZE).joiner.bufferRange.inputRangeObject;
}
/// Ditto
DataRange dataLoad(string path) {
    return dataLoad(File(path, "r"));
}

alias Loadeable = AliasSeq!(File, string);

/**
 * Documentation
 */
ImageRange!Pixel makedRGBRasterLoad(R, T)(R data,
                                          T[4] mask,
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

        this(R range) {
            this.range = range;
        }

        @property bool empty() {
            return y >= _height;
        }

        @property Pixel front() {
            return maskedRGBLoad(data, mask, bpp);
        }

        void popFront() {
            if (x < _width) x++;
            else {
                x = 0;
                y++;
            }
        }

        @property size_t width() { return _width; }
        @property size_t height() { return _height; }
    }

    return Range(data).imageRangeObject;
}

Pixel maskedRGBLoad(R, T)(R range, T[4] mask, size_t bpp) {
    auto data = range.takeExactly(bpp / 8);
    import std.stdio;writeln(data);
    return Pixel.init;
}
