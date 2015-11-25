module dil.bmp;

public static {
    import headers = dil.bmp.headers;
}

import std.math;
import std.traits;
import std.bitmanip;
import std.typecons;

import dil.misc;
import dil.color;
import dil.image;
import dil.pixels;
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
Image!PixelFmt open(PixelFmt)(ubyte[] data) {
    assert(isBMP(data));
    size_t offset = 2;

    auto bmpHeader = parseHeader!BmpHeader(data, offset);
    auto version_ = cast(DibVersion)parseHeader!uint(data, offset);

    DibHeader!() dibHeader;
    foreach (member; EnumMembers!DibVersion) {
        if (version_ == member) {
            dibHeader = cast(DibHeader!())parseHeader!(DibHeader!member)(data, offset);
        }
    }

    // Sanity Checks
    assert(version_ > DibVersion.CORE || dibHeader.bitCount < 16);
    assert(dibHeader.planes == 1);
    assert(dibHeader.compression == CompressionMethod.RGB || dibHeader.dataSize > 0);
    assert(dibHeader.width > 0);
    assert(dibHeader.height != 0); // Height may be negative

    // Compressions methods are not yet supported
    assert(dibHeader.compression == CompressionMethod.RGB);

    // V5 has a ICC color profile, not yet supported
    assert(version_ != DibVersion.V5);

    // Color tables are not yet supported
    assert(dibHeader.colorsUsed == 0);
    assert(dibHeader.bitCount > 8);

    // Sanity checks
    assert(dibHeader.dataSize == bmpHeader.size - bmpHeader.contentOffset);
    uint rowSize = (dibHeader.bitCount * dibHeader.width + 31)/32 * 4;
    uint columnSize = rowSize * dibHeader.height;
    assert(dibHeader.dataSize == columnSize);

    // Default RGB masks, as early versions didn't have them
    if (version_ <= DibVersion.INFO) {
        assert(dibHeader.bitCount in DEFAULT_MASKS);
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
    real[4] color;
    foreach (i; 0..4) {
        color[i] = colorData[i] / cast(real)(1 << offsets[i]);
    }

    return Color(color[0], color[1], color[2], color[3]);
}

unittest {
    import dil;

    auto image = bmp.open!Pixel24Bpp("test/small.bmp");
    assert(image.width == 41);
    assert(image.height == 45);
    assert(image.bpp == 24);
    assert(image[10, 10] == Pixel24Bpp(0, 0, 254));
    assert(image[30, 10] == Pixel24Bpp(0, 254, 0));
    assert(image[10, 30] == Pixel24Bpp(254, 0, 0));
    assert(image[30, 30] == Pixel24Bpp(254, 254, 254));
}
