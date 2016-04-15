.. d:module:: daffodil.color

daffodil.color
##############

Color Abstractions
==================

.. d:struct::
    struct Pixel(size_t bpc)

    .. d:alias::
        alias Value = Integer!bpc

Color Spaces
============

.. d:interface::
    interface ColorSpace(size_t bpc)

    .. d:alias::
        alias Value = Integer!bpc

    .. d:function::
        void channelopScalarMul(const Value[], const real, Value[]) const
        :name: channelopScalarMul

    .. d:function::
        void channelopColorAdd(const Value[], const Value[], Value[]) const
        :name: channelopColorAdd

    .. d:function::
        string channelToString(const Value[]) const
        :name: channelToString

.. d:class::
    class RGB(size_t bpc) : ColorSpace!bpc

    .. d:alias::
        alias Value = Integer!bpc
