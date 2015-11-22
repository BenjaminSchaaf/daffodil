module dil.pixels;

import std.meta;
import std.bigint;
import std.bitmanip;

private template sizeCompatible(size_t size) {
    template sizeCompatible(T) {
        enum sizeCompatible = T.sizeof * 8 >= size;
    }
}

template Integer(size_t size) {
    alias types = AliasSeq!(ubyte, ushort, uint, ulong);
    alias compatible = Filter!(sizeCompatible!size, types);
    static if (compatible.length >= 1) {
        alias Integer = compatible[0];
    } else {
        alias Integer = BigInt;
    }
}

unittest {
    static assert(is(Integer!8 == ubyte));
    static assert(is(Integer!9 == ushort));
    static assert(is(Integer!38 == ulong));
    static assert(is(Integer!128 == BigInt));
}

struct IndexPixel(size_t iSize) {
    Integer!iSize index;

    static @property size_t size() {
        return iSize;
    }
}

struct RGBPixel(size_t rgbSize) {
    alias T = Integer!rgbSize;

    T red;
    T green;
    T blue;

    static @property size_t size() {
        return 3 * rgbSize;
    }
}

struct RGBAPixel(size_t rgbSize, size_t aSize = 0) {
    alias rgbT = Integer!rgbSize;

    static if (aSize == 0) {
        alias aT = rgbT;
    } else {
        alias aT = Integer!aSize;
    }

    rgbT red;
    rgbT green;
    rgbT blue;
    aT alpha;

    static @property size_t size() {
        return 3 * rgbSize + (aSize == 0 ? rgbSize : aSize);
    }
}
