# RAI-49 — Pixel Life mobile-first brand audit

**Owner:** Mika Solberg, Brand & Visual Identity Designer
**Date:** 2026-05-16
**Status:** Audit complete. Validation-grade assets shipped in `branding/pixel_life/`. Store-listing assets deferred to follow-up.
**Parent:** RAI-47 (Pivot to Mobile APK Android)

---

## TL;DR (for Phoebe / Sam)

The Pixel Life web build (the PWA at `Desktop/Mobile App/`) already has its own design system — "Sunny": cream paper, ink black, coral accent, Archivo Black + Geist Mono. **It survives mobile-scale for in-app UI.** It does **not** survive as a Play Store identity, because:

1. The app icon SVG in `public/icons/icon.svg` is **off-brand** (a leftover purple-gradient mountain/sun illustration that predates the Sunny redesign). It will read fine at 512×512 but it has nothing to do with the Sunny visual language inside the app, so users will be confused at first launch.
2. The app is still named **"Personal Life"** in `<title>`, `apple-mobile-web-app-title`, and the PWA manifest. Reno will see the wrong name on home-screen tomorrow if nothing changes.
3. The `theme-color` meta tags are dark slate (#0f172a) — leftover from a previous dark theme. Sunny is light cream, so the Android status-bar tint will look broken.
4. No adaptive icon foreground/background pair exists for Android 8+.
5. No Play Store feature graphic (1024×500), no Play Store phone screenshots.

For **tomorrow's 9am Reno validation** (internal, not a store submission), items 1–4 matter. Item 5 does not. I have spec'd 1–4 below; full store assets are filed as a follow-up.

---

## 1. Does Pixel Life already have a brand?

**Yes — "Sunny".** Source of truth: `Desktop/Mobile App/src/index.css`.

| Token         | Value                | Role                                                    |
|---------------|----------------------|---------------------------------------------------------|
| Paper (bg)    | `#fff8e6`            | Page / app background. Warm cream.                      |
| Ink           | `#111111`            | Body text, borders (3px solid), hard slab shadows.      |
| Ink soft      | `#3a3328`            | Muted text.                                             |
| Accent coral  | `#ff5d7a`            | Hero accent. Links, danger states.                      |
| Tile rainbow  | coral, tangerine, saffron, jade, teal, sky, indigo, violet, pink, slate | Category cues on tiles, countdowns. |
| Display font  | Archivo Black        | h1/h2/h3, hero numbers.                                 |
| Body font     | Geist Mono           | Everything else, including UI numerics.                 |
| Radius        | `0` (hard square)    | No rounded corners anywhere.                            |
| Shadow        | `3px 3px 0 #111`     | Hard black slab; settles to `2px 2px 0` on press.       |

This is a cohesive identity. It is **not thin**. It's coherent, opinionated, and reads well at mobile widths because the type stack is monospace + a very heavy display face designed for chunky readability.

The brand name change "Personal Life" → "Pixel Life" is non-disruptive to the design system — Sunny's chunky-monospace + slab-shadow aesthetic is already "pixel-adjacent". We are renaming, not redesigning.

## 2. Does it survive at mobile sizes?

| Scale                                | Verdict     | Note                                                                            |
|--------------------------------------|-------------|---------------------------------------------------------------------------------|
| In-app UI (375–430dp phone width)    | ✅ Pass      | Sunny was built for this. Type scale (hero 140 / display 56 / h1 44) is tuned.  |
| App icon 192×192 (PWA install)       | ⚠ Fail (off-brand icon, not legibility) | Existing SVG draws sun + mountains; nothing about Sunny.        |
| App icon 48dp (Android drawer)       | ⚠ Fail (same)                            | Detail of mountains/sun lost; reads as "generic weather app".   |
| Adaptive icon (Android 8+)           | ❌ Missing                                | No foreground/background pair authored.                          |
| Splash screen at phone height        | ⚠ Risk      | Apple splash PNGs exist but were generated against the old icon.                |
| Play Store feature graphic 1024×500  | ❌ Missing                                | Not authored.                                                    |
| Play Store screenshots               | ❌ Missing                                | Captures not framed; UI not pixel-snapped for store presentation.|

**Bottom line:** The in-app brand holds up. The packaging around it (icon, name, theme color, store assets) does not.

## 3. What ships tonight for 9am Reno validation

These are the **minimum** changes required for the APK to install with the right name and a coherent first impression. None of these block the build — they are file swaps and string changes.

### 3.1 New app icon (DONE — in `branding/pixel_life/`)

I have authored a new on-brand Pixel Life icon. Files committed to `branding/pixel_life/`:

- `pixel_life_icon.svg` — 512×512 master. Cream background, chunky ink-black "PL" monogram on a 6×6 pixel grid, single coral pixel as accent, 3px ink border (matches Sunny slab convention). Subject occupies inner 384×384 safe area so adaptive masking does not crop.
- `pixel_life_icon_foreground.svg` — 512×512 transparent canvas with the "PL" monogram only (no background, no border). For Android adaptive icon foreground layer.
- `pixel_life_icon_background.svg` — 512×512 solid cream (#fff8e6) field. For Android adaptive icon background layer.
- `pixel_life_wordmark.svg` — horizontal "PIXEL LIFE" wordmark in Archivo Black weight, ink-on-cream. For splash and any in-app branding moment.

**Why these designs work for Sunny + Pixel Life:**
- 6×6 pixel grid construction nods to "Pixel" without going retro-arcade.
- Cream + ink + coral is the same triad already inside the app — first launch will not feel like a different app.
- Hard square geometry (no radii) matches Sunny's slab style.
- Reads at 48dp because there are only two letters and one accent pixel.

**Engineering action:** Theo / Mara — convert these SVGs to the PNG variants the Capacitor Android project consumes (`/android/app/src/main/res/mipmap-*` densities + adaptive XML). Build assets in `branding/pixel_life/exports/` keyed by density.

### 3.2 App name / title strings (BLOCK for engineering)

Strings that must change before APK build:

| File                                                | Current                | Should be       |
|-----------------------------------------------------|------------------------|-----------------|
| `Desktop/Mobile App/index.html` `<title>`           | `Personal Life`        | `Pixel Life`    |
| `Desktop/Mobile App/index.html` apple-mobile-web-app-title | `Life`           | `Pixel Life`    |
| `Desktop/Mobile App/public/manifest.webmanifest` `name` | (TBC by Theo)      | `Pixel Life`    |
| `Desktop/Mobile App/public/manifest.webmanifest` `short_name` | (TBC by Theo) | `Pixel Life`    |
| Capacitor `capacitor.config.ts` `appName`           | (TBC by Theo)          | `Pixel Life`    |
| Android `AndroidManifest.xml` `android:label`       | (TBC by Theo)          | `Pixel Life`    |
| Android `strings.xml` `app_name`                    | (TBC by Theo)          | `Pixel Life`    |

Owner: Theo Lin (Capacitor scaffold). Mara Voss (web build strings).

### 3.3 Theme-color meta tags

Replace in `Desktop/Mobile App/index.html`:

```html
<meta name="theme-color" content="#0f172a" media="(prefers-color-scheme: dark)" />
<meta name="theme-color" content="#f8fafc" media="(prefers-color-scheme: light)" />
```

with the Sunny brand values:

```html
<meta name="theme-color" content="#fff8e6" />
<meta name="apple-mobile-web-app-status-bar-style" content="default" />
```

Sunny is light-only — drop the dark-scheme media query. The Android status bar will pick up the cream paper color and stop looking broken.

Also update the SVG mask-icon color from `#0f172a` to `#111111` to match ink.

### 3.4 Splash screen (acceptable to defer 1 day)

Existing Apple splash PNGs in `Desktop/Mobile App/public/splash/` were generated against the old purple-gradient icon. They will look off-brand if shown.

**For Reno tomorrow:** acceptable if Theo configures Capacitor to show a solid cream (#fff8e6) splash with no logo. Better than a wrong-brand splash. I will produce the proper splash (cream paper, centered Pixel Life wordmark in ink, coral pixel accent) as part of the follow-up issue.

## 4. What is explicitly NOT in scope tonight

All filed under follow-up issue (see §6):

- Play Store feature graphic 1024×500
- Play Store phone screenshots (5×)
- Tablet screenshots
- Full store listing copy (short + long description)
- Promo video
- Final splash screens at all densities
- Apple icon variants (we are Android-first per RAI-47)

These are real work, but none are needed for **internal Reno validation** of an APK install + launch + first interaction.

## 5. Coordination with CTO (Sam Green)

Asks for Sam:

1. **Confirm** the rename to "Pixel Life" is final and not subject to another pivot. The brief in RAI-29 said canonical name was "Pixel Town". RAI-47 + this issue confirm the new direction is "Pixel Life". Treat this as confirmed unless Sam or Phoebe says otherwise.
2. **Launch timing** — when do we need the full Play Store asset pack? Confirming a target date so I can sequence the follow-up issue (and pull in Jules if we want any in-game vignette captures for screenshots).
3. **APK package ID** — for Theo's `applicationId` / Capacitor `appId`. Suggesting `com.heynessie.pixellife`. Sam to confirm or override.

I will post these on the RAI-49 thread and ping Sam directly.

## 6. Follow-up issue

Filing **RAI-49-followup** as a child of RAI-47 covering:

- App icon PNG export pack at all Android densities (mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi) + 512×512 Play Store listing PNG
- Adaptive icon XML + density PNGs for foreground/background
- Splash screen design (all densities)
- Play Store feature graphic 1024×500
- Play Store screenshots (5×, framed)
- Store listing short description ≤80c + long description ≤4000c
- Apple icon set (if iOS becomes in-scope)

Owner: Mika. Blockers: confirmation of name + package ID from Sam.

---

*Audit complete. Files committed to `branding/pixel_life/`. Next action: comment on RAI-49 thread with summary + tag Sam.*
