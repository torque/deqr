# Copyright (C) 2021 torque <torque@users.noreply.github.com>

# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

from __future__ import annotations
from typing import Optional

cimport cython

import enum

from . cimport binarize as bnz, quircdecl
from . import datatypes, image

from libc.string cimport memcpy
from libc.stdio cimport printf, fopen, fwrite, fclose, FILE


cdef class QuircDecoder:
    """
    QR code decoder using the Quirc backend.

    :raises MemoryError: if the QR code reader context allocation fails.
    """

    cdef quircdecl.quirc *_chndl

    def __cinit__(self):
        self._chndl = quircdecl.quirc_new()
        if self._chndl is NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._chndl is not NULL:
            quircdecl.quirc_destroy(self._chndl)


    def decode(
        self,
        image_data,
        binarize: bool = True,
        binarize_invert: bool = False,
        convert_data: bool = True,
        byte_charset: Optional[str] = "utf-8"
    ):
        """
        Decode all detectable QR codes in an image.

        .. warning::

            Binarization is done in-place on the image data buffer and
            changes the data. While this operation should be idempotent, it
            mutates the input data, which is a side effect.

            Additionally, inverting during binarization is also done in-place on
            the image data buffer and is *not* idempotent, so if image data is
            reused, it will be re-inverted and not decode correctly the second
            time.

        :param image_data:
            A python object containing the pixel data of the image to search for
            QR codes. This can be any format supported
            by :class:`image.ImageLoader`.

        :param binarize:
            If ``True``, binarize the input image (i.e. convert all
            pixels to either fully black or fully white). The decoder is
            unlikely to work properly on images that have not been binarized.

        :param binarize_invert:
            If ``True``, binarization inverts the reflectance (i.e dark pixels
            become white and light pixels become black).

        :param convert_data:
            If ``True``, all data entry payloads are  decoded into
            "native" python types:

            - :py:obj:`deqr.datatypes.QRDataType.NUMERIC` => :py:class:`int`,
            - :py:obj:`deqr.datatypes.QRDataType.ALPHANUMERIC` =>
              :py:class:`str` as ``ascii``
            - :py:obj:`deqr.datatypes.QRDataType.KANJI` =>
              :py:class:`str` as ``shift-jis``
            - :py:obj:`deqr.datatypes.QRDataType.BYTE` =>
              :py:class:`str` using the ``byte_charset`` parameter

            If ``False``, no conversion will be done and all data entry data
            will be returned as :py:class:`bytes`.

        :param byte_charset:
            The charset to use for converting all decoded data entries of type
            :py:obj:`deqr.datatypes.QRDataType.BYTE` found in the image. If ``None``,
            then data entries of type :py:obj:`deqr.datatypes.QRDataType.BYTE` will not be
            converted, even if ``convert_data`` is ``True``.

        :return: A list of objects containing information from the decoded QR
            codes.

        :raises MemoryError: if the decoder image buffer allocation fails.
        :raises TypeError: if ``image_data`` is of an unsupported type.
        :raises ValueError: if ``image_data`` is malformed somehow.
        """

        cdef int idx = 0
        cdef quircdecl.quirc_code code
        cdef quircdecl.quirc_data data

        decoded: list[datatypes.QRCode] = []

        if not isinstance(image_data, image.ImageLoader):
            image_data = image.ImageLoader(image_data)

        if binarize:
            bnz.binarize(
                image_data.data,
                image_data.width,
                image_data.height,
                binarize_invert
            )

        if convert_data:
            if byte_charset is not None:
                byte_converter = lambda d: d.decode(byte_charset)
            else:
                byte_converter = lambda d: d

            converters = {
                datatypes.QRDataType.NUMERIC: int,
                datatypes.QRDataType.ALPHANUMERIC: lambda d: d.decode("ascii"),
                datatypes.QRDataType.KANJI: lambda d: d.decode("shift-jis"),
                datatypes.QRDataType.BYTE: byte_converter,
            }

        for idx in range(
            self._set_image(
                image_data.data, image_data.width, image_data.height
            )
        ):
            quircdecl.quirc_extract(self._chndl, idx, &code)
            if quircdecl.quirc_decode(&code, &data) != quircdecl.QUIRC_SUCCESS:
                continue

            data_entries = (
                datatypes.QRCodeData(data.data_type, data.payload[:data.payload_len]),
            )

            if convert_data:
                for entry in data_entries:
                    entry.data = converters[entry.type](entry.data)

            center = self.compute_center_from_bounds(code.corners)

            decoded.append(
                datatypes.QRCode(
                    version=data.version,
                    ecc_level=data.ecc_level,
                    mask=data.mask,
                    data_entries=data_entries,
                    corners=tuple((c.x, c.y) for c in code.corners),
                    center=(center.x, center.y)
                )
            )

        return decoded

    cdef quircdecl.quirc_point compute_center_from_bounds(self, quircdecl.quirc_point corners[4]) nogil:
        cdef int divisor = 0
        cdef int lcoeff = 0
        cdef int rcoeff = 0

        divisor = (
            (corners[0].x - corners[2].x) * (corners[1].y - corners[3].y)
            - (corners[0].y - corners[2].y) * (corners[1].x - corners[3].x)
        )

        if divisor == 0:
            return quircdecl.quirc_point(-1, -1)
        else:
            lcoeff = corners[0].x * corners[2].y - corners[0].y * corners[2].x
            rcoeff = corners[1].x * corners[3].y - corners[1].y * corners[3].x

            return quircdecl.quirc_point(
                (
                    (corners[1].x - corners[3].x) * lcoeff
                    - (corners[0].x - corners[2].x) * rcoeff
                ) // divisor,
                (
                    (corners[1].y - corners[3].y) * lcoeff
                    - (corners[0].y - corners[2].y) * rcoeff
                ) // divisor
            )

    cdef int _set_image(self, quircdecl.uint8[::1] image, int width, int height) nogil:
        if quircdecl.quirc_resize(self._chndl, width, height) != quircdecl.QUIRC_SUCCESS:
            raise MemoryError("could not resize")

        cdef int bufsize = width*height

        cdef unsigned char *buffer = quircdecl.quirc_begin(self._chndl, NULL, NULL)
        memcpy(buffer, &image[0], bufsize)

        quircdecl.quirc_end(self._chndl)
        return quircdecl.quirc_count(self._chndl)
