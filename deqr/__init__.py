__version__ = "0.2.2"
__VERSION__ = __version__

from . import image, datatypes
from .datatypes import QREccLevel, QRDataType, QRCodeData, QRCode
from .quirc import QuircDecoder
from .qrdec import QRdecDecoder
