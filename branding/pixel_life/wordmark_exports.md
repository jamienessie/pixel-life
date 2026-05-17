# Wordmark export pack — production specs

**Owner:** Mika Solberg
**Sources:**
- `pixel_life_wordmark.svg` — ink-on-cream, framed (slab border).
- `pixel_life_wordmark_transparent.svg` — ink on transparent.
- `pixel_life_wordmark_white.svg` — white on transparent (dark-bg knockout).

All three masters share the same 640×128 viewBox and the same baseline geometry, so PNG bakes line up across variants.

## Target widths

For each variant, export PNGs at the following widths. Height scales proportionally (128 ÷ 640 = 0.2, so heights are width × 0.2).

| Width × Height  | Suggested use                                                |
|-----------------|--------------------------------------------------------------|
| 256 × 51        | Email signatures, favicons-on-marketing-pages, slack avatar. |
| 512 × 102       | App store collateral inline, small README header.            |
| 1024 × 205      | Landing-page hero secondary, social card.                    |
| 2048 × 410      | Press kit, large-format print, retina marketing chrome.      |

## File naming

```
exports/
  wordmark_inkcream_256.png
  wordmark_inkcream_512.png
  wordmark_inkcream_1024.png
  wordmark_inkcream_2048.png
  wordmark_ink_256.png            # transparent bg
  wordmark_ink_512.png
  wordmark_ink_1024.png
  wordmark_ink_2048.png
  wordmark_white_256.png          # transparent bg
  wordmark_white_512.png
  wordmark_white_1024.png
  wordmark_white_2048.png
```

## Export discipline

- All bakes use **bilinear** interpolation — wordmark is type, not pixel-grid art.
- Confirm Archivo Black is loaded before baking. If the export tool falls back to a system font, the textLength attribute will scale a generic sans into 500px and the result will look like a placeholder. Engineering: if the renderer cannot guarantee Archivo Black, outline the text first (e.g. via Inkscape `Path → Object to Path`) and bake from the outlined copy.
- Coral period stays `#ff5d7a` in all three variants — it is the brand accent and should not invert in the white-knockout version.
- Transparent variants must be 8-bit PNG with alpha (PNG32 / RGBA8). 1-bit alpha will jag the type edges.

## When to use each variant

| Variant         | Use when                                                            |
|-----------------|---------------------------------------------------------------------|
| Ink-on-cream    | Default. Anywhere the brand owns the surface — marketing chrome over a clean background, headers, in-app branding moments. |
| Ink transparent | The surface already supplies the cream / paper color, or the mark sits over an illustration. |
| White knockout  | Dark surfaces only — dark photography, dark slide decks, social cards with ink-black or rich background fills. |

## Acceptance

- Each PNG visually matches its master at 100% zoom — no soft type edges, no aliasing artefacts on the slab border (for the inkcream variant), coral period sits at the correct baseline offset.
- Spot-check the 256px bakes — small sizes catch interpolation problems first.
