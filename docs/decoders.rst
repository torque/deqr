Decoders
========

qrdec offers bindings to two different QR decoders, which have different
performance characteristics and capabilities.

QRdec
------------------------------------------

`QRdec on Github <https://github.com/torque/qrdec>`_

QRdec is a fairly fast and robust QR code decoder that uses purely integer math.
In basic tests it is faster at decoding QR codes than Quirc, though it more or
less requires the image to be binarized for successful decoding. It also
requires the image to have inverted reflectance, so it's reliant on more
pre-processing than Quirc.

QRdec seems to be able to generally decode warped or occluded codes with
slightly higher success rates than Quirc, but this is largely anecdotal.

Below is an example of a code that QRdec successfully decodes but Quirc does
not.

.. list-table::
    :align: center

    * - .. gimage:: cropped.jpg
      - .. gimage:: cropped-annotated-opencv-qrdec.jpg


Quirc
------------------------------------------

`Quirc on Github <https://github.com/dlbeer/quirc>`_

Quirc has a small and simple codebase and is a reasonably robust QR code
decoder. It can work with non-binarized images, though the decoding rate is
improved by proper image binarization.

Quirc appears to be better at decoding codes with extreme perspective transforms
compared to QRdec, though, again, this is largely anecdotal.

Below is an example of a code that Quirc successfully decodes but QRdec does
not.

.. list-table::
    :align: center

    * - .. gimage:: perspective.jpg
      - .. gimage:: perspective-annotated-opencv-quirc.jpg
