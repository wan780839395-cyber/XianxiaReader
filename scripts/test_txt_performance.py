import hashlib
import json
from pathlib import Path
import tempfile
import unittest

from run_txt_performance import generate


class TXTPerformanceFixtureTests(unittest.TestCase):
    def test_utf8_generator_hashes_and_every_chapter_boundary_are_independent(self):
        with tempfile.TemporaryDirectory() as temporary:
            source, metadata, expected = generate(Path(temporary), "chapters", 65536, 17)
            data = source.read_bytes()
            self.assertEqual(hashlib.sha256(data).hexdigest(), expected["sourceSHA256"])
            self.assertEqual(expected["sourceSHA256"], expected["normalizedSHA256"])
            self.assertEqual(len(data), expected["normalizedBytes"])
            self.assertEqual(json.loads(metadata.read_text(encoding="utf-8")), expected)
            next_byte = 0
            for chapter in expected["chapters"]:
                self.assertEqual(chapter["startByte"], next_byte)
                body = data[chapter["startByte"]:chapter["endByte"]].decode("utf-8")
                self.assertTrue(body.startswith(chapter["title"] + "\r\n"))
                next_byte = chapter["endByte"]
            self.assertEqual(next_byte,len(data))

    def test_bom_normalized_hash_and_giant_no_newline_sample(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            source, _, expected = generate(directory, "utf16", 65536, 13, encoding="utf-16-le")
            raw = source.read_bytes(); self.assertTrue(raw.startswith(b"\xff\xfe"))
            normalized = raw[2:].decode("utf-16-le").encode("utf-8")
            self.assertEqual(expected["normalizedSHA256"],hashlib.sha256(normalized).hexdigest())
            self.assertEqual(expected["normalizedBytes"],len(normalized))
            giant, _, expected = generate(directory,"giant",131072,1,giant=True)
            raw = giant.read_bytes(); self.assertNotIn(b"\n",raw); self.assertNotIn(b"\r",raw)
            self.assertGreater(len(raw),65536)
            self.assertEqual(expected["chapters"],[dict(title="正文",startByte=0,endByte=len(raw))])
            self.assertEqual(expected["sourceSHA256"],hashlib.sha256(raw).hexdigest())
