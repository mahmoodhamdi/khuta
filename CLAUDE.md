# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Development Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Run all tests
flutter test

# Run specific test file
flutter test test/cubit/auth/auth_cubit_test.dart

# Run tests in a specific directory
flutter test test/widgets/

# Generate mock classes (after adding @GenerateMocks annotations)
dart run build_runner build --delete-conflicting-outputs

# Continuous mock generation during development
dart run build_runner watch

# Generate test coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Android release build
flutter build apk --release

# iOS release build (macOS only)
flutter build ios --release
```

## Architecture Overview

**Khuta** is a Flutter app for ADHD assessment using the Conners' Rating Scale with AI-powered recommendations.

### State Management
- Uses **BLoC/Cubit** pattern with `flutter_bloc`
- Three main Cubits initialized in `main.dart`:
  - `AuthCubit` - Firebase authentication (login, register, email verification, password reset)
  - `ThemeCubit` - Light/dark theme switching via SharedPreferences
  - `OnboardingCubit` - First-time user onboarding flow

### Core Services
- `lib/core/services/ai_recommendations_service.dart` - Uses Firebase AI (Gemini 2.0 Flash) to generate personalized ADHD recommendations based on assessment answers. Auto-detects Arabic vs English from question content using regex (`[\u0600-\u06FF]`). Has fallback recommendations if AI fails.
- `lib/core/services/sdq_scoring_service.dart` - Calculates T-scores from assessment answers using age/gender-based scoring tables. Supports age groups 6-8, 9-11, 12-14, 15-17. Score interpretation ranges from "extremely below average" (<30) to "extremely above average" (>=70).

### Repository Pattern & Dependency Injection
- Abstract repository interfaces in `lib/core/repositories/` define contracts:
  - `ChildRepository` - CRUD operations for child profiles
  - `TestResultRepository` - CRUD operations for assessment results
- Concrete Firebase implementations in `lib/data/repositories/`
- `ServiceLocator` in `lib/core/di/service_locator.dart` provides singleton repositories
- For testing: use `ServiceLocator().registerChildRepository(mockRepo)` or `registerTestResultRepository(mockRepo)` to inject mocks, call `reset()` in tearDown

### Assessment Flow
1. User selects child from home screen
2. `AssessmentScreen` displays questions from `lib/core/constants/questions.dart`
3. `AssessmentController` manages navigation and answer collection
4. On completion, T-score is calculated via `SdqScoringService`
5. AI recommendations are fetched via `AiRecommendationsService` (with fallback recommendations if AI fails)
6. Results and recommendations are saved and displayed in `ResultsScreen`

### Data Layer
- **Firebase Auth** - User authentication with email verification flow
- **Cloud Firestore** - Cloud data storage for children and test results
- **SQLite (sqflite)** - Local data storage
- **Firebase App Check** - API security (currently only Android configured with `AndroidDebugProvider`)

### Localization
- Uses `easy_localization` package
- Translation files: `assets/translations/en.json` and `assets/translations/ar.json`
- Supports English and Arabic with RTL support
- **Always update both translation files when adding new strings**
- Use `.tr()` extension for translation keys

### Key Patterns
- Authentication requires email verification before granting access
- Cubits accept optional dependencies for DI in tests (e.g., `AuthCubit({FirebaseAuth? auth})`)
- Use `mockito` with `@GenerateMocks` annotation for mocking Firebase services
- Test files follow pattern: `*_test.dart` with corresponding `*_test.mocks.dart` for generated mocks
- After adding `@GenerateMocks`, run `dart run build_runner build --delete-conflicting-outputs` to regenerate mocks
- Soft delete pattern: entities have `isDeleted` flag, queries filter out deleted items
- App is portrait-only (enforced via `SystemChrome.setPreferredOrientations`)

### Testing Setup
- Tests require localization setup via `setupLocalizationForTest()` from `test/helpers/test_helpers.dart`
- Use `wrapWithLocalization()` helper to wrap widgets for widget tests
- Mock translations are stored in `test/helpers/mock_translations/`

### Testing Structure
```
test/
├── cubit/          # Unit tests for Cubits
├── widgets/        # Widget tests for UI components
├── integration/    # Integration tests for feature flows
├── services/       # Service unit tests
└── helpers/        # Test utilities and mock translations
```

### PDF Report Generation
- Uses `pdf` package for generating assessment reports
- Reports can be shared via `share_plus` package
