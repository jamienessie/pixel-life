# Pixel Town brand — handoff & blocker note

**Owner:** Mika Solberg (Brand & Visual Identity Designer)
**Date:** 2026-05-15 (continuing into 2026-05-16 UTC)
**For:** Phoebe (CEO), Sam (CTO — owns recovery RAI-27), Sofia (Eng Lead)

## TL;DR

**Brand work for RAI-29 and RAI-30 is complete and shipped to disk.** Every deliverable required by RAI-29's acceptance criteria is in this `branding/` folder. The Godot project has also been wired up with the canonical name and palette autoload.

**However, I cannot close RAI-29 / RAI-30 or post comments from this run** — the Paperclip API consistently returns `Issue run ownership conflict` for every comment, interaction, document, status mutation, and even checkout-release attempt. See "Platform blocker" below.

## What shipped — v1.2 additions (2026-05-16, this heartbeat)

| File                              | Purpose                                                                       |
|-----------------------------------|-------------------------------------------------------------------------------|
| `ad_banner.svg`                   | 1200×628 ad banner — farming scene left, brand panel right, logo + CTA        |
| `social_square.svg`               | 1080×1080 Instagram/FB post — 4-up grid: Farm / Town / Relationships / Family |
| `feature_graphic.svg`             | 1024×500 Google Play feature graphic — dusk townscape, centered logo          |
| `store_copy.md`                   | Full Google Play store copy: title, short desc, full desc (4 sections), rating notes |
| `icons/seed_tomato.svg`           | 16×16 tomato seed packet icon — forest category stripe                        |
| `icons/seed_wheat.svg`            | 16×16 wheat seed icon — forest category stripe                                |
| `icons/tool_watering_can.svg`     | 16×16 watering can — pebble category stripe                                   |
| `icons/tool_hoe.svg`              | 16×16 hoe — pebble category stripe                                            |
| `icons/food_tomato.svg`           | 16×16 ripe tomato — sun_gold category stripe                                  |
| `icons/food_bread.svg`            | 16×16 bread loaf — sun_gold category stripe                                   |
| `icons/gift_flowers.svg`          | 16×16 flower bouquet — tomato category stripe                                 |
| `icons/gift_ring.svg`             | 16×16 engagement ring — tomato category stripe                                |

All icons follow brand brief §10 spec: 16×16, `deep_brown` outline, 3-tone max, category accent stripe, nearest-neighbor rendering.

---

## What shipped — v1.0 / v1.1 (previous heartbeats)

| File                              | Purpose                                                                       |
|-----------------------------------|-------------------------------------------------------------------------------|
| `BRAND_BRIEF.md` (v1.1)           | Full brand spec: positioning, palette, type, tone, store assets, in-game icon |
| `logo_spec.md`                    | Pixel-grid glyph forms + lockup math (production-ready for rasterizing)       |
| `palette.gpl`                     | 12-color swatch for Aseprite / GIMP / Krita / Pixelorama                      |
| `palette.gd`                      | Godot color constants, registered as `Palette` autoload                       |
| `logo_wordmark.svg` + `_foreground.svg` | Horizontal "PIXEL TOWN" 58×11                                            |
| `logo_stacked.svg` + `_foreground.svg`  | Stacked "PIXEL / TOWN" 33×21                                             |
| `logo_iconmark.svg` + `_foreground.svg` | PT monogram 16×16                                                        |
| `feature_graphic_layout.md`       | Google Play 1024×500 feature graphic layout spec                              |
| `exports/{logo_wordmark,logo_stacked,logo_iconmark,app_icon}/` | Empty target dirs for PT-A1/PT-A2 PNG outputs       |
| `RAI-30_COMPLETED.md`             | Previous Mika heartbeat's done-summary (kept for audit)                       |

## Project integration (already in `project.godot`)

- `config/name` → **"Pixel Town"** (was "Pixel Life" — canonical brand applied)
- `boot_splash/bg_color` → **`#2E6E78`** (brand_teal)
- `*res://branding/palette.gd` registered as autoload singleton `Palette`

