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

# distutils: sources = ["deps/quirc/lib/decode.c", "deps/quirc/lib/identify.c", "deps/quirc/lib/quirc.c", "deps/quirc/lib/version_db.c"]
# distutils: include_dirs = ["deps/quirc/lib"]
# distutils: extra_compile_args = ["-fdiagnostics-color=always"]

from __future__ import annotations

cimport cython

import enum

import numpy as np

from . cimport quircdecl
from . import datatypes

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

    def decode(self, image: np.ndarray):
        cdef int idx = 0
        cdef quircdecl.quirc_code code
        cdef quircdecl.quirc_data data

        decoded: list[datatypes.QRCode] = []

        for idx in range(self.set_image(image)):
            quircdecl.quirc_extract(self._chndl, idx, &code)
            quircdecl.quirc_decode(&code, &data)

            data_entries = (
                datatypes.QRCodeData(data.data_type, data.payload[:data.payload_len]),
            )

            decoded.append(
                datatypes.QRCode(
                    version=data.version,
                    ecc_level=data.ecc_level,
                    mask=data.mask,
                    data_entries=data_entries,
                    corners=tuple((c.x, c.y) for c in code.corners)
                )
            )

        return decoded

    def set_image(self, image: np.ndarray):
        assert image.dtype == np.uint8
        if len(image.shape) > 2:
            # TODO: throwing out channels like this is wrong
            image = image[:,:,0]


        cdef int width = image.shape[1], height = image.shape[0]
        cdef quircdecl.uint8[::1] reshaped = np.ascontiguousarray(
            image.reshape(width*height)
        )
        return self._c_set_image(reshaped, width, height);

    cdef int _c_set_image(self, quircdecl.uint8[::1] image, int width, int height) nogil:

        if quircdecl.quirc_resize(self._chndl, width, height) != quircdecl.QUIRC_SUCCESS:
            raise MemoryError("could not resize")

        cdef int bufsize = width*height

        cdef unsigned char *buffer = quircdecl.quirc_begin(self._chndl, NULL, NULL)
        memcpy(buffer, &image[0], bufsize)

        quircdecl.quirc_end(self._chndl)
        return quircdecl.quirc_count(self._chndl)
