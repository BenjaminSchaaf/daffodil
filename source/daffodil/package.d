module daffodil;

import std.stdio;
import std.typecons;

import daffodil.util.data;
import daffodil.util.range;

public {
    import daffodil.meta;
    import daffodil.image;
    import daffodil.color;
    import daffodil.util.errors;

    static {
        // Image Formats
        import bmp = daffodil.bmp;

        // Submodules
        import filter = daffodil.filter;
        import transform = daffodil.transform;
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
auto load(size_t bpc, T : DataRange)(T data, MetaData meta = null) {
    import std.stdio;
    auto format = detectFormat(data.save);
    if (meta is null) meta = format.loadMeta(data);
    return new Image!bpc(format.loadImage(data, meta), new RGB!bpc);
}
/// Ditto
auto load(size_t bpc, T)(T loadeable) {
    return load!bpc(dataLoad(loadeable));
}

alias DataRange = ForwardRange!ubyte;

/**
 * Documentation
 */
struct Format {
    string name;
    bool function(DataRange) check;
    MetaData function(DataRange) loadMeta;
    ImageRange!PixelData function(DataRange, MetaData) loadImage;
    void function(OutputRange!ubyte, ImageRange!PixelData, MetaData) save;
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
