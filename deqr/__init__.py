__version__ = "__PLACEHOLDER__"

# this is to handle local development installs, where the version replacement
# gets reverted after the installation finishes.
if __version__ == "__PLACEHOLDER__":
    from importlib import metadata

    __version__ = metadata.version(__name__)


from . import image, datatypes
from .datatypes import QREccLevel, QRDataType, QRCodeData, QRCode
from .quirc import QuircDecoder
from .qrdec import QRdecDecoder
