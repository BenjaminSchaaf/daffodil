.. d:module:: daffodil.filter.convolve

daffodil.filter.convolve
########################

.. d:function::
    auto convolved(size_t bpc)(const Image!bpc image, const real[] matrix, int width, int[2] center)
    auto convolved(string axis, size_t bpc)(const Image!bpc image, const real[] matrix, int center)
    auto convolved(string axis, size_t bpc)(const Image!bpc image, const real[] matrix)
    :name: convolved

    Given a matrix, convolve an image.
