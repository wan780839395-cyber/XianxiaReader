"""Small original 1000-resource EPUB for bounded-reader integration tests."""
from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED, ZIP_STORED
ROOT=Path(__file__).resolve().parents[1]
COUNT=1000

def main():
    manifest=''.join(f'<item id="c{i}" href="chapter-{i}.xhtml" media-type="application/xhtml+xml"/>' for i in range(COUNT))
    spine=''.join(f'<itemref idref="c{i}"/>' for i in range(COUNT))
    files={
      'mimetype':'application/epub+zip',
      'META-INF/container.xml':'<container xmlns="urn:oasis:names:tc:opendocument:xmlns:container" version="1.0"><rootfiles><rootfile full-path="OEBPS/book.opf" media-type="application/oebps-package+xml"/></rootfiles></container>',
      'OEBPS/book.opf':f'<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="id"><metadata xmlns:dc="http://purl.org/dc/elements/1.1/"><dc:identifier id="id">urn:xianxiareader:window-test</dc:identifier><dc:title>千章窗口·原创测试</dc:title><dc:language>zh-CN</dc:language><meta property="dcterms:modified">2026-10-14T00:00:00Z</meta></metadata><manifest><item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>{manifest}</manifest><spine>{spine}</spine></package>',
      'OEBPS/nav.xhtml':'<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops"><head><title>目录</title></head><body><nav epub:type="toc"><ol><li><a href="chapter-0.xhtml">开始</a></li><li><a href="chapter-500.xhtml">中段</a></li><li><a href="chapter-999.xhtml">末章</a></li></ol></nav></body></html>'
    }
    for i in range(COUNT):
        paragraphs=''.join(f'<p id="line-{j}">第{i+1}章，第{j}段。山风吹过石阶，少年继续前行。这是项目原创窗口测试文字。</p>' for j in range(1,5))
        files[f'OEBPS/chapter-{i}.xhtml']=f'<html xmlns="http://www.w3.org/1999/xhtml" lang="zh-CN"><head><title>窗口章节{i+1}</title><style>body{{line-height:1.6;}}p{{text-indent:2em;}}</style></head><body><h1>第{i+1}章</h1>{paragraphs}</body></html>'
    with ZipFile(ROOT/'Tests/Fixtures/window-long.epub','w') as archive:
        for name,content in files.items():
            entry=ZipInfo(name,date_time=(2026,10,14,0,0,0)); entry.compress_type=ZIP_STORED if name=='mimetype' else ZIP_DEFLATED
            archive.writestr(entry,content.encode())
    print('Generated 1000 original, small resources; this is a window bound test, not a million-word benchmark.')
if __name__=='__main__': main()
