# GRS LIFE

**General Resolution Source** — *Your Life. Your Rules. Your Resolution.*

A premium, offline-first personal management app for Android built with Flutter.

## Overview

GRS LIFE combines daily planning, personal finance, learning tracking, goal
management, a personal journal, and productivity statistics in one dark,
luxury-fintech-styled application. All data is stored locally (SQLite +
SharedPreferences) and the app works with **no internet connection** — the
Android manifest does not even declare the `INTERNET` permission.

## Features

| Section | Capabilities |
| --- | --- |
| **Home** | Time-based greeting, live date, daily progress ring, today's tasks, financial overview, learning progress, active goals |
| **Planner** | Task CRUD, 6 categories, 3 priorities, deadlines, month calendar with task dots, in-app reminders, overdue detection |
| **Finance** | Income/expense entries, categories, monthly budget with over-budget warning, financial goals with progress, donut + bar charts, UZS currency |
| **Learning** | 6 courses (Python, English, Russian, Cybersecurity, AI, Cyber Diplomacy) × 8 bilingual lessons each, study timer (stopwatch), manual time entry, per-course and overall progress |
| **Profile** | Personal goals with progress slider, journal with moods, statistics dashboard (7-day completion chart, savings rate, course minutes), language switch (UZ/RU), PIN security, JSON backup & restore |

- **Languages:** Uzbek Latin (default) and Russian — 217 translation keys per
  language, switchable in Settings, applied instantly app-wide.
- **Design:** dark mode only, exact palette (`#0B0B0D`, `#151518`, `#1D1D21`,
  rose gold `#B76E79`, copper `#B87333`, text `#F5F3F0`/`#929096`),
  glassmorphism, gradient accents, custom-painted ring/donut/bar charts.
- **Security:** optional 4–6 digit PIN lock on app start.
- **Backup:** full export/import of all 8 database tables to a JSON file in
  the app documents directory.

## Tech Stack

- Flutter (Dart 3), Material 3, dark theme only
- `sqflite` — local SQLite database (`grs_life.db`, 8 tables)
- `shared_preferences` — settings, locale, PIN
- `provider` — 6 `ChangeNotifier` providers (settings, tasks, finance,
  learning, goals, journal), all loaded before `runApp`
- `flutter_localizations` — uz/ru locales; hand-rolled `AppLocalizations`
  (no codegen, no `intl` dependency in pubspec)
- Custom money/date formatting (space-grouped UZS, uz/ru month names)

No network packages, no `google_fonts`, no external APIs.

## Project Structure

```
lib/
├── main.dart                  # provider setup, await load(), runApp
├── app.dart                   # MaterialApp, theme, locale wiring
├── core/
│   ├── theme/app_theme.dart   # AppColors + ThemeData
│   ├── widgets/ui_kit.dart    # GlassCard, GradientButton, PressableScale, ...
│   ├── widgets/charts.dart    # RingProgress, DonutChart, BarChart (CustomPainter)
│   ├── l10n/app_localizations.dart  # 217 keys × uz/ru
│   ├── database/database_helper.dart # schema, exportAll, restore
│   ├── constants/app_constants.dart  # categories, priorities, moods
│   ├── constants/learning_content.dart # 6 courses × 8 bilingual lessons
│   └── utils/formatters.dart  # money/date/time formatting
├── models/models.dart         # Task, MoneyEntry, Budget, FinancialGoal,
│                              # StudySession, PersonalGoal, JournalEntry
├── providers/                 # 6 ChangeNotifiers (loaded in main)
└── ui/
    ├── root_shell.dart        # PIN gate + custom floating bottom nav
    ├── lock_screen.dart
    ├── screens/               # home, planner, finance, learning, profile,
    │                          # course_detail, goals, journal, statistics,
    │                          # settings, security, backup
    └── widgets/               # task_form_sheet, tx_form_sheet, task_tile
```

## Building the APK

This source was authored in an environment without the Flutter SDK, so it has
not been compiled here. To build it on a machine with Flutter installed:

```bash
# 1. Get dependencies
flutter pub get

# 2. Regenerate binary platform assets (gradle wrapper jar, launcher icons)
#    This does NOT overwrite existing source files.
flutter create --platforms=android --org com.grslife --project-name grs_life .

# 3. Run on a device/emulator
flutter run

# 4. Or build a release APK
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

Requirements: Flutter SDK ≥ 3.16 (Dart ≥ 3.2), Android SDK 34, Java 17.

## Tests

`test/models_test.dart` (model roundtrips, money/date formatting, l10n
fallbacks) and `test/widgets_test.dart` (design-system widgets) run with:

```bash
flutter test
```

## Data & Privacy

- Everything is stored on-device: `grs_life.db` (SQLite) + SharedPreferences.
- No analytics, no tracking, no network access of any kind.
- Backups are plain JSON files you create and keep yourself.
