unittest {
    import dil;

    auto image = bmp.open!Pixel24Bpp("test/images/bmp_small-24bpp.bmp");
    assert(image.width == 41);
    assert(image.height == 45);
    assert(image[10, 10] == Pixel24Bpp(0, 0, 254));
    assert(image[30, 10] == Pixel24Bpp(0, 254, 0));
    assert(image[10, 30] == Pixel24Bpp(254, 0, 0));
    assert(image[30, 30] == Pixel24Bpp(254, 254, 254));
}
