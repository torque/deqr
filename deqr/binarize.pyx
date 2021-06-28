# Copyright (C) 2021 torque <torque@users.noreply.github.com>

# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.

# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

from . cimport binarize as bnz

cdef extern void qr_binarize(unsigned char *_img, int _width, int _height, int invert) nogil

cpdef void binarize(bnz.uint8[::1] image, int width, int height, bint invert) nogil:
    """
    Binarize an image. Manipulation occurs in place, mutating the input data.

    :param image: a memoryview to the bytes of an image.
        For example, :attr:`deqr.image.ImageLoader.data`

    :param width: the width, in pixels, of the input image.

    :param height: the height, in pixels, of the input image.

    :param invert: whether or not the output image should be light/dark inverted.
    """
    qr_binarize(&image[0], width, height, invert)
