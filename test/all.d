unittest {
    import dil;

    auto image = open!Pixel24Bpp("test/images/bmp_small-24bpp.bmp");
    assert(image.size == [41, 45]);
}
