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
Format detectFormat(T)(T data) if (isDataRange!T) {
    auto range = data.inputRangeObject;
    foreach (format; formats) {
        try {
            if (format.check(range)) {
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
auto loadMeta(T)(T data) if (isDataRange!T) {
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
auto load(size_t bpc, T)(T data) if (isDataRange!T) {
    auto range = data.inputRangeObject;
    auto format = detectFormat(data);
    auto meta = format.loadMeta(range);
    return new Image!bpc(format.loadImage(range, meta), new RGB!bpc, meta);
}
/// Ditto
auto load(size_t bpc, T)(T loadeable) if (isLoadeable!T) {
    return load!bpc(dataLoad(loadeable));
}

/**
 * Documentation
 */
auto save(size_t bpc, T)(const Image!bpc image, T data) if (isOutRange!T) {

}
/// Ditto
void save(size_t bpc, T)(const Image!bpc image, T saveable) if (isSaveable!T) {
    return save(image, dataSave(saveable));
}

alias DataRange = InputRange!ubyte;
template isDataRange(T) {
    enum isDataRange = isInputRange!T && is(ElementType!T == ubyte);
}
alias OutRange = OutputRange!ubyte;
alias isOutRange(T) = isOutputRange!(T, ubyte);

/**
 * Documentation
 */
struct Format {
    string name;
    bool function(DataRange) check;
    MetaData function(DataRange) loadMeta;
    ImageRange!PixelData function(DataRange, MetaData) loadImage;
    void function(OutputRange!ubyte, RandomAccessImageRange!(real[]), MetaData) save;
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
