module dil.pixels;

import std.math;
import std.meta;
import std.bigint;

import dil.color;

// Template that, given a size in bits
// returns a template that returns whether a type fits in that size
private template sizeCompatible(size_t size) {
    template sizeCompatible(T) {
        enum sizeCompatible = T.sizeof * 8 >= size;
    }
}

// Template that returns an integer type that can contain a given number of bits
private template Integer(size_t size) {
    alias types = AliasSeq!(ubyte, ushort, uint, ulong);
    alias compatible = Filter!(sizeCompatible!size, types);
    static if (compatible.length >= 1) {
        alias Integer = compatible[0];
    } else {
        alias Integer = BigInt;
    }
}

unittest {
    static assert(is(Integer!3 == ubyte));
    static assert(is(Integer!8 == ubyte));
    static assert(is(Integer!9 == ushort));
    static assert(is(Integer!38 == ulong));
    static assert(is(Integer!128 == BigInt));
}

private auto maxBitValue(size_t bitSize) {
    return pow(2, bitSize) - 1;
}

private mixin template PixelCommon() {
    string toString() {
        return toColor().toString();
    }
}


/**
 * RGB Pixel, with each RGB field being a minimum of rgbSize bits.
 */
struct RGBPixel(size_t rgbSize) {
    mixin PixelCommon;

    alias T = Integer!rgbSize;

    T red;
    T green;
    T blue;

    enum size = 3 * rgbSize;

    this(T r, T g, T b) {
        red   = r;
        green = g;
        blue  = b;
    }

    this(Color color) {
        auto s = maxBitValue(rgbSize);
        this(cast(T)(color.red * s),
             cast(T)(color.green * s),
             cast(T)(color.blue * s));
    }

    Color toColor() {
        real s = maxBitValue(rgbSize);
        return Color(red / s, green / s, blue / s, 1);
    }

    unittest {
        auto pix = RGBPixel!8(50, 40, 30);
        assert(RGBPixel!8(pix.toColor()) == pix);
    }
}

/**
 * RGBA Pixel, with RGB fields being a minimum of rgbSize bits and
 * the A field being a minimum of either aSize bits or if left out, rgbSize bits.
 */
struct RGBAPixel(size_t rgbSize, size_t aSize = 0) {
    mixin PixelCommon;

    static if (aSize == 0) {
        enum aS = rgbSize;
    } else {
        enum aS = aSize;
    }

    alias rgbT = Integer!rgbSize;
    alias aT   = Integer!aS;

    rgbT red;
    rgbT green;
    rgbT blue;
    aT alpha;

    enum size = 3 * rgbSize + aS;

    this(rgbT r, rgbT g, rgbT b, aT a) {
        red   = r;
        green = g;
        blue  = b;
        alpha = a;
    }

    this(Color color) {
        auto s = maxBitValue(rgbSize);
        this(cast(rgbT)(color.red * s),
             cast(rgbT)(color.green * s),
             cast(rgbT)(color.blue * s),
             cast(aT)(color.alpha * maxBitValue(aS)));
    }

    Color toColor() {
        real s = maxBitValue(rgbSize);
        return Color(red / s, green / s, blue / s, alpha / cast(real)maxBitValue(aS));
    }

    unittest {
        auto pix = RGBAPixel!8(50, 40, 30, 20);
        assert(RGBAPixel!8(pix.toColor()) == pix);
    }
}

/// Standard 24Bpp pixel, 8R 8G 8B
alias Pixel24Bpp  = RGBPixel!8;
/// Standard 32Bpp pixel, 8R, 8G, 8B, 8A
alias Pixel32Bpp  = RGBAPixel!8;
/// Standard 64Bpp pixel, 16R, 16G, 16B, 16A
alias Pixel64Bpp  = RGBAPixel!16;
/// Standard 128Bpp pixel, 32R, 32G, 32B, 32A. Useful mainly internally.
alias Pixel128Bpp = RGBAPixel!32;
/// Standard 256Bpp pixel, 64R, 64G, 64B, 64A. Useful mainly internally.
alias Pixel256Bpp = RGBAPixel!64;
