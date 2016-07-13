module daffodil.filter.convolve;

import std.range;
import std.algorithm;

import daffodil.image;

/**
 * Convolve a flat 2D matrix with a given center over an image and return the result.
 *
 * With a matrix [0.5, 0.5] with width 2 and center [0, 0] convolved over an image
 * each resulting pixel will be a 50:50 mix of itself and its right neighbour.
 *
 * TODO: Abstract away matrix, width and center into a kernel
 */
auto convolved(V)(const Image!V image, const real[] matrix, int width, int[2] center) {
    auto height = matrix.length / width;
    auto ret = image.dup;

    foreach (imageY; 0..image.height) {
        foreach (imageX; 0..image.width) {
            // Make sure weighting always adds up to 1. Fixes corners and incorrect/incomplete matrices.
            real accum = 0;

            // Accumulate color by weighing adjacent pixels according to given matrix.
            auto color = ret.newColor();

            foreach (indexY; 0..height) {
                auto matrixY = indexY - center[1];
                if (matrixY + imageY < 0 || matrixY + imageY >= image.height) continue;

                foreach (indexX; 0..width) {
                    auto matrixX = indexX - center[0];
                    if (matrixX + imageX < 0 || matrixX + imageX >= image.width) continue;

                    auto matrixValue = matrix[indexX + indexY * width];
                    accum += matrixValue;

                    //TODO: Shorthand once color operation is implemented
                    color = color + image[imageX + matrixX, imageY + matrixY] * matrixValue;
                }
            }

            ret[imageX, imageY] = color * (1/accum);
        }
    }

    return ret;
}
/// Ditto
auto convolved(string axis, V)(const Image!V image, const real[] matrix, int center) {
    auto ret = image.dup;

    static if (canFind(axis, 'x')) {
        // Apply matrix horizontally
        ret = ret.convolved(matrix, cast(int)matrix.length, [center, 0]);
    }

    static if (canFind(axis, 'y')) {
        // Apply matrix vertically
        ret = ret.convolved(matrix, 1, [0, center]);
    }

    return ret;
}
/// Ditto
auto convolved(string axis, V)(const Image!V image, const real[] matrix) {
    return image.convolved!axis(matrix, cast(int)(matrix.length / 2));
}

//TODO: Add tests
