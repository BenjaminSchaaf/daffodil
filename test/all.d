@("detect and load a image file")
unittest {
    import dil;

    auto image = load!Pixel24Bpp("test/images/bmp_small-24bpp.bmp");
    assert(image.size == [41, 45]);
}
