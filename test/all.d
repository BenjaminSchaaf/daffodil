import dil.util.test;

mixin test!(null, "detect and load a image file", {
    import dil;

    auto image = load!Pixel24Bpp("test/images/bmp_small-24bpp.bmp");
    assert(image.size == [41, 45]);
});
