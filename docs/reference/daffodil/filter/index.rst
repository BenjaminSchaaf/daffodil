filter
######

The :d:mod:`daffodil.filter` module provides various filter functions that can
be performed on images. filter functions differ from transformations
(:d:mod:`daffodil.transform`) in that they cannot be performed in-place, ie. a
copy of the image is required to perform the filter.

.. toctree::
    :hidden:
    :maxdepth: 2

    convolve
    gaussian

.. automodule:: daffodil.filter
