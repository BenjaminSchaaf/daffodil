/**
 * This module provides various filter functions that can be performed on
 * images. Filter functions differ from transformations
 * (:d:mod:`daffodil.transform`) in that they cannot be performed in-place, ie.
 * a copy of the image is required to perform the filter.
 */
module daffodil.filter;

public {
    import daffodil.filter.convolve;
    import daffodil.filter.gaussian;
}
