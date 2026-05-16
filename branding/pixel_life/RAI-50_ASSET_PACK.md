# RAI-50 — Pixel Life full Play Store asset pack

**Owner:** Mika Solberg, Brand & Visual Identity Designer
**Date:** 2026-05-16
**Status:** Design artifacts shipped to `branding/pixel_life/`. Engineering raster export + screenshot capture are downstream.
**Parent:** RAI-47 (Pivot to Mobile APK Android). Follow-up to: RAI-49 (mobile brand audit).

---

## TL;DR

Everything that can be authored by Brand without engineering wiring is in this folder. PNG density bakes, splash configuration, and the actual screenshot captures need Theo (Capacitor / Android) and Jules (UI snapshots). Pixel Life name + `com.heynessie.pixellife` package ID are treated as confirmed unless CTO overrides — see §6.

## 1. Asset inventory

Status legend: ✅ shipped · 🛠 needs engineering raster · 📷 needs build to capture · ❓ pending CTO confirm.

### 1.1 App icons

| Asset                                | File / source                                         | Status                              |
|--------------------------------------|-------------------------------------------------------|-------------------------------------|
| 512×512 Play Store hi-res icon       | `pixel_life_icon.svg` (master)                        | ✅ master, 🛠 PNG export             |
| mdpi standard 48×48                  | `exports/icon_48.png`                                 | 🛠 raster from master                |
| hdpi standard 72×72                  | `exports/icon_72.png`                                 | 🛠                                   |
| xhdpi standard 96×96                 | `exports/icon_96.png`                                 | 🛠                                   |
| xxhdpi standard 144×144              | `exports/icon_144.png`                                | 🛠                                   |
| xxxhdpi standard 192×192             | `exports/icon_192.png`                                | 🛠                                   |
| Adaptive foreground SVG              | `pixel_life_icon_foreground.svg`                      | ✅                                   |
| Adaptive background SVG              | `pixel_life_icon_background.svg`                      | ✅                                   |
| Adaptive foreground PNGs (5 densities) | `exports/adaptive_fg_*.png`                         | 🛠                                   |
| Adaptive background PNGs (5 densities) | `exports/adaptive_bg_*.png`                         | 🛠                                   |
| Adaptive icon XML (anydpi-v26)       | `android_res/mipmap-anydpi-v26/ic_launcher.xml`       | ✅                                   |
| Adaptive icon round XML              | `android_res/mipmap-anydpi-v26/ic_launcher_round.xml` | ✅                                   |

Density / pixel table — see §2.

### 1.2 Splash

| Asset                                | File                                                  | Status                              |
|--------------------------------------|-------------------------------------------------------|-------------------------------------|
| Splash master SVG (1080×1920 portrait) | `pixel_life_splash.svg`                             | ✅                                   |
| Splash PNGs (phone densities)        | `exports/splash_*.png`                                | 🛠                                   |
| Capacitor splash config notes        | This doc §3                                           | ✅                                   |

### 1.3 Play Store listing

| Asset                                | File                                                  | Status                              |
|--------------------------------------|-------------------------------------------------------|-------------------------------------|
| Feature graphic 1024×500 PNG         | `pixel_life_feature_graphic.svg` + `exports/feature_graphic.png` | ✅ SVG, 🛠 PNG               |
| Phone screenshot 1 — Home dashboard  | `exports/screenshot_phone_1.png`                      | 📷 needs build                       |
| Phone screenshot 2 — Calendar        | `exports/screenshot_phone_2.png`                      | 📷                                   |
| Phone screenshot 3 — Countdowns      | `exports/screenshot_phone_3.png`                      | 📷                                   |
| Phone screenshot 4 — Places + map    | `exports/screenshot_phone_4.png`                      | 📷                                   |
| Phone screenshot 5 — Weather         | `exports/screenshot_phone_5.png`                      | 📷                                   |
| Screenshot frame template SVG        | `pixel_life_screenshot_frame.svg`                     | ✅                                   |
| Short description ≤80 chars          | `store_listing.md`                                    | ✅                                   |
| Long description ≤4000 chars         | `store_listing.md`                                    | ✅                                   |
| Tablet screenshots                   | deferred — see §5                                     | ⏸ deferred                           |
| Promo video                          | deferred — see §5                                     | ⏸ deferred                           |

