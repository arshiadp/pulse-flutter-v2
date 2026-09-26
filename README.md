# Pulse · BMI & Movement Tracker (Flutter)

A modern Flutter health and fitness tracking application focused on helping users understand their body metrics, create realistic movement goals, and track personal progress over time.

Pulse is a complete redesign and upgrade of the original BMI Calculator project:
https://github.com/arshiadp/Bmi_calculator

The application uses a modern dark interface with an ink/mint/lavender visual system, guided measurement onboarding, personalized weekly planning, and a local health progress journal.

<p align="center">
  <img src="docs/previews/05-desktop-demo.png" width="900"/>
</p>

## App Preview

### Guided Health Setup

The application provides a simple onboarding experience where users enter their measurements and create a personalized activity routine.

<p align="center">
  <img src="docs/previews/01-height.png" width="260"/>
  <img src="docs/previews/02-weight.png" width="260"/>
  <img src="docs/previews/03-plan.png" width="260"/>
</p>

---

### Health Dashboard

The overview dashboard gives users a complete picture of their current health information:

- BMI calculation and category
- Current measurements
- Weekly activity target
- Quick check-in actions
- Personalized health overview

<p align="center">
  <img src="docs/previews/05-desktop-demo.png" width="900"/>
</p>

---

### Progress Tracking

Users can save daily measurements and review their journey through a local progress journal.

Features:

- Weight history tracking
- Measurement timeline
- Check-in management
- CSV export
- Individual record deletion
- Complete data reset

<p align="center">
  <img src="docs/previews/06-progress.png" width="900"/>
</p>

---

### Health Insights

The application provides educational information about BMI, including its limitations and proper interpretation.

The goal is to help users understand their measurements instead of focusing only on numbers.

<p align="center">
  <img src="docs/previews/07-insights.png" width="900"/>
</p>


# Run

Validated with:

**Flutter 3.47.5 / Dart 3.13.4**

Use the pinned stable version for reproducible results.

```bash
flutter pub get
flutter run
```

Run on browser:

```bash
flutter run -d chrome
```

Quality checks:

```bash
flutter analyze
flutter test
flutter build web --release
```

Android:

```bash
flutter build apk --debug
```

iOS:

```bash
flutter build ios --no-codesign
```

Android and iOS builds require their own platform environments, SDK configuration, application identifiers, and signing setup before production deployment.


# Main Features

## Personal Health Measurements

- Height and weight tracking
- Metric and imperial unit support
- BMI calculation
- Validated user input
- Interactive sliders and typed values


## Progress Journal

- Local daily check-ins
- Automatic same-day updates
- Historical records
- Weight trend visualization
- CSV data export


## Weekly Activity Planner

Users can create realistic movement goals:

- Active days per week
- Minutes per session
- Week starting day selection
- Suggested weekly schedule


## Responsive Experience

The application supports different layouts:

- Mobile bottom navigation
- Desktop navigation rail
- Two-column dashboard layout
- Responsive Flutter widgets


## Privacy Focused

Pulse does not require:

- User accounts
- Analytics tracking
- Backend services

All information is stored locally on the user's device.

Storage:

```
pulse.health.v1
```

Shared Preferences is used for lightweight local persistence.


# Architecture

| Path | Responsibility |
| --- | --- |
| `lib/core` | Theme system, reusable components and design tokens |
| `lib/features/health/domain` | Models, calculations, units and business logic |
| `lib/features/health/data` | Local JSON persistence layer |
| `lib/features/health/application` | Riverpod state management and dependency injection |
| `lib/features/health/presentation` | Screens, widgets and user interactions |
| `test` | Unit and widget testing |
| `tool/render_previews.dart` | Screenshot generation tools |


# Technical Stack

- Flutter
- Dart
- Riverpod 3
- SharedPreferencesAsync
- Material Design principles
- Responsive UI architecture
- Local JSON data storage


# Design System

The interface follows a modern product design approach:

- Dark premium UI
- Ink background
- Slate surfaces
- Mint primary actions
- Lavender highlights
- Custom typography hierarchy
- Rounded cards
- Minimal interaction design


# Research & Scope

The application follows health information guidelines and avoids presenting BMI as a medical diagnosis.

BMI is used only as a general screening measurement and should not replace professional health assessment.

Additional research decisions and references:

```
docs/RESEARCH.md
```

Future improvements:

- Backdated entry editing
- Custom training schedules
- Reminders
- Encrypted storage
- RTL localization
- Wearable device integration


# Verification

Completed:

✅ Flutter analyze  
✅ Flutter tests  
✅ Web release build  
✅ Responsive UI testing  
✅ Preview rendering from Flutter widgets  


Test coverage includes:

- Domain calculations
- State management behavior
- Storage handling
- Responsive interactions


Generate preview images:

```bash
flutter test tool/render_previews.dart
```


# Project Author

Created and developed by **Arshia**

Flutter Developer focused on building modern, scalable, and user-centered applications.
