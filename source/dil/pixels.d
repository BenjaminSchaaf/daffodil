module dil.pixels;

struct StaticPixel(size_t r = 0, size_t g = 0, size_t b = 0, size_t a = 0) {
    ubyte[r] red;
    ubyte[g] green;
    ubyte[b] blue;
    ubyte[a] alpha;
}
