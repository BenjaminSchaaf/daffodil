unittest {
    import dil;

    auto image = bmp.open!Pixel24Bpp("test/images/bmp_small-24bpp.bmp");
    assert(image.width == 41);
    assert(image.height == 45);
    assert(image[10, 10] == Pixel24Bpp(0, 0, 255));
    assert(image[30, 10] == Pixel24Bpp(0, 255, 0));
    assert(image[10, 30] == Pixel24Bpp(255, 0, 0));
    assert(image[30, 30] == Pixel24Bpp(255, 255, 255));
}
