"""Render the original vector app icon. Optional authoring dependency: Pillow 12.3.0."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SCALE = 3
BACKGROUND = "#193C3A"
PAPER = "#F3E8CF"
GOLD = "#DCC99E"


def curve(start, control, end):
    return [((1-t)**2*start[0]+2*(1-t)*t*control[0]+t*t*end[0],
             (1-t)**2*start[1]+2*(1-t)*t*control[1]+t*t*end[1])
            for t in (i/48 for i in range(49))]


def scaled(points):
    return [(round(x*SCALE), round(y*SCALE)) for x, y in points]


def main():
    design = ROOT / "Documentation/Assets/AppIcon.svg"
    design.parent.mkdir(parents=True, exist_ok=True)
    design.write_text(f'''<svg xmlns="http://www.w3.org/2000/svg" width="1024" height="1024" viewBox="0 0 1024 1024">
  <title>XianxiaReader: open book, mountain and moon</title>
  <rect width="1024" height="1024" fill="{BACKGROUND}"/>
  <circle cx="748" cy="250" r="44" fill="{PAPER}"/>
  <path d="M252 522 L404 367 L515 508 L660 305 L772 522" fill="none" stroke="{GOLD}" stroke-width="22" stroke-linejoin="round" stroke-linecap="round"/>
  <path d="M192 592 Q350 559 512 624 Q674 559 832 592 L832 817 Q674 791 512 856 Q350 791 192 817 Z" fill="{PAPER}"/>
  <path d="M512 624 L512 856" stroke="{BACKGROUND}" stroke-width="18"/>
  <path d="M244 666 Q352 649 455 691 M244 724 Q352 709 455 750 M569 691 Q672 649 780 666 M569 750 Q672 709 780 724" fill="none" stroke="{GOLD}" stroke-width="12" stroke-linecap="round"/>
</svg>
''', encoding="utf-8", newline="\n")
    image = Image.new("RGB", (1024*SCALE, 1024*SCALE), BACKGROUND)
    draw = ImageDraw.Draw(image)
    draw.ellipse((704*SCALE, 206*SCALE, 792*SCALE, 294*SCALE), fill=PAPER)
    mountain = [(252, 522), (404, 367), (515, 508), (660, 305), (772, 522)]
    draw.line(scaled(mountain), fill=GOLD, width=22*SCALE, joint="curve")
    for x, y in mountain:
        draw.ellipse(((x-11)*SCALE, (y-11)*SCALE, (x+11)*SCALE, (y+11)*SCALE), fill=GOLD)
    book = (curve((192, 592), (350, 559), (512, 624))
            + curve((512, 624), (674, 559), (832, 592)) + [(832, 817)]
            + curve((832, 817), (674, 791), (512, 856))
            + curve((512, 856), (350, 791), (192, 817)))
    draw.polygon(scaled(book), fill=PAPER)
    draw.line(scaled([(512, 624), (512, 856)]), fill=BACKGROUND, width=18*SCALE)
    for start, control, end in [((244, 666), (352, 649), (455, 691)),
                                ((244, 724), (352, 709), (455, 750)),
                                ((569, 691), (672, 649), (780, 666)),
                                ((569, 750), (672, 709), (780, 724))]:
        draw.line(scaled(curve(start, control, end)), fill=GOLD, width=12*SCALE)
    output = ROOT / "App/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
    image.resize((1024, 1024), Image.Resampling.LANCZOS).save(output, optimize=True)
    print(f"Generated opaque 1024x1024 RGB AppIcon: {output}")


if __name__ == "__main__":
    main()
