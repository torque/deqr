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

cimport cython

import enum

from . cimport binarize as bnz, quircdecl
from . import datatypes, image

from libc.string cimport memcpy
from libc.stdio cimport printf, fopen, fwrite, fclose, FILE


cdef class QRDecoder:
    cdef quircdecl.quirc *_chndl

    def __cinit__(self):
        self._chndl = quircdecl.quirc_new()
        if self._chndl is NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._chndl is not NULL:
            quircdecl.quirc_destroy(self._chndl)

    def resize(self, width: cython.int, height: cython.int):
        if quircdecl.quirc_resize(self._chndl, width, height) == -1:
            raise MemoryError

    def decode(
        self, image_data, binarize: bool = True, binarize_invert: bool = False
    ):
        cdef int idx = 0
        cdef quircdecl.quirc_code code
        cdef quircdecl.quirc_data data

        decoded: list[datatypes.QRCode] = []

        img = image.ImageLoader(image_data)

        if binarize:
            bnz.binarize(img.data, img.width, img.height, binarize_invert)

        for idx in range(self._set_image(img.data, img.width, img.height)):
            quircdecl.quirc_extract(self._chndl, idx, &code)
            quircdecl.quirc_decode(&code, &data)

            data_entries = (
                datatypes.QRCodeData(data.data_type, data.payload[:data.payload_len]),
            )

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
