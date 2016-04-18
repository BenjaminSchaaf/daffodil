module daffodil.all;

import std.stdio;
import std.typecons;

import daffodil.util.data;
import daffodil.util.range;

public {
    import daffodil.meta;
    import daffodil.image;
    import daffodil.color;
    import daffodil.util.errors;

    // Submodules
    static {
        import filter = daffodil.filter;
        import transform = daffodil.transform;
        // Image Formats
        import bmp = daffodil.bmp;
    }
}

/**
 * Documentation
 */
Format detectFormat(T : DataRange)(T data) {
    foreach (format; formats) {
        try {
            if (format.check(data)) {
                return format;
            }
        } catch (ImageException e) {
            continue;
        }

    }
    throw new NotSupported("Unknown Format");
}
/// Ditto
auto detectFormat(T)(T loadeable) if (isLoadeable!T) {
    return detectFormat(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto loadMeta(T : DataRange)(T data) {
    auto format = detectFormat(data);
    return format.loadMeta(data);
}
/// Ditto
auto loadMeta(T)(T loadeable) if (isLoadeable!T) {
    return loadMeta(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto load(size_t bpc, T : DataRange)(T data) {
    import std.stdio;
    auto format = detectFormat(data);
    auto meta = format.loadMeta(data);
    return new Image!bpc(format.loadImage(data, meta), new RGB!bpc);
}
/// Ditto
auto load(size_t bpc, T)(T loadeable) if (isLoadeable!T) {
    return load!bpc(dataLoad(loadeable));
}

alias DataRange = InputRange!ubyte;

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
