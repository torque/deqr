import cv2
import numpy
import deqr

image_data = cv2.imread("amalgam.png")

decoder = deqr.QRdecDecoder()

decoded_codes = decoder.decode(image_data)


def draw_text(image, text, location, alignment):
    font_face = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 0.4
    font_thickness = 1
    line_type = cv2.LINE_AA

    (width, height), baseline = cv2.getTextSize(
        text, fontScale=font_scale, fontFace=font_face, thickness=font_thickness
    )

    # numpad-style alignment
    alignment -= 1
    location = (
        location[0] + [0, -width // 2, -width][alignment % 3],
        location[1] + [-baseline, height // 2, height][alignment // 3],
    )

    cv2.putText(
        image,
        text,
        org=location,
        fontFace=font_face,
        fontScale=font_scale,
        color=(0, 0, 0),
        thickness=font_thickness + 3,
        lineType=line_type,
    )

    cv2.putText(
        image,
        text,
        org=location,
        fontFace=font_face,
        fontScale=font_scale,
        color=(255, 255, 255),
        thickness=font_thickness,
    )


for code in decoded_codes:
    box_color = (255, 127, 127)

    cv2.polylines(
        image_data,
        [numpy.array(code.corners, dtype=numpy.int32)],
        True,
        color=box_color,
        thickness=1,
    )

    cv2.line(image_data, code.corners[0], code.corners[2], color=box_color, thickness=1)
    cv2.line(image_data, code.corners[1], code.corners[3], color=box_color, thickness=1)

    cv2.circle(image_data, code.center, radius=3, color=(0, 0, 0), thickness=2)
    cv2.circle(
        image_data, code.center, radius=3, color=(0, 0, 255), thickness=cv2.FILLED
    )

    for idx, (corner, alignment) in enumerate(zip(code.corners, (7, 9, 3, 1))):
        draw_text(image_data, f"C{idx}", corner, alignment)

    entry = code.data_entries[0]
    draw_text(image_data, entry.type.name, (code.center[0], code.corners[2][1] + 3), 8)


cv2.imwrite("amalgam-annotated-opencv-qrdec.png", image_data)
