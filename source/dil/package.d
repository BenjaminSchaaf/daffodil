module dil;

import std.stdio;
import std.typecons;

import dil.util.data;
import dil.util.range;

public {
    import dil.meta;
    import dil.image;
    import dil.color;
    import dil.pixels;

    static {
        // Image Formats
        import bmp = dil.bmp;

        // Submodules
        import filter = dil.filter;
        import transform = dil.transform;
    }
}

/**
 * Documentation
 */
Format detectFormat(T : DataRange)(T data) {
    foreach (format; formats) {
        if (format.check(data)) {
            return format;
        }
    }
    assert(false);
}
/// Ditto
auto detectFormat(T)(T loadeable) {
    return detectFormat(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto loadMeta(T : DataRange)(T data) {
    auto format = detectFormat(data.save);
    return format.loadMeta(data);
}
/// Ditto
auto loadMeta(T)(T loadeable) {
    return loadMeta(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto load(PixelFmt, T : DataRange)(T data, MetaData meta = null) {
    import std.stdio;
    auto format = detectFormat(data.save);
    if (meta is null) meta = format.loadMeta(data);
    return new Image!PixelFmt(format.loadImage(data, meta));
}
/// Ditto
auto load(PixelFmt, T)(T loadeable) {
    return load!PixelFmt(dataLoad(loadeable));
}

alias Pixel      = Tuple!(Color, "color", size_t, "x", size_t, "y");
alias DataRange  = ForwardRange!ubyte;

/**
 * Documentation
 */
struct Format {
    string name;
    bool function(DataRange) check;
    MetaData function(DataRange) loadMeta;
    ImageRange!Pixel function(DataRange, MetaData) loadImage;
    void function(OutputRange!ubyte, ImageRange!Pixel, MetaData) save;
    string[] extensions;
}

private Format[] formats;
private Format[string] formatsByExt;

/**
 * Documentation
 */
void registerFormat(Format format) {
    formats ~= format;

    foreach (ext; format.extensions) {
        assert(ext !in formatsByExt);
        formatsByExt[ext] = format;
    }
}
