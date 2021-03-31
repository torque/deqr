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

# distutils: sources = ["deps/qrdec/src/bch15_5.c", "deps/qrdec/src/binarize.c", "deps/qrdec/src/isaac.c", "deps/qrdec/src/qrdec.c", "deps/qrdec/src/rs.c", "deps/qrdec/src/util.c"]
# distutils: include_dirs = ["deps/qrdec/src"]
# distutils: extra_compile_args = ["-fdiagnostics-color=always"]

from __future__ import annotations

cimport cython

import enum

import numpy as np

from . cimport qrdecdecl
from . import datatypes

from libc.string cimport memcpy
from libc.stdio cimport printf, fopen, fwrite, fclose, FILE


QREccLevelMap = {
    0: datatypes.QREccLevel.L,
    1: datatypes.QREccLevel.M,
    2: datatypes.QREccLevel.Q,
    3: datatypes.QREccLevel.H,
}

cdef class QRDecoder:
    cdef qrdecdecl.qr_reader *_chndl

    def __cinit__(self):
        self._chndl = qrdecdecl.qr_reader_alloc()
        if self._chndl is NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._chndl is not NULL:
            qrdecdecl.qr_reader_free(self._chndl)

    def decode(self, image: np.ndarray):
        cdef qrdecdecl.qr_code_data_list qrlist

        assert image.dtype == np.uint8
        if len(image.shape) > 2:
            # TODO: throwing out channels like this is wrong
            image = image[:,:,0]


        cdef int width = image.shape[1], height = image.shape[0]
        cdef qrdecdecl.uint8[::1] reshaped = np.ascontiguousarray(
            image.reshape(width*height)
        )

        qrdecdecl.qr_code_data_list_init(&qrlist)

        cdef int idx = 0
        cdef qrdecdecl.qr_code_data *code
        decoded: list[datatypes.QRCode] = []
        try:
            for idx in range(
                qrdecdecl.qr_reader_locate(
                    self._chndl, &qrlist, &reshaped[0], width, height
                )
            ):
                code = qrlist.qrdata + idx
                corners = tuple((corner[0], corner[1]) for corner in code.bbox)
                data_entries = tuple(
                    datatypes.QRCodeData(
                        entry.mode,
                        entry.payload.data.buf[:entry.payload.data.len]
                    )
                    for entry in code.entries[:code.nentries]
                    if qrdecdecl.QR_MODE_HAS_DATA(entry.mode)
                )


                decoded.append(
                    datatypes.QRCode(
                        version=code.version,
                        ecc_level=QREccLevelMap[code.ecc_level],
                        mask=0,
                        data_entries=data_entries,
                        corners=corners
                    )
                )
        finally:
            qrdecdecl.qr_code_data_list_clear(&qrlist)

        return decoded
