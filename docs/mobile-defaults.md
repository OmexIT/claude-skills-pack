# Mobile defaults (greenfield only)

Existing applications keep their proven navigation, state, dependency-injection, and secure-storage
stack unless a measured problem justifies migration. For a greenfield choice:

- **Flutter**: Riverpod and GoRouter are reasonable defaults; use flavors only for real environment differences.
- **React Native**: use platform-backed secure storage for secrets, never AsyncStorage; keep state local before adding a shared store.
- **Android (Kotlin)**: Hilt and DataStore are reasonable defaults; add Baseline Profiles when startup performance is measured and release tooling supports them.
- **All platforms**: cached money reads must be visibly stale and non-authoritative. Do not queue
  offline money mutations unless the product has a reviewed durable idempotency, ordering, and
  reconciliation design; unknown results fail closed. Give interactive elements accessible names
  and semantics; add test IDs only when semantic selectors are insufficient.
