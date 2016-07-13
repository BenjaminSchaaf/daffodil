module testall;

import daffodil;
import unit_threaded;

@("fails on empty file")
unittest {
    shouldThrow!(ImageException)(
        load("test/images/empty.file")
    );
}

@("detect and load a image file")
unittest {
    auto image = load("test/images/bmp_small-24bpp.bmp");
    assert(image.size == [41, 45]);
}
