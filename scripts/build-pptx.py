#!/usr/bin/env python3
"""
build-pptx.py — compile a slide spec + a sota-present style into an EDITABLE .pptx.

The output is native PowerPoint: real text frames and shapes (editable in
PowerPoint / WPS / Keynote), coloured from the same design tokens used by the
HTML and Feishu-whiteboard engines, so all three outputs stay coordinated.

Usage:
  python3 scripts/build-pptx.py --style <style-id> --spec <spec.json> --out output/pptx/deck.pptx
  python3 scripts/build-pptx.py --style bold-signal --spec deck.json --out deck.pptx --cjk-font "PingFang SC"

Spec JSON:
  { "title": "...", "slides": [ { "type": "...", ... }, ... ] }
Slide types: cover | section | agenda | content | two_col | stat | statement | closing
(See skills/PPTX.md for the full field reference.)
"""
import argparse, json, os, sys
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.enum.shapes import MSO_SHAPE
from pptx.oxml.ns import qn

EMU_IN = 914400
W_IN, H_IN = 13.333, 7.5            # 16:9 stage

# ---------- helpers ----------
def hexcol(v):
    return RGBColor.from_string(str(v).lstrip("#").upper())

def fam(token):
    """'"Archivo Black", sans-serif' -> 'Archivo Black'"""
    return str(token).split(",")[0].strip().strip('"').strip("'")

def set_font(run, name=None, ea=None, size=None, bold=None, italic=None, color=None, spacing=None):
    f = run.font
    if size is not None:  f.size = Pt(size)
    if bold is not None:  f.bold = bold
    if italic is not None: f.italic = italic
    if color is not None: f.color.rgb = hexcol(color)
    rPr = run._r.get_or_add_rPr()
    if name is not None:
        f.name = name
        for tag in ("a:cs",):
            el = rPr.find(qn(tag)) or rPr.makeelement(qn(tag), {})
            if el.getparent() is None: rPr.append(el)
            el.set("typeface", name)
    if ea is not None:   # East-Asian (CJK) face
        el = rPr.find(qn("a:ea")) or rPr.makeelement(qn("a:ea"), {})
        if el.getparent() is None: rPr.append(el)
        el.set("typeface", ea)
    if spacing is not None:  # letter spacing in points*100
        rPr.set("spc", str(int(spacing * 100)))

