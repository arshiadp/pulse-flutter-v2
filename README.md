# Pulse · BMI & movement, version 2

A modern Flutter health and movement tracking application focused on helping users understand their body measurements, create realistic activity goals, and track personal progress over time.

A Flutter upgrade of the original BMI Calculator project:
https://github.com/arshiadp/Bmi_calculator

Pulse introduces a complete redesign with a modern ink/mint/lavender visual system, guided measurement onboarding, local progress journaling, responsive layouts, and a privacy-focused local storage approach.

![Desktop overview with illustrative test data](docs/previews/05-desktop-demo.png)

---

# App Preview

## Guided Measurement Setup

Pulse provides a simple step-by-step onboarding flow where users enter their measurements and create a personalized weekly movement routine.

The onboarding includes:

- Height selection
- Weight input
- Automatic BMI calculation
- Weekly activity planning

<p align="center">
  <img src="docs/previews/01-height.png" width="260"/>
  <img src="docs/previews/02-weight.png" width="260"/>
  <img src="docs/previews/03-plan.png" width="260"/>
</p>


## Health Dashboard

The main overview screen provides a complete summary of the user's current health information:

- Current measurements
- BMI result and category
- Weekly movement target
- Quick check-in actions
- Personalized overview


<p align="center">
  <img src="docs/previews/04-overview.png" width="900"/>
</p>


## Desktop Experience

Pulse includes a responsive desktop layout with navigation rail, adaptive content sections, and a two-column dashboard experience.


<p align="center">
  <img src="docs/previews/05-desktop-demo.png" width="900"/>
</p>


---

# Run

Validated with:

**Flutter 3.47.5 / Dart 3.13.4**

Use the pinned stable version for reproducibility.

```sh
flutter pub get
flutter run
```

Browser:

```sh
flutter run -d chrome
```

Quality checks:

```sh
flutter analyze
flutter test
flutter build web --release
```

Android:

```sh
flutter build apk --debug
```

iOS:

```sh
flutter build ios --no-codesign
```

Android/iOS builds require the correct native environment, application identifiers, signing configuration, and platform setup before publishing.


---

# What Changed

- Three-step height, weight and weekly-plan flow inspired by the supplied reference.
- Ink background, slate cards, mint actions, lavender accents and bundled Roboto fonts.
- Metric and imperial units with fine sliders and validated typed entry.
- Adult BMI calculation with correct category boundaries.
- Category calculation uses the unrounded BMI value.
- Locally saved daily check-ins.
- Same-day updates instead of duplicated records.
- Weight history tracking.
- CSV export and data reset.
- Weekly activity planning with selectable days and minutes.
- Phone bottom navigation and desktop navigation rail.
- Responsive two-column overview layout.
- Loading, storage failure and corrupted data recovery states.
- CDC/WHO health context and references.
- GitHub Actions workflow for formatting, analysis, testing and web compilation.


Measurements are constrained to 100–230 cm and 30–250 kg as product input limits, not medical thresholds.

BMI is a screening measurement, not a diagnosis, and should not be used as a replacement for professional health assessment.


---

# Architecture

| Path | Responsibility |
| --- | --- |
| `lib/core` | Theme tokens and reusable component styles |
| `lib/features/health/domain` | Pure Dart models, calculations, units and repository contracts |
| `lib/features/health/data` | Versioned JSON storage through SharedPreferencesAsync |
| `lib/features/health/application` | Riverpod dependency injection, hydration and persistence commands |
| `lib/features/health/presentation` | Onboarding, overview, history, plan, insights and shared widgets |
| `test` | Domain boundaries, controller behavior and responsive interaction tests |
| `tool/render_previews.dart` | Reproducible screenshots of Flutter widgets |


The repository layer can be replaced without changing the UI.

Immutable state flows from AsyncNotifier to consumers.

Temporary form drafts, selected tabs and dialog states remain local to widgets.


---

# Storage and Privacy

Pulse does not use:

- User accounts
- Analytics tracking
- Backend services

All information is stored locally.

Storage key:

```
pulse.health.v1
```

SharedPreferences provides lightweight local storage and should not be considered a clinical database.

Clearing browser/site data removes web journal data.

Copy CSV exports before resetting application data.


---

# Research and Scope

See:

```
docs/RESEARCH.md
```

Deferred features:

- Backdated entry editing
- Custom training weekdays
- Reminders
- Encrypted storage
- RTL localization
- Wearable device integration
- Platform file sharing


---

# Verification

Completed:

- `flutter analyze` ✅
- `flutter test` ✅
- `flutter build web --release` ✅
- Responsive UI testing ✅
- Flutter widget screenshot generation ✅


Preview images can be regenerated:

```sh
flutter test tool/render_previews.dart
```


---

# Tech Stack

- Flutter
- Dart
- Riverpod 3
- SharedPreferencesAsync
- Material Design principles
- Responsive Flutter layouts
- Local JSON persistence


---

# Design System

Pulse uses a modern product-focused visual language:

- Dark premium interface
- Ink background
- Slate surfaces
- Mint primary actions
- Lavender highlights
- Rounded cards
- Clear typography hierarchy
- Minimal interaction design


---

# License

Font license:

```
assets/fonts/Roboto_LICENSE.txt
```
