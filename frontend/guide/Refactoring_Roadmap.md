# TriTalk Architecture Refactoring Roadmap

This document outlines the step-by-step plan to migrate TriTalk's current architecture to a scalable, layered architecture inspired by ApparenceKit (Clean Architecture + Riverpod).

## 📊 Current Architecture Status

| Dimension            | Current State                 | Target State (ApparenceKit)              | Gap Assessment                        |
| -------------------- | ----------------------------- | ---------------------------------------- | ------------------------------------- |
| **Layering**         | 2-Layer (Screen + Service)    | 3-Layer (View + Domain + DAO/API)        | 🔴 Critical (Missing Repository)      |
| **State Management** | `StatefulWidget` (Local)      | `Riverpod` + `Freezed` (Global/Injected) | 🔴 Critical (Hard to test/share)      |
| **Business Logic**   | Embedded in UI (`ChatScreen`) | Separated in `StateNotifier`             | 🔴 Critical (`ChatScreen` > 2k lines) |
| **Modularity**       | By Type (screens/, services/) | By Feature (core/, modules/chat/)        | 🟡 Moderate                           |

---

## 🚀 Execution Roadmap

### Phase 1: Foundation & State Management (Riverpod)

_Target: Introduce dependency injection and global state management without breaking existing features._

- [x] **1.1. Setup Riverpod**
  - [x] Add dependencies: `flutter_riverpod`, `freezed_annotation`, `json_annotation`.
  - [x] Add dev dependencies: `build_runner`, `freezed`, `json_serializable`.
  - [x] Wrap `TriTalkApp` with `ProviderScope` in `main.dart`.
- [x] **1.2. Migrate Auth State**
  - [x] Create `core/auth/` directory.
  - [x] Create `AuthProvider` (`StateNotifier` or `Notifier`) to replace direct usage of `AuthService`.
  - [x] Refactor `LoginScreen` to watch `AuthProvider` instead of managing local loading state.
  - [x] Refactor `SplashScreen` to use `AuthProvider` for initialization check.
- [x] **1.3. Setup App Initializer**
  - [x] Create `core/initializer/app_initializer.dart`.
  - [x] Move Supabase init, Prefs init into this class.
  - [x] Call Initializer in `main.dart` with error handling.

### Phase 2: Layer Separation (Repository Pattern)

_Target: Decouple Data logic from UI logic. UI should never import `http` or `supabase` directly._

- [x] **2.1. Define Repository Interface**
  - [x] Create `features/chat/domain/repositories/chat_repository.dart`.
  - [x] Define abstract methods: `sendMessage`, `fetchHistory`, `analyzeMessage`.
- [x] **2.2. Implement Data Sources (API + Local)**
  - [x] Refactor `ApiService` (split into `ChatApi`, `VoiceApi` if needed) - _Kept as-is, repository delegates to ApiService_.
  - [x] Create `ChatRepositoryImpl` to coordinate between `ApiService` (Remote) and `ChatHistoryService` (Local).
  - [x] Create a Provider for the Repository: `chatRepositoryProvider`.

### Phase 3: View Logic Extraction (Notifier Pattern)

\_Target: Slim down `ChatScreen.dart`

- [x] **3.1. Design Immutable State**
  - [x] Create `features/chat/presentation/state/chat_page_state.dart` using Freezed.
    - Fields: `isLoading`, `isRecording`, `messages` (List), `currentScene`, `selectionMode`, etc.
- [x] **3.2. Create ChatPageNotifier**
  - [x] Create `features/chat/presentation/notifiers/chat_page_notifier.dart`.
  - [x] Move **Business Logic** from `_ChatScreenState` methods here:
    - [x] `sendMessage()`
    - [x] `handleAnalyze()` (as `analyzeMessage()`)
    - [x] `deleteMessages()` (as `deleteSelectedMessages()`)
    - [x] `toggleSelectionMode()` (as `toggleMultiSelectMode()`)
- [x] **3.3. Refactor ChatScreen (The Big One)**
  - [x] Convert `ChatScreen` from `StatefulWidget` to `ConsumerStatefulWidget` (kept Stateful for animation/controller lifecycle).
  - [x] Replace `setState` calls with `ref.read(chatProvider.notifier).action()`.
  - [x] Replace UI rendering logic to read from `ref.watch(chatProvider)`.

### Phase 4: Structural Reorganization (Core/Features)

_Target: Clean component isolation._

