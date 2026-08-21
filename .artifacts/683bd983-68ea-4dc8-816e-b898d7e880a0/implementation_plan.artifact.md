# Implementation Plan - Firebase Integration (Firestore & Phone Auth)

Integrate Firebase into the AnnaDaan app to support real-time data storage (Firestore) and secure mobile authentication (Phone Auth).

## Firebase Project
- **Project ID**: `annadaan-app-2026-v1`
- **Display Name**: `AnnaDaan`

## User Review Required

> [!WARNING]
> Phone Authentication requires additional setup in the Firebase Console:
> 1. Enable **Phone** as a sign-in provider in the Firebase Authentication settings.
> 2. (Android) Add your **SHA-1** and **SHA-256** certificates to the project settings.
> 3. (iOS) Configure **APNs** or **reCAPTCHA** for verification.

## Proposed Changes

### 1. Dependency Updates
- Add `firebase_core`, `firebase_auth`, and `cloud_firestore` to `pubspec.yaml`.

### 2. Firebase Configuration
- Run `flutterfire configure` (if available) or manually set up `firebase_options.dart`.
- Fetch and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) using the Firebase CLI.

### 3. Core Service Layer (`lib/core/services`)
- `firebase_service.dart`: Initialization logic.
- `auth_service.dart`: Phone number verification, OTP submission, and sign-out logic.
- `firestore_service.dart`: Generic CRUD operations and specific AnnaDaan collection logic.

### 4. UI Integration
- **Auth Flow**: Update `login_screen.dart` and `otp_verification_screen.dart` to call `AuthService`.
- **Dashboard**: Update `MainDashboard` to fetch real Anadanam data from Firestore.
- **Upload Flow**: Update `UploadPreviewScreen` to save submissions to Firestore.

### 5. Repository Layer (`lib/data/repositories`)
- `auth_repository.dart`: Manage user state using Riverpod.
- `anadanam_repository.dart`: Stream active food services from Firestore.

## Verification Plan

### Automated Tests
- Unit tests for `AuthService` and `FirestoreService` using mocks.
- Verify Firebase initialization in `main.dart`.

### Manual Verification
- Test the full Phone Auth flow (using test numbers in Firebase Console).
- Create a food service and verify it appears on the dashboard in real-time.
- Verify data persistence in the Firestore Emulator or Console.
