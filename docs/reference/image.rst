.. d:module:: daffodil.image

daffodil.image
##############

The :d:mod:`daffodil.image` module exposes the :d:class:`Image` class, which
provides basic storage, access and conversion of images.

.. d:class::
    class Image(size_t bpc_)

    .. d:enum::
        enum bpc = bpc_

        The bits per channel of this image.

    .. d:alias::
        alias Value = Integer!bpc

        The type used internally to store values of a pixel for each channel.

    .. d:function::
        this(size_t width, size_t height, size_t channelCount, ColorSpace!bpc colorSpace)
        this(R)(R range, ColorSpace!bpc colorSpace) if (isImageRange!R && is(ElementType!R == PixelData))
        this(const Image other)
        :name: this

        .. todo:: docs

    .. d:function::
        @property size_t width() const
        :name: width

        Get the width of the image.

    .. d:function::
        @property size_t height() const
        :name: height

        Get the height of the image.

    .. d:function::
        @property size_t[2] size() const
        :name: size

        Get the size of the image as a array containing :d:func:`width` and
        :d:func:`height`.

    .. d:function::
        @property size_t channelCount() const
        :name: channelCount

        Get the number of color channels in the image.

    .. d:function::
        size_t opDollar(size_t pos)() const
        :name: opDollar

        .. todo:: docs

    .. d:function::
        auto opIndex(size_t x, size_t y) const
        :name: opIndex

        .. todo:: docs

    .. d:function::
        void opIndexAssign(const Pixel!bpc color, size_t x, size_t y)
        void opIndexAssign(real[] values, size_t x, size_t y)
        :name: opIndexAssign

        .. todo:: docs

    .. d:function::
        @property Image!bpc dup() const
        :name: dup

        Create a duplicate of the image.

    .. d:function::
        override string toString() const
        :name: toString

        Return a nicely formatted string representation of the image's data.
