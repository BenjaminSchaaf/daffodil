@("load BMP meta data")
unittest {
    import daffodil;
    import bmp = daffodil.bmp;

    auto meta = loadMeta("test/images/bmp_small-24bpp.bmp");
    assert(meta !is null);
    assert(meta.width);
    assert(meta.height);
    assert(cast(bmp.BmpMetaData)meta);
}

@("load BMP image data")
unittest {
    import daffodil;

    auto image = load!8("test/images/bmp_small-24bpp.bmp");
    assert(image !is null);
    assert(image.width == 41);
    assert(image.height == 45);
    assert(image[10, 10] == [  0f,   0f, 255f]);
    assert(image[30, 10] == [  0f, 255f,   0f]);
    assert(image[10, 30] == [255f,   0f,   0f]);
    assert(image[30, 30] == [255f, 255f, 255f]);
}
