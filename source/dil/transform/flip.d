module dil.transform.flip;

import std.algorithm;

import dil.image;

/**
 * Flips a image along either the x, y or both axis.
 */
void flip(string axis, PixelFmt)(Image!PixelFmt image) {
    static if (canFind(axis, 'x')) {
        foreach (y; 0..image.height) {
            foreach (x; 0..image.width/2) {
                auto temp = image[$ - x - 1, y];
                image[$ - x - 1, y] = image[x, y];
                image[x, y] = temp;
            }
        }
    }

    static if (canFind(axis, 'y')) {
        foreach (x; 0..image.width) {
            foreach(y; 0..image.height/2) {
                auto temp = image[x, $ - y - 1];
                image[x, $ - y - 1] = image[x, y];
                image[x, y] = temp;
            }
        }
    }
}
/// Ditto
auto flipped(string axis, PixelFmt)(const Image!PixelFmt image) {
    auto output = image.dup;
    output.flip!axis();
    return output;
}

unittest {
    import dil;

    auto image = new Image!Pixel24Bpp(2, 2);
    image[0, 0] = Pixel24Bpp(255, 255, 255);
    image[0, 1] = Pixel24Bpp(255,   0,   0);
    image[1, 0] = Pixel24Bpp(  0, 255,   0);
    image[1, 1] = Pixel24Bpp(  0,   0, 255);

    image.flip!"x"();
    assert(image[0, 0] == Pixel24Bpp(  0, 255,   0));
    assert(image[0, 1] == Pixel24Bpp(  0,   0, 255));
    assert(image[1, 0] == Pixel24Bpp(255, 255, 255));
    assert(image[1, 1] == Pixel24Bpp(255,   0,   0));

    image.flip!"y"();
    assert(image[0, 0] == Pixel24Bpp(  0,   0, 255));
    assert(image[0, 1] == Pixel24Bpp(  0, 255,   0));
    assert(image[1, 0] == Pixel24Bpp(255,   0,   0));
    assert(image[1, 1] == Pixel24Bpp(255, 255, 255));

    image = image.flipped!"xy"();
    assert(image[0, 0] == Pixel24Bpp(255, 255, 255));
    assert(image[0, 1] == Pixel24Bpp(255,   0,   0));
    assert(image[1, 0] == Pixel24Bpp(  0, 255,   0));
    assert(image[1, 1] == Pixel24Bpp(  0,   0, 255));
}
