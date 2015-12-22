module dil.image;

import std.typecons;

import dil.pixels;

/**
 * Generic Image class for a given pixel format.
 * Holds a two dimensional array of pixels in a specified format, allowing
 * generic transformations and manipulations using other interfaces.
 */
class Image(PixelFmt) {
    private PixelFmt[][] raster;

    /**
     * Create an empty Image given a width and a height.
     * Pixels default to `init`
     */
    this(size_t width, size_t height) {
        raster.length = height;
        foreach (ref column; raster) {
            column.length = width;
        }
    }

    /**
     * Get the width and height of the Image.
     */
    @property size_t width() { return raster[0].length; }
    @property size_t height() { return raster.length; } /// Ditto
    @property auto size() { return tuple(width, height); } /// Ditto
    auto opDollar(size_t pos)() { return size[pos]; } /// Ditto

    unittest {
        auto image = new Image!Pixel24Bpp(123, 234);
        assert(image.width == 123);
        assert(image.height == 234);
        assert(image.size == tuple(123, 234));
        assert(image.opDollar!0 == 123);
        assert(image.opDollar!1 == 234);
    }

    /**
     * Get the size of the given pixel format
     */
    enum bpp = PixelFmt.size;

    unittest {
        assert((Image!Pixel24Bpp).bpp == 24);
        assert((Image!Pixel32Bpp).bpp == 32);
        assert((Image!Pixel64Bpp).bpp == 64);
    }

    /**
     * Get a pixel of the given pixel format at a location on the image.
     */
    PixelFmt opIndex(size_t x, size_t y) {
        return raster[y][x];
    }
    /// Ditto
    PixelFmt opIndexAssign(PixelFmt pixel, size_t x, size_t y) {
        return raster[y][x] = pixel;
    }

    /**
     * Copies the entire image into a new image of a new specified pixel format.
     */
    Image!Fmt convert(Fmt)() {
        //TODO
    }

    override string toString() {
        import std.format;
        return format("%s", raster);
    }
}
