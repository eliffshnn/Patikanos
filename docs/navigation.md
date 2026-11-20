# Navigation Structure

This document shows which screens Patikanos has and how the user moves between them. It reflects the code after the onboarding, map fixes and design-system changes; screens that are planned but not built yet are drawn with dashed borders.

## Tabs

On first launch the app opens on `OnboardingScreen` (`lib/screens/onboarding_screen.dart`, three pages). After that it opens on `HomeScreen` (`lib/screens/home_screen.dart`), which holds a bottom navigation bar with five tabs. Tabs keep their state when you switch between them (`IndexedStack`).

| Tab | Screen | File | Purpose |
|---|---|---|---|
| Bugün | `TodayScreen` | `lib/screens/today_screen.dart` | Pick an activity, see today's best time, featured routes |
| Keşfet | `ExploreScreen` | `lib/screens/explore_screen.dart` | Search and filter all routes |
| Harita | `MapScreen` | `lib/screens/map_screen.dart` | Start points of all routes on an OpenStreetMap map |
| Favoriler | `FavoritesScreen` | `lib/screens/favorites_screen.dart` | Routes the user marked with ♥ |
| Profil | `ProfileScreen` | `lib/screens/profile_screen.dart` | User info, preferences, settings |

## Flow diagram

```mermaid
flowchart TD
    Start([App start]) -- "first launch" --> Onboarding
    Start -- "session saved" --> Home

    subgraph Onboarding["OnboardingScreen · 3 pages"]
        direction LR
        O1["Intro"] -- "Başlayalım" --> O2["Smart timing"] -- "Devam" --> O3["Activity, name, e-mail"]
        O1 -. "Atla" .-> O3
    end
    O3 -- "Keşfetmeye başla<br/>(POST /users)" --> Home

    subgraph Home["HomeScreen · bottom navigation"]
        direction LR
        Today["Bugün<br/>TodayScreen"]
        Explore["Keşfet<br/>ExploreScreen"]
        Map["Harita<br/>MapScreen"]
        Favs["Favoriler<br/>FavoritesScreen"]
        Profile["Profil<br/>ProfileScreen"]
    end

    Today -- "Devam<br/>(bike / walk / both)" --> Weather["WeatherScreen<br/>score, tips, best time"]
    Today -- "Tümünü gör" --> Explore
    Today -- "featured route card" --> RouteDetail

    Explore -- "route card" --> RouteDetail["RouteDetailScreen<br/>stats, start point"]
    Favs -- "route card" --> RouteDetail
    Favs -- "empty state:<br/>Rotaları keşfet" --> Explore

    RouteDetail -- "Hava durumuna bak<br/>(route start point)" --> Weather
    Weather -- "Saatlik skor card" --> Hourly["DetailScreen<br/>hourly breakdown"]

    Notif(["Local notification<br/>hourly + 21:00"]) -. "opens app" .-> Home

    Map -- "tap a marker" --> PinSheet["Bottom sheet<br/>stats, ♥"]
    Map -- "tap a cluster" --> Map
    PinSheet -- "Rota detayını aç" --> RouteDetail
    Profile -- "Çıkış yap" --> Onboarding
    Favs -. "Geçmiş" .-> History["Activity history"]:::planned

    classDef planned stroke-dasharray: 5 5,color:#888
```

## Screenshots

Taken on an iPhone 17 Pro Max simulator with the backend running. To refresh them after a UI change, start the backend (`docker compose up`) and run:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart -d <device>
# shrink for the repo (macOS): PNG -> JPEG
cd docs/screenshots && for f in *.png; do sips -Z 1434 -s format jpeg -s formatOptions 78 "$f" --out "${f%.png}.jpg" && rm "$f"; done
```

| Onboarding 1 | Onboarding 2 | Onboarding 3 |
|---|---|---|
| ![Onboarding 1](screenshots/01_onboarding_1.jpg) | ![Onboarding 2](screenshots/02_onboarding_2.jpg) | ![Onboarding 3](screenshots/03_onboarding_3.jpg) |

| Bugün | Weather (both) | Hourly detail | Keşfet |
|---|---|---|---|
| ![Bugün](screenshots/04_bugun.jpg) | ![Weather](screenshots/05_hava_durumu.jpg) | ![Hourly detail](screenshots/06_saatlik_detay.jpg) | ![Keşfet](screenshots/07_kesfet.jpg) |

| Route detail | Harita | Favoriler | Profil |
|---|---|---|---|
| ![Route detail](screenshots/08_rota_detayi.jpg) | ![Harita](screenshots/09_harita.jpg) | ![Favoriler](screenshots/10_favoriler.jpg) | ![Profil](screenshots/11_profil.jpg) |

## Actions that do not navigate

| Where | Action | Effect |
|---|---|---|
| Route card, route detail | ♥ button | Adds/removes the route from Favoriler (in memory, see `lib/data/favorites.dart`) |
| Keşfet | Search box, filter chips | Filters the list in place |
| Route detail | Start point tile | Copies coordinates to the clipboard |
| Weather screen | 🔔 button | Sends a test notification after 5 seconds |
| Profil | Settings rows | Not implemented yet (placeholder) |

## Planned screens

| Screen | Owner | Status |
|---|---|---|
| Route lines on the map | Esma Gül Baş | `geometry` is still empty in the route data; only start points are shown |
| Activity history (Geçmiş) | UI/UX | Removed from Favoriler in PR #44 until there is data to show |
| Sign-in | Backend + UI/UX | Needed before favorites and preferences can sync to `/users/{id}/...` |
