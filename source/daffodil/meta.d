/**
 * Exposes the :d:class:`MetaData` class, used to store metadata for images.
 */
module daffodil.meta;

import daffodil.color;

/**
 * Metadata class for images.
 * Any image format can defined subclasses to provide more format-specific
 * metadata.
 */
class MetaData {
    ///
    size_t width;
    ///
    size_t height;
}
