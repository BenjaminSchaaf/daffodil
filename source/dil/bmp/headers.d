module dil.bmp.headers;

import dil.bmp;
import dil.util.headers;

const BMP_FILE_HEADER = [0x42, 0x4D];

struct BmpHeader {
@(Endianess.little):
    uint size;
    ushort reserved1;
    ushort reserved2;
    uint contentOffset;
}

enum DibVersion {
    CORE   = 12,
    INFO   = 40,
    V2INFO = 52,
    V3INFO = 56,
    V4     = 108,
    V5     = 124,
}

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

/// Matches the typedefs found here: https://forums.adobe.com/servlet/JiveServlet/showImage/2-3273299-47801/BMP_Headers.png
struct DibHeader(DibVersion version_ = DibVersion.V5) {
@(Endianess.little):
    // All versions
    static if (version_ <= DibVersion.CORE) {
        ushort width;
        ushort height;
    } else {
        int width;
        int height;
    }
    ushort planes;
    ushort bitCount;

    static if (version_ >= DibVersion.INFO) {
        uint compression;
        uint dataSize;
        int xPixelsPerMeter;
        int yPixelsPerMeter;
        uint colorsUsed;
        uint colorsImportant;
    }

    static if (version_ >= DibVersion.V2INFO) {
        uint redMask;
        uint greenMask;
        uint blueMask;
    }

    static if (version_ >= DibVersion.V3INFO) {
        uint alphaMask;
    }

    static if (version_ >= DibVersion.V4) {
        uint csType;
        // No idea what this is, but its 32 bits long
        static struct Endpoints { long a; long b; long c; long d; int e; };
        Endpoints endpoints;
        uint gammaRed;
        uint gammaGreen;
        uint gammaBlue;
    }

    static if (version_ >= DibVersion.V5) {
        uint intent;
        uint profileData;
        uint profileSize;
        uint reserved;
    }

    mixin Upcast;
}
