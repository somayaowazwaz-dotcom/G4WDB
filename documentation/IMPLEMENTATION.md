# Implementation Details

This document outlines the technical implementation of key features in the G4WDB AI Agent.

## 1. Offline Intelligence
The core philosophy of the G4WDB Agent is **Offline-First**. 

### AI Engine (Gemma/TFLite)
*   The system integrates `tflite_flutter` for local inference.
*   The `GemmaCore` engine handles local LLM interactions without requiring an internet connection.
*   OCR is implemented using `google_mlkit_text_recognition` for rapid document scanning in the field.

### Database Architecture
*   **Tactical Combat Casualty Care (TCCC)**: A structured SQLite database (`tccc.sqlite`) provides immediate medical protocols.
*   **Unexploded Ordnance (UXO)**: A reference database (`uxo.sqlite`) for identifying hazardous materials.
*   **Synchronization**: Uses a `DatabaseHelper` singleton to manage connections and ensure data integrity across multiple platform-specific paths.

## 2. Connectivity & Mesh Networking
Designed for environments with zero cellular coverage.
*   **Bluetooth Low Energy (BLE)**: Managed via `flutter_blue_plus`.
*   **P2P Mesh**: Utilizes `nearby_connections` to create a local communication grid between devices, allowing field agents to share data without a central server.

## 3. Accessibility & Battery Optimization
Tactical reliability depends on longevity and ease of use.
*   **High Contrast Modes**: Implemented via `AccessibilityService` to support visibility in high-glare environments.
*   **Battery Optimizer**: A background service that adjusts the app's power consumption based on current battery levels, disabling non-essential animations or lowering sensor polling rates when critical.

## 4. Voice Interaction
*   **Speech-to-Text (STT)**: Allows hands-free operation for medical reporting.
*   **Text-to-Speech (TTS)**: Provides audible feedback for critical alerts or guided protocols.

## 5. Security
*   **Encryption**: Sensitive field data is encrypted using the `encrypt` package (AES-256) before storage.
*   **Hash Verification**: Integrity checks on the database files to prevent tampering.
