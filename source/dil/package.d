module dil;

public static {
    import image = dil.image;
    import pixels = dil.pixels;
    import bmp = dil.bmp;
}

import dil.image;

import std.stdio;
import std.file;

Image open(string path) {
    return open(cast(ubyte[])read(path));
}

Image open(File file) {
    assert(file.size < ulong.max);
    ubyte[] buffer = new ubyte[cast(uint)file.size];
    return open(file.rawRead!ubyte(buffer));
}

Image open(ubyte[] data) {
    if (bmp.isBMP(data)) {
        return bmp.BMP(data);
    }
    assert(0);
}

unittest {
    auto image = open("test/small.bmp");
    assert(image.width == 41);
    assert(image.height == 45);
}
