/**
 * Exposes the :d:class:`Image` class, which provides basic storage, access and
 * conversion of images.
 */
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
     * Number of bits per channel.
     */
    enum bpc = bpc_;

    /**
     * Storage type for each value in a channel.
     */
    alias Value = Integer!bpc;

    /// The maximum value for any channel value.
    enum maxValue = pow(2, bpc) - 1;

    /// The metadata of the image.
    MetaData meta;

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
    this(size_t width, size_t height, size_t channelCount,
         ColorSpace!bpc colorSpace, MetaData meta = null) {
        _size = [width, height];
        this._channelCount = channelCount;
        this.colorSpace = colorSpace;
        raster.length = width * height * channelCount;
        this.meta = meta;
    }

    /**
     * Create a Image from a given image range, color space and optional
     * metadata.
     */
    this(R)(R range, ColorSpace!bpc colorSpace,
            MetaData meta = null) if (isImageRange!R &&
                                      is(ElementType!R == PixelData)) {
        this(range.width, range.height, range.channelCount, colorSpace, meta);

        foreach (pixel; range) {
            this[pixel.x, pixel.y] = pixel.data;
        }
    }

    /// Create a image from data copied off another image.
    this(const Image other) {
        this._size         = other._size;
        this._channelCount = other._channelCount;
        this.raster        = other.raster.dup;
        this.colorSpace    = other.colorSpace;
        // TODO: Take copy here?
        this.meta          = cast(MetaData)other.meta;
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
            raster[index + i] = cast(Value)(values[i] * maxValue);
        }
    }

    /**
     * Create a new color within the color space of the image.
     */
    auto newColor() const {
        return Pixel!bpc(channelCount, colorSpace);
    }

    /// Return a copy of the image.
    @property Image dup() const {
        return new Image(this);
    }

    override string toString() const {
        return raster.to!string;
    }

    /// Return a image range for the image.
    @property auto range() const {
        struct Range {
            const Image image;
            real[] outBuffer;

            this(const Image image) {
                this.image = image;
                outBuffer = new real[channelCount];
            }
            @property auto width() { return image.width; }
            @property auto height() { return image.height;}
            @property auto channelCount() { return image.channelCount; }
            @property auto front() { return outBuffer; }
            @property auto empty() { return false; }
            void popFront() {}
            real[] opIndex(size_t x, size_t y) {
                auto color = image[x, y];
                foreach (index; 0..channelCount) {
                    outBuffer[index] = color[index] / cast(real)maxValue;
                }
                return outBuffer;
            }
        }

        return Range(this);
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

@("Image to string")
unittest {
    auto image = new Image!32(2, 2, 3, new RGB!32);
    assert(image.toString == "[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]");
}

@("Image range")
unittest {
    static assert(isRandomAccessImageRange!(typeof(Image!8.range)));
}
