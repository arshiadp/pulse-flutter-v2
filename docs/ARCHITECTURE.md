# State and persistence contract

`ProviderScope` installs the dependency container. `healthRepositoryProvider` injects a `HealthRepository`; `healthProvider` owns the `AsyncNotifier<HealthState>`.

1. Startup loads a versioned snapshot. A missing key yields an empty profile. Malformed or unsupported data produces an explicit recovery screen instead of silently destroying the original value.
2. Onboarding/editing uses a transient draft. Canceling has no persistent side effect.
3. A save validates input, normalizes the local date, replaces a same-day measurement and sorts history.
4. Commands run on a sequential future chain. Storage is written before a new `AsyncData` is published. A failed command leaves the previous state intact and does not poison the queue.
5. Deletion and reset use that same queue. Data-reset recovery also works from an error state. Initial load does not automatically retry malformed data; the user can explicitly retry.
6. UI subscribes through Riverpod. A navigation route owns the edit screen; it closes only after a successful save.

Canonical units are centimeters and kilograms. Display conversions do not mutate canonical values. Each historical entry retains the height used to compute its BMI. Deleting history does not clear the current profile measurements; those are labeled separately.

## Tradeoffs

The app uses one small feature aggregate and one persisted document, appropriate for a lightweight journal. JSON encoding is colocated with immutable models to avoid duplicating equivalent DTOs. The repository interface keeps storage dependencies outside the domain. When history becomes large or multi-device synchronization is introduced, use a database and granular entities through the existing repository boundary.

Only local application state is synchronized. Simultaneous writes from multiple browser tabs or processes are not coordinated. Shared preferences does not guarantee medical-record-grade durability. The code neither collects credentials nor sends health measurements to a server.
