module dil.bitmap;

import std.stdio;
import std.file;
import std.bitmanip;

class BitMap {

    ubyte[] img_data;
    uint file_size;
    ubyte[2] reserved1;
    ubyte[2] reserved2;

    this(File stream) {
        ubyte[] buf = [];
        auto data = stream.rawRead(buf);
        
        // Parse data and setup
        // BMP Header
        // TODO: ID field needed?
        file_size = littleEndianToNative!uint(data[2..6]);
        reserved1 = data[6..8];
        reserved2 = data[8..10];
        uint offset = littleEndianToNative!uint(data[10..14]);

        // DIB Header

    }
}
