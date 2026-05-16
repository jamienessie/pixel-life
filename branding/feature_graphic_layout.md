# Google Play feature graphic — layout spec

**Canvas:** 1024 × 500 px, 32-bit RGBA, no transparency, no rounded corners.
**Owner spec:** Mika. **Producer:** engineering (PT-A3).

## Safe-zone rules

Google Play overlays an "Install" CTA and may crop the right ~25% on some surfaces. **All critical content stays in the left 768px**, and **no text in the outer 100px gutters** (top, bottom, left, right).

```
┌────────────────────────────────────────────────────────────────────────────┐  ← y=0
│  ░░ 100px gutter (decorative only) ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
│  ┌──────────────────────────────────────┐ ┌─────────────────────────────┐  │
│  │                                      │ │                             │  │
│  │   LEFT PANEL  (560 × 300)            │ │   RIGHT PANEL (288 × 300)   │  │
│  │   Logo + tagline                     │ │   Gameplay vignette         │  │
│  │   Background: brand_teal             │ │   (cropped town-at-dusk     │  │
│  │                                      │ │    composition with player  │  │
│  │   [stacked PIXEL TOWN logo,          │ │    + NPC + lit lanterns)    │  │
│  │    centered horizontally in panel,   │ │                             │  │
│  │    top-justified at y=130]           │ │                             │  │
│  │                                      │ │                             │  │
│  │   tagline at y=270 in m5x7 @ 3×:     │ │                             │  │
│  │   "Plant. Work. Love. Pass it on."   │ │                             │  │
│  │                                      │ │                             │  │
│  └──────────────────────────────────────┘ └─────────────────────────────┘  │
│  ░░ 100px gutter ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  │
└────────────────────────────────────────────────────────────────────────────┘  ← y=500
   ↑0                                                                        ↑1024
```

## Layout

| Region          | x      | y      | w   | h   | Notes                                                     |
|-----------------|--------|--------|-----|-----|-----------------------------------------------------------|
| Left panel      | 100    | 100    | 560 | 300 | Background `brand_teal`. Stacked logo + tagline.          |
| Right panel     | 660    | 100    | 288 | 300 | Cropped gameplay scene, dusk lighting. Bleed allowed.     |
| Right gutter    | 948    | 0      | 76  | 500 | Decorative only. Anchor a pixel-tree silhouette here.     |
| Top/bottom gutter | 0/0  | 0/400  | 1024| 100 | `brand_teal` solid OR pixel-cobblestone pattern at 2×.    |

**Logo placement:** stacked variant from `logo_spec.md`. Render at ~7× scale (final size ≈ 231 × 147 px). Center horizontally in the left panel; top of the stacked lockup at y = 130.

**Tagline:** *"Plant. Work. Love. Pass it on."* — `m5x7.ttf` at 3× scale, color `brand_cream`. Center horizontally in the left panel; baseline at y = 380.

**Gameplay vignette:** in-engine screenshot. Required content: player character, one NPC, at least one lit lantern (sun_gold glow), dusk overlay (`dusk_plum` 30% multiply). Crop to fill 288 × 300 with bleed; do not stretch.

## Color & finish

- Background: `brand_teal` (#2E6E78) flat fill OR an optional 4×-scaled cobblestone tile pattern.
- Top + bottom 100px gutter: same teal, optional 1-pixel `deep_brown` decorative border at y=99 and y=400 for crispness.
- No drop shadows, glows, or gradients. Pixel logo logic applies — integer-scale only.

## Acceptance check

- [ ] All text inside the 100px-padded safe area.
- [ ] Logo and tagline within the left 768px.
- [ ] No text in the outer gutters.
- [ ] Background not transparent.
- [ ] Exports as 1024 × 500 PNG, < 1 MB.
- [ ] Rendered at integer pixel scale (no anti-aliasing on the logo edges).
