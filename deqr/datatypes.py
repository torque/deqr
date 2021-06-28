from __future__ import annotations

import enum


class QREccLevel(enum.IntEnum):
    """
    An :py:class:`enum.IntEnum` representing the QR code's error correction
    code (ECC) level.

    This value represents how much error correction data the QR code contains,
    which directly maps to how much of the code can be missing or occluded
    while still permitting successful decoding.

    The integer value matches the number encoded into the QR code itself, rather
    than corresponding to the amount of ECC data contained. :obj:`QREccLevel.L`
    contains the least data, followed by :obj:`QREccLevel.M`,
    :obj:`QREccLevel.Q` and :obj:`QREccLevel.H` in order of increasing amount of
    ECC data.

    See Wikipedia__ for more information

    .. __: https://en.wikipedia.org/wiki/QR_code#Error_correction
    """

    M = 0  #: The code can successfully decode with 15% of codewords missing.
    L = 1  #: The code can successfully decode with 7% of codewords missing.
    H = 2  #: The code can successfully decode with 30% of codewords missing.
    Q = 3  #: The code can successfully decode with 25% of codewords missing.


class QRDataType(enum.IntEnum):
    """
    An :py:class:`enum.IntEnum` representing the data storage format of a given
    data section.

    QR codes can encode multiple different types of data with varying levels of
    efficiency. An individual QR code can also contain multiple different data
    sections, each with their own storage format.

    See Wikipedia__ for more information.

    .. __: https://en.wikipedia.org/wiki/QR_code#Encoding
    """

    NUMERIC = 1  #: The data was stored as numeric (characters [0-9])
    ALPHANUMERIC = 2  #: The data was stored as alphanumeric ([0-9A-Z] and some)
    BYTE = 4  #: The data was stored as 8-bit bytes (normally a UTF-8 string)
    KANJI = 8  #: the data was stored as 13-bit kanji (Shift-JIS encoded)


class QRCodeData:
    """
    A data segment read from the QR code.
    """

    #: the type of QR code data, which also represents its storage format in the
    #: code, for types that contain data.
    #:
    #: The QR code decoder backend is responsible for decoding the data into a
    #: meaningful byte sequence before providing it to the user, so this is
    #: mostly just metadata about how the data was stored in the QR code.
    #: See :meth:`deqr.QRdecDecoder.decode` for details.
    type: QRDataType
    #: The binary data contained in the segment.
    data: bytes

    def __init__(self, type, data):
        self.type = QRDataType(type)
        self.data = data

    def __str__(self):
        return "QrCodeData(type=%s, data=%s)" % (
            self.type,
            self.data,
        )

    def __repr__(self):
        return str(self)


class QRCode:
    """
    A structured collection of information about a QR code that has been decoded.

    This class cannot usefully be instantiated by the user, but instances of it
    are created by :meth:`deqr.QRdecDecoder.decode`
    or :meth:`deqr.QuircDecoder.decode`.
    """

    #: The QR code version, which determines its size and data storage capacity.
    version: int
    #: The error correction code level of this QR code.
    ecc_level: QREccLevel
    #: The data masking pattern used on the code.
    mask: int

    #: The data segments contained in this QR code.
    #:
    #: deqr currently only produces data entries from segments that contain
    #: data, i.e. entries stored as :obj:`QRDataType.NUMERIC`,
    #: :obj:`QRDataType.ALPHANUMERIC`, :obj:`QRDataType.BYTE`, or
    #: :obj:`QRDataType.KANJI`
    data_entries: tuple[QRCodeData, ...]

    #: The pixel coordinates of the geometric center of the QR code, relative to
    #: the top-left of the image. Coordinates are ordered ``(x, y)``, i.e.
    #: ``(horizontal, vertical)``.
    center: tuple[int, int]

    #: A sequence of pixel coordinates of the four corners of the QR code
    #: relative to the top-left of the image.
    #:
    #: These coordinates always start with the corner containing the top-left
    #: finder pattern (relative to nominal "normal" QR code orientation). For
    #: example, if the QR code is upside down in the image, the first corner in
    #: this list of coordinates will actually be the bottom-right corner of the
    #: code's position within the image.
    corners: tuple[tuple[int, int], ...]

    def __init__(self, version, ecc_level, mask, data_entries, corners, center):
        self.version = version
        self.ecc_level = QREccLevel(ecc_level)
        self.mask = mask
        self.data_entries = data_entries

        self.corners = corners
        self.center = center

    def __str__(self):
        return (
            "QRCode(version=%d, ecc_level=%s, mask=%d, data_entries=%s, "
            "corners=%s, center=%s)"
        ) % (
            self.version,
            self.ecc_level,
            self.mask,
            self.data_entries,
            self.corners,
            self.center
        )

    def __repr__(self):
        return str(self)
