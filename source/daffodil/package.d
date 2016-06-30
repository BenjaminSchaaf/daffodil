/**
 * This module provides the public interface for Daffodil.
 */
module daffodil;

import std.path;
import std.stdio;
import std.typecons;
import std.algorithm;

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
 * Detects the :d:struct:`Format` a given input is in.
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
/// Ditto
Format detectFormat(size_t bpc)(const Image!bpc image) {
    auto typeInfo = typeid(image.meta);
    foreach (format; formats) {
        if (format.metaType && format.metaType == typeInfo) {
            return format;
        }
    }
    throw new NotSupported("Unknown Format");
}

/**
 * Loads the metadata from a given input.
 */
auto loadMeta(T)(T data) if (isDataRange!T) {
    auto format = detectFormat(data);
    return format.loadMeta(data.inputRangeObject);
}
/// Ditto
auto loadMeta(T)(T loadeable) if (isLoadeable!T) {
    return loadMeta(dataLoad(loadeable));
}

/**
 * Loads a :d:class:`Image` from a given input.
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
 * Saves a particular :d:class:`Image` to a given output.
 */
void save(size_t bpc, T)(const Image!bpc image, T data) if (isOutRange!T) {
    auto format = detectFormat(image);
    format.save(data.outputRangeObject!ubyte, image.range.imageRangeObject, image.meta);
}
/// Ditto
void save(size_t bpc)(const Image!bpc image, string path) {
    // Specialcase for paths, to match by extension
    Nullable!Format format;
    foreach (f; formats) {
        if (f.extensions.canFind(path.extension)) {
            format = f;
            break;
        }
    }

    if (format.isNull) {
        format = detectFormat(image);
    }

    auto data = dataSave(path).outputRangeObject!ubyte;
    format.save(data, image.range.imageRangeObject, image.meta);
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
 * A struct for metadata about an Image Format. See :d:func:`registerFormat` for
 * more information.
 */
struct Format {
    ///
    string name;
    ///
    bool function(DataRange) check;
    ///
    MetaData function(DataRange) loadMeta;
    ///
    ImageRange!PixelData function(DataRange, MetaData) loadImage;
    ///
    void function(OutputRange!ubyte, RandomAccessImageRange!(real[]), const MetaData) save;
    ///
    string[] extensions;
    ///
    TypeInfo metaType;
}

private Format[] formats;
private Format[string] formatsByExt;

/**
 * Register a new format for auto-detection with :d:func:`detectFormat`,
 * :d:func:`loadMeta` and :d:func:`load` functions.
 */
void registerFormat(Format format) {
    formats ~= format;

    foreach (ext; format.extensions) {
        assert(ext !in formatsByExt);
        formatsByExt[ext] = format;
    }
}
