import PIL.Image, PIL.ImageDraw, PIL.ImageFont
import deqr

image_data = PIL.Image.open("amalgam.png")

decoder = deqr.QuircDecoder()

decoded_codes = decoder.decode(image_data)

drawer = PIL.ImageDraw.Draw(image_data)


def translate(point, x, y=None):
    if y is None:
        y = x
    return (point[0] + x, point[1] + y)


font = PIL.ImageFont.truetype("Arial Unicode.ttf", 16)
for code in decoded_codes:
    box_color = (127, 127, 255)

    drawer.polygon(code.corners, outline=box_color)

    drawer.line((code.corners[0], code.corners[2]), fill=box_color, width=1)
    drawer.line((code.corners[1], code.corners[3]), fill=box_color, width=1)

    drawer.ellipse(
        (translate(code.center, -3), translate(code.center, 3)),
        fill=(255, 0, 0),
        outline=(0, 0, 0),
        width=1,
    )

    for idx, (corner, anchor) in enumerate(zip(code.corners, ("lt", "rt", "rb", "lb"))):
        drawer.text(
            corner,
            f"C{idx}",
            font=font,
            anchor=anchor,
            fill=(255, 255, 255),
            stroke_fill=(0, 0, 0),
            stroke_width=2,
        )

    entry = code.data_entries[0]
    drawer.text(
        (code.center[0], code.corners[2][1] + 3),
        entry.type.name,
        font=font,
        fill=(0, 0, 0),
        anchor="mt",
    )


image_data.save("amalgam-annotated-pillow-quirc.png")