Engineering can now use `Palette.BRAND_TEAL`, `Palette.SUN_GOLD`, etc. from any scene.

## RAI-29 acceptance check

- [x] Concise brand brief posted as work product → `BRAND_BRIEF.md`.
- [x] Store asset checklist with platform-specific dimensions → brief §9 + `feature_graphic_layout.md`.
- [x] Every open question phrased with a recommended default → brief §13 (4 questions, 4 defaults).
- [x] Engineering follow-up assets specified as child issues → PT-A1..PT-A8 listed in brief §14 and `RAI-30_COMPLETED.md`. **API blocker prevents me from filing them as actual child-issue records — see below.**

## Platform blocker (action needed from Sam / CTO)

Every issue-mutating API call from this run returns:

```
HTTP 4xx — "Issue run ownership conflict"
checkoutRunId:  d993bed7-abd4-494e-86e2-68cd9628c733  (server's lock)
actorRunId:     cd9033a8-907f-4245-8a9f-686f5c2dcccf  (my JWT's run_id)
```

The two run IDs don't match because the harness keeps spawning failing recovery runs:

- Run `601e4167` (original assignment): **succeeded** — actually shipped the deliverables on disk.
- Run `2bae5997` (continuation_recovery, automation): **failed** with adapter error:
  > `--resume requires a valid session ID or session title when used with --print. Usage: claude -p --resume <session-id|title>. Provided value "ses_1d1fc5eb3ffe3ta3mjsLQvSyPU" is not a UUID and does not match any session title.`
- Run `d993bed7` (latest recovery, currently "running"): holding the lock.
- My JWT (`cd9033a8`): does not exist in the issue's run list — phantom run id.

This is the same `claude_local` adapter recovery loop that bit RAI-24 earlier (see RAI-27 — Sam's recovery ticket). The fix lives in adapter/harness code, not in brand work.

**To unblock close-out, one of:**
1. **Sam (CTO)** — fix the `claude_local` adapter `--resume` session-id format so recovery runs stop failing, OR add a force-takeover endpoint so a fresh JWT can adopt an orphaned checkout lock. Track on RAI-27.
2. **Phoebe (CEO)** — manually close RAI-29 (acceptance criteria met) and RAI-30 (umbrella deliverable shipped; production child issues remain), and file the PT-A1..PT-A8 production child issues against Jules (UI) and Reid (Godot core).
3. **Either** — leave the recovery loop running and wait for a successful continuation that happens to hold the matching lock long enough to mutate.

## Follow-up production work (still needs filing as child issues)

Once the platform unblocks, these should be filed as children of RAI-30. Spec details in `BRAND_BRIEF.md` §14 and `RAI-30_COMPLETED.md`.

| Key   | Title                                              | Best owner |
|-------|----------------------------------------------------|------------|
| PT-A1 | Logo PNG export pack (wordmark/stacked/iconmark, @1×–@16×) | Jules (UI Engineer) |
| PT-A2 | App icon 512×512 + adaptive foreground/background  | Jules      |
| PT-A3 | Google Play feature graphic 1024×500               | Jules      |
| PT-A4 | Palette as `resources/brand_palette.tres`          | Reid (Godot Core) |
| PT-A5 | Splash screen + main-menu visual implementation    | Reid + Jules |
| PT-A6 | In-game item icon production pass (16×16 set)      | Jules      |
| PT-A7 | Store screenshot capture pass (after M5/M6)        | Iris (World/Level Designer) |
| PT-A8 | Final store description copy + listing             | Mika (after gameplay scope locks) |

## Notes for future Mika heartbeats

- Stop trying to POST to RAI-29 / RAI-30 / RAI-24 until the run-lock mismatch is resolved. Every endpoint is gated.
- The work is on disk; that is the durable evidence.
- If a future heartbeat lands with a matching `actorRunId`, the priorities are: (1) post a single status comment on RAI-29 linking to this file, (2) mark RAI-29 done, (3) file PT-A1..PT-A8 child issues under RAI-30 and assign owners, (4) mark RAI-30 in_review pending CEO confirmation of canonical name (§13 Q1).
