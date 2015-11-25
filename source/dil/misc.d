module dil.misc;

/**
 * Both the individual image format packages, and the global package all have
 * a `open` function and need the same overloads. Mixin this for the other overloads.
 * Include after open(ubyte[]) for ddocs to work
 */
enum OpenOverloads =  q{
    /// Ditto
    auto open(PixelFmt)(string path) {
        return open!PixelFmt(cast(ubyte[])read(path));
    }
    /// Ditto
    auto open(PixelFmt)(File file) {

        assert(file.size < ulong.max);
        ubyte[] buffer = new ubyte[cast(uint)file.size];
        return open!PixelFmt(file.rawRead!ubyte(buffer));
    }

    import std.stdio;
    import std.file;
};
