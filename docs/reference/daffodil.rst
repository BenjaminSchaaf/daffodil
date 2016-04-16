.. d:module:: daffodil

daffodil
########

The :d:mod:`daffodil` module provides the public interface for Daffodil.

Public Imports:

- :d:mod:`daffodil.meta`
- :d:mod:`daffodil.image`
- :d:mod:`daffodil.color`
- :d:mod:`daffodil.util.errors`

Submodules
==========

- :d:mod:`filter<daffodil.filter>`
- :d:mod:`transform<daffodil.transform>`
- :d:mod:`bmp<daffodil.bmp>`

Image Functions
===============

.. d:function::
    Format detectFormat(T : DataRange)(T data)
    Format detectFormat(T : Loadeable) if (isLoadable!T)
    :name: detectFormat

    .. todo:: docs

.. d:function::
    MetaData loadMeta(T : DataRange)(T data)
    MetaData loadMeta(T : Loadeable) if (isLoadable!T)
    :name: loadMeta

    .. todo:: docs

.. d:function::
    Image!bpc load(size_t bpc, T : DataRange)(T data)
    Image!bpc load(size_t bpc, T : Loadeable) if (isLoadable!T)
    :name: load

    .. todo:: docs

.. d:alias::
    alias DataRange = ForwardRange!ubyte
    :name: DataRange

    Alias for a stream of byte data that a image can be loaded from.

API Extensions
==============

.. d:function::
    void registerFormat(Format format)
    :name: registerFormat

    Register a new :d:struct:`Format` for loading images.

    Example::

        // my_image_format.d
        static this() {
            registerFormat(Format(
                "MyImageFormat",
                &check!DataRange,
                &loadMeta!DataRange,
                &loadImage!DataRange,
                null, // Not implemented yet
                [".mif", ".myif"],
            ));
        }

        // MyImageFormat can then be inferred
        auto image = load!8("daffodil.mif");

.. d:struct::
    struct Format

    ::

        string name;
        bool function(DataRange) check;
        MetaData function(DataRange) loadMeta;
        ImageRange!PixelData function(DataRange, MetaData) loadImage;
        void function(OutputRange!ubyte, ImageRange!PixelData, MetaData) save;
        string[] extensions;
