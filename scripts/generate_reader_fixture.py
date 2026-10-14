"""Original image/viewport/scroll regression EPUB, kept separate from search fixtures."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZIP_STORED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]


def main() -> None:
    chapters = [("cover", "封面完整性"), ("one", "第一章 山门"), ("two", "第二章 云海")]
    manifest = ''.join(f'<item id="{name}" href="{name}.xhtml" media-type="application/xhtml+xml"/>' for name, _ in chapters)
    spine = ''.join(f'<itemref idref="{name}"/>' for name, _ in chapters)
    toc = ''.join(f'<li><a href="{name}.xhtml#start">{title}</a></li>' for name, title in chapters)
    files = {
        "mimetype": "application/epub+zip",
        "META-INF/container.xml": '<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0"><rootfiles><rootfile full-path="OEBPS/package.opf" media-type="application/oebps-package+xml"/></rootfiles></container>',
        "OEBPS/package.opf": f'''<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="id"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:identifier id="id">urn:xianxiareader:reader-layout</dc:identifier><dc:title>青山长卷·阅读测试</dc:title><dc:creator>XianxiaReader 测试</dc:creator><dc:language>zh-CN</dc:language><meta property="dcterms:modified">2026-10-13T00:00:00Z</meta></metadata><manifest><item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/><item id="image" href="tall.svg" media-type="image/svg+xml" properties="cover-image"/><item id="css" href="style.css" media-type="text/css"/>{manifest}</manifest><spine>{spine}</spine></package>''',
        "OEBPS/nav.xhtml": f'<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" lang="zh-CN"><head><title>目录</title></head><body><nav epub:type="toc"><ol>{toc}</ol></nav></body></html>',
        "OEBPS/tall.svg": '<svg xmlns="http://www.w3.org/2000/svg" width="600" height="1400" viewBox="0 0 600 1400"><rect width="600" height="1400" fill="#e9dfc3"/><rect x="30" y="30" width="540" height="90" fill="#275847"/><path d="M30 1100L220 300L330 650L450 220L570 1100Z" fill="#678479"/><rect x="30" y="1280" width="540" height="90" fill="#cfab57"/></svg>',
        "OEBPS/style.css": 'body{margin:0;line-height:1.7;}p{text-indent:2em;}h1{text-align:center;}.cover{height:100%;margin:0;}.cover img{width:100%;height:100%;object-fit:contain;}img{max-width:100%;}',
    }
    for index, (name, title) in enumerate(chapters):
        if name == "cover":
            body = '<div class="cover" id="start"><img id="cover-image" src="tall.svg" alt="青山长卷，上下各有完整色条"/></div>'
        else:
            paragraphs = ''.join(f'<p id="line-{i + 1}">青山之下，少年缓步前行。这是第{i + 1}段原创排版测试文字，山风从远处吹来。</p>' for i in range(24 if name == "one" else 3))
            body = f'<h1 id="start">{title}</h1>{paragraphs}'
        if index < len(chapters) - 1:
            body += f'<p><a id="next-section" href="{chapters[index + 1][0]}.xhtml#start">继续下一节</a></p>'
        files[f'OEBPS/{name}.xhtml'] = f'<html xmlns="http://www.w3.org/1999/xhtml" lang="zh-CN"><head><title>{title}</title><link rel="stylesheet" type="text/css" href="style.css"/></head><body>{body}</body></html>'
    output = ROOT / 'Tests/Fixtures/reader-layout.epub'
    with ZipFile(output, 'w') as archive:
        for name, content in files.items():
            entry = ZipInfo(name, date_time=(2026, 10, 13, 0, 0, 0))
            entry.compress_type = ZIP_STORED if name == 'mimetype' else ZIP_DEFLATED
            archive.writestr(entry, content.encode('utf-8'))
    print('Generated original reader-layout.epub (tall cover + long/short chapters).')


if __name__ == '__main__':
    main()
