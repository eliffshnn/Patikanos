# Test Plan

This plan describes what we test in Patikanos, who takes part, and how we run and record each test. It covers the Flutter app and the FastAPI backend. Dates are given as sprint weeks; fill in the calendar dates from the project board.

## 1. What we test

| Level | Scope | Tool | When |
|---|---|---|---|
| Unit | Weather scoring, best window, clothing tips | `pytest` (`backend/tests/`) | Every backend change |
| API | `/weather/score` with a mocked Open-Meteo (done); `/routes` and `/users/{id}/favorites` (to do, need a test database) | `pytest` + FastAPI `TestClient` | Every backend change |
| Widget | Bottom navigation, route list (16 routes), adding a favorite | `flutter test` (`test/widget_test.dart`) | Every app change |
| Manual device check | All screens on one iOS and one Android device | Simulator / emulator | Before each milestone demo |
| Usability | Can new users complete the main tasks without help? | Moderated sessions (section 3) | After M3, again after fixes |

Every pull request must pass `flutter analyze`, `flutter test` and `pytest` before it is merged.

## 2. Manual device check

Run this list on an iOS simulator and an Android emulator before each demo, with the backend running (`docker compose up`).

| # | Check | Expected |
|---|---|---|
| D0 | First launch (or after Çıkış yap) | Onboarding opens; Atla jumps to the last page; Keşfetmeye başla creates the account and opens Bugün with the user's name |
| D1 | Open the app again | Bugün tab opens directly, no layout errors or overflow stripes |
| D2 | Switch through all four tabs | Each tab opens; going back keeps the scroll position and filters |
| D3 | Bugün → choose Yürüyüş → Devam | Weather screen shows a walking score, tips and the best time |
| D4 | Bugün → İkisi de → Devam | Weather screen shows both cycling and walking sections |
| D5 | Stop the backend, open the weather screen | "Hava durumu alınamadı" with a working "Tekrar dene" button |
| D6 | Keşfet → search "Fethiye" | Only Fethiye routes are listed |
| D7 | Keşfet → Bisiklet + Kolay filters | Only easy cycling routes are listed; "Tümü" clears both |
| D8 | Open a route → Hava durumuna bak | Weather for the route's start point, with the region name in the title |
| D9 | ♥ a route, open Favoriler | The route is listed with the total distance |
| D10 | Weather screen → 🔔 | A test notification appears after about 5 seconds |
| D11 | Large text (Settings → Accessibility → Larger Text) | Text wraps, nothing is cut off |

## 3. Usability test

### Participants

5 participants. Nielsen's guideline is that five users find most usability problems in a round.

- At least 3 who walk or cycle regularly in Muğla (e.g. university outdoor or cycling clubs)
- At least 2 who have never seen the app or our designs
- Not members of the project team

### Roles

| Role | Task |
|---|---|
| Moderator | Reads the tasks, does not help or hint |
| Note taker | Records time, errors, and quotes in the results sheet |

Team members take turns in each role; one person should not run every session.

### Method

- 20–25 minute sessions, in person, on a phone with the app installed and the backend running
- Think-aloud: participants say what they are looking for and what they expect to happen
- The moderator reads each task from the card below, then stays silent
- A task fails if the participant gives up or needs more than 3 minutes
- After the tasks, the participant fills in the 10-question System Usability Scale (SUS) and answers two open questions: "What was most confusing?" and "What would make you use this app?"
- Ask for consent before taking notes; do not record names in the results sheet (use P1–P5)

### Tasks

Read to participants in Turkish.

| # | Task (as read to the participant) | Success when | Screens covered |
|---|---|---|---|
| T1 | "Bugün bisiklete binmek istiyorsun. Uygulamaya göre şu an çıkmak için iyi bir zaman mı?" | States the current cycling score or label | Bugün → Weather |
| T2 | "Bugün yürüyüşe çıkmak için en uygun saat aralığı hangisi?" | Reads the best time window for walking | Bugün → Weather |
| T3 | "Fethiye'de kolay bir yürüyüş rotası bul." | Opens a route that is in Fethiye and marked Kolay | Keşfet, filters, search |
| T4 | "Bu rotayı daha sonra bulabilmek için kaydet." | Route appears in Favoriler | Route detail / card ♥ |
| T5 | "Kaydettiğin rotanın başlangıç noktasında hava nasıl olacak, öğren." | Opens the weather screen from the route detail | Favoriler → Route detail → Weather |
| T6 | "Öğleden sonra 3'te rüzgâr ne kadar güçlü olacak?" | Reads the 15:00 wind value from the hourly detail | Weather → Hourly detail |
| T7 | "Yanına ne alman gerektiğine dair uygulamanın önerisi var mı?" | Finds the "Bunları unutma" card | Weather |

### Metrics

| Metric | Target |
|---|---|
| Task success rate | ≥ 80% for each task |
| Time on task | T1–T2 under 60 s, T3–T7 under 2 min |
| Errors | Count wrong taps or dead ends per task |
| SUS score | ≥ 68 (industry average) |

### Results and follow-up

1. Record each session in a shared sheet: participant, task, success (yes/partly/no), time, errors, notes.
2. After all five sessions, list each problem with how many participants hit it and a severity: 3 = blocks the task, 2 = slows the user down, 1 = cosmetic.
3. Open a GitHub issue for every problem with severity 2 or 3, labelled `usability`.
4. Fix the severity 3 issues, then repeat T1–T7 with 3 new participants.

## 4. Reporting bugs

Open a GitHub issue with:

- **Steps:** what you tapped, in order
- **Expected / actual:** what should have happened and what happened
- **Device:** simulator or phone model, iOS/Android version
- **Screenshot** if the problem is visible

## 5. Schedule

| Week | Activity |
|---|---|
| M3 week | Automated tests green on `main`; manual device check (section 2) |
| M3 + 1 | Recruit participants; dry run with one team member's friend |
| M3 + 2 | Five usability sessions; results sheet |
| M3 + 3 | Fix severity 3 issues; second round with 3 participants |
| Final | Summary of findings and changes in the final report |