class Deck:
    def __init__(self, tokens, cjk):
        self.t = tokens
        self.cjk = cjk
        self.heading = fam(tokens.get("font_heading", "Arial"))
        self.body = fam(tokens.get("font_body", "Arial"))
        self.prs = Presentation()
        self.prs.slide_width = Emu(int(W_IN * EMU_IN))
        self.prs.slide_height = Emu(int(H_IN * EMU_IN))
        self.blank = self.prs.slide_layouts[6]

    def _slide(self):
        s = self.prs.slides.add_slide(self.blank)
        s.background.fill.solid()
        s.background.fill.fore_color.rgb = hexcol(self.t["color_bg"])
        return s

    def rect(self, s, x, y, w, h, fill, line=None, rounded=False):
        shp = s.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE if rounded else MSO_SHAPE.RECTANGLE,
                                 Inches(x), Inches(y), Inches(w), Inches(h))
        shp.fill.solid(); shp.fill.fore_color.rgb = hexcol(fill)
        if line: shp.line.color.rgb = hexcol(line); shp.line.width = Pt(2)
        else: shp.line.fill.background()
        shp.shadow.inherit = False
        return shp

    def text(self, s, x, y, w, h, runs, align=PP_ALIGN.LEFT, anchor=MSO_ANCHOR.TOP, line_spacing=1.1):
        tb = s.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
        tf = tb.text_frame; tf.word_wrap = True; tf.vertical_anchor = anchor
        tf.margin_left = tf.margin_right = tf.margin_top = tf.margin_bottom = 0
        for i, line in enumerate(runs):
            p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
            p.alignment = align; p.line_spacing = line_spacing
            segs = line if isinstance(line, list) else [line]
            for seg in segs:
                r = p.add_run(); r.text = seg.get("t", "")
                set_font(r, name=seg.get("font", self.body), ea=self.cjk,
                         size=seg.get("size", 18), bold=seg.get("bold", False),
                         italic=seg.get("italic", False),
                         color=seg.get("color", self.t["color_text"]),
                         spacing=seg.get("spacing"))
        return tb

    # ---- slide renderers ----
    def cover(self, d):
        s = self._slide()
        self.rect(s, 0, 0, 5.0, 0.16, self.t["color_accent"])           # top bar
        if d.get("eyebrow"):
            self.text(s, 0.9, 2.1, 8, 0.5, [[{"t": d["eyebrow"], "font": self.body,
                      "size": 16, "bold": True, "color": self.t["color_accent"], "spacing": 3}]])
        self.text(s, 0.85, 2.5, 11.6, 2.6,
                  [[{"t": d["title"], "font": self.heading, "size": d.get("title_size", 66),
                     "bold": True, "color": self.t["color_primary"]}]], line_spacing=1.0)
        if d.get("subtitle"):
            self.text(s, 0.9, 5.0, 11.0, 1.3, [[{"t": d["subtitle"], "font": self.body,
                      "size": 24, "color": self.t["color_text"]}]], line_spacing=1.25)
        if d.get("footer"):
            self.text(s, 0.9, 6.7, 11, 0.5, [[{"t": d["footer"], "font": self.body,
                      "size": 14, "color": self.t["color_text_muted"], "spacing": 2}]])

    def section(self, d):
        s = self._slide()
        if d.get("num"):
            self.text(s, 0.8, 0.6, 4, 2.2, [[{"t": d["num"], "font": self.heading,
                      "size": 130, "bold": True, "color": self.t["color_accent"]}]])
        self.text(s, 0.85, 3.1, 11.6, 2, [[{"t": d["title"], "font": self.heading,
                  "size": 54, "bold": True, "color": self.t["color_primary"]}]], line_spacing=1.0)
        if d.get("subtitle"):
            self.text(s, 0.9, 4.6, 10.5, 1.3, [[{"t": d["subtitle"], "font": self.body,
                      "size": 22, "color": self.t["color_text_muted"]}]], line_spacing=1.3)

    def _heading(self, s, txt):
        self.rect(s, 0.85, 0.85, 0.12, 0.7, self.t["color_accent"])
        self.text(s, 1.15, 0.8, 11.2, 1.1, [[{"t": txt, "font": self.heading,
                  "size": 36, "bold": True, "color": self.t["color_primary"]}]])

    def agenda(self, d):
        s = self._slide(); self._heading(s, d["heading"])
        y = 2.3
        for i, item in enumerate(d.get("items", []), 1):
            self.rect(s, 0.9, y + 0.08, 0.42, 0.42, self.t["color_accent"])
            self.text(s, 0.9, y + 0.06, 0.42, 0.42, [[{"t": str(i), "font": self.body,
                      "size": 18, "bold": True, "color": self.t["color_bg"], }]],
                      align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
            self.text(s, 1.6, y, 10.6, 0.7, [[{"t": item, "font": self.body, "size": 26,
                      "color": self.t["color_text"]}]], anchor=MSO_ANCHOR.MIDDLE)
            y += 0.92

    def content(self, d):
        s = self._slide(); self._heading(s, d["heading"])
        if d.get("lead"):
            self.text(s, 1.15, 2.05, 11.0, 1.0, [[{"t": d["lead"], "font": self.body,
                      "size": 22, "color": self.t["color_text"]}]], line_spacing=1.3)
        y = 3.2 if d.get("lead") else 2.3
        for b in d.get("bullets", []):
            self.rect(s, 1.15, y + 0.16, 0.22, 0.22, self.t["color_accent"])
            self.text(s, 1.6, y, 10.8, 0.9, [[{"t": b, "font": self.body, "size": 22,
                      "color": self.t["color_text"]}]], line_spacing=1.2)
            y += 0.86

    def two_col(self, d):
        s = self._slide(); self._heading(s, d["heading"])
        for col, key, tkey in [(0, "left", "left_title"), (1, "right", "right_title")]:
            x = 0.9 + col * 6.05
            self.rect(s, x, 2.1, 5.6, 4.4, self.t["color_surface"], rounded=True)
            self.text(s, x + 0.45, 2.45, 4.8, 0.7, [[{"t": d.get(tkey, ""), "font": self.heading,
                      "size": 28, "bold": True, "color": self.t["color_accent"]}]])
            yy = 3.4
            for it in d.get(key, []):
                self.text(s, x + 0.45, yy, 4.8, 0.7, [[{"t": "› " + it, "font": self.body,
                          "size": 19, "color": self.t["color_text"]}]], line_spacing=1.15)
                yy += 0.72

    def stat(self, d):
        s = self._slide(); self._heading(s, d.get("heading", ""))
        items = d.get("items", [])
        n = max(1, len(items)); cw = (11.6 - (n - 1) * 0.4) / n
        for i, it in enumerate(items):
            x = 0.9 + i * (cw + 0.4)
            self.text(s, x, 2.6, cw, 1.6, [[{"t": it.get("value", ""), "font": self.heading,
                      "size": 72, "bold": True, "color": self.t["color_primary"]}]])
            self.text(s, x, 4.3, cw, 1.2, [[{"t": it.get("label", ""), "font": self.body,
                      "size": 20, "color": self.t["color_text_muted"]}]], line_spacing=1.2)

    def statement(self, d):
        s = self._slide()
        self.rect(s, 0, 0, 0.16, H_IN, self.t["color_accent"])
        self.text(s, 1.1, 1.9, 11.2, 3.4, [[{"t": d["text"], "font": self.heading,
                  "size": d.get("size", 48), "bold": True, "color": self.t["color_primary"]}]],
                  anchor=MSO_ANCHOR.MIDDLE, line_spacing=1.05)
        if d.get("sub"):
            self.text(s, 1.1, 5.6, 10.5, 1.2, [[{"t": d["sub"], "font": self.body,
                      "size": 22, "color": self.t["color_text_muted"]}]], line_spacing=1.3)

    def closing(self, d):
        s = self._slide()
        self.text(s, 0.85, 2.4, 11.6, 2.6, [[{"t": d["title"], "font": self.heading,
                  "size": d.get("title_size", 60), "bold": True, "color": self.t["color_primary"]}]],
                  line_spacing=1.0)
        if d.get("subtitle"):
            self.text(s, 0.9, 5.2, 11.0, 1.3, [[{"t": d["subtitle"], "font": self.body,
                      "size": 22, "color": self.t["color_text_muted"]}]], line_spacing=1.3)
        self.rect(s, W_IN - 4.2, H_IN - 0.16, 4.2, 0.16, self.t["color_accent"])

    def render(self, spec):
        fn = {"cover": self.cover, "section": self.section, "agenda": self.agenda,
              "content": self.content, "two_col": self.two_col, "stat": self.stat,
              "statement": self.statement, "closing": self.closing}
        for sl in spec.get("slides", []):
            fn.get(sl.get("type", "content"), self.content)(sl)

def load_tokens(style_id):
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    styles = json.load(open(os.path.join(root, "catalog/styles.json")))["styles"]
    st = next((s for s in styles if s["id"] == style_id), None)
    if not st:
        sys.exit(f"❌ style not found: {style_id}")
    return st["tokens"], st["name"]

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--style", required=True)
    ap.add_argument("--spec", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--cjk-font", default="PingFang SC")
    a = ap.parse_args()
    tokens, name = load_tokens(a.style)
    spec = json.load(open(a.spec))
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    deck = Deck(tokens, a.cjk_font)
    deck.render(spec)
    deck.prs.save(a.out)
    print(f"✅ {a.out}  ({len(spec.get('slides', []))} slides, style: {name})")

if __name__ == "__main__":
    main()
