# Prepwise

Prepwise is a Flutter study-planning app that helps students turn their goals
into an organized, trackable study routine. It combines AI-assisted planning
with daily plans, a Pomodoro timer, progress analytics, reminders, and an
AI study chat.

## Features

- Email/password and Google authentication
- First-use onboarding
- AI-generated study plans
- Study plan and daily task views
- Pomodoro focus timer
- Progress and analytics dashboards
- AI chat for study support
- Local study reminders and notifications
- Light and dark themes
- Local preferences and onboarding state persistence

## Tech Stack

- Flutter and Dart
- Firebase Core, Authentication, and Cloud Firestore
- Riverpod for state management
- HTTP for AI service requests
- `fl_chart` for progress visualizations
- `flutter_local_notifications` and `timezone` for reminders
- Shared Preferences for local storage

## Requirements

- Flutter SDK with Dart 3.0 or later
- A configured Firebase project
- Android Studio and/or Xcode for mobile builds
- A device or emulator supported by Flutter

## Setup

1. Install Flutter and verify the installation:

   ```bash
   flutter doctor
   ```

2. Install the project dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase for the platforms you intend to run. The app initializes
   Firebase during startup and expects the generated platform options in
   `lib/firebase_options.dart`. Enable the authentication providers used by
   the app and configure Firestore in the Firebase console.

4. Run the app:

   ```bash
   flutter run
   ```

## Useful Commands

```bash
flutter analyze
flutter test
flutter run -d chrome
```

## Project Structure

```text
lib/
  app.dart                 # MaterialApp, routes, and theme mode
  main.dart                # Firebase, timezone, and notification startup
  core/                    # Shared theme, constants, errors, and widgets
  features/                # Feature modules and presentation screens
    ai_chat/
    ai_planner/
    analytics/
    auth/
    onboarding/
    pomodoro/
    study_plan/
  models/                  # Application data models
  providers/               # Riverpod providers
  services/                # AI, Firebase, notification, and storage services
  utils/                   # Date, time, validation, and extension helpers
```

## Application Flow

The app opens on the login route. After authentication, users complete
onboarding if needed and are then taken to their study plan. The main routes
are defined in `lib/app.dart`, including plan generation, daily planning,
Pomodoro focus sessions, progress, chat, and analytics.

## Development Notes

- Keep Firebase configuration out of source control when it contains project-
  specific credentials or identifiers.
- Test notification behavior on a real device where possible; emulator support
  varies by platform.
- Run `flutter analyze` and `flutter test` before submitting changes.