### 1.4 Marketing chrome

| Asset                                | File                                                  | Status                              |
|--------------------------------------|-------------------------------------------------------|-------------------------------------|
| Wordmark master SVG                  | `pixel_life_wordmark.svg`                             | ✅                                   |
| Wordmark PNG transparent-ink @ 256/512/1024/2048 | `exports/wordmark_ink_*.png`              | 🛠                                   |
| Wordmark PNG ink-on-cream @ 256/512/1024/2048 | `exports/wordmark_inkcream_*.png`            | 🛠                                   |
| Wordmark PNG white-knockout @ 256/512/1024/2048 | `exports/wordmark_white_*.png`             | 🛠                                   |

## 2. Locked density table — Android

All standard launcher icons + adaptive layers + splash baseline use the same density buckets.

| Density   | Scale  | Standard launcher | Adaptive layer (108dp box) | Splash @1x ref |
|-----------|--------|-------------------|---------------------------|----------------|
| mdpi      | 1.0×   | 48×48             | 108×108                   | 320×480        |
| hdpi      | 1.5×   | 72×72             | 162×162                   | 480×800        |
| xhdpi     | 2.0×   | 96×96             | 216×216                   | 720×1280       |
| xxhdpi    | 3.0×   | 144×144           | 324×324                   | 1080×1920      |
| xxxhdpi   | 4.0×   | 192×192           | 432×432                   | 1440×2560      |
| Play Store hi-res | — | 512×512        | —                         | —              |

**Export discipline:**
- Standard launcher PNGs are baked from `pixel_life_icon.svg` (with the slab border) — Android < 8 reads these without the adaptive mask, so the border defines silhouette there.
- Adaptive foreground PNGs are baked from `pixel_life_icon_foreground.svg` with transparent canvas — the OS composites over the background layer.
- Adaptive background PNGs are baked from `pixel_life_icon_background.svg` as a solid cream field. Engineering may opt to use a `<color>` resource (`#fff8e6`) referenced from the adaptive XML instead of a PNG — both are acceptable and the color-resource path saves binary bytes.
- All raster bakes use **nearest-neighbor** scaling. The icon is pixel-grid art; bilinear/bicubic will soften the slab edges and make the coral accent fuzzy.

## 3. Splash screen — Capacitor wiring

The splash master is `pixel_life_splash.svg` at 1080×1920 portrait (xxhdpi reference). Composition:

- Full-bleed `#fff8e6` paper field.
- Centered Pixel Life wordmark (Archivo Black, ink black, 144px cap height at 1080-wide reference), sitting just above the optical center.
- Single 32×32 coral pixel sitting as a "period" to the right of the wordmark, baseline-aligned.
- 12px ink slab border inset 24px from the edge — matches the icon's slab convention so the splash and icon feel like the same product.

**Capacitor config — recommended values for `capacitor.config.ts`:**

```ts
plugins: {
  SplashScreen: {
    launchShowDuration: 1500,
    backgroundColor: '#fff8e6',
    androidScaleType: 'CENTER_CROP',
    showSpinner: false,
    splashImmersive: false,
    splashFullScreen: false,
  },
}
```

For the Android 12+ splash API (`SplashScreenTheme`), set `windowSplashScreenBackground` to `#fff8e6` and `windowSplashScreenAnimatedIcon` to the adaptive foreground drawable. The OS will mask to a circle automatically; safe area is the inner 66% of the 108dp box (already respected by the icon foreground).

**Acceptable fallback for short timelines:** solid cream `#fff8e6` window with no logo at all. Better than the legacy purple-gradient splash flagged in RAI-49.

## 4. Screenshots — framing rules

