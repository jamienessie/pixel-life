# Pixel Town — Brand Brief v1.0

**Owner:** Mika Solberg, Brand & Visual Identity Designer
**Date:** 2026-05-15
**Status:** v1.1 — SVGs committed, palette files in place, logo spec finalized. Ready for engineering child issues (PT-A1 through PT-A8). Open questions in §13 have recommended defaults.
**Related issues:** RAI-29 (this brief), RAI-30 (production umbrella), RAI-24 (parent — hiring).

---

## 1. Canonical brand name

**Pixel Town** is the canonical product name everywhere user-facing: store listing, in-game title screen, splash, social, marketing, press.

The local workspace folder is named `Pixel Life` — that is an internal path artifact only, kept to avoid churning paths in the Godot project. It is **not** a brand name and must not appear in user-facing assets.

> Open question 1 — see §13.

## 2. Positioning

**One-liner:** A cozy pixel-art life sim where you live, love, work, and pass it all on.

**Vibe:** warm, cozy, generational. Not edgy, not chaotic. Daylight palette. Gentle humor in NPC dialogue, never ironic distance, never fourth-wall breaks.

**Reference vocabulary:**
- *Stardew Valley* — cozy farm-sim warmth, 16×16 grid clarity.
- *Animal Crossing* — gentle pacing, character-first.
- *The Sims* — life arcs and family lineage, but at-a-glance pixel readability instead of HD figures.
- *GBA/SNES JRPG towns* — top-down, small but legible characters, hand-placed maps.

**What we are NOT:** survival, roguelite, action, dark/horror, ironic/postmodern, photo-real, isometric, 60fps action animation.

## 3. Logo direction

The wordmark is a chunky pixel display face at 7px cap height. **Not Press Start 2P** (reads too retro-arcade) — we want a softer, slightly rounded pixel form that aligns with the cozy life-sim positioning.

**Three lockup variants:**
- **Stacked:** "PIXEL" over "TOWN", center-aligned. Used for square slots (app icon background, splash screen).
- **Horizontal:** "PIXEL TOWN" on one line. Used for store header, feature graphic, in-game title screen, marketing banners.
- **Iconmark only:** 64×64 pixel "town silhouette" — three peaked rooflines with a single chimney and a flagpole. Used at tiny scales (favicon, social avatar, app drawer when wordmark is illegible).

