# Mobile defaults (opinionated, salvaged from mobile-dev)

- **Flutter**: Riverpod for state; GoRouter for navigation; flavors per environment.
- **React Native**: react-native-keychain for secrets — never AsyncStorage; local state first,
  Zustand/RTK only when it can't carry the need.
- **Android (Kotlin)**: Hilt DI; DataStore over SharedPreferences; Baseline Profiles for startup.
- **All platforms**: money surfaces are offline-tolerant — queue and reconcile, never
  double-submit (pair with ledger idempotency keys); `data-testid`/semantics labels on every
  interactive element for e2e tests.
