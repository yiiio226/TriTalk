# 📦 TriTalk Frontend 缓存策略文档

本文档详细记录了 TriTalk 前端项目中所有缓存的使用场景、架构设计及具体规则。

## 一、缓存架构概览

为了解决分散式缓存管理的问题，项目引入了轻量级的 **CacheManager** 作为协调层，同时保留各业务服务对自己缓存逻辑的控制权。

### 1. 核心架构 (CacheManager)

`CacheManager` (位于 `lib/core/cache/cache_manager.dart`) 是缓存系统的统一入口，主要负责：

- **统一注册**：所有缓存服务需实现 `CacheProvider` 并注册到 `CacheManager`。
- **统一清理**：提供 `clearAllUserCache()` 方法，在用户登出时通过 `AuthService` 调用，确保数据安全。
- **状态查询**：提供统一接口查询缓存是否存在 (`hasCache`) 及缓存占用大小 (`getCacheSize`)。

### 2. 缓存类型 (CacheType)

目前支持以下 4 种主要缓存类型：

| 缓存类型 (Enum) | 对应 Provider              | 存储介质                 | 用途           |
| :-------------- | :------------------------- | :----------------------- | :------------- |
| `ttsCache`      | `TtsCacheProvider`         | 文件系统 (WAV)           | TTS 音频流文件 |
| `wordTts`       | `WordTtsCacheProvider`     | 文件系统 (WAV)           | 单词发音音频   |
| `chatHistory`   | `ChatHistoryCacheProvider` | SharedPreferences (JSON) | 聊天消息记录   |
| `shadowCache`   | `ShadowingCacheProvider`   | SharedPreferences (JSON) | 跟读练习结果   |

### 3. 常量管理

所有缓存相关的常量（如目录名、Key 前缀）统一收敛在 `lib/core/cache/cache_constants.dart` 中，避免硬编码。

---

## 二、详细使用场景

### 1️⃣ StreamingTtsService - 流式 TTS 音频缓存

**文件**: `lib/core/services/streaming_tts_service.dart`

**缓存策略**: **Hybrid Playback & Cache** (混合播放与缓存)

- **流式播放**: 使用 `SoLoud` 引擎进行低延迟流式播放 (PCM 数据)。
- **缓存播放**: 音频下载完整后保存为 WAV 文件，后续播放使用 `AudioPlayer` (audioplayers) 直接播放本地文件，以解决 iOS 文件锁问题并提高稳定性。

**存储规则**:

```dart
// 目录 (来自 CacheConstants.ttsCacheDir)
'{documentsDir}/{userId}/tts_cache/'

// 文件名
'{messageId}.wav' (特殊字符会被替换为 '_')
```

**特点**:

- ✅ **真正的流式体验**: 数据一边下载一边通过 SoLoud 缓冲播放。
- ✅ **自动持久化**: 播放完成后自动合并 PCM 数据块并写入 WAV Header 保存。
- ✅ **用户隔离**: 严格使用 `StorageKeyService` 生成用户专属路径。

### 2️⃣ ShadowingCacheService - 跟读练习缓存

**文件**: `lib/features/study/data/shadowing_cache_service.dart`

**缓存策略**: **Local-First / Latest-Entry** (本地优先 / 最新记录)

该服务主要用于缓存用户的跟读练习结果。目前的 Schema 设计倾向于只保存每个来源（Source）的最新练习记录。

**存储规则**:

```dart
// Cache Key (来自 CacheConstants.shadowingPracticePrefix)
'shadow_v2_{sourceType}_{sourceId}'

// 示例
'shadow_v2_ai_message_msg_12345'
```

**特点**:

- ✅ **SharedPreferences 存储**: 存储序列化后的 JSON 数据。
- ✅ **静默失败**: 缓存读写异常不会阻断主流程。
- ✅ **登出清理**: 通过 `CacheManager` 统一清理 `shadow_v2_` 开头的所有 key。

### 3️⃣ ChatHistoryService - 聊天记录缓存

**文件**: `lib/features/chat/data/chat_history_service.dart`

**缓存策略**: **Three-Tier Storage** (三层存储架构)

```
内存 Map (_histories) → SharedPreferences (Cache) → Supabase (Cloud)
```

**存储规则**:

```dart
// Cache Key (来自 CacheConstants.chatHistoryPrefix)
'{userId}_chat_history_{sceneKey}'

// 示例
'user123_chat_history_cafe_scene'
```

**特点**:

- ✅ **用户隔离**: Key 中明确包含 `userId`。
- ✅ **同步机制**: 使用 `updated_at` 时间戳解决本地与云端的冲突。
- ✅ **离线支持**: 无网络时可完全依赖本地缓存进行会话。

### 4️⃣ WordTtsService - 单词发音缓存

**文件**: `lib/features/speech/data/services/word_tts_service.dart`

**缓存策略**: **On-Demand Cache** (按需缓存)

**存储规则**:

```dart
// 目录 (来自 CacheConstants.wordTtsCacheDir)
'{documentsDir}/word_tts_cache/{language}/'

// 文件名
'{md5(word)}.wav'
```

**特点**:

- ✅ **哈希文件名**: 使用 MD5(word) 避免文件名过长或非法字符。
- ✅ **语言分类**: 不同语言存储在不同子目录，方便按语言清理。

### 5️⃣ Segment Audio - 分段音频缓存 (智能分段)

**Context**: `ShadowingSheet` 中的分段播放功能。

**缓存策略**: **Delegate to StreamingTtsService** (委托给 TTS 服务)

分段播放实际上复用了 `StreamingTtsService` 的能力。

**存储规则**:

```dart
// Cashe Key (作为 messageId 传递给 TTS 服务)
'seg_{messageId}_{segmentIndex}'

// 最终文件路径
'{documentsDir}/{userId}/tts_cache/seg_msg123_0.wav'
```

**特点**:

- ✅ **Widget 级状态**: `ShadowingSheet` 内部维护一个 `Map<String, String>` 记录分段 Key 到本地路径的映射，避免重复请求。
- ✅ **物理缓存**: 实际音频文件由 `StreamingTtsService` 统一管理和持久化。

---

## 三、用户隔离机制 (StorageKeyService)

**文件**: `lib/core/data/local/storage_key_service.dart`

项目严格执行用户数据隔离策略，防止多用户登录时数据混淆。

### 1. SharedPreferences 隔离

对于 KV存储，通常在 Key 中拼接 User ID：
`storageKey.getUserScopedKey('my_feature')` -> `'user123_my_feature'`

### 2. 文件系统隔离

对于文件存储，在路径中包含 User ID 目录：
`storageKey.getUserScopedPath(docDir, 'tts_cache')` -> `'/.../Documents/user123/tts_cache'`

---

## 四、最佳实践与开发指南

1.  **添加新缓存**:
    - 在 `CacheType` 枚举中定义新类型。
    - 在 `cache_constants.dart` 中定义 Key 前缀或目录名。
    - 实现 `CacheProvider` 接口。
    - 在 `CacheManager` 中注册该 Provider。

2.  **清理规范**:
    - 不要直接调用 `SharedPreferences.clear()`，这会误删所有数据。
    - 应使用 `CacheManager.clearAllUserCache()` 进行安全的登出清理。

3.  **异常处理**:
    - 缓存层应始终保持 **Fail-Safe**（故障安全）。缓存读写失败（如磁盘满、权限问题）不应导致 App 崩溃，应降级为无缓存模式运行。

4.  **键名规范**:
    - 优先使用 `CacheConstants` 中的定义，禁止在业务代码中硬编码字符串 Key。
