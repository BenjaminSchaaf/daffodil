module daffodil.transform.flip;

import std.algorithm;

import daffodil.image;

/**
 * Flip ``image`` along ``axis`` in-place. ``axis`` may contain ``x``, ``y`` or
 * both.
 */
void flip(string axis, V)(Image!V image) {
    static if (canFind(axis, 'x')) {
        foreach (y; 0..image.height) {
            foreach (x; 0..image.width/2) {
                auto temp = image[$ - x - 1, y].dup;
                image[$ - x - 1, y] = image[x, y];
                image[x, y] = temp;
            }
        }
    }

    static if (canFind(axis, 'y')) {
        foreach (x; 0..image.width) {
            foreach(y; 0..image.height/2) {
                auto temp = image[x, $ - y - 1].dup;
                image[x, $ - y - 1] = image[x, y];
                image[x, y] = temp;
            }
        }
    }
}

/**
 * Same as :d:func:`flip` but performs the operation on a copy of ``image``.
 * Allows for stringing operations together.
 */
auto flipped(string axis, V)(const Image!V image) {
    auto output = image.dup;
    output.flip!axis();
    return output;
}

@("flip transformation")
unittest {
    import daffodil;

    auto image = new Image!ubyte(2, 2, 3, RGB!ubyte);
    image[0, 0] = [1f, 1f, 1f];
    image[0, 1] = [1f, 0f, 0f];
    image[1, 0] = [0f, 1f, 0f];
    image[1, 1] = [0f, 0f, 1f];

    image.flip!"x"();
    assert(image[0, 0] == [  0, 255,   0]);
    assert(image[0, 1] == [  0,   0, 255]);
    assert(image[1, 0] == [255, 255, 255]);
    assert(image[1, 1] == [255,   0,   0]);

    image.flip!"y"();
    assert(image[0, 0] == [  0,   0, 255]);
    assert(image[0, 1] == [  0, 255,   0]);
    assert(image[1, 0] == [255,   0,   0]);
    assert(image[1, 1] == [255, 255, 255]);

    image = image.flipped!"xy"();
    assert(image[0, 0] == [255, 255, 255]);
    assert(image[0, 1] == [255,   0,   0]);
    assert(image[1, 0] == [  0, 255,   0]);
    assert(image[1, 1] == [  0,   0, 255]);
}
