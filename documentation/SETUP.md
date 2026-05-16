# Setup Guide: G4WDB AI Agent

This guide provides step-by-step instructions to set up the development environment and run the G4WDB AI Agent application.

## Prerequisites

Before you begin, ensure you have the following installed:

1.  **Flutter SDK**: Version 3.0.0 or higher.
    *   [Download Flutter](https://docs.flutter.dev/get-started/install)
2.  **Dart SDK**: Included with Flutter.
3.  **Android Studio / VS Code**: With Flutter and Dart plugins.
4.  **Android SDK**: For mobile deployment.
5.  **CocoaPods**: (Only for macOS/iOS development).

## Installation Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd g4wdb_ai_agent
```

### 2. Install Dependencies
Run the following command to fetch all required packages:
```bash
flutter pub get
```

### 3. Generate Code
The project uses `riverpod_generator` for state management. Run the build runner to generate necessary files:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Database Setup
The application uses bundled SQLite databases. Ensure the following files exist in `assets/databases/`:
*   `tccc.sqlite`
*   `uxo.sqlite`

These are automatically copied to the system directory during the first run.

### 5. Running the Application

#### Mobile (Android/iOS)
Connect your device or start an emulator, then run:
```bash
flutter run
```

#### Desktop (Windows/macOS/Linux)
The application supports desktop platforms via FFI.
```bash
flutter run -d windows  # or macos, linux
```

## Troubleshooting

*   **SQLite Issues on Desktop**: Ensure `sqflite_common_ffi` is correctly initialized. The app handles this in `main.dart`.
*   **Missing Translations**: If text appears as keys (e.g., `main.title`), check if `assets/translations/` contains the necessary JSON files.
*   **Permission Errors**: Ensure you grant Camera and Location permissions when prompted on the device.
