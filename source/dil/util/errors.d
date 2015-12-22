module dil.util.errors;

public import std.exception;

/// Create a basic exception subclass with the default exception constructor.
mixin template classException(string name, base = Exception) {
    mixin(q{
        class }~name~q{ : base {
            @safe pure nothrow this(string m, string f = __FILE__, size_t l = __LINE__, Throwable n = null ) {
                super(m, f, l, n);
            }
        }
    });
}

/// Exception thrown when a image failed to load
mixin classException!"ImageException";

/// Exception thrown when the header for an image is invalid
mixin classException!("InvalidHeader", ImageException);

/// Exception thrown when image data was not in a required format, ie. wrong file type
mixin classException!("InvalidImageType", ImageException);

/// Exception thrown when a image has unsupported features.
mixin classException!("NotSupported", ImageException);
