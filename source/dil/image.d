module dil.image;

import std.typecons;

import dil;
import dil.util.range;

/**
 * Generic Image class for a given pixel format.
 * Holds a two dimensional array of pixels in a specified format, allowing
 * generic transformations and manipulations using other interfaces.
 */
class Image(PixelFmt) {
    private size_t[2] _size;
    private PixelFmt[] raster;

    /**
     * Create an empty Image given a width and a height.
     * Pixels default to `init`
     */
    this(size_t width, size_t height) {
        _size = [width, height];
        raster.length = width * height;
    }

    /**
     * Documentation
     */
    this(R)(R range) if (isImageRange!R && is(ElementType!R == Pixel)) {
        this(range.width, range.height);

        foreach (pixel; range) {
            this[pixel.x, pixel.y] = PixelFmt(pixel.color);
        }
    }

    // Used for creating copies
    private this(size_t[2] _size, PixelFmt[] raster) {
        this._size = _size;
        this.raster = raster;
    }

    /**
     * Get the width and height of the Image.
     */
    @property size_t width() const { return _size[0]; }
    @property size_t height() const { return _size[1]; } /// Ditto
    @property size_t[2] size() const { return _size; } /// Ditto
    auto opDollar(size_t pos)() const { return _size[pos]; } /// Ditto

    /**
     * Get the size of the given pixel format
     */
    enum bpp = PixelFmt.size;

    /**
     * Get a pixel of the given pixel format at a location on the image.
     */
    PixelFmt opIndex(size_t x, size_t y) const {
        return raster[x + y * width];
    }
    /// Ditto
    PixelFmt opIndexAssign(PixelFmt pixel, size_t x, size_t y) {
        return raster[x + y * width] = pixel;
    }
    /// Ditto
    PixelFmt opIndexAssign(Color color, size_t x, size_t y) {
        return opIndexAssign(PixelFmt(color), x, y);
    }

    /**
     * Copies the entire image into a new image of a new specified pixel format.
     */
    Image!Fmt convert(Fmt)() const {
        //TODO
    }

    @property auto dup() const {
        return new Image!PixelFmt(_size, raster.dup);
    }

    override string toString() const {
        import std.format;
        return format("%s", raster);
    }
}

@("Image bpp property")
unittest {
    assert((Image!Pixel24Bpp).bpp == 24);
    assert((Image!Pixel32Bpp).bpp == 32);
    assert((Image!Pixel64Bpp).bpp == 64);
}

@("Image size properties")
unittest {
    auto image = new Image!Pixel24Bpp(123, 234);
    assert(image.width == 123);
    assert(image.height == 234);
    assert(image.size == [123, 234]);
    assert(image.opDollar!0 == 123);
    assert(image.opDollar!1 == 234);
}
