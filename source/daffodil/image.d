module daffodil.image;

import std.conv;
import std.math;
import std.typecons;

import daffodil;
import daffodil.util.data;
import daffodil.util.range;
import daffodil.util.types;

/**
 * Generic Image class for a given pixel format.
 * Holds a two dimensional array of pixels in a specified format, allowing
 * generic transformations and manipulations using other interfaces.
 */
class Image(size_t bpc_) {
    /**
     * Bits per Channel
     */
    enum bpc = bpc_;

    /**
     * Storage type for each value in a channel
     */
    alias Value = Integer!bpc;

    private {
        size_t[2] _size;
        size_t    _channelCount;
        Value[]   raster;

        const ColorSpace!bpc colorSpace;
    }

    /**
     * Create an empty Image given a width and a height.
     * Pixels default to `init`
     */
    this(size_t width, size_t height, size_t channelCount, ColorSpace!bpc colorSpace) {
        _size = [width, height];
        this._channelCount = channelCount;
        this.colorSpace = colorSpace;
        raster.length = width * height * channelCount;
    }

    /**
     * Documentation
     */
    this(R)(R range, ColorSpace!bpc colorSpace) if (isImageRange!R && is(ElementType!R == PixelData)) {
        this(range.width, range.height, range.channelCount, colorSpace);

        foreach (pixel; range) {
            this[pixel.x, pixel.y] = pixel.data;
        }
    }

    /// Create a image from data copied off another image
    this(const Image other) {
        this._size         = other._size;
        this._channelCount = other._channelCount;
        this.raster        = other.raster.dup;
        this.colorSpace    = other.colorSpace;
    }

    /**
     * Get the width and height of the Image.
     */
    @property auto width() const { return _size[0]; }
    @property auto height() const { return _size[1]; } /// Ditto
    @property auto size() const { return _size; } /// Ditto
    auto opDollar(size_t pos)() const { return _size[pos]; } /// Ditto

    /**
     * Get the number of channels in the image.
     */
    @property auto channelCount() const { return _channelCount; }



    /**
     * Get a pixel of the given pixel format at a location on the image.
     */
    auto opIndex(size_t x, size_t y) const {
        auto index = (x + y * width) * channelCount;
        auto slice = raster[index..index + channelCount];

        return Pixel!bpc(cast(Value[])slice, colorSpace);
    }
    /// Ditto
    void opIndexAssign(const Pixel!bpc color, size_t x, size_t y) {
        (cast(Pixel!bpc)this[x, y]).opAssign(color);
    }
    /// Ditto
    void opIndexAssign(real[] values, size_t x, size_t y) {
        assert(values.length == channelCount);
        auto index = (x + y * width) * channelCount;
        foreach (i; 0..channelCount) {
            raster[index + i] = cast(Value)(values[i] * Value.max);
        }
    }

    /**
     * Create a new color compatible with the image
     */
    auto newColor() const {
        return Pixel!bpc(channelCount, colorSpace);
    }

    @property Image!bpc dup() const {
        return new Image(this);
    }

    override string toString() const {
        import std.format;
        return format("%s", raster);
    }
}

@("Image bpp property")
unittest {
    assert((Image!24).bpc == 24);
    assert((Image!31).bpc == 31);
    assert((Image!568).bpc == 568);
}

@("Image size properties")
unittest {
    auto image = new Image!32(123, 234, 1, new RGB!32);
    assert(image.width == 123);
    assert(image.height == 234);
    assert(image.size == [123, 234]);
    assert(image.opDollar!0 == 123);
    assert(image.opDollar!1 == 234);
}
