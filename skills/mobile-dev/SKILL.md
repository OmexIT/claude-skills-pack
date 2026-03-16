---
name: mobile-dev
description: >
  Mobile development patterns and guidance for Flutter, React Native, and Android (Kotlin).
  Covers architecture, state management, navigation, testing, platform channels, and app store readiness.
  Triggers: "mobile", "flutter", "react native", "android", "ios", "mobile app", "widget test", "app store".
argument-hint: "[platform: flutter | react-native | android] [feature description]"
---

# Mobile development

## What I'll do
Provide stack-aware mobile development guidance, implementation patterns, and testing strategies for Flutter, React Native, or Android (Kotlin).

## Inputs I'll use (ask only if missing)
- Target platform (Flutter / React Native / Android / cross-platform)
- Feature description or spec reference
- Existing project? (check for pubspec.yaml, package.json, build.gradle)
- State management approach in use (BLoC, Riverpod, Redux, ViewModel)
- Backend API details (REST endpoints, auth mechanism)

## How I'll think about this

### Flutter (Dart)
1. **Architecture**: Clean Architecture layers (presentation → domain → data). Features as directories, not file types. One widget per file.
2. **State management**: Riverpod for new projects (compile-safe, testable). BLoC for complex event-driven flows. Provider for simple apps. Never raw setState in production.
3. **Navigation**: GoRouter for declarative routing. Deep link support from day one. Named routes with typed parameters.
4. **Platform channels**: MethodChannel for one-off calls. EventChannel for streams. Pigeon for type-safe platform interop. Always handle PlatformException.
5. **Testing**: Widget tests for UI logic (fast, no device needed). Integration tests for full flows. Golden tests for visual regression. `flutter test --coverage` for coverage reports.
6. **Build variants**: Flavors for dev/staging/prod. Separate Firebase configs per flavor. `--dart-define` for build-time constants.
7. **Performance**: `const` constructors everywhere possible. `ListView.builder` for long lists (never `ListView` with children). Profile with DevTools. Avoid rebuilding entire widget trees.

### React Native (TypeScript)
1. **Architecture**: Feature-based directories. Shared components in `src/components/`. Platform-specific code in `.ios.tsx` / `.android.tsx` files.
2. **State management**: Zustand or Redux Toolkit. React Query for server state. AsyncStorage for persistence. Never store sensitive data in AsyncStorage (use react-native-keychain).
3. **Navigation**: React Navigation 6+ with typed routes. Deep linking via linking config. Tab + Stack composition pattern.
4. **Native modules**: Turbo Modules for new architecture. Bridge modules for legacy. Always provide TypeScript types for native interfaces.
5. **Testing**: Jest + React Native Testing Library for component tests. Detox for E2E. `jest --coverage` for reports.
6. **Performance**: Hermes engine (enabled by default). FlatList with `getItemLayout` for fixed-height items. `useMemo`/`useCallback` for expensive computations. Profile with Flipper.

### Android (Kotlin)
1. **Architecture**: MVVM with Jetpack Compose. ViewModel + StateFlow for UI state. Repository pattern for data access. Hilt for dependency injection.
2. **State management**: StateFlow in ViewModel. SavedStateHandle for process death survival. DataStore for preferences (not SharedPreferences).
3. **Navigation**: Jetpack Navigation Compose with typed arguments. Deep links in AndroidManifest. Single-Activity architecture.
4. **Testing**: JUnit 5 + MockK for unit tests. Espresso for UI tests. Compose Testing for composable tests. Robolectric for fast on-JVM tests.
5. **Build variants**: buildTypes (debug/release) + productFlavors (dev/staging/prod). ProGuard/R8 rules for release. Separate signing configs per variant.
6. **Performance**: Baseline Profiles for startup. Lazy composition in lists. Profile with Android Studio Profiler. StrictMode in debug builds.

### Cross-cutting concerns (all platforms)
1. **Offline-first**: Local DB (SQLite/Hive/Room) as source of truth. Sync queue for pending operations. Conflict resolution strategy.
2. **Deep linking**: Universal Links (iOS) + App Links (Android) + GoRouter/Navigation. Test with `adb shell am start` / `xcrun simctl openurl`.
3. **Push notifications**: FCM setup with platform-specific handlers. Notification channels (Android). Background vs foreground handling.
4. **Accessibility**: Semantics labels (Flutter), accessibilityLabel (RN), contentDescription (Android). Test with TalkBack/VoiceOver. Minimum touch target 48dp.
5. **Responsive layouts**: MediaQuery/LayoutBuilder (Flutter), Dimensions (RN), WindowSizeClass (Android). Never hardcode pixel values.
6. **App store readiness**: Privacy manifest, screenshots per device size, app review guidelines compliance, versioning strategy (semver).

## Anti-patterns to flag
- ⚠️ Blocking the UI thread with synchronous operations
- ⚠️ Platform-specific code in shared business logic
- ⚠️ Missing null safety (Flutter) or missing TypeScript strict mode (RN)
- ⚠️ Hardcoded dimensions instead of responsive layouts
- ⚠️ Storing secrets or tokens in plain text storage
- ⚠️ No loading/error/empty states for async operations
- ⚠️ Rebuilding entire widget/component trees on every state change
- ⚠️ Skipping accessibility labels

## Quality bar
- ✅ Clean architecture with clear layer separation
- ✅ State management is testable and predictable
- ✅ Widget/component tests cover happy path + error states
- ✅ Deep linking works for all primary routes
- ✅ Offline behavior is defined (even if "show error")
- ✅ Accessibility passes automated audit
- ✅ No hardcoded strings (use l10n/i18n)
- ✅ Build variants configured for dev/staging/prod

## Workflow context
- Typically follows: `/design-doc`, `/api-design`, `/flow-map`
- Feeds into: `/test-plan` (mobile test cases), `/verify-impl` (mobile verification)
- Related: `/ux-review` (mobile UX), `/infra-design` (CI/CD for mobile builds)

## Output contract
```yaml
produces:
  - type: implementation_guidance
    format: markdown
    sections: [architecture, state_management, navigation, testing, platform_specific]
  - type: test_commands
    commands: ["flutter test", "npx jest", "./gradlew testDebugUnitTest"]
  - type: build_commands
    commands: ["flutter build apk --flavor prod", "npx react-native run-android"]
```
