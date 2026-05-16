# RAI-30 Brand Identity — shipped

**Owner:** Mika Solberg
**Date:** 2026-05-15
**Status:** done — brand identity spec'd, authored, and wired into the engine.

## What shipped

### Logo SVGs (6 files, pixel-grid accurate)
| File | Canvas | Description |
|------|--------|-------------|
| `logo_wordmark.svg` | 58×11 | Horizontal "PIXEL TOWN" on brand_teal |
| `logo_wordmark_foreground.svg` | 58×11 | Foreground-only for compositing |
| `logo_stacked.svg` | 33×21 | Vertical "PIXEL / TOWN" on brand_teal |
| `logo_stacked_foreground.svg` | 33×21 | Foreground-only for compositing |
| `logo_iconmark.svg` | 16×16 | PT monogram on brand_teal |
| `logo_iconmark_foreground.svg` | 16×16 | Foreground-only for compositing |

All built from the exact glyph grids in `logo_spec.md`.
Glyphs decomposed into SVG `<path>` data with `shape-rendering="crispEdges"` — scales cleanly at any integer factor via nearest-neighbor.

### Engine integration (project.godot)
- **config/name** → "Pixel Town" (canonical brand name, was "Pixel Life")
- **boot_splash/bg_color** → brand_teal `#2E6E78` (was dark gray)
- **Palette autoload** → registered `*res://branding/palette.gd` as a global singleton

Now any scene can call `Palette.BRAND_TEAL`, `Palette.SUN_GOLD`, etc.

### Exports directory structure
```
branding/exports/
  logo_wordmark/   ← PT-A1 target
  logo_stacked/    ← PT-A1 target
  logo_iconmark/   ← PT-A1 target
  app_icon/        ← PT-A2 target
```

## Open question resolution
| §13 Question | Default | Action |
|:---|:---|---|
| Q1 — Canonical name | "Pixel Town" | Applied to project.godot |
| Q2 — SVG authorship | Author in-repo | SVGs created |
| Q3 — Android first | Android primary | Spec unchanged |
| Q4 — Steam assets | Defer | Deferred |

## Follow-up issues needed (engineering child issues)
- PT-A1: PNG export pack from SVGs (@1×–@16×)
- PT-A2: App icon 512×512 + adaptive layers
- PT-A3: Feature graphic 1024×500 composite
- PT-A5: Splash screen + main menu (uses stacked logo + teal bg)
