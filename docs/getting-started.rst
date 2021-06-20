Getting Started
===============

If you already have an image containing a QR code that you'd like to decode, the
process is pretty simple.

OpenCV Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: python
    :linenos:
    :name: opencv-load-example

    import cv2
    import deqr

    image_data = cv2.imread("path/to/image.png")image_data = cv2.imread("path/to/image.png")image_data = cv2.imread("path/to/image.png")image_data = cv2.imread("path/to/image.png")image_data = cv2.imread("path/to/image.png")

    decoder = deqr.QRdecDecoder()

    decoded_codes = decoder.decode(image_data)


Pillow Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: python
    :linenos:
    :name: pillow-load-example

    import PIL.Image
    import deqr

    image_data = PIL.Image.open("path/to/image.png")

    decoder = deqr.QRdecDecoder()

    decoded_codes = decoder.decode(image_data)
