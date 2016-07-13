/**
 * A gaussian filter (aka gaussian blur) is a convolution
 * (:d:mod:`daffodil.filter.convolve`) using a matrix created from a gaussian
 * distribution.
 */
module daffodil.filter.gaussian;

import std.math;

import daffodil.image;
import daffodil.filter;

/**
 * Evaluate the gaussian/normal distribution for a given ``x``, ``stDev`` and
 * ``mean``.
 */
real gaussianDistribution(real x, real stDev = 1, real mean = 0) {
    return 1/(stDev * sqrt(2 * PI))* E.pow(-pow(x - mean, 2)/(2 * pow(stDev, 2)));
}

@("gaussian distribution")
unittest {
    static void assertEq(real a, real b) {
        return assert(approxEqual(a, b));
    }

    // Standard Normal Distribution
    assertEq(gaussianDistribution(0), 0.398942);
    assertEq(gaussianDistribution(1), 0.241971);
    assertEq(gaussianDistribution(1), gaussianDistribution(-1));
    assertEq(gaussianDistribution(2), 0.053991);
    assertEq(gaussianDistribution(2), gaussianDistribution(-2));
    assertEq(gaussianDistribution(3), 0.004432);
    assertEq(gaussianDistribution(3), gaussianDistribution(-3));

    // Changed standard deviation
    assertEq(gaussianDistribution(0, 2), 0.199471);
    assertEq(gaussianDistribution(2, 2), 0.120985);

    // Changed mean
    assertEq(gaussianDistribution(0, 2, 2), 0.120985);
    assertEq(gaussianDistribution(2, 2, 2), 0.199471);
    assertEq(gaussianDistribution(4, 2, 2), 0.120985);
}

/**
 * Create a 1D matrix of a discrete gaussian distribution with a given standard
 * deviation and the number of standard deviations to stop generating at. The
 * result is mirrored with guaranteed odd length.
 *
 * The result can be used to convolve a image.
 */
real[] gaussianMatrix(real stDev = 1, real maxDev = 3) {
    auto range = cast(uint)ceil(stDev * maxDev);
    auto ret = new real[1 + 2*range];

    ret[range] = gaussianDistribution(0, stDev);
    foreach (i; 1..range + 1) {
        ret[range + i] = ret[range - i] = gaussianDistribution(i, stDev);
    }

    return ret;
}

@("gaussian matrix")
unittest {
    const matrix = [0.004432, 0.053991, 0.241971, 0.398942, 0.241971, 0.053991, 0.004432];
    assert(approxEqual(gaussianMatrix(), matrix));

    assert(gaussianMatrix(10).length == 61);
}

/**
 * Return a copy of ``image`` with a gaussian blur applied across axies
 * ``axis`` with a given standard deviation and the number of standard
 * deviations to stop at.
 */
auto gaussianBlurred(string axis = "xy", V)(const Image!V image, real stDev = 1, real maxDev = 3) {
    auto matrix = gaussianMatrix(stDev, maxDev);

    return image.convolved!axis(matrix);
}

@("gaussian blur")
unittest {
    import daffodil;

    auto image = new Image!ubyte(2, 2, 3, &RGB);
    image[0, 0] = [1f, 1f, 1f];
    image[0, 1] = [1f, 0f, 0f];
    image[1, 0] = [0f, 1f, 0f];
    image[1, 1] = [0f, 0f, 1f];

    auto blurred = image.gaussianBlurred(2);
    assert(blurred[0, 0] == [130, 130, 122]);
    assert(blurred[0, 1] == [130, 117, 122]);
    assert(blurred[1, 0] == [114, 130, 122]);
    assert(blurred[1, 1] == [114, 117, 122]);
}
