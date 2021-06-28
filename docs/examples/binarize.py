import cv2
import numpy
import deqr

image_data = cv2.imread("dark.jpg")

img = deqr.image.ImageLoader(image_data)

deqr.binarize.binarize(img.data, img.width, img.height, False)

reshaped = numpy.reshape(img.data, (img.height, img.width))

cv2.imwrite("dark-binarized.jpg", reshaped)
