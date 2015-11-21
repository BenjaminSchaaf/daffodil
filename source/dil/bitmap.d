module dil.bitmap;

import std.stdio;
import std.file;

class BitMap {

    ubyte[] img_data;
    size_t file_size;
    this(File stream) {
        ubyte[] buf = [];
        auto data = stream.rawRead(buf);
        
        // Parse data and setup
        
    }
}
