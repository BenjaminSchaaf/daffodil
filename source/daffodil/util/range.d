/**
 * Provides extended functionality to std.range
 */
module daffodil.util.range;

import std.traits;
public import std.range;

/**
 * Forward Range that wraps a Input Range with a buffer to provide the save primitive.
 */
struct BufferRange(R) if (isInputRange!R) {
    private {
        alias E = ElementType!R;

        size_t location = 0;
        E[] buffer = [];
        R range;
    }

    this(R range) {
        this.range = range;
        growBuffer();
    }

    private this(size_t location, E[] buffer, R range) {
        this.location = location;
        this.buffer = buffer;
        this.range = range;
    }

    private void growBuffer() {
        buffer ~= range.front();
        range.popFront();
    }

    @property bool empty() {
        if (location + 1 < buffer.length) {
            return false;
        }
        return range.empty;
    }

    @property E front() {
        return buffer[location];
    }

    void popFront() {
        location++;
        if (location == buffer.length && !range.empty) {
            growBuffer();
        }
    }

    @property auto save() {
        return BufferRange!R(location, buffer, range);
    }
}

auto bufferRange(R)(R range) {
    return BufferRange!R(range);
}

@("buffer range")
unittest {
    auto r1 = bufferRange("foobar");

    assert(r1.front == 'f');
    r1.popFront();
    assert(r1.front == 'o');
    assert(r1.front == 'o');
    r1.popFront();
    assert(r1.front == 'o');

    auto r2 = r1.save;
    r1.popFront();
    assert(r1.front == 'b');
    assert(r2.front == 'o');
    r2.popFront();
    assert(r1.front == 'b');
    assert(r2.front == 'b');
}

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
