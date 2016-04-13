@("detect and load a image file")
unittest {
    import daffodil;

    auto image = load!32("test/images/bmp_small-24bpp.bmp");
    assert(image.size == [41, 45]);
}
