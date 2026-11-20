# Design System

All colors, text styles and shadows in Patikanos are defined once in `lib/theme/app_theme.dart`. Screens pick from these tokens instead of writing their own values, so every screen looks the same.

`test/design_system_test.dart` enforces this: it fails if any file outside `lib/theme/` contains a color code (`Color(0x…)`), a Material color (`Colors.red`), a `fontSize` or a `fontFamily`, and prints the line and what to use instead.

## How to use

```dart
Text('Rotalar', style: AppText.screenTitle)                       // as is
Text('Fethiye', style: AppText.label.copyWith(color: AppColors.sea)) // only change the color
Container(color: AppColors.tint(AppColors.sunset))                // light background of any color
Container(decoration: BoxDecoration(boxShadow: AppShadows.raised))
```

`Theme.of(context).textTheme` returns the same styles (for example `textTheme.headlineLarge` is `AppText.screenTitle`), so existing code that uses the theme keeps working.

## Colors

Inspired by Muğla: pine forests, the Aegean, sand and sunset.

| Token | Value | Used for |
|---|---|---|
| `pine` | `#1F5E4B` | Primary: buttons, selected states, walking routes |
| `pineDark` | `#143F33` | Gradients, text on light buttons |
| `sea` | `#1F7A8C` | Secondary: links, region names, cycling routes |
| `seaLight` | `#D7ECEF` | Icon backgrounds, nav indicator |
| `seaBright` | `#3FA7B5` | Cycling thumbnail gradient |
| `sunset` | `#E8833A` | Accent: favorites, warnings, map clusters |
| `sunsetLight` | `#F6C79A` | Sun illustration, focused input on photos |
| `sand` | `#F6F1E7` | Page background, light pill buttons |
| `sandDark` | `#EDE5D5` | Progress track, disabled buttons |
| `surface` | `#FCF9F3` | Cards, nav bar (warm paper tone instead of pure white) |
| `ink` | `#1C2A27` | Main text |
| `muted` | `#6B7A75` | Secondary text, icons |
| `line` | `#E4DDD0` | Card borders, dividers |
| `good` / `fair` / `okay` / `bad` | `#2E9E6A` / `#8DB64A` / `#E8A53A` / `#D9534F` | Weather scores and difficulty |

On photos and dark gradients:

| Token | Value | Used for |
|---|---|---|
| `onDark` | white | Text and icons |
| `onDarkMuted` / `onDarkSubtle` | white 78% / 60% | Secondary text, hints |
| `onDarkGood` / `onDarkBad` | `#BFE3C9` / `#FFC9C2` | Status and error text |
| `glass` / `glassBorder` | white 12% / 22% | Frosted fields, chips, borders |
| `glassDark`, `photoSheet` | pine 36% / 16% | Frosted cards and sheets on photos |
| `heroGradient` | pineDark → pine → sea | Hero cards, route detail header |
| `photoScrim`, `photoScrimTop` | pine gradients | Keep text readable on onboarding photos |

`AppColors.tint(color)` gives the 12% background of any color (icon boxes, badges, warning cards).

## Typography

Headings use **Fraunces** (serif), everything else **Manrope**. Both are bundled in `assets/fonts/` (SIL Open Font License) and work offline.

| Token | Font | Size / weight | Used for | Theme name |
|---|---|---|---|---|
| `score` | Fraunces | 44 / 500 | Weather score numbers | `displaySmall` |
| `screenTitle` | Fraunces | 32 / 500 | Tab titles ("Rotalar", "Favoriler") | `headlineLarge` |
| `hero` | Fraunces | 28 / 500 | Hero cards, route name on detail | `headlineMedium` |
| `title` | Fraunces | 24 / 500 | App name, score label, best time, onboarding titles | `headlineSmall` |
| `section` | Fraunces | 20 / 500 | Section headers, app bar titles | `titleLarge` |
| `cardTitle` | Manrope | 16 / 700 | Card and list titles, stat values | `titleMedium` |
| `body` | Manrope | 15 / 500 | Body text, form input | `bodyLarge` |
| `bodyMuted` | Manrope | 14 / 500 | Descriptions | `bodyMedium` |
| `caption` | Manrope | 12 / 500 | Metadata, nav labels, chart labels | `bodySmall` |
| `button` | Manrope | 16 / 700 | Buttons | `labelLarge` |
| `label` | Manrope | 13 / 600 | Chips, tags, region names | `labelMedium` |
| `eyebrow` | Manrope | 11 / 700, letter-spaced | Small caps headers, badges | `labelSmall` |

An italic word inside a Fraunces heading is the one decorative accent ("Bugün hangi rota, *hangi saatte?*").

## Photos and maps

`AppImages` holds the three onboarding photos. They are mood images only (Bugün header, weather score card, "Ne zaman gitmeli?" card) because none of them shows a specific route. Wherever a specific route is shown (route cards, route detail header) the app shows the real OpenStreetMap map of its start point (`RouteMapPreview` in `lib/widgets/nature.dart`).

Shared building blocks in `lib/widgets/nature.dart`: `PillButton` (the arrow pill button from onboarding, used for every primary action), `PhotoHeader`, `GlassPill` and `RouteMapPreview`.

## Shadows

| Token | Used for |
|---|---|
| `AppShadows.soft` | Bottom navigation bar |
| `AppShadows.raised` | Map markers, floating cards |

Cards on the light background use a 1 px `line` border instead of a shadow.
