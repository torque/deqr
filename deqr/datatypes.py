from __future__ import annotations

import enum


class QREccLevel(enum.IntEnum):
    M = 0
    L = 1
    H = 2
    Q = 3


class QRDataType(enum.IntEnum):
    NUMERIC = 1
    ALPHANUMERIC = 2
    BYTE = 4
    KANJI = 8


class QRCodeData:
    type: common.QRDataType
    data: bytes

    def __init__(self, type, data):
        self.type = QRDataType(type)
        self.data = data

    def __str__(self):
        return "QrCodeData(type=%s, data=<%s>)" % (
            self.type,
            self.data.hex(" ").upper(),
        )

    def __repr__(self):
        return str(self)


class QRCode:
    """
    Information about a physical QR code that has been decoded.
    """

    version: int
    ecc_level: QREccLevel
    mask: int

    data_entries: tuple[QRCodeData]

    center: tuple[int, int]
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
