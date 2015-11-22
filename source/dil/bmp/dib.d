module dil.bmp.dib;

import std.bitmanip;

const BMP_FILE_HEADER = [0x42, 0x4D];

enum BmpVersion {
    CORE,
    CORE2,
    INFO,
    V2INFO,
    V3INFO,
    V4,
    V5,
}

private enum sizeToBmpVersion = [
    12:  BmpVersion.CORE,
    64:  BmpVersion.CORE2,
    40:  BmpVersion.INFO,
    52:  BmpVersion.V2INFO,
    56:  BmpVersion.V3INFO,
    108: BmpVersion.V4,
    124: BmpVersion.V5,
];

enum CompressionMethod {
    RGB            = 0,
    RLE8           = 1,
    RLE4           = 2,
    BITFIELDS      = 3,
    JPEG           = 4,
    PNG            = 5,
    ALPHABITFIELDS = 6,
    CMYK           = 11,
    CMYKRLE8       = 12,
    CMYKRLE4       = 13,
}

struct DIB {
    // CORE
    uint size;
    BmpVersion version_;
    int width, height;
    ushort bpp;
    // INFO
    CompressionMethod compression = CompressionMethod.RGB;
    uint dataSize;
    int horizontalResolution, verticalResolution;
    uint colorTableSize;
    uint importantColors;

    this(ubyte[] data) {
        size = littleEndianToNative!uint(data[0..4]);
        version_ = sizeToBmpVersion[size];

        if (version_ <= BmpVersion.CORE) {
            width = littleEndianToNative!ushort(data[4..6]);
            height = littleEndianToNative!ushort(data[6..8]);
            data = data[8..$];
        } else {
            width = littleEndianToNative!int(data[4..8]);
            height = littleEndianToNative!int(data[8..12]);
            data = data[12..$];
        }

        // Number of color planes, must be 1
        assert(littleEndianToNative!short(data[0..2]) == 1);

        bpp = littleEndianToNative!ushort(data[2..4]);

        // For CORE or CORE2, bpp cannot be 16 or 32
        assert(version_ > BmpVersion.CORE2 || bpp < 16);

        if (version_ >= BmpVersion.INFO) {
            compression = cast(CompressionMethod)littleEndianToNative!int(data[4..8]);
            dataSize = littleEndianToNative!int(data[8..12]);
            assert(compression == CompressionMethod.RGB || dataSize > 0);

            horizontalResolution = littleEndianToNative!int(data[12..16]);
            verticalResolution = littleEndianToNative!int(data[12..16]);
            colorTableSize = littleEndianToNative!uint(data[16..20]);
            importantColors = littleEndianToNative!uint(data[20..24]);
        } else {
            // colorTableSize defaults to 2^bpp
            colorTableSize = 1 << bpp;
        }

        //TODO: The rest of DIB
    }
}
