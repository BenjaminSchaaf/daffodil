.. d:module:: daffodil.meta

daffodil.meta
#############

The :d:mod:`daffodil.meta` module exposes the :d:struct:`MetaData` class.

.. d:class::
    class MetaData

    A data container used to store metadata for an image. Can usually be loaded
    separately to an image itself and is used by save functions to derive
    formatting. Different image formats usually use their own subclasses.

    .. d:variable::
        size_t width

        The width of the image.

    .. d:variable::
        size_t height

        The height of the image.
