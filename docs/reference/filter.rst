.. d:module:: daffodil.filter

daffodil.filter
###############

The :d:mod:`daffodil.filter` module provides various filter functions that can
be performed on images. filter functions differ from transformations
(:d:mod:`daffodil.transform`) in that they cannot be performed in-place, ie. a
copy of the image is required to perform the filter.

Public Imports:

- :d:mod:`daffodil.filter.convolve`
- :d:mod:`daffodil.filter.gaussian`

.. toctree::
    :hidden:
    :maxdepth: 2

    filter/convolve
    filter/gaussian