**Color treatment:** warm cream foreground (#F8EDD4) on brand teal background (#2E6E78). 1px deep-brown (#3A2A1B) outline for legibility against busy in-game backdrops. Reverse (teal foreground on cream background) is allowed for light backgrounds and print.

**Rendering rules:**
- Author at 1× pixel size; scale only by integer multiples (2×, 3×, 4×, 6×, 8×, 12×, 16×).
- Never anti-alias. Filter mode = nearest neighbor everywhere.
- Never rotate, never skew, never apply drop shadow or glow. Pixel logos that lose their grid lose their identity.

**SVG sources:** see `branding/logo_wordmark.svg` (horizontal PIXEL TOWN, 58×11), `branding/logo_stacked.svg` (PIXEL / TOWN stacked, 33×21), and `branding/logo_iconmark.svg` (PT monogram + town silhouette, 64×64) in this folder. They are pixel-grid-accurate and rasterize cleanly to any integer scale. ✅ All committed as of v1.1.

## 4. App icon (Google Play)

**Concept:** the stacked "PT" monogram (P stacked on T, sharing a pixel column) sitting on a circular cobblestone "town square" patch, with two pixel-tree silhouettes flanking it. Cozy, instantly readable at 48dp.

**Deliverable spec:**
- **Standard icon:** 512×512 PNG, 32-bit RGBA. Subject occupies the inner 480×480 safe area; the outer 16px ring is brand-teal background only (so Google Play's adaptive masking does not crop the mark).
- **Adaptive icon (Android 8+):**
  - Foreground PNG, 432×432 subject inside 512×512 transparent canvas.
  - Background PNG, solid brand teal (#2E6E78), 512×512.
- **Maskable Web icon** (PWA, optional): 512×512 with at least 10% inner safe area.

**No text inside the icon.** "PT" monogram only. The full wordmark is not legible at app-drawer scale.

## 5. Color palette

12-color cozy pixel palette. All values are fixed and named. See `branding/palette.gpl` (GIMP/Aseprite/Krita) and `branding/palette.gd` (Godot constants).

| Token         | Hex     | Role                                                                       |
|---------------|---------|----------------------------------------------------------------------------|
| `brand_teal`  | #2E6E78 | Primary brand. Icon background, marketing chrome, splash backdrop.         |
| `brand_cream` | #F8EDD4 | Logo fill, text on dark, page background.                                  |
| `sun_gold`    | #F5C26B | Accent. Money UI, highlights, Energy need bar.                             |
| `tomato`      | #E07A5F | Warmth, hearts, relationship UI.                                           |
| `forest`      | #6A994E | Crops, grass, Social need bar.                                             |
| `sky`         | #A8DADC | UI panels, day-sky backdrop.                                               |
| `dusk_plum`   | #6D5A7E | Evening transitions, dialogue panel base.                                  |
| `deep_brown`  | #3A2A1B | Outlines, dark text.                                                       |
| `pebble`      | #B7AB98 | Stone, walls, dividers.                                                    |
| `bone`        | #EAE0CC | Light UI panel fill.                                                       |
| `cherry`      | #C84630 | Critical states (`need_critical`), danger.                                 |
| `mist`        | #DAD2BC | Disabled / muted text.                                                     |

**Usage rule:** every UI screen picks **≤ 5** of these 12. Do not introduce a 13th color without sign-off from Mika.

**Why these 12:** they blend cleanly with LimeZu Modern Interiors / Exteriors (the primary tileset locked in `PLAN.txt`) without introducing chromatic clashes. The teal/cream/gold trio carries the warmth that "cozy" demands; the cherry/forest/tomato accents give state and category cues; the dusk_plum/sky pair drives the day/night time-of-day overlay.

## 6. Typography

| Slot              | Font                       | Size       | Notes                                                                                       |
|-------------------|----------------------------|------------|---------------------------------------------------------------------------------------------|
| Display / title   | Custom Pixel Town wordmark | n/a        | Only in the wordmark, nowhere else.                                                         |
| Body UI           | `m5x7.ttf` (in repo)       | 7px native | Dialogue, menus, HUD numbers, button labels. Integer-scale only.                            |
| Tiny UI           | `m3x6.ttf` (in repo)       | 6px native | Inventory tooltip subtext, debug overlays. **Never use m3x6 for dialogue body.**            |
| Marketing / store | Inter or system sans       | n/a        | Store description fields use platform default (Google renders our copy in its own type).    |

Both `m3x6.ttf` and `m5x7.ttf` are already in `assets/fonts/` (Daniel Linssen pixel fonts, free for any use). **No new font procurement needed.**

- Letter spacing: 0.
- Line height: native + 1px for dialogue, native for HUD.
- Color: text always uses one of `brand_cream`, `deep_brown`, or `mist` from the palette — never an off-palette color.

## 7. Tone of voice

For store copy, marketing, and NPC dialogue:

- Warm, plainspoken, present-tense.
- NPC dialogue is gently funny — never cynical, never breaking the fourth wall, never meme-referential.
- Store copy avoids superlatives ("epic", "ultimate", "addictive", "endless"). Prefers concrete promises.

**Yes:** *"Plant tomatoes, marry the librarian, watch your great-grandkid inherit your fishing rod."*
**No:** *"The ULTIMATE cozy life sim experience — endless adventures await!"*

## 8. Visual style rules (game-wide, non-negotiable)

- **Pixel grid:** all sprites drawn at 16×16 multiples. No sub-pixel rendering. `Camera2D.snap_2d_transforms_to_pixel = true`.
- **Outlines:** characters and key interactables get a 1px `deep_brown` outline against the world. Decorative props (flowers, fences, small grass) do **not** get outlines — keeps the world from going visually noisy.
- **Lighting:** no per-pixel light shaders. Use 2–3 stepped time-of-day color overlays (day = neutral, dusk = `dusk_plum` 30% multiply, night = `dusk_plum` 50% multiply).
- **Animation:** 4-frame walk cycles, ~6 fps idle bounce. **No 60fps animation.** Readability over smoothness.
- **Particles:** chunky 2×2 pixel particles only. Disable Godot's default soft-edge particle texture.
- **Camera:** integer pixel snap on. No camera shake larger than ±2 pixels.

## 9. Google Play store assets — checklist

| Asset                       | Spec                                                                                                | Owner / Status                                       |
|-----------------------------|-----------------------------------------------------------------------------------------------------|------------------------------------------------------|
| App icon (standard)         | 512×512 PNG, 32-bit RGBA, subject in inner 480×480                                                  | Mika spec ✅ → engineering produces PNG (child issue) |
| App icon (adaptive)         | Foreground 432×432-in-512 transparent + background 512×512 solid teal                               | Mika spec ✅ → engineering produces PNGs              |
| Feature graphic             | 1024×500 PNG, no text in outer 100px gutters, no transparency                                       | Mika layout in `feature_graphic_layout.md`           |
| Phone screenshots           | 1920×1080 landscape (game is 16:9 native). 5 shots, framing rules in §9.1                           | Mika framing rules ✅ → engineering captures           |
| Tablet screenshots          | 2048×1536. Optional for v1                                                                          | Defer to launch+1                                    |
| Promo video                 | YouTube link, 30–120s                                                                               | Defer to post-launch                                 |
| Short description           | ≤ 80 chars                                                                                          | Draft below ✅                                        |
| Full description            | ≤ 4000 chars                                                                                        | Draft frame below ✅; final copy in follow-up issue   |
| Title                       | 30 chars max — "Pixel Town" (10 chars, safe)                                                        | ✅                                                    |

### 9.1 Screenshot framing rules (5 shots, in order)

1. **Town square at midday.** Player visible center, 2–3 NPCs in motion. Sells the world.
2. **Farm with crops at multiple growth stages** + player watering. Sells the gameplay loop.
3. **Dialogue with a romanceable NPC**, hearts UI visible at top. Sells the relationship hook.
4. **HUD-clean wide shot at dusk** (`dusk_plum` overlay). Sells the pretty time-of-day system.
5. **Family tree / relationship menu** open showing 2 generations. Sells the unique generational twist.

**Mandatory:** every screenshot includes the in-game HUD. Never use "no-UI" beauty shots — they mislead players about the actual viewing experience. **No marketing text overlays** on screenshots in v1; let the game speak. Revisit only if conversion data demands it.

### 9.2 Short description (draft, 78 chars)

> Cozy pixel life sim. Plant, work, fall in love, raise kids, pass it on.

### 9.3 Full description (frame; final copy in follow-up issue)

Three short paragraphs of ≤120 words each:

1. **The cozy promise** — town, neighbors, seasons, a quiet life.
2. **What you actually do** — jobs (Service / Skilled / Self-employed / Creative), dating and marriage, raising kids, the four zones (Town / Farm / Forest / Beach).
3. **The generational twist** — you age, you die, your adult child picks up the save and keeps going. No other cozy sim does this.

Followed by 6–8 feature bullets, then a one-line tagline matching §9.2.

## 10. In-game icon style guide (for UI / gameplay engineering)

**For Jules (UI Engineer) and any agent producing in-game item, crop, or UI icons.**

- **Canvas:** all in-game icons authored at **16×16 native**, displayed at integer scale only.
- **Outline:** 1px `deep_brown` (#3A2A1B) on transparent background. Icons sit on UI panels that vary by screen, so outlines are required for legibility.
- **Shading:** 3-tone maximum (highlight, mid, shadow). No gradients. Dithering allowed only for crops, water, and metallic items.
- **Silhouette test:** the icon must be readable as a solid black blob at 16×16. If not, redesign the silhouette before applying color.
- **Category color cue** (optional 2-pixel accent stripe, bottom-left corner):
  - Seeds → `forest`
  - Food → `sun_gold`
  - Tools → `pebble`
  - Relationship gifts → `tomato`
  - Quest items → `dusk_plum`
- **File naming:** `assets/sprites/items/{category}/{snake_case_id}.png`. Filename must equal `ItemData.id`.
- **Godot import settings:** Filter = Nearest, Mipmaps = Disabled, Fix Alpha Border = On.
- **No emoji, no Unicode glyphs as placeholder icons.** If an icon is missing, ship the white-square missing-asset sprite from `assets/ui/_missing.png` (engineering: please create one) so QA can flag it.

## 11. Posters / ads / key art direction (RAI-30)

All marketing visuals composed from **in-engine pixel art**, not commissioned HD illustration. Cohesion over polish.

| Format          | Dimensions    | Layout                                                                                                |
|-----------------|---------------|-------------------------------------------------------------------------------------------------------|
| Poster (mobile) | 1080×1920     | Stacked logo top 25%, hero composition center (player + NPC partner at sunset), cream banner tagline bottom 15%. `dusk_plum` 30% overlay for atmosphere. |
| Ad banner       | 1200×628      | Horizontal logo right-aligned, gameplay vignette left (cropped farming or cooking shot), brand-teal panel separator. |
| Square social   | 1080×1080     | Iconmark top-center, 4-up gameplay grid below.                                                        |
| Vertical story  | 1080×1920     | Animated 3-shot loop (town → farm → family tree) with stacked logo persistent top-left.               |

**Hero shot composition rules:**
- Always include at least one character with visible face direction (eyes toward the action or toward camera, never blank stare).
- Always include the town silhouette or a recognizable zone landmark in the background.
- Always include a time-of-day cue (sun position or dusk overlay) — never neutral lighting.

## 12. Naming, file hygiene, license tracking

- All brand assets live in `branding/`. The brief is `BRAND_BRIEF.md`, the palette is `palette.gpl` / `palette.gd`, logo sources are `logo_*.svg`.
- All production PNGs land in `branding/exports/{asset_name}/{size}.png`. Keep sources (`.svg`, `.aseprite`) next to exports.
- Track every third-party font/sprite license in `assets/LICENSES.md` (already exists). m3x6 and m5x7 already covered.
- Logo and brand palette are original to Pixel Town — no third-party license obligations.

## 13. Open questions (each with a recommended default)

1. **Canonical name confirmation.** *Recommended default:* ship as **"Pixel Town"**. It matches the project name in Paperclip and the board's most recent usage on RAI-24. The workspace folder stays as `Pixel Life` (internal path artifact). → **CEO/board to confirm or correct.**
2. **Logo wordmark execution path.** *Recommended default:* I author the wordmark as a hand-crafted pixel SVG inside this repo (sources committed alongside the brief). No external designer commission. → **Default assumed yes** unless board says otherwise; SVG sources will be in this folder.
3. **Target market & launch order.** *Recommended default:* cozy-sim audience on **Android first** (Google Play primary), Steam later, iOS / Switch deferred. Tone, copy, and screenshot specs assume that. → **Confirm if iOS or Switch is in scope for v1.**
4. **Steam-specific assets (capsule images, library hero).** *Recommended default:* defer all Steam-specific art until Steam ship date is set. Mention in launch-readiness checklist later. → No action needed now.

## 14. Follow-up work (engineering child issues — to be filed)

These are the concrete production deliverables this brief unlocks. Each will be created as a child of RAI-30 with the brief as evidence:

- **PT-A1.** Logo PNG export pack (wordmark + iconmark + stacked, at @1x/@2x/@4x/@8x).
- **PT-A2.** App icon 512×512 + adaptive foreground/background PNG.
- **PT-A3.** Google Play feature graphic 1024×500 PNG.
- **PT-A4.** Brand palette imported as `resources/brand_palette.tres` + autoloaded `Palette` singleton with named color constants.
- **PT-A5.** Splash screen + main-menu visual implementation (uses `brand_teal` background, stacked logo, version string in `m5x7`).
- **PT-A6.** In-game item icon production pass (16×16 set for seeds/tools/food/gifts) following §10.
- **PT-A7.** Store screenshot capture pass — runs after M5/M6 milestones land (needs farming and sleep to be playable). Blocked until then.
- **PT-A8.** Store description + listing copy final-pass (after gameplay scope is locked).

---

*End of brief. Questions / pushback: comment on RAI-29 or DM Mika.*
