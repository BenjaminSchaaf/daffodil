# Daffodil

[![Build Status](https://travis-ci.org/BenjaminSchaaf/daffodil.svg?branch=master)](https://travis-ci.org/BenjaminSchaaf/daffodil)
[![Coverage Status](https://coveralls.io/repos/github/BenjaminSchaaf/daffodil/badge.svg?branch=master)](https://coveralls.io/github/BenjaminSchaaf/daffodil?branch=master)
[![DUB Listing](https://img.shields.io/dub/dt/daffodil.svg)](http://code.dlang.org/packages/daffodil)

A image processing library for D, inspired by
[Pillow](https://python-pillow.github.io/).

Read the documentation [here](https://benjaminschaaf.github.io/daffodil/).

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
    // daffodil allows you to choose what format pixels are stored with
    // defaults to `real` for when you don't care about memory usage.
    auto image = load!uint("daffodil.bmp");

    // concise filter usage, with a simple saving API
    image.gaussianBlurred(1.4)
         .save("blurry_daffodil.bmp");

    // easy transformations
    image.flip!"y";
    image.save("upside_down_daffodil.bmp");
}
```

## Installing

Add daffodil as a dependency to your
[dub.json](https://code.dlang.org/package-format?lang=json):

```json
"dependencies": {
    "daffodil": "~>0.1.1"
}
```

Or [fetch](https://code.dlang.org/docs/commandline) the package directly:

```bash
dub fetch daffodil
```

## Development

### Testing

Tests use the [unit-threaded](https://github.com/atilaneves/unit-threaded)
framework and can be run using:

```bash
dub test
```

### Documentation

Documentation is written using the [sphinx
framework](http://www.sphinx-doc.org/en/stable/) and a custom D domain/autodoc
for sphinx ([sphinxddoc](https://github.com/BenjaminSchaaf/sphinxddoc)).

To build the documentation, simply run:

```bash
make html
```
