# Pixel Life — Google Play Store listing copy

**Owner:** Mika Solberg
**Status:** v1 draft. Pending tone review by Phoebe (CEO) and a legal pass on the data-handling sentence before submission.
**Replaces:** `branding/store_copy.md` (legacy Pixel Town life-sim copy — superseded by the RAI-47 pivot).

---

## App title (30 char max)

```
Pixel Life
```

_(10 chars)_

## Short description (80 char max)

```
A calm home screen for your real life — weather, plans, todos, places, books.
```

_(78 chars)_

### Alternates if 78c is too tight after final font check

- `Your day at a glance — weather, plans, todos, countdowns, places, books.` _(72c)_
- `A quiet daily home for what's coming up, what's done, and where you've been.` _(76c)_

## Long description (≤4000 chars)

```
Pixel Life is a quiet home for everything you keep track of.

Open the app and your day is at the top — today's weather with a five-model forecast and a confidence score, what is coming up on the calendar, what is due, and the countdowns you pinned. No dashboards that need decoding. Big numbers. Plain words.

What is inside

· Today — weather, events, todos due today, pinned countdowns, all on one screen.
· Weather — fourteen days out, with five forecast models combined into one answer, a confidence chip, an interesting-fact card, and the option to drill into any single model.
· Calendar — a month grid with countdown markers on the days that have one. Tap a day to see what is planned.
· Countdowns — live tickers in days, hours, minutes, seconds. Pin the ones you want on the home screen.
· Todos — type "buy milk tomorrow at 6pm" and the natural-language parser handles the date. Mark them done with one tap.
· Places and map — drop pins on a real map. Categorise them — restaurant, trailhead, friend's place — and long-press anywhere on the map to add a new one.
· Library — track the books you read, leave a short note, see your stats.
· Budget, News, Holidays, TV, Wishlist — small focused tools that follow the same calm visual rules.

The visual language

Cream paper background. Ink-black text. Heavy display type for the things that matter, monospace for the rest. One coral accent for the things that need to stand out. Hard square corners and hard slab shadows. It is opinionated on purpose, so the app is easy to read at a glance in any light.

No tricks

· No ads.
· No engagement timers.
· No streaks designed to pull you back.
· Your todos, notes, places and books are yours. Export them whenever you want.

Built for one screen

Pixel Life is built for an Android phone you actually look at — a place to land before the rest of your day starts, and a place to come back to when you want to know what is next.
```

_Character count: ~1,950. Well inside the 4,000 budget._

## Feature graphic alt text (accessibility)

```
A cream-paper rectangle with the words PIXEL LIFE in heavy ink-black display type, followed by a single coral pixel as a period. Beneath the wordmark: the tagline "Your day, at a glance" in monospaced caps, and a horizontal strip of ten small coloured tiles in the app's category palette (coral, tangerine, saffron, jade, teal, sky, indigo, violet, pink, slate).
```

## Categories and tags

- **Primary category:** Productivity
- **Secondary category:** Lifestyle
- **Tags:** dashboard, planner, calendar, weather, todos, countdowns, places, reading, budget, daily home

## Content rating notes (for submission)

- Violence: None
- Sexual content: None
- Scary content: None
- Language: None
- In-app purchases: None (v1)
- User-generated content: Yes — users author todos, notes, places, book entries. No public sharing surface in v1.
- Data collection: User-supplied content syncs via Supabase under the user's account. Weather forecasts and map tiles are fetched from third-party services (per `SETUP.md` in the Mobile App repo). Confirm with legal before submission whether a Data Safety form disclosure beyond "account info" + "app activity" is required.

## Submission checklist

- [x] Confirm `Pixel Life` is the final name with CTO (RAI-49 §5.1 ask still open). **CONFIRMED by Sam Green (CTO), 2026-05-17.**
- [x] Confirm `com.heynessie.pixellife` as `applicationId` with CTO. **CONFIRMED by Sam Green (CTO), 2026-05-17.** `capacitor.config.json` and `android/app/build.gradle` updated accordingly.
- [ ] Final tone read from Phoebe.
- [ ] Legal pass on the data-collection sentence above.
- [ ] Replace placeholder screenshots with real captures per `RAI-50_ASSET_PACK.md` §4.
- [ ] Feature graphic PNG baked from `pixel_life_feature_graphic.svg`.

### CTO launch date note (Sam Green)

**Recommending ship phone-only screenshots, add tablet captures post-launch.** I don't have a confirmed launch date pinned. If it's >2 weeks out, tablet captures can be folded in; if tighter, we ship phone-only. Safest path: phone-only for v1 submission, tablet as a v1.1 enhancement.

---

*Sunny tone discipline (Mika's note to self): no superlatives, no "amazing/best/seamless/intuitive", concrete over abstract, plain words over jargon. If a sentence could appear in a competitor's listing, rewrite it.*
