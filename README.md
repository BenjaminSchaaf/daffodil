# Daffodil

[![Build Status](https://travis-ci.org/BenjaminSchaaf/daffodil.svg?branch=master)](https://travis-ci.org/BenjaminSchaaf/daffodil)
[![Coverage Status](https://coveralls.io/repos/github/BenjaminSchaaf/daffodil/badge.svg?branch=master)](https://coveralls.io/github/BenjaminSchaaf/daffodil?branch=master)
[![Documentation Status](https://readthedocs.org/projects/daffodil/badge/?version=latest)](http://daffodil.readthedocs.org/en/latest/?badge=latest)
[![DUB Listing](https://img.shields.io/dub/dt/daffodil.svg)](http://code.dlang.org/packages/daffodil)

A image processing library for D, inspired by
[Pillow](https://python-pillow.github.io/).

Read the documentation [here](http://daffodil.readthedocs.org/en/latest/).

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
import daffodil.filter;
import daffodil.transform;

void main() {
    auto image = load!32("daffodil.bmp");

    image.gaussianBlurred(1.4).save("blurry_daffodil.bmp");

    image.flipped!"y".save("upside_down_daffodil.bmp");
}
```
