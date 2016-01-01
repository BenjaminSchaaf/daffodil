# DIL

D Imaging Library: Image processing in D, a library inspired by
[Pillow](https://python-pillow.github.io/). Unlike other libraries, the internal storage
format is not predefined and can instead be anything from 8Bpp to 1024Bpp+.

## Goals

- Simple, Extensible API
- Controllable internals with suitable defaults
- Wide format support with extensive testing
- High performance
- Support a variety of filters and transformations
- Thread Safety (pending)

## Example

``` D
import dil;
import std.stdio;

void main() {
    auto image = open!Pixel24Bpp("some_image.bmp");

    writefln("some_image.bmp, %dx%d", image.width, image.height);
    writeln("image[10, 10] = ", image[10, 10].toColor());
}
```
