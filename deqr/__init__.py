from .version import __version__, __VERSION__

from . import image, datatypes
from .datatypes import QREccLevel, QRDataType, QRCodeData, QRCode
from .quirc import QuircDecoder
from .qrdec import QRdecDecoder
