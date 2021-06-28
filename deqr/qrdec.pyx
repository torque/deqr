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

from . cimport binarize as bnz, qrdecdecl
from . import datatypes, image

from libc.string cimport memcpy
from libc.stdio cimport printf, fopen, fwrite, fclose, FILE


QREccLevelMap = {
    0: datatypes.QREccLevel.L,
    1: datatypes.QREccLevel.M,
    2: datatypes.QREccLevel.Q,
    3: datatypes.QREccLevel.H,
}

cdef class QRdecDecoder:
    """
    QR code decoder using the QRdec backend.

    .. note::

        This decoder requires that input images have inverted reflectance in
        order to be able to decode them. The binarization defaults
        on :meth:`decode` handle performing this inversion, but if either
        binarization or the inversion is disabled, images will not be decoded
        properly without preprocessing.

    :raises MemoryError: if the QR code reader context allocation fails.
    """

    cdef qrdecdecl.qr_reader *_chndl

    def __cinit__(self):
        self._chndl = qrdecdecl.qr_reader_alloc()
        if self._chndl is NULL:
            raise MemoryError

    def __dealloc__(self):
        if self._chndl is not NULL:
            qrdecdecl.qr_reader_free(self._chndl)

    def decode(
        self,
        image_data,
        binarize: bool = True,
        binarize_invert: bool = True,
        convert_data: bool = True,
        byte_charset: Optional[str] = "utf-8"
    ) -> list[datatypes.QRCode]:
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

            - :py:obj:`datatypes.QRDataType.NUMERIC` => :py:class:`int`,
            - :py:obj:`datatypes.QRDataType.ALPHANUMERIC` =>
              :py:class:`str` as ``ascii``
            - :py:obj:`datatypes.QRDataType.KANJI` =>
              :py:class:`str` as ``shift-jis``
            - :py:obj:`datatypes.QRDataType.BYTE` =>
              :py:class:`str` using the ``byte_charset`` parameter

            If ``False``, no conversion will be done and all data entry data
            will be returned as :py:class:`bytes`.

        :param byte_charset:
            The charset to use for converting all decoded data entries of type
            :py:obj:`datatypes.QRDataType.BYTE` found in the image. If
            ``None``, then data entries of type
            :py:obj:`datatypes.QRDataType.BYTE` will not be converted,
            even if ``convert_data`` is ``True``.

        :return: A list of objects containing information from the decoded QR
            codes.

        :raises TypeError: if ``image_data`` is of an unsupported type.
        :raises ValueError: if ``image_data`` is malformed somehow.
        """
        cdef qrdecdecl.qr_code_data_list qrlist

        if not isinstance(image_data, image.ImageLoader):
            image_data = image.ImageLoader(image_data)

        qrdecdecl.qr_code_data_list_init(&qrlist)

        cdef qrdecdecl.uint8[::1] imagebytes = image_data.data
        cdef int idx = 0
        cdef qrdecdecl.qr_code_data *code
        decoded: list[datatypes.QRCode] = []

        if binarize:
            bnz.binarize(
                image_data.data,
                image_data.width,
                image_data.height,
                binarize_invert,
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

        try:
            for idx in range(
                qrdecdecl.qr_reader_locate(
                    self._chndl,
                    &qrlist,
                    &imagebytes[0],
                    image_data.width,
                    image_data.height,
                )
            ):
                code = qrlist.qrdata + idx
                corners = tuple(
                    (code.bbox[idx][0], code.bbox[idx][1])
                    for idx in (0, 1, 3, 2)
                )

                data_entries = tuple(
                    datatypes.QRCodeData(
                        entry.mode,
                        entry.payload.data.buf[:entry.payload.data.len],
                    )
                    for entry in code.entries[:code.nentries]
                    if qrdecdecl.QR_MODE_HAS_DATA(entry.mode)
                )

                if convert_data:
                    for entry in data_entries:
                        entry.data = converters[entry.type](entry.data)

                decoded.append(
                    datatypes.QRCode(
                        version=code.version,
                        ecc_level=QREccLevelMap[code.ecc_level],
                        mask=code.mask,
                        data_entries=data_entries,
                        corners=corners,
                        center=(code.center[0], code.center[1])
                    )
                )
        finally:
            qrdecdecl.qr_code_data_list_clear(&qrlist)

        return decoded
