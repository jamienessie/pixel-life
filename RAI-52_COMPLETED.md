# RAI-52 — Raster export pack from branding SVGs

**Status:** done
**Date:** 2026-05-17
**Owner:** Theo Lin (took over raster export from Mika Solberg's design handoff)
**Source of truth:** `branding/pixel_life/RAI-50_ASSET_PACK.md` §1–§2, `branding/pixel_life/wordmark_exports.md`

## Deliverables

All 34 PNGs are verified in `branding/pixel_life/exports/`.

### Wordmarks (3 variants × 4 sizes = 12 files)

| Variant | Source SVG | Exported PNGs |
|---------|-----------|---------------|
| Ink-on-cream | `pixel_life_wordmark.svg` | `wordmark_inkcream_256/512/1024/2048.png` |
| Ink transparent | `pixel_life_wordmark_transparent.svg` | `wordmark_ink_256/512/1024/2048.png` |
| White knockout | `pixel_life_wordmark_white.svg` | `wordmark_white_256/512/1024/2048.png` |

### App icons (6 files)

| Density | Size | PNG |
|---------|------|-----|
| mdpi | 48×48 | `icon_48.png` |
| hdpi | 72×72 | `icon_72.png` |
| xhdpi | 96×96 | `icon_96.png` |
| xxhdpi | 144×144 | `icon_144.png` |
| xxxhdpi | 192×192 | `icon_192.png` |
| Play Store | 512×512 | `icon_512.png` |

### Adaptive layers (10 files)

**Foreground** (from `pixel_life_icon_foreground.svg`): `adaptive_fg_108/162/216/324/432.png`
**Background** (from `pixel_life_icon_background.svg`): `adaptive_bg_108/162/216/324/432.png`

### Splash screens (5 files)

`branding/pixel_life/exports/splash_320x480/480x800/720x1280/1080x1920/1440x2560.png`

### Feature graphic (1 file)

`branding/pixel_life/exports/feature_graphic.png` (1024×500)

### Android resource XMLs

- `branding/pixel_life/android_res/mipmap-anydpi-v26/ic_launcher.xml`
- `branding/pixel_life/android_res/mipmap-anydpi-v26/ic_launcher_round.xml`
- `branding/pixel_life/android_res/values/ic_launcher_background.xml` (color `#fff8e6`)

## Verification

All 34 PNG files confirmed:
- Valid PNG header (89 50 4E 47)
- Nonzero file sizes (316 – 39,633 bytes)
- Naming matches `wordmark_exports.md` and `RAI-50_ASSET_PACK.md` §2 density table
- Nearest-neighbor scaling expected (pixel-grid art)

## Handoff to downstream

Per `RAI-50_STATUS_2026-05-17.md`:

1. **Jules Marek** — screenshots (📷 in RAI-50_ASSET_PACK §1) blocked until stable Capacitor Android build.
2. **Sam Green (CTO)** — confirmations still open: package ID `com.heynessie.pixellife`, launch target date.
3. **Phoebe Walker (CEO)** — tone review of `store_listing.md`.
