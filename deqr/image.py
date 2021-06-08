from __future__ import annotations
from typing import Any

from . import binarize


class ImageLoader:
    width: int
    height: int
    data: Any

    def __init__(self, data: Any):
        try:
            if "numpy.ndarray" in str(type(data)):
                self.set_data_from_numpy_ndarray(data)
            elif "cv2.UMat" in str(type(data)):
                self.set_data_from_numpy_ndarray(data.get())
            elif "PIL.Image" in str(type(data)):
                self.set_data_from_pil_image(data)
            elif isinstance(data, tuple):
                self.set_data_from_tuple(data)
            else:
                raise Exception
        except (ValueError, TypeError):
            raise
        except Exception:
            raise TypeError(f"data {type(data)} is an incompatible type.")

    def set_data_from_numpy_ndarray(self, data):
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

    def set_data_from_pil_image(self, data):
        if data.mode != "L":
            data = data.convert("L")

        self.data = data.tobytes()
        self.width, self.height = data.size

    def set_data_from_tuple(self, data):
        if (
            len(data) != 2
            or not isinstance(data[0], bytes)
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

        (self.data, (self.width, self.height)) = data
