# Product and technical decisions

Research checked 26 September 2026. These are primary sources, not copied competitor features.

| Source | Finding | Applied decision |
| --- | --- | --- |
| [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) | Separate UI/data responsibilities, inject repositories, use immutable state and test components. | Feature-first domain/data/application/presentation layers. Repository override for tests. Avoid code generation and unnecessary use-case classes for a small app. |
| [Riverpod providers](https://riverpod.dev/docs/concepts2/providers) | Notifiers expose state that changes through user actions. | AsyncNotifier owns hydration and persisted mutations; Provider injects repository; widget state is restricted to transient UI drafts/navigation. |
| [Shared preferences](https://pub.dev/packages/shared_preferences) | Async API avoids cached singleton coherence issues; storage is not for critical data. | SharedPreferencesAsync for a small, nonclinical, local journal. Versioned JSON, explicit failure/retry states, CSV copy. Not encrypted or a medical record. Replace repository with SQLite/encrypted storage for larger or sensitive deployments. |
| [CDC adult categories](https://www.cdc.gov/bmi/adult-calculator/bmi-categories.html) | Categories are for ages 20+; boundaries are 18.5, 25, 30, 35, 40. | Age confirmation; unrounded classification; correct inclusive boundaries and obesity classes. No binary good/bad score. |
| [CDC about BMI](https://www.cdc.gov/bmi/about/index.html) | BMI is screening, not diagnosis; it cannot distinguish fat from muscle. | Context screen, neutral wording, no automated calorie prescription or claims about body fat. |
| [WHO physical activity](https://www.who.int/news-room/fact-sheets/detail/physical-activity) | Adult guidance includes 150–300 moderate minutes or 75–150 vigorous minutes weekly, plus strengthening. | User-chosen days and minutes, total planned volume, gradual-start language, suggested evenly spaced schedule. Planned activity is never presented as completed activity. |

## Why these features

- Daily check-ins and date-scaled trends give the original single-result calculator continuity.
- Metric/imperial switching preserves canonical cm/kg values; no accumulated unit-conversion drift.
- Precision entry complements sliders, including keyboard and accessibility use.
- Same-day saves replace that day's entry instead of producing duplicate points.
- Local storage avoids requiring an account for basic functionality. It is not encrypted; platform backups may contain it.
- CSV copy and individual/all-data deletion give people control of their records.
- No invented history, workout completion, weight-loss forecasts, calorie targets, wearable sync or notification claims.

## Visual direction

The supplied reference informed the three-step onboarding, rounded cards, ruler controls and large typography. The revised direction uses deep ink `#0B131B`, slate `#18232B`, mint `#A7F3CE`, lavender `#C9BCF5`, secondary text `#A5B5BD` and warm white. Mint highlights primary actions; lavender accents planning. Mobile uses bottom navigation; larger screens use a rail and two-column overview. Content scrolls independently of the onboarding primary action.

## Future extensions

Useful next additions: editable/backdated history, user-selected training weekdays, platform export/share files, local reminders, encrypted SQLite, localization including Persian RTL, and optional Health Connect/HealthKit import. Each needs additional permission, product and platform testing; none is represented as implemented here.