- [x] **4.1. Establish Directory Structure**
  - [x] Create `lib/core` (Shared logic, Env, Theme, Utils).
  - [x] Create `lib/features` (Chat, Scenes, Profile, Onboarding).
- [x] **4.2. Move Files**
  - [x] Move `screens/chat_screen.dart` -> `features/chat/presentation/pages/`.
  - [x] Move `services/scene_service.dart` -> `features/scenes/data/`.
  - [x] Move `design/` -> `core/design/`.
- [x] **4.3. Update Imports**
  - [x] Bulk update import paths (backward-compatible re-exports created).

### Phase 5: Polish & Testing

- [ ] **5.1. Unit Tests**
  - [x] Write tests for `ChatPageNotifier` (mocking the Repository).
  - [x] Write tests for `ChatRepositoryImpl` (mocking the API).
- [ ] **5.2. Integration Tests**
  - [ ] Test critical flows (Login -> Chat -> Send Message).

### Phase 6: Core Infrastructure Migration (Services -> Core)

_Target: Move global services to `lib/core` as per ApparenceKit guidelines._

- [ ] **6.1. Networking & API**
  - [ ] Move `services/api_service.dart` -> `core/data/api/api_service.dart`.
  - [ ] Move `services/auth_interceptor.dart`, `services/client_provider.dart` -> `core/data/api/`.
- [ ] **6.2. Local Storage & Env**
  - [ ] Move `services/preferences_service.dart` -> `core/data/local/preferences_service.dart`.
  - [ ] Move `services/storage_key_service.dart` -> `core/data/local/storage_keys.dart`.
  - [ ] Create `core/utils/` for any helpers currently in services.
- [ ] **6.3. Authentication Service**
  - [ ] Move `services/auth_service.dart` -> `features/auth/data/services/` (or keep in `core/auth/data` if shared).

### Phase 7: Feature Completion (Screens -> Features)

_Target: Move all screens from `lib/screens/` to their respective feature modules._

- [ ] **7.1. Auth & Onboarding Module**
  - [ ] Move `screens/login_screen.dart` -> `features/auth/presentation/pages/`.
  - [ ] Move `screens/onboarding_screen.dart` -> `features/onboarding/presentation/pages/`.
  - [ ] Move `screens/splash_screen.dart` -> `features/onboarding/presentation/pages/` (or `core/presentation`).
- [ ] **7.2. Profile Module**
  - [ ] Move `screens/profile_screen.dart` -> `features/profile/presentation/pages/`.
  - [ ] Move `screens/unified_favorites_screen.dart` -> `features/profile/presentation/pages/favorites_screen.dart`.
  - [ ] Move `services/user_service.dart` -> `features/profile/data/services/`.
- [ ] **7.3. Scenes Module**
  - [ ] Move `screens/scenario_configuration_screen.dart` -> `features/scenes/presentation/pages/`.
- [ ] **7.4. Home Module**
  - [ ] Create `features/home` structure.
  - [ ] Move `screens/home_screen.dart` -> `features/home/presentation/pages/`.
- [ ] **7.5. Subscription Module**
  - [ ] Create `features/subscription`.
  - [ ] Move `screens/paywall_screen.dart` -> `features/subscription/presentation/pages/`.
  - [ ] Move `services/revenue_cat_service.dart` -> `features/subscription/data/services/`.
- [ ] **7.6. Study Tools (Vocab/Notes)**
  - [ ] Create `features/study`.
  - [ ] Move `services/vocab_service.dart`, `services/note_service.dart` into `features/study/data/`.

### Phase 8: Final Cleanup & Standardization

_Target: Eliminate root-level `screens`, `services`, and `widgets` folders._

- [ ] **8.1. Standardize Widgets**
  - [ ] Move generic widgets from `lib/widgets/` -> `core/widgets/`.
  - [ ] Move feature-specific widgets from `lib/widgets/` -> `features/{feature}/presentation/widgets/`.
- [ ] **8.2. Directory Cleanup**
  - [ ] Remove `lib/screens/` directory.
  - [ ] Remove `lib/services/` directory.
  - [ ] Remove `lib/widgets/` directory.
  - [ ] Verify no imports reference the old paths.

---

## 🛠 Tech Stack Update

- **State Management**: `flutter_riverpod`
- **Immutability**: `freezed`
- **Dependency Injection**: `riverpod`
- **Architecture**: Domain-Driven Design (Lite) / Clean Architecture
