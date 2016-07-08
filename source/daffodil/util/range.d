/**
 * Provides extended functionality to std.range
 */
module daffodil.util.range;

public import std.range;

template isImageRange(R, E) {
    enum bool isImageRange = isImageRange!R && is(ElementType!R == E);
}

template isImageRange(R) {
    enum bool isImageRange = isInputRange!R && is(typeof(
        (inout int = 0) {
            R r = R.init;
            size_t w = r.width;
            size_t h = r.height;
            size_t c = r.channelCount;
        }
    ));
}

template isRandomAccessImageRange(R) {
    enum bool isRandomAccessImageRange = isImageRange!R && is(typeof(
        (inout int = 0) {
            R r = R.init;
            ElementType!R e = r[0, 0];
        }
    ));
}

interface ImageRange(E) : InputRange!E {
    @property size_t width();
    @property size_t height();
    @property size_t channelCount();
}

unittest {
    static assert(isImageRange!(ImageRange!int));
}

interface RandomAccessImageRange(E) : ImageRange!E {
    E opIndex(size_t x, size_t y);
}

unittest {
    static assert(isRandomAccessImageRange!(RandomAccessImageRange!int));
}

template MostDerivedImageRange(R) if (isImageRange!R) {
    alias E = ElementType!R;

    static if (isRandomAccessImageRange!R) {
        alias MostDerivedImageRange = RandomAccessImageRange!E;
    } else {
        alias MostDerivedImageRange = ImageRange!E;
    }
}

class ImageRangeObject(R) : MostDerivedImageRange!R if (isImageRange!R) {
    private alias E = ElementType!R;

    private R _range;

    this(R range) {
        _range = range;
    }

    @property E front() { return _range.front; }
    void popFront() { _range.popFront(); }
    @property bool empty() { return _range.empty; }
    @property size_t width() { return _range.width; }
    @property size_t height() { return _range.height; }
    @property size_t channelCount() { return _range.channelCount; }

    E moveFront() {
        return .moveFront(_range);
    }

    // Optimization:  One delegate call is faster than three virtual
    // function calls.  Use opApply for foreach syntax.
    int opApply(int delegate(E) dg) {
        int res;

        foreach (i, e; this) {
            res = dg(e);
            if (res) break;
        }

        return res;
    }

    int opApply(int delegate(size_t, E) dg) {
        int res;

        size_t i = 0;
        for(; !empty; popFront()) {
            res = dg(i, front);
            if (res) break;
            i++;
        }

        return res;
    }

    static if (isRandomAccessImageRange!R) {

        E opIndex(size_t x, size_t y) {
            return _range[x, y];
        }

    }
}

unittest {
    static assert(isImageRange!(ImageRangeObject!(ImageRange!int)));
    static assert(isRandomAccessImageRange!(ImageRangeObject!(RandomAccessImageRange!int)));
}

ImageRangeObject!R imageRangeObject(R)(R range) if (isImageRange!R) {
    static if (is(R : ImageRange!(ElementType!R))) {
        return range;
    } else {
        return new ImageRangeObject!R(range);
    }
}

class Iter(R) if (isRandomAccessRange!R) {
    private R range;

    this(R r) {
        range = r;
    }

    void popFront() {
        range = range[1..$];
    }

    @property bool empty() { return range.length == 0; }
    @property ubyte front() { return range[0]; }
}

auto iter(R)(R range) if (isRandomAccessRange!R) {
    return new Iter!R(range);
}
