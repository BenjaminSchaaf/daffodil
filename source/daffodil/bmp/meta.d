module daffodil.bmp.meta;

import daffodil.meta;
import daffodil.bmp.headers;

class BmpMetaData : MetaData {
    BmpHeader bmpHeader;
    DibVersion dibVersion;
    DibHeader!() dibHeader;

    this(size_t width, size_t height, BmpHeader bmpHeader,
         DibVersion dibVersion, DibHeader!() dibHeader) {
        this.width      = width;
        this.height     = height;
        this.bmpHeader  = bmpHeader;
        this.dibVersion = dibVersion;
        this.dibHeader  = dibHeader;
    }
}
