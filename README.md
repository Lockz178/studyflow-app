# StudyFlow

StudyFlow is a Flutter mobile app for planning coursework, tracking deadlines,
and following daily study progress. The app domain is student productivity for
mobile coursework: users can review upcoming deadlines, create day-by-day study
plans, track progress, save favourite plans, browse study tips, and adjust app
settings.

**Author:** Phan Ngoc Phuoc Loc  
**Repository:** [github.com/Lockz178/studyflow-app](https://github.com/Lockz178/studyflow-app.git)

## Requirements Checklist

| Requirement | How it is met |
|-------------|----------------|
| Drawer or tab bar on first screen | Drawer on the dashboard |
| First screen contains a scrollable list | Dashboard uses a `ListView` |
| Data from API or database populated with JSON asset | SQLite database is seeded from `assets/data/studyflow_seed_data.json` |
| Images from assets or URL | About screen uses `Image.asset`; tips list uses `Image.network` with icon fallback |
| Custom list tiles with text and image/icon | `StudyPlanCard` and `StudyTipListTile` |
| Detail screen | `PlanDetailPage` at `/plan/:id` |
| Validated input with validator outside widget | Study plan and feedback validators in `lib/validators/` |
| Light/dark theme switching | Settings screen supports device, light, and dark modes |
| State management | `provider` powers settings, study flow, favourites, and premium preview state |
| Layered architecture | Models, services, providers, screens, widgets, router, theme, and validators are separated |
| Loading, error, and empty states | Dashboard seed loading/error/retry, empty plan states, paginated tips loading/end states |
| Named routes or routing package | `go_router` route table in `lib/router/app_router.dart` |
| Tests in `test/` | Model, validator, service, provider, and widget tests |
| Settings stored in shared prefs | Theme, notifications, favourite IDs, and user-created plans are persisted |
| Design effort | Material 3 themes, icons, cards, progress bars, calendar, and screenshots |
| Infinite scrolling bonus | Tips library loads tips in small pages while scrolling |
| Comprehensive widget tests bonus | Widget tests cover dashboard, tips, help, settings, about, and planner screens |

## Flutter Version

Use a current stable Flutter SDK that satisfies the Dart SDK constraint in
`pubspec.yaml`:

```yaml
environment:
  sdk: ^3.11.4
```

Check your installed version:

```bash
flutter --version
```

## Setup And Run

Clone the repository, install dependencies, and run the app on an Android or iOS
emulator:

```bash
git clone https://github.com/Lockz178/studyflow-app.git
cd studyflow-app
flutter pub get
flutter run
```

Run static analysis and tests:

```bash
flutter analyze
flutter test
```

## Main Packages

| Package | Why it is used |
|---------|----------------|
| `provider` | App-wide state management for settings, study data, favourites, and premium preview state |
| `go_router` | Declarative named routing for dashboard, planner, details, settings, about, tips, and help screens |
| `shared_preferences` | Persistent settings, notification preference, favourite plan IDs, and created study plans |
| `sqflite` | Local database populated from the bundled JSON seed file |
| `path` | Portable database path construction |
| `url_launcher` | Opens feedback email links and the project repository externally |

## Screenshots

| Dashboard | Study Planner | Plan Detail |
|---|---|---|
| ![Dashboard](assets/images/dashboard_dark.png) | ![Planner](assets/images/planner.png) | ![Detail](assets/images/plan_detail.png) |

The screenshots were captured from the running Flutter app and are included in
the repository under `assets/images/`.

## Project Layout

- `lib/models/` - domain models such as study plans, plan items, events, and templates
- `lib/services/` - database seeding, mock data access, settings, and favourites storage
- `lib/providers/` - app state and orchestration with `ChangeNotifier`
- `lib/screens/` - full app screens
- `lib/widgets/` - reusable UI components
- `lib/router/` - `go_router` route configuration
- `lib/theme/` - light and dark Material themes
- `lib/validators/` - form validation helpers
- `test/` - unit, provider/service, validator, and widget tests
