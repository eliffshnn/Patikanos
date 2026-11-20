# Navigation Structure

This document shows which screens Patikanos has and how the user moves between them. It reflects the code on `main` after PR #44 and #45; screens that are planned but not built yet are drawn with dashed borders.

## Tabs

The app opens on `HomeScreen` (`lib/screens/home_screen.dart`), which holds a bottom navigation bar with five tabs. Tabs keep their state when you switch between them (`IndexedStack`).

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
    Start([App start]) --> Home

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

    Onboarding["Onboarding"]:::planned -. "first launch" .-> Home
    Map -- "tap a marker" --> PinSheet["Bottom sheet<br/>name, region, distance"]
    PinSheet -. "open route detail" .-> RouteDetail
    Favs -. "Geçmiş" .-> History["Activity history"]:::planned

    classDef planned stroke-dasharray: 5 5,color:#888
```

## Screenshots

Taken on an iPhone 17 Pro Max simulator with the backend running. To refresh them after a UI change, start the backend (`docker compose up`) and run:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshots_test.dart -d <device>
```

| Bugün | Weather (both) | Hourly detail | Keşfet |
|---|---|---|---|
| ![Bugün](screenshots/01_bugun.png) | ![Weather](screenshots/02_hava_durumu.png) | ![Hourly detail](screenshots/03_saatlik_detay.png) | ![Keşfet](screenshots/04_kesfet.png) |

| Route detail | Favoriler | Profil | Harita |
|---|---|---|---|
| ![Route detail](screenshots/05_rota_detayi.png) | ![Favoriler](screenshots/06_favoriler.png) | ![Profil](screenshots/07_profil.png) | ![Harita](screenshots/08_harita.png) |

## Actions that do not navigate

| Where | Action | Effect |
|---|---|---|
| Route card, route detail | ♥ button | Adds/removes the route from Favoriler (in memory, see `lib/data/favorites.dart`) |
| Keşfet | Search box, filter chips | Filters the list in place |
| Route detail | Start point tile | Copies coordinates to the clipboard |
| Weather screen | 🔔 button | Sends a test notification after 5 seconds |
| Profil | Settings rows, Çıkış yap | Not implemented yet (placeholder) |

## Planned screens

| Screen | Owner | Status |
|---|---|---|
| Map → route detail | Esma Gül Baş | The marker sheet does not open `RouteDetailScreen` yet; route lines (`geometry`) are still empty |
| Onboarding (first launch) | UI/UX | Not started; the activity picker on Bugün covers the choice for now |
| Activity history (Geçmiş) | UI/UX | Removed from Favoriler in PR #44 until there is data to show |
| Sign-in | Backend + UI/UX | Needed before favorites and preferences can sync to `/users/{id}/...` |
