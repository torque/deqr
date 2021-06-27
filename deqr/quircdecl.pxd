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

ctypedef unsigned char uint8
ctypedef unsigned int  uint32

cdef extern from "quirc.h":
    cdef struct quirc:
        pass

    const char *quirc_version() nogil

    quirc *quirc_new() nogil
    void quirc_destroy(quirc *q) nogil

    int quirc_resize(quirc *q, int width, int height) nogil

    uint8 *quirc_begin(quirc *q, int *width, int *height) nogil
    void quirc_end(quirc *q) nogil

    cdef struct quirc_point:
        int x
        int y

    ctypedef enum quirc_decode_error_t:
        QUIRC_SUCCESS = 0
        QUIRC_ERROR_INVALID_GRID_SIZE
        QUIRC_ERROR_INVALID_VERSION
        QUIRC_ERROR_FORMAT_ECC
        QUIRC_ERROR_DATA_ECC
        QUIRC_ERROR_UNKNOWN_DATA_TYPE
        QUIRC_ERROR_DATA_OVERFLOW
        QUIRC_ERROR_DATA_UNDERFLOW

    const char *quirc_strerror(quirc_decode_error_t err) nogil

    cdef enum:
        QUIRC_MAX_VERSION = 40
        QUIRC_MAX_GRID_SIZE = (QUIRC_MAX_VERSION * 4) + 17
        QUIRC_MAX_BITMAP = ((QUIRC_MAX_GRID_SIZE * QUIRC_MAX_GRID_SIZE) + 7) // 8
        QUIRC_MAX_PAYLOAD = 8896

    cdef enum:
        QUIRC_ECC_LEVEL_M = 0
        QUIRC_ECC_LEVEL_L = 1
        QUIRC_ECC_LEVEL_H = 2
        QUIRC_ECC_LEVEL_Q = 3

    cdef enum:
        QUIRC_DATA_TYPE_NUMERIC = 1
        QUIRC_DATA_TYPE_ALPHA = 2
        QUIRC_DATA_TYPE_BYTE = 4
        QUIRC_DATA_TYPE_KANJI = 8

    cdef enum:
        QUIRC_ECI_ISO_8859_1 = 1
        QUIRC_ECI_IBM437 = 2
        QUIRC_ECI_ISO_8859_2 = 4
        QUIRC_ECI_ISO_8859_3 = 5
        QUIRC_ECI_ISO_8859_4 = 6
        QUIRC_ECI_ISO_8859_5 = 7
        QUIRC_ECI_ISO_8859_6 = 8
        QUIRC_ECI_ISO_8859_7 = 9
        QUIRC_ECI_ISO_8859_8 = 10
        QUIRC_ECI_ISO_8859_9 = 11
        QUIRC_ECI_WINDOWS_874 = 13
        QUIRC_ECI_ISO_8859_13 = 15
        QUIRC_ECI_ISO_8859_15 = 17
        QUIRC_ECI_SHIFT_JIS = 20
        QUIRC_ECI_UTF_8 = 26

    cdef struct quirc_code:
        quirc_point corners[4]
        int         size
        uint8       cell_bitmap[QUIRC_MAX_BITMAP]

    # /* This structure holds the decoded QR-code data */
    cdef struct quirc_data:
        int    version
        int    ecc_level
        int    mask
        int    data_type
        uint8  payload[QUIRC_MAX_PAYLOAD]
        int    payload_len
        uint32 eci

    int quirc_count(const quirc *q) nogil
    void quirc_extract(const quirc *q, int index, quirc_code *code) nogil
    quirc_decode_error_t quirc_decode(const quirc_code *code, quirc_data *data) nogil
    void quirc_flip(quirc_code *code) nogil
