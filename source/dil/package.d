module dil;

public {
    import dil.image;
    import dil.color;
    import dil.pixels;

    // Image Formats
    static {
        import bmp = dil.bmp;
    }
}

import dil.image;
import dil.pixels;
import dil.misc;

/**
 * Attempt to open an image of arbitrary given a pixel format.
 */
auto open(PixelFmt)(ubyte[] data) {
    if (bmp.isBMP(data)) {
        return bmp.BMP(data);
    }
    assert(0);
}
mixin(OpenOverloads);
