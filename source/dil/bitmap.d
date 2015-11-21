module dil.bitmap;

import std.file;
import std.stdio;
import std.bitmanip;

import dil.image;

class BitMap {

    // BMP Header
    short headerID; // typically 'BM'
    uint fileSize;
    ubyte[2] reserved1;
    ubyte[2] reserved2;
    uint contentOffset;

    // DIB header
    uint dibSize;
    int width;
    int height;
    short bpp; // bits per pixel
    uint compressionMethod;
    uint contentSize;
    int hozRes;
    int vertRes;
    uint colorPalleteSize;
    uint nImportantColors;

    // Content
    ubyte[] imgData;

    this(File stream) {
        ubyte[] buf = [];
        auto data = stream.rawRead(buf);
        
        // BMP Header
        headerID = littleEndianToNative!short(data[0..2]);
        fileSize = littleEndianToNative!uint(data[2..6]);
        reserved1 = data[6..8];
        reserved2 = data[8..10];
        contentOffset = littleEndianToNative!uint(data[10..14]);

        // DIB Header
        dibSize = littleEndianToNative!int(data[14..18]);
        width = littleEndianToNative!int(data[18..22]);
        height = littleEndianToNative!int(data[22..26]);
        assert(littleEndianToNative!short(data[26..28]) == 1); // No. color planes
        bpp = littleEndianToNative!short(data[28..30]);
        compressionMethod = littleEndianToNative!int(data[30..34]);

        contentSize = fileSize - contentOffset;
        const uint suppliedSize = littleEndianToNative!int(data[34..38]);
        if (suppliedSize != 0) {
            // Checking calculated size matches with supplied size
            assert(contentSize == suppliedSize);
        }

        hozRes = littleEndianToNative!int(data[38..42]);
        vertRes = littleEndianToNative!int(data[42..46]);

        colorPalleteSize = littleEndianToNative!uint(data[46..50]);
        nImportantColors = littleEndianToNative!uint(data[50..54]);

        // Color Table
        // TODO

        // Content
        imgData = data[contentOffset..$];

    }
}
