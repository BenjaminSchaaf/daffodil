gaussian
########

A gaussian filter (aka gaussian blur) is a convolution
(:d:mod:`daffodil.filter.convolve`) using a matrix created from a gaussian
distribution.

.. d:function::
    real gaussianDistribution(real x, real stDev = 1, real mean = 0)
    :name: gaussianDistribution

    Evaluate the gaussian/normal distribution for a given ``x``, ``stDev`` and
    ``mean``.

.. d:function::
    real[] gaussianMatrix(real stDev = 1, real maxDev = 3)
    :name: gaussianMatrix

    Create a 1D matrix of a discrete gaussian distribution with a given standard
    deviation and the number of standard deviations to stop generating at. The
    result is mirrored with guaranteed odd length.

    The result can be used to convolve a image.

.. d:function::
    auto gaussianBlurred(string axis = "xy", size_t bpc)(const Image!bpc image, real stDev = 1, real maxDev = 3)
    :name: gaussianBlurred

    Return a copy of ``image`` with a gaussian blur applied across axies
    ``axis`` with a given standard deviation and the number of standard
    deviations to stop at.

.. automodule:: daffodil.filter.gaussian
