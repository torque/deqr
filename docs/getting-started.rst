Getting Started
===============

If you already have an image containing a QR code that you'd like to decode, the
process is pretty straightforward.

Installation
------------

``deqr`` is published on PyPi with pre-built binaries for common platforms and
modern Python versions. It can be installed with ``pip``::

    pip install deqr

A Basic Exmaple
---------------

Decoding From an Image
~~~~~~~~~~~~~~~~~~~~~~

The easiest way to decode QR codes from an image file is to use the external
OpenCV_ or Pillow_ libraries. These libraries are not shipped as dependencies
of ``deqr``, so you have to manually install whichever one you want to use.

Given the following image, which is a directly generated image and therefore
ideal for decoding:

.. gfigure:: amalgam.png
    :align: center

This image contains codes with data in the four basic types: numeric,
alphanumeric, byte, and kanji.

.. _OpenCV: https://github.com/opencv/opencv
.. _Pillow: https://github.com/python-pillow/Pillow

.. tab:: OpenCV

    .. tab:: QRdec

        .. literalinclude:: /examples/opencv-qrdec.py
            :lines: 1-9

    .. tab:: Quirc

        .. literalinclude:: /examples/opencv-quirc.py
            :lines: 1-9

.. tab:: Pillow

    .. tab:: QRdec

        .. literalinclude:: /examples/pillow-qrdec.py
            :lines: 1-8

    .. tab:: Quirc

        .. literalinclude:: /examples/pillow-quirc.py
            :lines: 1-8


.. note::

    deqr attempts to have sane defaults for data conversion while providing the
    user with sufficient flexibility to deal with nonstandard QR codes or those
    created with domain-specific data encoding. See
    the :py:meth:`deqr.QRdecDecoder.decode` documentation for more information
    about how data conversion is performed.


These examples have virtually identical outputs (the bounding box computation
varies slightly between the decoders, and the ordering of the output list isn't
guaranteed to be consistent between the two)::

    decoded_codes = [
        QRCode(
            version=2,
            ecc_level=QREccLevel.H,
            mask=4,
            data_entries=(
                QrCodeData(type=QRDataType.KANJI, data="こんにちは世界"),
            ),
            corners=((17, 17), (115, 16), (116, 116), (16, 115)),
            center=(65, 65),
        ),
        QRCode(
            version=2,
            ecc_level=QREccLevel.H,
            mask=5,
            data_entries=(
                QrCodeData(type=QRDataType.ALPHANUMERIC, data="HELLO WORLD"),
            ),
            corners=((181, 17), (279, 16), (280, 116), (180, 115)),
            center=(229, 65),
        ),
        QRCode(
            version=4,
            ecc_level=QREccLevel.H,
            mask=1,
            data_entries=(
                QrCodeData(
                    type=QRDataType.BYTE, data="https://github.com/torque/deqr"
                ),
            ),
            corners=((148, 148), (279, 148), (280, 280), (148, 279)),
            center=(214, 214).
        ),
        QRCode(
            version=2,
            ecc_level=QREccLevel.H,
            mask=3,
            data_entries=(
                QrCodeData(
                    type=QRDataType.NUMERIC, data=925315282350536773542486064879
                ),
            ),
            corners=((17, 181), (115, 180), (116, 280), (16, 279)),
            center=(65, 229),
        ),
    ]



Visualizing the Results
~~~~~~~~~~~~~~~~~~~~~~~

When trying to understand what the decoder is finding, it can be helpful to
annotate the source image using the information returned by the decoder. Here,
we show off the information we just decoded.

.. note::

    If your source image is encoded as grayscale, you will not be able to draw
    colored annotations on it without first converting it into a colorspace
    with color channels. See the documentation of the annotation tool you are
    using (e.g. :py:meth:`PIL.Image.Image.convert`) for instruction on how to
    accomplish that.

.. tab:: OpenCV

    .. tab:: QRdec

        .. gfigure:: amalgam-annotated-opencv-qrdec.png
            :align: center

        .. literalinclude:: /examples/opencv-qrdec.py
            :lines: 12-

    .. tab:: Quirc

        .. gfigure:: amalgam-annotated-opencv-quirc.png
            :align: center

        .. literalinclude:: /examples/opencv-quirc.py
            :lines: 12-

.. tab:: Pillow

    .. tab:: QRdec

        .. gfigure:: amalgam-annotated-pillow-qrdec.png
            :align: center

        .. literalinclude:: /examples/pillow-qrdec.py
            :lines: 10-

    .. tab:: Quirc

        .. gfigure:: amalgam-annotated-pillow-quirc.png
            :align: center

        .. literalinclude:: /examples/pillow-quirc.py
            :lines: 10-

Practical Usage
---------------

QR codes were invented primarily to facilitate the process of transferring
information from real, physical objects into a computer system. As such, images
containing QR codes frequently have artifacts such as noise, blur, lens
distortion, uneven lighting, and offset perspective and rotation along with
other non-ideal characteristics that can impede the reliability of QR code
decoding.

``deqr`` ships with defaults that should perform reasonably well in real-world
scenarios.

Binarization
~~~~~~~~~~~~

Binarization is the process of converting all pixels in an image to either
completely white or completely black. Because the value of a QR code "bit" is
dependent on whether it is light or dark, this process makes a dramatic
difference in decoding rates in variable lighting conditions. The built-in
binarization conversion performs an adaptive threshold that binarizes the image
by comparing each pixel to a group of its neighbors. This approach compensates
for images that have poor or somewhat uneven lighting.

Demonstration
~~~~~~~~~~~~~

Below are two examples of successfully decoded images. The first shows the
binarization dealing with poor lighting, and the second shows a somewhat blurry
image featuring some minor lens distortion. The outputs were generated using
the same scripts as the basic example above, with some minor modification to
preserve the binarization for demonstration purposes. These images also both
have the QR code rotated relative to its nominal orientation, illustrating that
the bounding box corner ordering follows the nominal QR code orientation rather
than the image orientation.

The inverted reflectance required by QRdec is also shown in the output.

.. list-table::
    :align: center
    :header-rows: 1

    * - Source
      - QRdec
      - Quirc
    * - .. gimage:: dark.jpg
      - .. gimage:: dark-annotated-opencv-qrdec.jpg
      - .. gimage:: dark-annotated-opencv-quirc.jpg
    * - .. gimage:: warped.jpg
      - .. gimage:: warped-annotated-opencv-qrdec.jpg
      - .. gimage:: warped-annotated-opencv-quirc.jpg

Accessing Intermediates
~~~~~~~~~~~~~~~~~~~~~~~

While not particularly recommended, here's an example of accessing the
intermediate binarization image by (ab)using the fact that it is an in-place
mutation and that :class:`deqr.image.ImageLoader` is passed through the decode
process without being copied.

.. code-block:: python

    import cv2, numpy
    import deqr

    image_data = cv2.imread("dark.jpg")
    img = deqr.image.ImageLoader(image_data)

    deqr.QRdecDecoder().decode(img)

    reshaped = numpy.reshape(img.data, (img.height, img.width))

    cv2.imwrite("dark-binarized.jpg", reshaped)