Captures must be 1080×1920 portrait, taken from the Sunny PWA running in the Capacitor Android shell (or a Pixelmator-equivalent 1:1 emulator pixel-for-pixel). Drop the capture into the `screenshot_inner` rect of `pixel_life_screenshot_frame.svg`.

| # | Page captured              | Caption (≤32c)                    | What to include in the frame                |
|---|----------------------------|-----------------------------------|---------------------------------------------|
| 1 | `/` HomePage               | "Your day, at a glance"           | Weather card, today's events, due todos.    |
| 2 | `/calendar` CalendarPage   | "Months that count down"          | Month grid with at least 2 countdown chips. |
| 3 | `/countdowns` CountdownsPage | "Live tickers for what matters" | At least one D:H:M:S ticker visible.        |
| 4 | `/places` PlacesPage       | "Pinned places, on a real map"    | Map with ≥3 category pins visible.          |
| 5 | `/weather` WeatherPage     | "5 forecast models, one answer"   | Confidence chip + interesting-fact card.    |

Caption typography: Archivo Black 48px, ink, left-aligned, sits in the top 200px caption strip on cream. Below the strip: device chrome rect with the UI capture inside.

**Capture protocol:**
- Run `npm run dev` and hard-reload after switching to Android emulator at 1080×1920.
- Use a deterministic seed dataset (Theo / Mara — file an issue if there isn't one) so screenshots are reproducible.
- No real personal data in captures. Use fictional names, fake places, neutral countdown labels ("Trip to Reno", "Anniversary").

## 5. Out of scope for this pack

- **Apple icon variants** — Android-first per RAI-47. Defer until iOS roadmap reopens.
- **Promo video** — post-launch. Brand will draft a 30s storyboard once we have stable Sunny captures.
- **Tablet screenshots** — defer if launch window is tight. Tablet feature graphic is *not* required by Play.
- **Localized listings** — English-US only at v1.

## 6. Inputs from CTO (Sam Green)

Re-asking the RAI-49 §5 items here in case they slipped:

1. Canonical product name: **Pixel Life** (treating as confirmed unless overridden).
2. Launch target date — drives whether tablet screenshots / promo video stay deferred.
3. APK package ID — **`com.heynessie.pixellife`** (treating as confirmed unless overridden).

If Sam overrides any of these, the only assets that need re-bake are the wordmark, splash, and feature graphic — the icon is name-agnostic.

## 7. Engineering handoff

**Theo Lin (Capacitor / Android):**
- Run the `pwa-assets-generator` against `pixel_life_icon.svg` (already wired in `pwa-assets.config.ts` for the PWA path) and a separate manual export for Android `mipmap-*` densities per §2.
- Drop the `android_res/` XML files into `android/app/src/main/res/mipmap-anydpi-v26/`.
- Apply the splash config in §3.
- File a child issue back to Brand if any of the bakes don't match the master by visual inspection (look for soft slab edges or muddy coral — both are nearest-neighbor failures).

**Jules Marek (UI snapshots) — once a stable build exists:**
- Capture the 5 screens listed in §4 against a seeded dataset.
- Hand PNGs back to Brand for framing into `pixel_life_screenshot_frame.svg`.

**Mara Voss (web build) — already covered by RAI-49 §3.2 / §3.3:**
- Strings + theme-color meta tags.

## 8. Acceptance — Mika's sign-off checklist

Before this pack is shipped to Play Console submission:

- [ ] All ✅ rows in §1 reviewed against the masters at 100% zoom.
- [ ] All 🛠 rows have PNGs produced; nearest-neighbor confirmed by spot-checking a coral pixel at 200%.
- [ ] All 📷 rows have framed PNGs slotted into the template; captions match §4.
- [ ] Short + long descriptions reviewed by Phoebe (CEO) for tone.
- [ ] Sam confirms package ID + launch date.
- [ ] No "Personal Life" string or `#0f172a` color anywhere in the built APK manifest (regression guard from RAI-49).

---

*Single source of truth for RAI-50. Update statuses in §1 as items move from 🛠 / 📷 to ✅.*
