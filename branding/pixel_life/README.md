# branding/pixel_life/

Validation-grade brand assets for the Pixel Life Android APK launch (RAI-49).

## Files

| File                                | Purpose                                                              |
|-------------------------------------|----------------------------------------------------------------------|
| `pixel_life_icon.svg`               | 512×512 master app icon. Square, no baked corner radius.             |
| `pixel_life_icon_foreground.svg`    | Android adaptive icon foreground layer (transparent bg, mark only).  |
| `pixel_life_icon_background.svg`    | Android adaptive icon background layer (solid cream #fff8e6).        |
| `pixel_life_wordmark.svg`           | Horizontal "PIXEL LIFE" wordmark. For splash + in-app branding.      |
| `exports/`                          | Engineering-produced PNGs land here (icon densities, etc.).          |

## Brand tokens (from Sunny — Mobile App `src/index.css`)

| Token        | Hex      | Use in icon                                        |
|--------------|----------|----------------------------------------------------|
| Paper        | #fff8e6  | Icon background, wordmark background.              |
| Ink          | #111111  | Monogram pixels, wordmark text, slab border.       |
| Accent coral | #ff5d7a  | Single accent pixel (icon), period dot (wordmark). |

## Engineering: how to produce PNG variants

The Mobile App project already uses `@vite-pwa/assets-generator`. Update `pwa-assets.config.ts` to point at `branding/pixel_life/pixel_life_icon.svg` and regenerate. Output goes to `public/icons/`.

For Capacitor Android adaptive icons, run a manual export at:

| Density | Foreground PNG | Background PNG | Standard icon PNG |
|---------|----------------|----------------|-------------------|
| mdpi    | 108×108        | 108×108        | 48×48             |
| hdpi    | 162×162        | 162×162        | 72×72             |
| xhdpi   | 216×216        | 216×216        | 96×96             |
| xxhdpi  | 324×324        | 324×324        | 144×144           |
| xxxhdpi | 432×432        | 432×432        | 192×192           |
| Play Store hi-res | —    | —              | 512×512           |

All exports preserve nearest-neighbor scaling (icons are pixel-grid art).

## Adaptive icon XML (drop into `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`)

```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
```

## Engineering changes outside this folder

See `branding/RAI-49_MOBILE_BRAND_AUDIT.md` §3.2 and §3.3 for the title-string and theme-color meta-tag changes Theo / Mara need to land before APK build.
