/**
 * Templates for easily parsing headers using structs
 */
module dil.util.headers;

import std.meta;
import std.traits;
import std.bitmanip;

/**
 * Attribute signifying the endianess of a field or type
 */
enum Endianess {
    little,
    big,
}

private template endianess(alias field, Endianess default_) {
    template isEndianess(alias E) {
        enum isEndianess = is(typeof(E) == Endianess);
    }

    // Use either the given default or the last attribute
    alias endianessAttrs = Filter!(isEndianess, __traits(getAttributes, field));
    static if (endianessAttrs.length > 0) {
        enum endianess = endianessAttrs[$-1];
    } else {
        enum endianess = default_;
    }
}

/**
 * Documentation
 */
template convertable(T) {
    enum convertable = isIntegral!T || isSomeChar!T || isBoolean!T ||
                       (__traits(isPOD, T) && isAggregateType!T);
}

/**
 * Given a type and endianess, convert a ubyte[] to that type.
 * Does not support any dynamically sized types or non-standard alignments
 */
T parseHeader(T, Endianess e = Endianess.little)(ubyte[] data, ref size_t offset) if (convertable!T) {
    static if (isAggregateType!T) {
        T value;

        foreach (field; FieldNameTuple!T) {
            auto member = mixin("value."~field);
            mixin("value."~field) = parseHeader!(typeof(member), endianess!(mixin("value."~field), e))(data, offset);
        }
        return value;
    } else {
        data = data[offset..$];
        offset += T.sizeof;

        static if (e == Endianess.little) {
            return littleEndianToNative!T(data[0..T.sizeof]);
        } else {
            return bigEndianToNative!T(data[0..T.sizeof]);
        }
    }
}

unittest {
    static struct Data {
        ushort field1;
        @(Endianess.little)
        ushort field2;
    }

    ubyte[4] data = [0xDE, 0xAD, 0xAD, 0xDE];

    size_t offset = 0;
    Data d = parseHeader!(Data, Endianess.big)(data, offset);
    assert(offset == 4);
    assert(d.field1 == 0xDEAD);
    assert(d.field2 == 0xDEAD);
}

/**
 * A mixin template that adds by-field casting.
 * Allows headers to be implemented as templates given a version with minimal effort.
 */
mixin template Upcast() {
    T opCast(T)() if (convertable!T) {
        import std.meta;
        import std.traits;

        alias This = typeof(this);
        template hasMember(string name) {
            enum hasMember = std.traits.hasMember!(This, name);
        }
        alias inCommon = Filter!(hasMember, FieldNameTuple!T);
        // Cast by assigning by member
        T value;
        foreach (field; inCommon) {
            mixin("value."~field~" = cast(typeof(value."~field~"))this."~field~";");
        }
        return value;
    }
}
