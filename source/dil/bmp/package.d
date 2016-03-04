module dil.bmp;

public {
    static {
        import headers = dil.bmp.headers;
    }
}

import std.math;
import std.traits;
import std.bitmanip;
import std.typecons;
import std.algorithm;

import dil;
import dil.util.data;
import dil.util.range;
import dil.util.errors;
import dil.util.headers;

import dil.bmp.headers;

/// Register this file format with the common api
static this() {
    registerFormat(Format(
        "BMP",
        &check!DataRange,
        &loadMeta!DataRange,
        &loadImage!DataRange,
        null,
        [".bmp", ".dib"],
    ));
}

/**
 * Documentation
 */
bool check(R)(R data) if (isInputRange!R &&
                          is(ElementType!R == ubyte)) {
    // Take a 'save' of the range, so we don't alter our input
    // Make sure data starts with "BM"
    return equal(data.takeExactly(2), [0x42, 0x4D]);
}
/// Ditto
bool check(T : Loadeable)(T loadeable) {
    return check(dataLoad(loadeable));
}

@("BMP file format check")
unittest {
    assert( check(cast(ubyte[])[0x42, 0x4D, 0x32, 0x7D, 0xFA, 0x9E]));
    assert(!check(cast(ubyte[])[0x43, 0x4D, 0x32, 0x7D, 0xFA, 0x9E]));
    assert(!check(cast(ubyte[])[0x42, 0x4C, 0x32, 0x7D, 0xFA, 0x9E]));
}

/**
 * Documentation
 */
class BMPMetaData : MetaData {

}

/**
 * Documentation
 */
BMPMetaData loadMeta(R)(R data) if (isInputRange!R &&
                                    is(ElementType!R == ubyte)) {
    return null;
}
/// Ditto
auto loadMeta(T : Loadeable)(T loadeable) {
    return loadMeta(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto load(PixelFmt, T : DataRange)(T data, MetaData meta = null) {
    if (meta is null) meta = loadMeta(data);
    return new Image!PixelFmt(loadImage(data, meta));
}
/// Ditto
auto load(PixelFmt, T)(T loadeable) {
    return load!PixelFmt(dataLoad(loadeable));
}

// The default rgba masks for common formats
private enum DEFAULT_MASKS = [
    16 : tuple(    0x0_F_0_0u,     0x0_0_F_0u,     0x0_0_0_Fu,     0xF_0_0_0u),
    24 : tuple(   0x00_00_FFu,    0x00_FF_00u,    0xFF_00_00u,    0x00_00_00u),
    32 : tuple(0x00_FF_00_00u, 0x00_00_FF_00u, 0x00_00_00_FFu, 0xFF_00_00_00u),
];

/**
 * Documentation
 */
auto loadImage(R)(R data, MetaData meta) if (isInputRange!R &&
                                             is(ElementType!R == ubyte)) {
    enforce!InvalidImageType(check(data), "Data does not contain a bmp image.");

    auto bmpHeader = parseHeader!BmpHeader(data);
    auto dibVersion = cast(DibVersion)parseHeader!uint(data);

    // Parse dib header according to version, but store in most complex version
    DibHeader!() dibHeader;
    foreach (ver; EnumMembers!DibVersion) {
        if (dibVersion == ver) {
            dibHeader = cast(DibHeader!())parseHeader!(DibHeader!ver)(data);
        }
    }

    // Validation
    alias checkValid = enforce!(InvalidHeader, bool);

    checkValid(dibVersion > DibVersion.CORE || dibHeader.bitCount < 16,
               "Old BMP image header does not support bpp > 8");
    checkValid(dibHeader.planes == 1, "BMP image can only have one color plane.");
    checkValid(dibHeader.compression == CompressionMethod.RGB || dibHeader.dataSize > 0,
               "Invalid data size for compression method");
    checkValid(dibHeader.width > 0, "BMP image width must be positive");
    checkValid(dibHeader.height != 0, "BMP image height must not be 0");

    checkValid(dibHeader.dataSize == bmpHeader.size - bmpHeader.contentOffset,
               "BMP header's image size does not match DIB header's");

    // Calculate raster data sizes
    uint rowSize = (dibHeader.bitCount * dibHeader.width + 31)/32 * 4;
    uint columnSize = rowSize * dibHeader.height;
    checkValid(dibHeader.dataSize == columnSize,
               "BMP data size does not match image dimensions");

    // Compressions methods are not yet supported
    enforce!NotSupported(dibHeader.compression == CompressionMethod.RGB);

    // V5 has a ICC color profile, not yet supported
    enforce!NotSupported(dibVersion != DibVersion.V5);

    // Color tables are not yet supported
    enforce!NotSupported(dibHeader.colorsUsed == 0);
    enforce!NotSupported(dibHeader.bitCount > 8);

    // Default RGB masks, as early versions didn't have them
    if (dibVersion <= DibVersion.INFO) {
        checkValid((dibHeader.bitCount in DEFAULT_MASKS) != null,
                   "BMP header uses non-standard bpp without color masks");
        auto mask = DEFAULT_MASKS[dibHeader.bitCount];
        dibHeader.redMask   = mask[0];
        dibHeader.greenMask = mask[1];
        dibHeader.blueMask  = mask[2];
        dibHeader.alphaMask = mask[3];
    }

    uint[4] mask = [dibHeader.redMask, dibHeader.greenMask,
                    dibHeader.blueMask, dibHeader.alphaMask];

    return maskedRGBRasterLoad(data, mask, dibHeader.bitCount,
                               dibHeader.width, -dibHeader.height, 4);
}
