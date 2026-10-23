"""Offline font audit; requires fontTools for this optional QA tool only."""

import hashlib
import json
from pathlib import Path

from fontTools.ttLib import TTFont


ROOT = Path(__file__).resolve().parents[1]
FONTS = ROOT / "assets/fonts"
SOURCES = {
    "PlusJakartaSans.ttf": ("Plus Jakarta Sans", 200, 800, "89b3fb38aa0d275d7a731d0d817a4f1622b316b4d7fbdedcf02ee9099ff68bc8", "plusjakartasans"),
    "NotoSansHK.ttf": ("Noto Sans HK", 100, 900, "76098ee78ec234cd4f8c950742b3f766fea2f8b43d5180d901048f4fc86c6849", "notosanshk"),
    "NotoSansSC.ttf": ("Noto Sans SC", 100, 900, "a3041811a78c361b1de50f953c805e0244951c21c5bd412f7232ef0d899af0da", "notosanssc"),
    "NotoSansJP.ttf": ("Noto Sans JP", 100, 900, "c2f3b4d463500a2ddcd3849cded1fceeb9fd6d1c32e6cbecd568453ba50fc68f", "notosansjp"),
    "NotoSansThai.ttf": ("Noto Sans Thai", 100, 900, "5a1c559bb539583c8a1fd99d1c5b9491e5e14478c9cd2bd0970d5c3096cc9ef8", "notosansthai"),
}
SAMPLES = [
    "HK$ 12,580.50 餐飲",
    "支付寶 Alipay ¥1,280",
    "Amazon JP ¥8,900",
    "ร้านอาหาร HK$350",
    "東京 Metro ¥220",
    "KeEv Ledger 交易紀錄",
    "Visa •••• 1234",
    "USD 1,250.75",
    "THB 3,450.00",
]


def main():
    manifest = (ROOT / "pubspec.yaml").read_text()
    result = {}
    all_cmaps = []
    for filename, (family, min_weight, max_weight, expected_hash, directory) in SOURCES.items():
        path = FONTS / filename
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        assert digest == expected_hash, f"Upstream font mismatch: {filename}"
        assert f"- family: {family}\n" in manifest and f"- asset: assets/fonts/{filename}\n" in manifest
        licence = (FONTS / (directory + "-OFL.txt")).read_text()
        assert "SIL OPEN FONT LICENSE Version 1.1" in licence
        font = TTFont(path)
        assert family in font["name"].getDebugName(1), filename
        weight = next(axis for axis in font["fvar"].axes if axis.axisTag == "wght")
        assert (weight.minValue, weight.maxValue) == (min_weight, max_weight)
        cmap = font.getBestCmap()
        all_cmaps.append(cmap)
        digits = [font["hmtx"][cmap[ord(d)]][0] for d in "0123456789"]
        features = set()
        for table in ("GSUB", "GPOS"):
            if table in font and font[table].table.FeatureList:
                features.update(x.FeatureTag for x in font[table].table.FeatureList.FeatureRecord)
        assert len(set(digits)) == 1 or "tnum" in features, filename
        if filename == "NotoSansThai.ttf":
            assert all(ord(mark) in cmap for mark in "่้๊๋ิีืุู")
        result[family] = {
            "asset": filename,
            "sha256": digest,
            "weight_axis": [min_weight, max_weight],
            "digit_advances_equal_at_default": len(set(digits)) == 1,
            "has_tnum_feature": "tnum" in features,
            "licence": "SIL OFL 1.1",
        }
    uncovered = sorted({c for sample in SAMPLES for c in sample if not c.isspace() and not any(ord(c) in cmap for cmap in all_cmaps)})
    assert not uncovered, f"Mixed-script sample glyphs missing: {uncovered}"
    print(json.dumps({"status": "PASS", "fonts": result, "mixed_samples": SAMPLES, "missing_sample_glyphs": uncovered}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
