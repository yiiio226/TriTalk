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

_Target: Slim down `ChatScreen.dart` from 2000+ lines to <500 lines._

- [ ] **3.1. Design Immutable State**
  - [ ] Create `features/chat/presentation/state/chat_page_state.dart` using Freezed.
    - Fields: `isLoading`, `isRecording`, `messages` (List), `currentScene`, `selectionMode`, etc.
- [ ] **3.2. Create ChatPageNotifier**
  - [ ] Create `features/chat/presentation/notifiers/chat_page_notifier.dart`.
  - [ ] Move **Business Logic** from `_ChatScreenState` methods here:
    - [ ] `sendMessage()`
    - [ ] `handleAnalyze()`
    - [ ] `deleteMessages()`
    - [ ] `toggleSelectionMode()`
- [ ] **3.3. Refactor ChatScreen (The Big One)**
  - [ ] Convert `ChatScreen` from `StatefulWidget` to `ConsumerWidget`.
  - [ ] Replace `setState` calls with `ref.read(chatProvider.notifier).action()`.
  - [ ] Replace UI rendering logic to read from `ref.watch(chatProvider)`.
  - [ ] Extract sub-widgets (e.g., `ChatInputArea`, `AiMessageBubble`) into separate files if not already done.

### Phase 4: Structural Reorganization (Core/Features)

_Target: Clean component isolation._

- [ ] **4.1. Establish Directory Structure**
  - [ ] Create `lib/core` (Shared logic, Env, Theme, Utils).
  - [ ] Create `lib/features` (Chat, Scenes, Profile, Onboarding).
- [ ] **4.2. Move Files**
  - [ ] Move `screens/chat_screen.dart` -> `features/chat/presentation/pages/`.
  - [ ] Move `services/scene_service.dart` -> `features/scenes/data/`.
  - [ ] Move `design/` -> `core/design/`.
- [ ] **4.3. Update Imports**
  - [ ] Bulk update import paths.

### Phase 5: Polish & Testing

- [ ] **5.1. Unit Tests**
  - [ ] Write tests for `ChatPageNotifier` (mocking the Repository).
  - [ ] Write tests for `ChatRepositoryImpl` (mocking the API).
- [ ] **5.2. Integration Tests**
  - [ ] Test critical flows (Login -> Chat -> Send Message).

---

## 🛠 Tech Stack Update

- **State Management**: `flutter_riverpod`
- **Immutability**: `freezed`
- **Dependency Injection**: `riverpod`
- **Architecture**: Domain-Driven Design (Lite) / Clean Architecture
