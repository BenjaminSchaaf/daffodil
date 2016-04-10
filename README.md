# Daffodil

A image processing library for D, inspired by
[Pillow](https://python-pillow.github.io/).

## Goals

- Simple, Extensible API
- Controllable internals with suitable defaults
- Wide format support with extensive testing
- High performance
- Support a variety of filters and transformations
- Thread Safety (pending)

## Example

```D
import daffodil;
import std.stdio;

void main() {
    auto image = open!Pixel24Bpp("some_image.bmp");

    writefln("some_image.bmp, %dx%d", image.width, image.height);
    writeln("image[10, 10] = ", image[10, 10].toColor());
}
```
