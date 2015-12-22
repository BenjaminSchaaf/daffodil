module dil.bmp;

public static {
    import headers = dil.bmp.headers;
}

import std.math;
import std.traits;
import std.bitmanip;
import std.typecons;

import dil;
import dil.misc;
import dil.util.errors;
import dil.util.headers;

import dil.bmp.headers;

/**
 * Returns: Whether a `ubyte[]` looks like BMP file
 */
bool isBMP(ubyte[] data) {
    return data[0..2] == BMP_FILE_HEADER;
}

unittest {
    assert(isBMP([0x42, 0x4D, 0x32, 0x7D, 0xFA, 0x9E]));
    assert(!isBMP([0x43, 0x4D, 0x32, 0x7D, 0xFA, 0x9E]));
    assert(!isBMP([0x42, 0x4C, 0x32, 0x7D, 0xFA, 0x9E]));
}

// The default rgba masks for common formats
private enum DEFAULT_MASKS = [
    16 : tuple(    0x0_F_0_0u,     0x0_0_F_0u,     0x0_0_0_Fu,     0xF_0_0_0u),
    24 : tuple(   0x00_00_FFu,    0x00_FF_00u,    0xFF_00_00u,    0x00_00_00u),
    32 : tuple(0x00_FF_00_00u, 0x00_00_FF_00u, 0x00_00_00_FFu, 0xFF_00_00_00u),
];

/**
 * Attempts to open an image as a BMP file given a pixel format.
 * Returns: A Image object of the given pixel format.
 */
auto open(PixelFmt)(ubyte[] data) {
    enforce!InvalidImageType(isBMP(data), "Data does not contain a bmp image.");
    size_t offset = 2;

    auto bmpHeader = parseHeader!BmpHeader(data, offset);
    auto version_ = cast(DibVersion)parseHeader!uint(data, offset);

    DibHeader!() dibHeader;
    foreach (member; EnumMembers!DibVersion) {
        if (version_ == member) {
            dibHeader = cast(DibHeader!())parseHeader!(DibHeader!member)(data, offset);
        }
    }

    alias checkValid = enforce!(InvalidHeader, bool);

    // Check that the header is valid
    checkValid(version_ > DibVersion.CORE || dibHeader.bitCount < 16,
               "Old BMP image header does not support bpp > 8");
    checkValid(dibHeader.planes == 1, "BMP image can only have one color plane.");
    checkValid(dibHeader.compression == CompressionMethod.RGB || dibHeader.dataSize > 0,
               "Invalid data size for compression method");
    checkValid(dibHeader.width > 0, "BMP image width must be positive");
    checkValid(dibHeader.height != 0, "BMP image height must not be 0");

    checkValid(dibHeader.dataSize == bmpHeader.size - bmpHeader.contentOffset,
               "BMP header's image size does not match DIB header's");
    uint rowSize = (dibHeader.bitCount * dibHeader.width + 31)/32 * 4;
    uint columnSize = rowSize * dibHeader.height;
    checkValid(dibHeader.dataSize == columnSize,
               "BMP data size does not match image dimensions");

    // Compressions methods are not yet supported
    enforce!NotSupported(dibHeader.compression == CompressionMethod.RGB);

    // V5 has a ICC color profile, not yet supported
    enforce!NotSupported(version_ != DibVersion.V5);

    // Color tables are not yet supported
    enforce!NotSupported(dibHeader.colorsUsed == 0);
    enforce!NotSupported(dibHeader.bitCount > 8);

    // Default RGB masks, as early versions didn't have them
    if (version_ <= DibVersion.INFO) {
        checkValid((dibHeader.bitCount in DEFAULT_MASKS) != null,
                   "BMP header uses non-standard bpp without color masks");
        auto mask = DEFAULT_MASKS[dibHeader.bitCount];
        dibHeader.redMask   = mask[0];
        dibHeader.greenMask = mask[1];
        dibHeader.blueMask  = mask[2];
        dibHeader.alphaMask = mask[3];
    }

    //TODO: Handle color table

    ubyte[] pixelArray = data[bmpHeader.contentOffset..$];
    auto image = new Image!PixelFmt(dibHeader.width, abs(dibHeader.height));

    // Read pixelArray into colors, which convert to pixels
    foreach (rowIndex; 0..abs(dibHeader.height)) {
        auto row = pixelArray[rowIndex * rowSize .. (rowIndex + 1) * rowSize];
        foreach (columnIndex; 0..dibHeader.width) {
            auto bitIndex = columnIndex * dibHeader.bitCount;

            // Grab the range of ubytes that contain the bit data
            auto lowerByte = cast(uint)floor(bitIndex / 8.0);
            auto upperByte = cast(uint)ceil((bitIndex + dibHeader.bitCount) / 8.0);
            auto pixelData = row[lowerByte..upperByte];

            // Get the bit offset relative to the first byte
            bitIndex += dibHeader.bitCount - 8 - lowerByte * 8;

            // Get the color from the ubytes
            Color color = maskedBitsToColor(pixelData, bitIndex,
                                            [dibHeader.redMask, dibHeader.greenMask,
                                             dibHeader.blueMask, dibHeader.alphaMask]);

            // Bmp stores them bottom to top
            image[columnIndex, dibHeader.height - rowIndex - 1] = PixelFmt(color);
        }
    }

    return image;
}
mixin(OpenOverloads);

private auto maskedBitsToColor(ubyte[] data, uint shift, uint[4] masks) {
    import core.bitop;

    uint[4] offsets;
    uint[4] colorData;
    foreach (piece; data) {
        foreach (i; 0..4) {
            // Get part of mask relevant to piece
            ubyte mask = cast(ubyte)(masks[i] >> shift);

            // If any part of piece should be considered
            if (mask > 0) {
                // TODO: Lots of optimisation
                foreach (j; bsf(mask)..bsr(mask) + 1) {
                    if (mask & (1 << j)) {
                        colorData[i] += (piece >> j & 1) * (1 << offsets[i]);
                        offsets[i]++;
                    }
                }
            }

        }
        shift -= 8;
    }

    // Read integer values into reals
    Color color;
    foreach (i; 0..4) {
        // Only if any value was read, otherwise use the color's default
        if (offsets[i] > 0) {
            color[i] = colorData[i] / cast(real)((1 << offsets[i]) - 1);
        }
    }
    return color;
}
