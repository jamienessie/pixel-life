# Pixel Town logo — pixel-grid spec

**Owner:** Mika
**Purpose:** Production-ready letterform spec so engineering can rasterize the wordmark deterministically without re-designing it.

All glyphs are **5 columns × 7 rows** except `I` which is **3 × 7**. Cap height = 7px. Inter-letter gap = 1px. Inter-word gap = 4px.

Grid convention: column 0 is leftmost, row 0 is top. A `█` is a filled pixel (`brand_cream`, #F8EDD4). A `·` is transparent (or background `brand_teal` #2E6E78 on locked backgrounds).

## Glyph grids

### P (5×7)
```
████·
█···█
█···█
████·
█····
█····
█····
```

### I (3×7)
```
███
·█·
·█·
·█·
·█·
·█·
███
```

### X (5×7)
```
█···█
·█·█·
·█·█·
··█··
·█·█·
·█·█·
█···█
```

### E (5×7)
```
█████
█····
█····
████·
█····
█····
█████
```

### L (5×7)
```
█····
█····
█····
█····
█····
█····
█████
```

### T (5×7)
```
█████
··█··
··█··
··█··
··█··
··█··
··█··
```

### O (5×7)
```
·███·
█···█
█···█
█···█
█···█
█···█
·███·
```

### W (5×7)
```
█···█
█···█
█···█
█···█
█·█·█
██·██
█···█
```

### N (5×7)
```
█···█
██··█
█·█·█
█··██
█···█
█···█
█···█
```

## Lockup math

### Horizontal "PIXEL TOWN"

| Glyph | x start | width |
|-------|---------|-------|
| P     | 0       | 5     |
| (gap) | 5       | 1     |
| I     | 6       | 3     |
| (gap) | 9       | 1     |
| X     | 10      | 5     |
| (gap) | 15      | 1     |
| E     | 16      | 5     |
| (gap) | 21      | 1     |
| L     | 22      | 5     |
| word gap | 27   | 4     |
| T     | 31      | 5     |
| (gap) | 36      | 1     |
| O     | 37      | 5     |
| (gap) | 42      | 1     |
| W     | 43      | 5     |
| (gap) | 48      | 1     |
| N     | 49      | 5     |
| **total** | —   | **54 wide × 7 tall** |

Add 2px padding all around → final canvas **58 × 11**. Content origin at (2, 2).

### Stacked "PIXEL / TOWN"

- Top row "PIXEL" is 27 wide.
- Bottom row "TOWN" is 23 wide; centered → x offset = (27 − 23) / 2 = **2**.
- Vertical gap between rows = **1px**.
- Combined content: 27 wide × 15 tall (rows 0–6 = PIXEL, row 7 = gap, rows 8–14 = TOWN).
- Add 3px padding all around → final canvas **33 × 21**.

### Iconmark (PT monogram, 16×16)

Single-glyph stacked monogram for tiny placements. `P` sits in the top-left, `T` overlapping shifted right and down, sharing the central vertical bar.

```
··············
·████··█████··
·█···█···█····
·█···█···█····
·████····█····
·█·······█····
·█·······█····
·█·······█····
··············
```

(9 rows × 14 cols above; pad to 16×16 → 4px left, 3px right, 4px top, 3px bottom.)

Render the monogram at 32× on the 512×512 app icon (gives 448px monogram inside the 480-safe area, with margin).

## Color rules

- **On brand-teal lockup:** fill `brand_cream` (#F8EDD4), no outline.
- **On variable/photographic background** (e.g. screenshots, marketing composites): fill `brand_cream` + 1px `deep_brown` (#3A2A1B) outline (drawn by expanding the silhouette by 1px in all 8 directions before filling).
- **Reverse (light theme):** fill `brand_teal` on `brand_cream` background. Used for print, light marketing surfaces.

## Production guidance

For PNG export pack `PT-A1`:
1. Open in Aseprite or any pixel editor at 1× canvas.
2. Type each glyph from the grids above. Verify columns by eye.
3. Export at @1×, @2×, @4×, @8×, @16× — all nearest-neighbor scale.
4. Filename pattern: `branding/exports/logo_{variant}/{scale}.png` where variant is `wordmark` / `stacked` / `iconmark`.
5. Commit the source `.aseprite` file alongside.
