from __future__ import annotations
from typing import Any, Union


class ImageLoader:
    """
    Load image data from common Python data containers.

    This is responsible for manipulating image data into a format that the QR
    decoders can understand. Images are converted to 8-bytes-per-pixel
    grayscale and ordered as a 1-dimensional row-major array of data.

    To avoid unnecessary hard dependencies on large external libraries, the
    source format of provided data is inferred by inspecting the object's type
    description. Supported source formats include the :class:`numpy.ndarray`
    used by numpy and OpenCV, the :class:`cv2.UMat` format from OpenCV (this is
    converted to a :class:`numpy.ndarray`), the :class:`PIL.Image.Image` format
    used by Pillow, or, if all else fails, a
    :class:`tuple[bytes, tuple[int, int]]` containing a pre-converted bytes
    object and its associated width, height pair.

    .. warning::

        It is strongly discouraged to access any of the properties of this class
        after it has been created. :attr:`ImageLoader.data` uses a different
        backing class depending on the source type (:class:`numpy.ndarray` when
        coming from numpy or OpenCV, :class:`bytearray` otherwise) and the QR
        code decoders may do in-place manipulation of the data (e.g. the
        binarization routine manipulates the data in place).
    """

    #: The width, in pixels, of the image data stored in :attr:`data`
    width: int
    #: The height, in pixels, of the image data stored in :attr:`data`
    height: int
    #: The image binary data.
    data: Union[bytearray, numpy.ndarray]

    def __init__(self, data: Any):
        try:
            if "numpy.ndarray" in str(type(data)):
                self._set_data_from_numpy_ndarray(data)
            elif "cv2.UMat" in str(type(data)):
                self._set_data_from_numpy_ndarray(data.get())
            elif "PIL." in str(type(data)):
                self._set_data_from_pil_image(data)
            elif isinstance(data, tuple):
                self._set_data_from_tuple(data)
            else:
                raise Exception
        except (ValueError, TypeError):
            raise
        except Exception:
            raise TypeError(f"data {type(data)} is an incompatible type.")

    def _set_data_from_numpy_ndarray(self, data: numpy.ndarray) -> None:
        if data.dtype.name != "uint8":
            # data.astype is not really usable here as it just does blind casts,
            # which doesn't scale properly from larger types. At the same time,
            # it's not possible to really guess what the appropriate range of
            # the input data is for useful conversion
            raise ValueError(f"np.ndarray dtype {data.dtype} must be uint8")
        if data.ndim == 3:
            # try to convert sanely by averaging values
            data = data.mean(axis=2).astype(data.dtype)
        elif data.ndim != 2:
            raise ValueError(f"np.ndarray doesn't look like a 2D image {data.shape}")

        self.data = data.ravel(order="C")
        self.height, self.width = data.shape

    def _set_data_from_pil_image(self, data):
        if data.mode != "L":
            data = data.convert("L")

        self.data = bytearray(data.tobytes())
        self.width, self.height = data.size

    def _set_data_from_tuple(self, data):
        if (
            len(data) != 2
            or not isinstance(data[0], (bytes, bytearray))
            or len(data[1]) != 2
            or not isinstance(data[1][0], int)
            or not isinstance(data[1][1], int)
        ):
            raise TypeError("Data tuple is not of format (bytes, (int, int))")

        if len(data[0]) != (data[1][0] * data[1][1]):
            raise ValueError(
                f"Wrong amount of image data {len(data[0])} for "
                f"{data[1][0]} by {data[1][1]} image"
            )

        self.data = bytearray(data[0])
        self.width, self.height = data[1]
