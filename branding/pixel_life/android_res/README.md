# android_res/

Drop-in Android resource files for the Pixel Life launcher icon. Mirrors the layout under
`android/app/src/main/res/` in the Capacitor project — copy these into place and run the
raster export per `RAI-50_ASSET_PACK.md` §2.

## File map

| Source here                                          | Destination in Capacitor project                                |
|------------------------------------------------------|-----------------------------------------------------------------|
| `mipmap-anydpi-v26/ic_launcher.xml`                  | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`    |
| `mipmap-anydpi-v26/ic_launcher_round.xml`            | `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml` |
| `values/ic_launcher_background.xml`                  | `android/app/src/main/res/values/ic_launcher_background.xml`    |
| `exports/adaptive_fg_*.png` (produced from SVG)      | `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`  |
| `exports/icon_*.png` (produced from SVG)             | `android/app/src/main/res/mipmap-*/ic_launcher.png` and `ic_launcher_round.png` |

## Why a `<color>` for the background

Android's adaptive-icon spec allows either a drawable or a color reference. We use a color
(`#fff8e6`, the Sunny paper token) instead of a 5-density PNG bake because:

- One source of truth — if the cream token ever shifts, only this one file changes.
- Saves five PNGs from the APK.
- Pixel-grid art lives only in the foreground layer; the background is a flat fill, so PNG
  buys nothing.

If engineering prefers PNG backgrounds (e.g. for tooling consistency), point the `<background>`
element at `@mipmap/ic_launcher_background` instead and bake the PNGs from
`pixel_life_icon_background.svg`.

## `ic_launcher_round` notes

We point round and square at the same adaptive-icon definition because the OS handles the
mask. The visible silhouette difference between square and round is the system's
responsibility, not ours.

## Legacy (pre-Android-8) launcher

For devices on API < 26 the OS uses `mipmap-*/ic_launcher.png` directly without the adaptive
mask. Those PNGs are baked from `pixel_life_icon.svg` (the version with the slab border) so
the silhouette still reads as "Pixel Life" on Android 7 and earlier — not "PL floating in
nothing".
