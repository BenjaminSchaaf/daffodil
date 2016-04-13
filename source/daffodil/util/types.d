module daffodil.util.types;

import std.meta;
import std.bigint;

// Template that, given a size in bits
// returns a template that returns whether a type fits in that size
private template sizeCompatible(size_t size) {
    template sizeCompatible(T) {
        enum sizeCompatible = T.sizeof * 8 >= size;
    }
}

// Template that returns an integer type that can contain a given number of bits
template Integer(size_t size) {
    alias types = AliasSeq!(ubyte, ushort, uint, ulong);
    alias compatible = Filter!(sizeCompatible!size, types);
    static if (compatible.length >= 1) {
        alias Integer = compatible[0];
    } else {
        // TODO: BigInt support
        // alias Integer = BigInt;
        alias Integer = ulong;
    }
}

@("bit size to type conversion")
unittest {
    static assert(is(Integer!3 == ubyte));
    static assert(is(Integer!8 == ubyte));
    static assert(is(Integer!9 == ushort));
    static assert(is(Integer!32 == uint));
    static assert(is(Integer!38 == ulong));
    static assert(is(Integer!128 == ulong)); // TODO: BigInt
}
