/**
 * Provides extended functionality to std.range
 */
module dil.util.range;

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
    }

    private this(size_t location, E[] buffer, R range) {
        this.location = location;
        this.buffer = buffer;
        this.range = range;
    }

    @property bool empty() {
        if (location < buffer.length) {
            return false;
        }
        return buffer.empty;
    }

    @property E front() {
        while (location + 1 > buffer.length) {
            buffer ~= range.front();
            range.popFront();
        }
        return buffer[location];
    }

    void popFront() {
        location++;
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
    auto r2 = r1.save;

    assert(r1.front == 'f');
    assert(r2.front == 'f');
}

template isImageRange(R) {
    enum bool isImageRange = isInputRange!R && isSized!R;
}


template isSized(R) {
    enum bool isSized = is(typeof(
        (inout int = 0) {
            R r = R.init;
            size_t w = r.width;
            size_t h = r.height;
        }
    ));
}

interface ImageRange(E) : InputRange!E {
    @property size_t width();
    @property size_t height();
}

template ImageRangeObject(R) if (isImageRange!R) {
    alias E = ElementType!R;

    class ImageRangeObject : ImageRange!E {
        private R _range;

        this(R range) {
            _range = range;
        }

        @property E front() { return _range.front; }
        void popFront() { _range.popFront(); }
        @property bool empty() { return _range.empty; }
        @property size_t width() { return _range.width; }
        @property size_t height() { return _range.height; }

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
}

ImageRangeObject!R imageRangeObject(R)(R range) if (isImageRange!R) {
    static if (is(R : ImageRange!(ElementType!R))) {
        return range;
    } else {
        return new ImageRangeObject!R(range);
    }
}
