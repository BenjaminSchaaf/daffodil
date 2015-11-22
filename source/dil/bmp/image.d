module dil.bmp.image;

import dil.bmp.dib;
import dil.image;

class BitmapImage(PixelFmt) : ImageManip!PixelFmt {
    private {
        DIB dib;
        PixelFmt[] pixels;
    }

    this(DIB d, PixelFmt[] p) {
        dib = d;
        pixels = p;
    }

    // Image

    @property size_t width() {
        return dib.width;
    }

    @property size_t height() {
        return dib.height;
    }

    // ImageManip

    // TODO: ALL
    PixelFmt opIndex(size_t x, size_t y) {
        return PixelFmt.init;
    }

    PixelFmt opIndexAssign(PixelFmt pixel, size_t x, size_t y) {
        return PixelFmt.init;
    }
}
