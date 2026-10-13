"""Generate deterministic, original Chinese EPUB 2/3 fixtures. No third-party novels."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED, ZIP_STORED

ROOT = Path(__file__).resolve().parents[1]
FIXTURES = ROOT / "Tests" / "Fixtures"


def write_epub(version: int) -> None:
    FIXTURES.mkdir(parents=True, exist_ok=True)
    identifier = f"urn:xianxiareader:test:epub{version}"
    nav_item = '<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>' if version == 3 else ''
    modified = '<meta property="dcterms:modified">2026-10-13T00:00:00Z</meta>' if version == 3 else ''
    cover_properties = ' properties="cover-image"' if version == 3 else ''
    files = {
        "mimetype": "application/epub+zip",
        "META-INF/container.xml": '''<?xml version="1.0"?><container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="OEBPS/package.opf" media-type="application/oebps-package+xml"/></rootfiles></container>''',
        "OEBPS/package.opf": f'''<?xml version="1.0" encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="{version}.0" unique-identifier="book-id">
<metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:identifier id="book-id">{identifier}</dc:identifier><dc:title>云海问道·测试样书</dc:title><dc:creator>XianxiaReader 测试</dc:creator><dc:language>zh-CN</dc:language><meta name="cover" content="cover"/>{modified}</metadata>
<manifest>{nav_item}<item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/><item id="css" href="style.css" media-type="text/css"/><item id="cover" href="cover.svg" media-type="image/svg+xml"{cover_properties}/><item id="one" href="one.xhtml" media-type="application/xhtml+xml"/><item id="two" href="two.xhtml" media-type="application/xhtml+xml"/></manifest>
<spine toc="ncx"><itemref idref="one"/><itemref idref="two"/></spine></package>''',
        "OEBPS/nav.xhtml": '''<?xml version="1.0"?><html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="zh-CN"><head><title>目录</title></head><body><nav epub:type="toc"><ol><li><a href="one.xhtml">第一章 山门</a></li><li><a href="two.xhtml#start">第二章 云海</a></li></ol></nav></body></html>''',
        "OEBPS/toc.ncx": f'''<?xml version="1.0"?><ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1"><head><meta name="dtb:uid" content="{identifier}"/><meta name="dtb:depth" content="1"/><meta name="dtb:totalPageCount" content="0"/><meta name="dtb:maxPageNumber" content="0"/></head><docTitle><text>云海问道·测试样书</text></docTitle><navMap><navPoint id="one" playOrder="1"><navLabel><text>第一章 山门</text></navLabel><content src="one.xhtml"/></navPoint><navPoint id="two" playOrder="2"><navLabel><text>第二章 云海</text></navLabel><content src="two.xhtml#start"/></navPoint></navMap></ncx>''',
        "OEBPS/style.css": "body{font-family:serif;line-height:1.7;}p{text-indent:2em;margin:0 0 .65em;}h1{text-align:center;font-size:1.35em;margin:1.5em 0 2em;}img{max-width:100%;}",
        "OEBPS/cover.svg": '''<svg xmlns="http://www.w3.org/2000/svg" width="400" height="600" viewBox="0 0 400 600"><rect width="400" height="600" fill="#25483d"/><path d="M0 480L140 200L220 340L290 180L400 480Z" fill="#c8ccb0"/></svg>''',
    }
    for index, filename in enumerate(["one.xhtml", "two.xhtml"]):
        title = ["第一章 山门", "第二章 云海"][index]
        paragraphs = ''.join(f'<p>云雾漫过山门，少年沿石阶前行。第{i + 1}段：风吹竹叶，远山传来钟声。“修行从此刻开始。”</p>' for i in range(40))
        other = "two.xhtml#start" if index == 0 else "one.xhtml"
        files[f"OEBPS/{filename}"] = f'''<?xml version="1.0" encoding="UTF-8"?><html xmlns="http://www.w3.org/1999/xhtml" lang="zh-CN"><head><title>{title}</title><link rel="stylesheet" type="text/css" href="style.css"/></head><body><h1 id="start">{title}</h1>{paragraphs}<img src="cover.svg" alt="青山"/><p><a href="{other}">前往另一章</a></p></body></html>'''
    if version == 2:
        del files["OEBPS/nav.xhtml"]
    with ZipFile(FIXTURES / f"chinese-epub{version}.epub", "w") as archive:
        for name, text in files.items():
            entry = ZipInfo(name, date_time=(2026, 10, 13, 0, 0, 0))
            entry.compress_type = ZIP_STORED if name == "mimetype" else ZIP_DEFLATED
            archive.writestr(entry, text.encode("utf-8"))


if __name__ == "__main__":
    for version in [2, 3]:
        write_epub(version)
    print("Generated 2 original Chinese EPUB fixtures.")
