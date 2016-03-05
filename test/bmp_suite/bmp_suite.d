module bmp_suite.bmp_suite;

import std.file;
import std.format;

import unit_threaded;
import dil;

@ShouldFail
@("BMP test suite")
unittest {
    auto succeeded = 0;
    auto failed = 0;

    foreach (fileName; dirEntries("test/bmp_suite/g", SpanMode.shallow)) {
        writelnUt("test %s".format(fileName));

        try {
            auto image = bmp.load!Pixel24Bpp(fileName);
            assert(image !is null);
            succeeded++;
        } catch (ImageException e) {
            writelnUt(e);
            failed++;
        }
    }

    writelnUt("%d succeeded, %d failed".format(succeeded, failed));
    assert(failed == 0);
}
