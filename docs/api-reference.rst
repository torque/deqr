API Reference
=============

.. module:: deqr

Decoders
--------

QRdecDecoder
~~~~~~~~~~~~~~~~~

.. autoclass:: deqr.QRdecDecoder
    :members:

QuircDecoder
~~~~~~~~~~~~~~~~~

.. autoclass:: deqr.QuircDecoder
    :members:

Data Types
----------

These data types are structured collections of data produced by the decoders
upon successfully decoding QR codes.

QRCode
~~~~~~

.. autoclass:: deqr.datatypes.QRCode
    :members:

QRCodeData
~~~~~~~~~~

.. autoclass:: deqr.datatypes.QRCodeData
    :members:

QRDataType
~~~~~~~~~~

.. autoclass:: deqr.datatypes.QRDataType
    :members:

QREccLevel
~~~~~~~~~~

.. autoclass:: deqr.datatypes.QREccLevel
    :members:

Image Loader
------------

.. automodule:: deqr.image
    :members:

Binarize
--------

.. note::

    The binarization function is expected to be invoked by the decoder as
    appropriate and not normally directly by the user, so it only offers a
    low-level interface.

.. automodule:: deqr.binarize
    :members:
