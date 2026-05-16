# Architecture & Framework Description

G4WDB AI Agent follows a **Feature-Driven, Clean Architecture** approach tailored for the Flutter ecosystem.

## Framework Selection

### 1. Flutter
Chosen for its cross-platform consistency and high-performance rendering. The app targets Android, iOS, and Windows Desktop.

### 2. Riverpod (State Management)
*   Used for reactive state management.
*   Decouples business logic from UI components.
*   Enables easy testing by allowing provider overrides.
*   Code generation (`riverpod_generator`) ensures type safety and reduces boilerplate.

### 3. Easy Localization
*   Handles multi-language support (11+ languages including RTL support for Arabic and Persian).
*   Uses JSON-based translation files stored in `assets/translations/`.

## Directory Structure

```text
lib/
├── agents/          # AI logic and agent behaviors (Gemma, etc.)
├── config/          # Global configuration (Themes, Routes)
├── core/            # Infrastructure (Database helpers, Utilities, Shared Services)
├── features/        # Business logic organized by domain
│   ├── accessibility/
│   ├── medical/
│   └── uxo_id/
├── models/          # Global data structures
└── ui/              # Common UI widgets and layouts
```

## Data Flow
1.  **UI Layer**: Listens to Riverpod Providers.
2.  **Provider Layer**: Orchestrates logic and communicates with Services/Repositories.
3.  **Service Layer**: Interacts with local databases, AI engines, or hardware sensors.
4.  **Data Layer**: SQLite databases and raw assets.

## Design Patterns
*   **Singleton**: For service classes like `DatabaseHelper` and `BatteryOptimizer`.
*   **Observer**: To monitor app lifecycle and battery status.
*   **Repository Pattern**: (Planned/Implemented) to abstract data sources.
