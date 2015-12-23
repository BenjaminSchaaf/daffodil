.. d:module:: dil

dil
###

The :d:mod:`dil` module provides the public interface for DIL. Publicly imports
:d:mod:`dil.image`, :d:mod:`dil.pixels` and statically imports
:d:mod:`dil.bmp`.

Functions
=========

.. d:function::
    Image!PixelFmt open(PixelFmt)(File file)
    Image!PixelFmt open(PixelFmt)(string path)
    Image!PixelFmt open(PixelFmt)(ubyte[] data)
    :name: open

    Attempt to detect the given image's type and then load it into an
    :d:class:`Image` instance. The ``PixelFmt`` defines the internal storage
    format used by DIL.

Example
-------

.. code-block:: d

    import dil;

    auto image = open!Pixel24Bpp("foo.bmp")
