.. d:module:: daffodil

daffodil
########

The :d:mod:`daffodil` module provides the public interface for Daffodil.
Publicly imports :d:mod:`daffodil.image`, :d:mod:`daffodil.pixels` and
statically imports :d:mod:`daffodil.bmp`.

Functions
=========

.. d:function::
    Image!PixelFmt open(PixelFmt)(File file)
    Image!PixelFmt open(PixelFmt)(string path)
    Image!PixelFmt open(PixelFmt)(ubyte[] data)
    :name: open

    Attempt to detect the given image's type and then load it into an
    :d:class:`Image` instance. The ``PixelFmt`` defines the internal storage
        format used by Daffodil.

Example
-------

.. code-block:: d

    import daffodil;

    auto image = open!Pixel24Bpp("foo.bmp")
