Decoders
========

qrdec offers bindings to different QR decoders, which have different performance
characteristics and capabilities.

QRdec
-----

QRdec is a fairly fast and robust QR code decoder that uses purely integer math.
In basic tests it is faster at decoding QR codes than Quirc, though it more or
less required the image to be binarized for successful decoding. It also
requires the image to have inverted reflectance, so it's reliant on more
pre-processing than Quirc.

QRdec seems to be able to generally decode warped or occluded codes with
slightly higher success rates than Quirc, but this is largely anecdotal and
there are definitely instances where Quirc successfuly decodes an image that
QRdec cannot.

Quirc
-----

Quirc has a small and simple codebase and is a reasonably robust QR code
decoder. It can work with non-binarized images, though the decoding rate is
improved by proper image binarization.
