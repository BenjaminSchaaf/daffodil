module dil.image;

import std.typecons;

import dil.pixels;

/// Interface for all images
interface Image {
    @property size_t width();
    @property size_t height();

    final @property auto size() {
        return tuple(width, height);
    }
}

/// Interface for specific pixel formats. Abstracted away by Image.
interface ImageManip(PixelFmt) : Image {
    PixelFmt opIndex(size_t x, size_t y);
    PixelFmt opIndexAssign(PixelFmt pixel, size_t x, size_t y);

    final size_t opDollar(size_t pos)() if (pos == 0) {
        return width;
    }
    final size_t opDollar(size_t pos)() if (pos == 1) {
        return height;
    }
}
