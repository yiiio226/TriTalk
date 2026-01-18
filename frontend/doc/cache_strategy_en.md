# 📦 TriTalk Frontend Cache Strategy

This document details the usage scenarios, architectural design, and specific rules for all caching in the TriTalk Frontend project.

## I. Cache Architecture Overview

To address the issue of decentralized cache management, the project introduces a lightweight **CacheManager** as a coordination layer, while retaining control of caching logic within individual business services.

### 1. Core Architecture (CacheManager)

`CacheManager` (located in `lib/core/cache/cache_manager.dart`) is the unified entry point for the cache system, primarily responsible for:

- **Unified Registration**: All cache services must implement `CacheProvider` and register with `CacheManager`.
- **Unified Cleanup**: Provides `clearAllUserCache()` method, called via `AuthService` on user logout to ensure data security.
- **Status Query**: Provides a unified interface to query cache existence (`hasCache`) and cache size (`getCacheSize`).

### 2. Cache Types (CacheType)

Currently supports 4 main cache types:

| Cache Type (Enum) | Provider                   | Storage Medium           | Usage                      |
| :---------------- | :------------------------- | :----------------------- | :------------------------- |
| `ttsCache`        | `TtsCacheProvider`         | File System (WAV)        | TTS Audio Stream Files     |
| `wordTts`         | `WordTtsCacheProvider`     | File System (WAV)        | Word Pronunciation Audio   |
| `chatHistory`     | `ChatHistoryCacheProvider` | SharedPreferences (JSON) | Chat Message History       |
| `shadowCache`     | `ShadowingCacheProvider`   | SharedPreferences (JSON) | Shadowing Practice Results |

### 3. Constant Management

All cache-related constants (like directory names, Key prefixes) are converged in `lib/core/cache/cache_constants.dart` to avoid hardcoding.

---

## II. Detailed Usage Scenarios

### 1️⃣ StreamingTtsService - Streaming TTS Audio Cache

**File**: `lib/core/services/streaming_tts_service.dart`

**Strategy**: **Hybrid Playback & Cache**

- **Streaming Playback**: Uses `SoLoud` engine for low-latency streaming playback (PCM data).
- **Cached Playback**: Saves as WAV file after download completes. Subsequent playback uses `AudioPlayer` (audioplayers) to play the local file directly, solving iOS file lock issues and improving stability.

**Storage Rules**:

```dart
// Directory (from CacheConstants.ttsCacheDir)
'{documentsDir}/{userId}/tts_cache/'

// Filename
'{messageId}.wav' (Special characters are replaced with '_')
```

**Features**:

- ✅ **True Streaming Experience**: Buffers and plays via SoLoud while downloading.
- ✅ **Auto Persistence**: Merges PCM chunks and writes WAV Header automatically after playback.
- ✅ **User Isolation**: Strictly uses `StorageKeyService` to generate user-specific paths.

### 2️⃣ ShadowingCacheService - Shadowing Practice Cache

**File**: `lib/features/study/data/shadowing_cache_service.dart`

**Strategy**: **Local-First / Latest-Entry**

This service is mainly used to cache user shadowing practice results. The current Schema design tends to save only the latest practice record for each source.

**Storage Rules**:

```dart
// Cache Key (from CacheConstants.shadowingPracticePrefix)
'shadow_v2_{sourceType}_{sourceId}'

// Example
'shadow_v2_ai_message_msg_12345'
```

**Features**:

- ✅ **SharedPreferences Storage**: Stores serialized JSON data.
- ✅ **Silent Fail**: Cache read/write errors do not block the main flow.
- ✅ **Logout Cleanup**: Unifies cleanup of keys starting with `shadow_v2_` via `CacheManager`.

### 3️⃣ ChatHistoryService - Chat History Cache

**File**: `lib/features/chat/data/chat_history_service.dart`

**Strategy**: **Three-Tier Storage**

```
Memory Map (_histories) → SharedPreferences (Cache) → Supabase (Cloud)
```

**Storage Rules**:

```dart
// Cache Key (from CacheConstants.chatHistoryPrefix)
'{userId}_chat_history_{sceneKey}'

// Example
'user123_chat_history_cafe_scene'
```

**Features**:

- ✅ **User Isolation**: Key explicitly includes `userId`.
- ✅ **Sync Mechanism**: Uses `updated_at` timestamp to resolve local/cloud conflicts.
- ✅ **Offline Support**: Can rely entirely on local cache for conversation when offline.

### 4️⃣ WordTtsService - Word Pronunciation Cache

**File**: `lib/features/speech/data/services/word_tts_service.dart`

**Strategy**: **On-Demand Cache**

**Storage Rules**:

```dart
// Directory (from CacheConstants.wordTtsCacheDir)
'{documentsDir}/word_tts_cache/{language}/'

// Filename
'{md5(word)}.wav'
```

**Features**:

- ✅ **Hash Filename**: Uses MD5(word) to avoid long filenames or illegal characters.
- ✅ **Language Classification**: Stores different languages in different subdirectories for easy cleanup by language.

### 5️⃣ Segment Audio - Smart Segment Audio Cache

**Context**: Segment playback in `ShadowingSheet`.

**Strategy**: **Delegate to StreamingTtsService**

Segment playback actually reuses `StreamingTtsService` capabilities.

**Storage Rules**:

```dart
// Cache Key (passed as messageId to TTS service)
'seg_{messageId}_{segmentIndex}'

// Final File Path
'{documentsDir}/{userId}/tts_cache/seg_msg123_0.wav'
```

**Features**:

- ✅ **Widget-Level State**: `ShadowingSheet` internally maintains a `Map<String, String>` recording Segment Key to local path mapping to avoid duplicate requests.
- ✅ **Physical Cache**: Actual audio files are unified managed and persisted by `StreamingTtsService`.

---

## III. User Isolation Mechanism (StorageKeyService)

**File**: `lib/core/data/local/storage_key_service.dart`

The project strictly enforces user data isolation strategies to prevent data confusion during multi-user login.

### 1. SharedPreferences Isolation

For KV storage, usually concatenates User ID in the Key:
`storageKey.getUserScopedKey('my_feature')` -> `'user123_my_feature'`

### 2. File System Isolation

For file storage, includes User ID directory in the path:
`storageKey.getUserScopedPath(docDir, 'tts_cache')` -> `'/.../Documents/user123/tts_cache'`

---

## IV. Best Practices and Development Guide

1.  **Adding New Cache**:
    - Define new type in `CacheType` enum.
    - Define Key prefix or directory name in `cache_constants.dart`.
    - Implement `CacheProvider` interface.
    - Register that Provider in `CacheManager`.

2.  **Cleanup Standards**:
    - Do not call `SharedPreferences.clear()` directly, as it will accidentally delete all data.
    - Should use `CacheManager.clearAllUserCache()` for safe logout cleanup.

3.  **Exception Handling**:
    - Cache layer should always remain **Fail-Safe**. Cache read/write failures (disk full, permission issues) should not crash the App, but degrade to no-cache mode.

4.  **Key Naming Standards**:
    - Prioritize using definitions in `CacheConstants`, forbid hardcoding string Keys in business code.
