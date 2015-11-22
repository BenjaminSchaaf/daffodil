module dil.bmp;

public {
    import dil.bmp.dib;
    import dil.bmp.image;
}

import std.bitmanip;

import dil.image;
import dil.pixels;

bool isBMP(ubyte[] data) {
    return data[0..2] == BMP_FILE_HEADER;
}

Image BMP(ubyte[] data) {
    assert(isBMP(data));

    // BMP File Header
    uint fileSize = littleEndianToNative!uint(data[2..6]);
    // 6..10 is application dependent
    uint contentOffset = littleEndianToNative!uint(data[10..14]);

    DIB dib = DIB(data[14..$]);

    // V5 has a ICC color profile, not yet supported
    assert(dib.version_ != BmpVersion.V5);

    // sanity checks
    assert(dib.dataSize == fileSize - contentOffset);
    uint rowSize = (dib.bpp * dib.width + 31)/32 * 4;
    assert(dib.dataSize == row_size * dib.height);

    ubyte[] pixelArray = data[contentOffset..$];

    switch (dib.bpp) {
        // First try common pixel formats
        case 1:
            alias FMT = IndexPixel!1;
            return new BitmapImage!FMT(dib, []);
        case 2:
            alias FMT = IndexPixel!2;
            return new BitmapImage!FMT(dib, []);
        case 4:
            alias FMT = IndexPixel!4;
            return new BitmapImage!FMT(dib, []);
        case 8:
            alias FMT = IndexPixel!8;
            return new BitmapImage!FMT(dib, []);
        case 16:
            alias FMT = RGBAPixel!(5, 1);
            return new BitmapImage!FMT(dib, []);
        case 24:
            alias FMT = RGBPixel!8;
            return new BitmapImage!FMT(dib, []);
        case 32:
            alias FMT = RGBAPixel!8;
            return new BitmapImage!FMT(dib, []);
        default:
            // TODO: Add support for other sizes
            assert(0);
    }
}
