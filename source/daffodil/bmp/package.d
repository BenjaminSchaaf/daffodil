module daffodil.bmp;

public {
    import daffodil.bmp.meta;

    static {
        import headers = daffodil.bmp.headers;
    }
}

import std.math;
import std.traits;
import std.bitmanip;
import std.typecons;
import std.algorithm;
import core.bitop;

import daffodil;
import daffodil.util.data;
import daffodil.util.range;
import daffodil.util.errors;
import daffodil.util.headers;

import daffodil.bmp.headers;

/// Register this file format with the common api
static this() {
    registerFormat(Format(
        "BMP",
        &check!DataRange,
        &loadMeta!DataRange,
        (d, m) => loadImage!DataRange(d, cast(BmpMetaData)m).imageRangeObject,
        (d, i, m) => saveImage!(OutputRange!ubyte, RandomAccessImageRange!(real[]))(d, i, cast(BmpMetaData)m),
        [".bmp", ".dib"],
        typeid(BmpMetaData),
    ));
}

// Magic Number "BM"
const ubyte[] MAGIC_NUMBER = [0x42, 0x4D];

/**
 * Documentation
 */
bool check(R)(R data) if (isInputRange!R &&
                          is(ElementType!R == ubyte)) {
    auto taken = data.take(2).array;
    enforce!UnexpectedEndOfData(taken.length == 2);
    // Make sure data starts with the magic number
    return taken == MAGIC_NUMBER;
}
/// Ditto
bool check(T)(T loadeable) if (isLoadeable!T) {
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
auto load(V, T : DataRange)(T data, BmpMetaData meta = null) {
    enforce!InvalidImageType(check(data), "Data does not contain a bmp image.");

    if (meta is null) meta = loadMeta(data);
    return new Image!V(loadImage(data, meta), meta);
}
/// Ditto
auto load(V, T)(T loadeable) if (isLoadeable!T) {
    return load!V(dataLoad(loadeable));
}

// The default rgba masks for common formats
private enum DEFAULT_MASKS = [
    16 : tuple(0x0F_00_00_00u, 0x00_F0_00_00u, 0x00_0F_00_00u, 0xF0_00_00_00u),
    24 : tuple(0x00_00_FF_00u, 0x00_FF_00_00u, 0xFF_00_00_00u, 0x00_00_00_00u),
    32 : tuple(0x00_FF_00_00u, 0x00_00_FF_00u, 0x00_00_00_FFu, 0xFF_00_00_00u),
];

/**
 * Documentation
 */
BmpMetaData loadMeta(R)(R data) if (isInputRange!R &&
                                    is(ElementType!R == ubyte)) {
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
    enforce!NotSupported(dibHeader.compression == CompressionMethod.RGB ||
                         dibHeader.compression == CompressionMethod.BITFIELDS);

    // V5 has a ICC color profile, not yet supported
    enforce!NotSupported(dibVersion != DibVersion.V5);

    // Color tables are not yet supported
    enforce!NotSupported(dibHeader.colorsUsed == 0);
    enforce!NotSupported(dibHeader.bitCount > 8);

    // Use special color mask for special compression method
    if (dibHeader.compression == CompressionMethod.BITFIELDS) {
        auto mask = parseHeader!(DibColorMask!false)(data);
        dibHeader.redMask   = mask.redMask;
        dibHeader.greenMask = mask.greenMask;
        dibHeader.blueMask  = mask.blueMask;
    }
    // Default RGB masks, as early versions didn't have them
    else if (dibVersion <= DibVersion.INFO) {
        checkValid((dibHeader.bitCount in DEFAULT_MASKS) != null,
                   "BMP header uses non-standard bpp without color masks");
        auto mask = DEFAULT_MASKS[dibHeader.bitCount];
        dibHeader.redMask   = mask[0];
        dibHeader.greenMask = mask[1];
        dibHeader.blueMask  = mask[2];
        dibHeader.alphaMask = mask[3];
    }

    uint[] masks = [dibHeader.redMask, dibHeader.greenMask, dibHeader.blueMask];
    if (dibHeader.alphaMask != 0) {
        masks ~= dibHeader.alphaMask;
    }

    // Validate color masks
    foreach (mask; masks) {
        checkValid(mask != 0, "Color mask is 0");
    }

    return new BmpMetaData(dibHeader.width, abs(dibHeader.height),
                           bmpHeader, dibVersion, dibHeader);
}
/// Ditto
auto loadMeta(T)(T loadeable) if (isLoadeable!T) {
    return loadMeta(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto loadImage(R)(R data, BmpMetaData meta) if (isInputRange!R &&
                                                is(ElementType!R == ubyte)) {
    enforce!ImageException(meta !is null, "Cannot load bmp Image without bmp Meta Data");

    auto dib = meta.dibHeader;
    uint[] masks = [dib.redMask, dib.greenMask, dib.blueMask];
    if (dib.alphaMask != 0) {
        masks ~= dib.alphaMask;
    }

    return maskedRasterLoad(data, masks, dib.bitCount,
                            dib.width, -dib.height, &RGB, 4);
}
/// Ditto
auto loadImage(T)(T loadeable, BmpMetaData meta) if (isLoadeable!T) {
    return loadImage(dataLoad(loadeable), meta);
}

/**
 * Documentation
 */
void save(V, R)(Image!V image, R output) if (isOutputRange!(R, ubyte)) {
    saveImage(output, image.range, cast(BmpMetaData)image.meta);
}
/// Ditto
void save(V, T)(Image!V image, T saveable) if (isSaveable!T) {
    save(image, dataSave(saveable));
}

/**
 * Documentation
 */
void saveImage(R, I)(R output, I image, BmpMetaData meta) if (isOutputRange!(R, ubyte) &&
                                                              isRandomAccessImageRange!I) {
    if (meta is null) {
        // TODO: Default
        assert(false);
    }

    put(output, MAGIC_NUMBER[]);
    // TODO: Validation
    writeHeader(meta.bmpHeader, output);
    writeHeader(meta.dibVersion, output);

    foreach (ver; EnumMembers!DibVersion) {
        if (meta.dibVersion == ver) {
            writeHeader(cast(DibHeader!ver)meta.dibHeader, output);
        }
    }

    auto dib = meta.dibHeader;
    uint[] masks = [dib.redMask, dib.greenMask, dib.blueMask];
    if (dib.alphaMask != 0) {
        masks ~= dib.alphaMask;
    }

    maskedRasterSave(image, output, masks, dib.bitCount, dib.width, -dib.height, 4);
}
/// Ditto
void saveImage(T, I)(T saveable, I image, BmpMetaData meta) if (isSaveable!T &&
                                                                isRandomAccessImageRange!I) {
    return saveImage(dataSave(saveable), image, meta);
}
