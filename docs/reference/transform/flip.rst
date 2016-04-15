.. d:module:: daffodil.transform.flip

daffodil.transform.flip
#######################

.. d:function::
    void flip(string axis, size_t bpc)(Image!bpc image)
    :name: flip

    Flip ``image`` along ``axis`` in-place. ``axis`` may contain ``x``, ``y`` or
    both.

    Example::

        auto image = load!8("daffodil.bmp");
        image.flip!"x"(); // Flip the image horizontally
        image.flip!"y"(); // Flip the image vertically

.. d:function::
    Image!bpc flipped(string axis, size_t bpc)(const Image!bpc image)
    :name: flip

    Same as :d:func:`flip` but performs the operation on a copy of ``image``.
    Allows for stringing operations together.

    Example::

        auto image = load!8("daffodil.bmp");

        // Flip along each axis individually, making a copy each time.
        auto flipped = image.flipped!"x".flipped!"y";
