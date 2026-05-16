## Pixel Town brand palette — v1.0
## Source of truth: branding/BRAND_BRIEF.md §5.
## Engineering: register this as `Palette` autoload in Project Settings,
## then reference colors as `Palette.BRAND_TEAL`, `Palette.SUN_GOLD`, etc.
extends Node

const BRAND_TEAL  := Color8(0x2E, 0x6E, 0x78)
const BRAND_CREAM := Color8(0xF8, 0xED, 0xD4)
const SUN_GOLD    := Color8(0xF5, 0xC2, 0x6B)
const TOMATO      := Color8(0xE0, 0x7A, 0x5F)
const FOREST      := Color8(0x6A, 0x99, 0x4E)
const SKY         := Color8(0xA8, 0xDA, 0xDC)
const DUSK_PLUM   := Color8(0x6D, 0x5A, 0x7E)
const DEEP_BROWN  := Color8(0x3A, 0x2A, 0x1B)
const PEBBLE      := Color8(0xB7, 0xAB, 0x98)
const BONE        := Color8(0xEA, 0xE0, 0xCC)
const CHERRY      := Color8(0xC8, 0x46, 0x30)
const MIST        := Color8(0xDA, 0xD2, 0xBC)

## Role aliases — use these in UI code instead of raw colors so a future
## brand re-skin only touches this file.
const UI_PANEL_FILL       := BONE
const UI_PANEL_BORDER     := DEEP_BROWN
const UI_TEXT_PRIMARY     := DEEP_BROWN
const UI_TEXT_ON_DARK     := BRAND_CREAM
const UI_TEXT_MUTED       := MIST
const HUD_MONEY           := SUN_GOLD
const HUD_NEED_ENERGY     := SUN_GOLD
const HUD_NEED_SOCIAL     := FOREST
const HUD_NEED_FUN        := SKY
const HUD_NEED_HUNGER     := TOMATO
const HUD_NEED_HYGIENE    := DUSK_PLUM
const STATE_CRITICAL      := CHERRY
const TIME_OF_DAY_DUSK    := DUSK_PLUM
const TIME_OF_DAY_NIGHT   := DUSK_PLUM ## Sample at higher overlay alpha; see §8.

## Convenience: full ordered list for swatch UI / debug panels.
static func all_colors() -> Array[Color]:
	return [BRAND_TEAL, BRAND_CREAM, SUN_GOLD, TOMATO, FOREST, SKY,
			DUSK_PLUM, DEEP_BROWN, PEBBLE, BONE, CHERRY, MIST]
