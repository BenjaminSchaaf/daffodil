/**
 * Provides extended functionality to std.range
 */
module daffodil.util.range;

public import std.range;

template isImageRange(R) {
    enum bool isImageRange = isInputRange!R && hasImageRangeAttrs!R;
}

private template hasImageRangeAttrs(R) {
    enum bool hasImageRangeAttrs = is(typeof(
        (inout int = 0) {
            R r = R.init;
            size_t w = r.width;
            size_t h = r.height;
            size_t c = r.channelCount;
        }
    ));
}

interface ImageRange(E) : InputRange!E {
    @property size_t width();
    @property size_t height();
    @property size_t channelCount();
}

class ImageRangeObject(R) : ImageRange!(ElementType!R) {
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

        for(auto r = _range; !r.empty; r.popFront()) {
            res = dg(r.front);
            if (res) break;
        }

        return res;
    }

    int opApply(int delegate(size_t, E) dg) {
        int res;

        size_t i = 0;
        for(auto r = _range; !r.empty; r.popFront()) {
            res = dg(i, r.front);
            if (res) break;
            i++;
        }

        return res;
    }
}

unittest {
    static assert(isImageRange!(ImageRange!int));
}

ImageRangeObject!R imageRangeObject(R)(R range) if (isImageRange!R) {
    static if (is(R : ImageRange!(ElementType!R))) {
        return range;
    } else {
        return new ImageRangeObject!R(range);
    }
}
