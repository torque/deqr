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

cdef extern from "qrcode.h":
    ctypedef int qr_point[2]

    cdef struct qr_reader:
        pass

    cdef struct qr_code_data_entry_raw_data:
        unsigned char *buf
        int len

    cdef struct qr_code_data_entry_sa_header:
        unsigned char sa_index
        unsigned char sa_size
        unsigned char sa_parity

    cdef union qr_code_data_entry_payload:
        qr_code_data_entry_raw_data data
        unsigned int eci
        int ai
        qr_code_data_entry_sa_header sa

    cdef struct qr_code_data_entry:
        qr_mode mode
        qr_code_data_entry_payload payload

    cdef struct qr_code_data:
        qr_code_data_entry *entries;
        int nentries;
        unsigned char version;
        unsigned char ecc_level;
        unsigned char mask;
        unsigned char sa_index;
        unsigned char sa_size;
        unsigned char sa_parity;
        unsigned char self_parity;
        qr_point bbox[4];
        qr_point center;

    cdef struct qr_code_data_list:
        qr_code_data *qrdata
        int nqrdata
        int cqrdata

    ctypedef enum qr_mode:
        QR_MODE_NUM = 1
        QR_MODE_ALNUM
        QR_MODE_STRUCT
        QR_MODE_BYTE
        QR_MODE_FNC1_1ST
        QR_MODE_ECI = 7
        QR_MODE_KANJI
        QR_MODE_FNC1_2ND

    ctypedef enum qr_eci_encoding:
        QR_ECI_GLI0 = 0
        QR_ECI_GLI1
        QR_ECI_CP437
        QR_ECI_ISO8859_1
        QR_ECI_ISO8859_2
        QR_ECI_ISO8859_3
        QR_ECI_ISO8859_4
        QR_ECI_ISO8859_5
        QR_ECI_ISO8859_6
        QR_ECI_ISO8859_7
        QR_ECI_ISO8859_8
        QR_ECI_ISO8859_9
        QR_ECI_ISO8859_10
        QR_ECI_ISO8859_11
        QR_ECI_ISO8859_13 = QR_ECI_ISO8859_11 + 2
        QR_ECI_ISO8859_14
        QR_ECI_ISO8859_15
        QR_ECI_ISO8859_16
        QR_ECI_SJIS = 20
        QR_ECI_UTF8 = 26

    uint8 QR_MODE_HAS_DATA(qr_mode mode)
    qr_reader * qr_reader_alloc() nogil
    void qr_reader_free(qr_reader *_reader) nogil
    void qr_code_data_list_init(qr_code_data_list *_qrlist) nogil
    void qr_code_data_list_clear(qr_code_data_list *_qrlist) nogil

    int qr_reader_locate(
        qr_reader *_reader,
        qr_code_data_list *_qrlist,
        const unsigned char *_img,
        int _width,int _height
    ) nogil


    int qr_reader_extract_text(
        qr_reader *_reader,
        const unsigned char *_img,
        int _width,
        int _height,
        char ***_text,
        int _allow_partial_sa
    ) nogil
    void qr_text_list_free(char **_text, int _ntext) nogil
