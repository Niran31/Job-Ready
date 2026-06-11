# JobReady 🔥
> Your personal accountability + job hunt tracker app.
> Built with Flutter · Dart · GetX · Hive

---

## What's inside

| Screen | What it does |
|--------|-------------|
| 🏠 Dashboard | Daily habits, streak counter, motivation banner, active jobs preview |
| 💼 Jobs | Add applications, update status (applied → interview → offer/rejected), pipeline view |
| ⚡ Skills | Log study sessions by skill, weekly bar chart, all-time hours tracker |
| 📊 Stats | Grind Score, 30-day habit heatmap, job funnel, streak leaderboard |
| ⚙️ Settings | Lazy mode alarm (buzzes if you haven't logged by your set time), name config |

---

## Setup on AegonX

### 1. Install Flutter
```bash
# Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
# Add flutter/bin to your PATH
flutter doctor   # fix any issues shown
```

### 2. Install Android Studio
- Download from https://developer.android.com/studio
- Install Android SDK + emulator via SDK Manager
- OR just connect your Android phone via USB (enable Developer Mode + USB debugging)

### 3. Clone and run this project
```bash
# Copy this folder to your machine, then:
cd jobready
flutter pub get
flutter run
```

### 4. Build APK to install on your phone
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
# Transfer to phone and install
```

---

## Project structure

```
lib/
├── main.dart                  ← App entry + navigation
├── theme/
│   └── app_theme.dart         ← Colors, typography, dark theme
├── models/
│   ├── habit_model.dart       ← HabitModel + JobModel + SkillLogModel
│   └── habit_model.g.dart     ← Hive adapters (auto-generated)
├── controllers/
│   └── habit_controller.dart  ← GetX controller (all state + logic)
├── screens/
│   ├── dashboard_screen.dart  ← Home tab
│   ├── jobs_screen.dart       ← Jobs tab
│   ├── skills_screen.dart     ← Skills tab
│   ├── stats_screen.dart      ← Stats tab
│   └── settings_screen.dart   ← Settings tab
├── widgets/
│   ├── stat_card.dart         ← Stat card widget
│   ├── habit_tile.dart        ← Swipeable habit row
│   └── section_header.dart    ← Section title + action
└── services/
    └── notification_service.dart ← Daily lazy-mode alarm
```

---

## Phase 2 plan (add after MVP)
- [ ] Firebase sync (access from multiple devices)
- [ ] Weekly review screen (Sunday planning)
- [ ] GitHub commit auto-tracker
- [ ] Claude API daily tip based on your progress

## Phase 3 plan
- [ ] Resume vs JD gap analyzer (Claude API)
- [ ] Daily random DSA/interview question
- [ ] Velzyn Labs branding polish + Play Store submission

---

Built by Niran × Velzyn Labs 🚀
