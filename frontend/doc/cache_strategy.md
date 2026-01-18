# 📦 TriTalk Frontend 缓存策略文档

本文档详细记录了 TriTalk 前端项目中所有缓存的使用场景和规则。

## 一、缓存类型总览

Frontend 项目使用了 **3 种主要缓存机制**：

| 缓存类型              | 存储介质   | 用途                 | 数据持久性 |
| --------------------- | ---------- | -------------------- | ---------- |
| **SharedPreferences** | 键值对存储 | 结构化数据(JSON)     | 持久化     |
| **文件系统缓存**      | 磁盘文件   | 音频文件、二进制数据 | 持久化     |
| **内存缓存**          | Map/List   | 运行时快速访问       | 临时性     |

---

## 二、详细使用场景

### 1️⃣ ShadowingCacheService - 跟读练习缓存

**文件**: `lib/features/study/data/shadowing_cache_service.dart`

**缓存策略**: Cache-First (本地优先)

```dart
// Cache Key 格式
'shadow_v2_{source_type}_{source_id}'

// 示例
'shadow_v2_chat_message123'
'shadow_v2_scene_cafe_greeting'
```

**使用规则**:

- ✅ 保存时：先写本地缓存，再异步同步云端
- ✅ 读取时：先读本地缓存，无缓存才请求云端
- ✅ 无需 `user_id` 前缀（本地缓存天然用户隔离）
- ✅ 使用 `ShadowingCacheData` 包装，包含 `practicedAt` 和 `syncedAt` 时间戳

**数据结构**:

```dart
class ShadowingCacheData {
  final ShadowingPractice practice;
  final DateTime practicedAt;
  final DateTime? syncedAt;  // null 表示未同步到云端
}
```

---

### 2️⃣ StreamingTtsService - TTS 音频缓存

**文件**: `lib/core/services/streaming_tts_service.dart`

**缓存策略**: Play-Then-Cache (播放后缓存)

```dart
// 缓存目录
'{documentsDir}/{userId}/tts_cache/{messageId}.wav'

// 示例
'/Documents/abc123/tts_cache/msg_001.wav'
```

**使用规则**:

- ✅ 首次播放：流式播放 PCM 数据，播放完成后保存为 WAV 文件
- ✅ 后续播放：直接使用 `playCached(path)` 播放缓存文件
- ✅ 文件名：使用 `messageId` 生成安全文件名
- ✅ 用户隔离：通过 `StorageKeyService.getUserScopedPath()` 实现
- ✅ 回调机制：`onCacheSaved` 通知缓存文件保存完成

**音频格式**: WAV (24kHz, 16-bit, mono)

---

### 3️⃣ WordTtsService - 单词发音缓存

**文件**: `lib/features/speech/data/services/word_tts_service.dart`

**缓存策略**: Hybrid TTS (本地TTS优先 + 云端TTS缓存)

```dart
// 缓存目录
'{documentsDir}/word_tts_cache/{language}/{hash}.wav'

// Cache Key 生成
MD5(word.toLowerCase().trim()).substring(0, 16)

// 示例
'/Documents/word_tts_cache/en-US/a1b2c3d4e5f6g7h8.wav'
```

**优先级流程**:

```
用户点击单词
    ↓
[1. 检查本地缓存] ───(有)──→ 直接播放 ✅
    ↓ (无)
[2. 检查语言是否本地 TTS 支持]
    ↓
  ┌─(支持)────→ [3a] 本地 TTS 播放 ✅（零成本）
  │
  └─(不支持)──→ [3b] 请求云端 TTS → 播放 → 缓存
```

**使用规则**:

- ✅ 缓存 Key：使用 MD5 哈希（前16字符）
- ✅ 支持按语言清除缓存：`clearCache(language: 'en-US')`
- ✅ 防抖机制：300ms 内重复点击被忽略

---

### 4️⃣ ChatHistoryService - 聊天记录缓存

**文件**: `lib/features/chat/data/chat_history_service.dart`

**缓存策略**: Local-First with Cloud Sync (本地优先 + 云端同步)

```dart
// Cache Key 格式
'{userId}_chat_history_{sceneKey}'
'{userId}_chat_history_{sceneKey}_updated_at'

// 示例
'abc123_chat_history_cafe_greeting'
'abc123_chat_history_cafe_greeting_updated_at'
```

**三层存储架构**:

```
内存 Map (_histories) → SharedPreferences → Supabase
       ↑                      ↑                ↑
    最快访问              本地持久化          云端同步
```

**使用规则**:

- ✅ 时间戳冲突解决：基于 `updated_at` 决定使用云端或本地数据
- ✅ 删除同步：云端删除时，本地也会被清理
- ✅ 超时回退：云端同步 2s 超时后使用本地缓存
- ✅ 后台同步：不阻塞 UI 响应

---

### 5️⃣ SceneService - 场景数据缓存

**文件**: `lib/features/scenes/data/scene_service.dart`

**缓存策略**: Cloud-as-Source-of-Truth (云端为权威数据源)

```dart
// Cache Keys
'{userId}_custom_scenes_v1'          // 自定义场景
'{userId}_scene_order_v1'            // 场景排序
'{userId}_scene_activity_v1'         // 最近活动时间
'{userId}_hidden_standard_scenes'    // 隐藏的标准场景
```

**使用规则**:

- ✅ 启动时：先加载本地，后台刷新云端
- ✅ 合并策略：(标准场景 - 隐藏场景) + 自定义场景
- ✅ 排序同步：本地和云端同步场景顺序
- ✅ 活动追踪：记录每个场景最后活动时间

---

### 6️⃣ VocabService - 词汇本缓存

**文件**: `lib/features/study/data/vocab_service.dart`

**缓存策略**: Optimistic UI (乐观更新)

```dart
// Cache Key
'{userId}_vocab_items_v2'
```

**使用规则**:

- ✅ 添加/删除：立即更新本地，后台同步云端
- ✅ 去重逻辑：基于 `phrase` + `scenarioId` 判断
- ✅ 排序：按 `createdAt` 降序（最新在前）
- ✅ 云端同步失败不影响本地操作

---

### 7️⃣ NoteService - 笔记缓存

**文件**: `lib/features/study/data/note_service.dart`

**缓存策略**: Local-Only (纯本地)

```dart
// Cache Keys
'{userId}_saved_sentences'
'{userId}_saved_vocabulary'
```

**使用规则**:

- ✅ 仅本地存储，不同步云端
- ✅ 使用 StringList 存储
- ✅ 词汇保存包含上下文和时间戳

---

### 8️⃣ HintsSheet - 提示缓存

**文件**: `lib/features/chat/presentation/widgets/hints_sheet.dart`  
**状态文件**: `lib/features/chat/presentation/state/chat_page_state.dart`

**缓存策略**: Session Memory Cache (会话内存缓存)

```dart
// State 中的字段
List<String>? cachedHints;
```

**使用规则**:

- ✅ 内存缓存，关闭页面后失效
- ✅ 基于消息数量验证缓存有效性
- ✅ 通过 `onHintsCached` 回调保存
- ✅ 新消息发送时自动清除缓存

---

### 9️⃣ Segment Audio Cache - 分段音频缓存

**文件**: `lib/features/study/presentation/widgets/shadowing_sheet.dart`

**缓存策略**: In-Widget Map Cache (Widget 内 Map 缓存)

```dart
// Cache Key 格式
'seg_{messageId}_{segmentIndex}'

// 存储
Map<String, String> _segmentCachePaths = {};
```

**使用规则**:

- ✅ Widget 生命周期内有效
- ✅ 用于避免重复请求相同分段的 TTS
- ✅ Widget dispose 后自动清理

---

## 三、用户隔离机制

### StorageKeyService

**文件**: `lib/core/data/local/storage_key_service.dart`

所有用户数据通过 `StorageKeyService` 实现用户隔离：

```dart
// SharedPreferences Key 格式
'{userId}_{baseKey}'

// 文件路径格式
'{basePath}/{userId}/{subPath}'

// 使用示例
final storageKey = StorageKeyService();
final key = storageKey.getUserScopedKey('chat_history_scene1');
// 结果: 'abc123_chat_history_scene1'

final path = storageKey.getUserScopedPath('/Documents', 'tts_cache');
// 结果: '/Documents/abc123/tts_cache'
```

**需要迁移的旧 Keys**:

- `bookmarked_conversations`
- `custom_scenes_v1`
- `scene_order_v1`
- `scene_activity_v1`
- `hidden_standard_scenes`
- `vocab_items_v2`
- `saved_sentences`
- `saved_vocabulary`
- `native_language`
- `target_language`
- `chat_history_*`

---

## 四、缓存规则总结

| 规则         | 描述                                   |
| ------------ | -------------------------------------- |
| **用户隔离** | 所有缓存 Key 必须包含 `userId` 前缀    |
| **本地优先** | 优先读取本地缓存，减少网络请求         |
| **乐观更新** | UI 先响应，后台异步同步                |
| **冲突解决** | 使用时间戳 `updated_at` 决定数据权威性 |
| **容错设计** | 缓存读写失败不影响核心功能（静默失败） |
| **清理机制** | 登出时清理用户相关缓存                 |

---

## 五、缓存清理入口

```dart
// 跟读练习缓存
ShadowingCacheService().clearAll();

// 单词发音缓存
WordTtsService().clearCache();           // 清除所有
WordTtsService().clearCache(language: 'en-US');  // 清除特定语言

// 聊天记录缓存
ChatHistoryService().clearHistory(sceneKey);

// 旧格式数据清理（迁移后）
StorageKeyService().cleanupOldData();
```

---

## 六、最佳实践

### 添加新缓存时：

1. **确定缓存策略**：Cache-First / Write-Through / Memory-Only
2. **使用 StorageKeyService** 生成用户隔离的 Key
3. **实现容错机制**：缓存读写失败时静默处理
4. **考虑清理机制**：提供 `clear` 方法
5. **文档更新**：在本文档中添加新缓存的说明

### Key 命名规范：

```dart
// SharedPreferences
'{userId}_{feature}_{version}'
'{userId}_{feature}_{identifier}'

// 文件路径
'{documentsDir}/{userId}/{feature_cache}/{filename}.{ext}'
```

---

## 七、相关文件索引

| 文件                                                      | 描述                  | 纳入 CacheManager |
| --------------------------------------------------------- | --------------------- | ----------------- |
| `lib/core/data/local/storage_key_service.dart`            | 用户隔离 Key 生成服务 | -                 |
| `lib/core/services/streaming_tts_service.dart`            | 流式 TTS 服务         | ✅ TtsCache       |
| `lib/features/study/data/shadowing_cache_service.dart`    | 跟读缓存服务          | ✅ ShadowCache    |
| `lib/features/speech/data/services/word_tts_service.dart` | 单词发音服务          | ✅ WordTts        |
| `lib/features/chat/data/chat_history_service.dart`        | 聊天历史服务          | ✅ ChatHistory    |
| `lib/features/scenes/data/scene_service.dart`             | 场景服务              | ❌ 用户数据       |
| `lib/features/study/data/vocab_service.dart`              | 词汇本服务            | ❌ 用户数据       |
| `lib/features/study/data/note_service.dart`               | 笔记服务              | ❌ 用户数据       |

---

## 八、架构分析：是否需要集中化 CacheManager？

> 📅 分析日期：2026-01-18

### 现状分析

当前缓存架构采用 **分散式管理**：

```
┌─────────────────────────────────────────────────────────────┐
│                    StorageKeyService                        │
│              (仅负责用户隔离的 Key 生成)                      │
└─────────────────────────────────────────────────────────────┘
                              ↑
        ┌─────────────────────┼─────────────────────┐
        ↓                     ↓                     ↓
┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ ChatHistory │  │ ShadowCache │  │  TtsCache   │  │   WordTts   │
│  (JSON)     │  │   (JSON)    │  │   (Audio)   │  │   (Audio)   │
└─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘
```

**问题**：

- 各服务独立实现缓存逻辑，存在重复代码
- 缓存检查、清理、统计没有统一入口
- 调试困难，难以一览所有缓存状态

### 架构建议：✅ 推荐实现轻量级 CacheManager

**结论：值得做，但要保持轻量**

不建议创建一个"大一统"的 CacheManager 来接管所有缓存操作，而是建议创建一个 **协调层（Coordinator）**，提供：

#### 推荐实现的功能

| 功能               | 优先级 | 说明                          |
| ------------------ | ------ | ----------------------------- |
| **Cache Key 生成** | P0     | 统一 key 命名规范，避免硬编码 |
| **缓存存在检查**   | P0     | `hasCache(type, id)` 统一接口 |
| **全局缓存清理**   | P0     | 登出时一键清理所有用户缓存    |
| **缓存大小统计**   | 先不做 | 用于设置页显示存储占用        |
| **缓存有效期管理** | 先不做 | 可选，用于自动清理过期缓存    |

#### 不推荐统一的功能

| 功能             | 原因                                                     |
| ---------------- | -------------------------------------------------------- |
| **缓存读写操作** | 各类型差异大（JSON vs 音频 vs 内存），统一反而增加复杂度 |
| **同步策略**     | 各服务的云端同步逻辑不同，不应强行抽象                   |
| **数据序列化**   | 各 Model 的序列化方式不同                                |

### 推荐的架构设计

```
┌───────────────────────────────────────────────────────────────────┐
│                         CacheManager                              │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ - registerCache(CacheType, CacheProvider)                   │ │
│  │ - hasCache(CacheType, String id) -> bool                    │ │
│  │ - getCacheKey(CacheType, String id) -> String               │ │
│  │ - clearAll() / clearType(CacheType)                         │ │
│  └─────────────────────────────────────────────────────────────┘ │
└───────────────────────────────────────────────────────────────────┘
                                  ↑
                        implements CacheProvider
     ┌─────────────┬─────────────┼─────────────┬─────────────┐
     ↓             ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  Chat   │  │ Shadow  │  │   Tts   │  │  Word   │
│ History │  │  Cache  │  │  Cache  │  │   Tts   │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
```

### 实现建议

```dart
// lib/core/cache/cache_manager.dart

enum CacheType {
  chatHistory,
  shadowCache,
  ttsCache,
  wordTts,
}

abstract class CacheProvider {
  CacheType get type;
  Future<bool> hasCache(String id);
  Future<void> clearCache(String? id);  // null = clear all
  Future<int> getCacheSize();           // bytes
}

class CacheManager {
  static final CacheManager _instance = CacheManager._();
  factory CacheManager() => _instance;
  CacheManager._();

  final Map<CacheType, CacheProvider> _providers = {};

  void register(CacheProvider provider) {
    _providers[provider.type] = provider;
  }

  /// 统一的 cache key 生成
  String getCacheKey(CacheType type, String id) {
    final userId = StorageKeyService().currentUserId;
    return '${type.name}_${userId}_$id';
  }

  /// 检查缓存是否存在
  Future<bool> hasCache(CacheType type, String id) async {
    return _providers[type]?.hasCache(id) ?? false;
  }

  /// 清理所有用户缓存（登出时调用）
  Future<void> clearAllUserCache() async {
    for (final provider in _providers.values) {
      await provider.clearCache(null);
    }
  }

  /// 获取缓存大小统计
  Future<Map<CacheType, int>> getCacheSizes() async {
    final sizes = <CacheType, int>{};
    for (final entry in _providers.entries) {
      sizes[entry.key] = await entry.value.getCacheSize();
    }
    return sizes;
  }
}
```

### 迁移策略

1. **Phase 1**: 创建 `CacheManager` 和 `CacheProvider` 接口
2. **Phase 2**: 让现有服务实现 `CacheProvider`，注册到 `CacheManager`
3. **Phase 3**: 在登出流程中使用 `CacheManager.clearAllUserCache()`
4. **Phase 4**: 在设置页添加缓存大小显示和清理按钮

### 风险评估

| 风险                   | 等级 | 缓解措施                         |
| ---------------------- | ---- | -------------------------------- |
| 过度抽象导致复杂度上升 | 中   | 保持接口简单，不强制统一读写逻辑 |
| 迁移工作量             | 低   | 渐进式迁移，不影响现有功能       |
| 性能影响               | 低   | 仅增加一层薄封装，无额外 I/O     |

### 最终建议

**✅ 推荐实现**，ROI 较高：

- 投入：约 2-3 小时开发
- 收益：
  - 统一登出清理逻辑
  - 支持设置页显示/清理缓存
  - 为未来缓存监控打基础
  - 减少硬编码的 cache key

**下一步行动**：如需实现，可创建 `lib/core/cache/cache_manager.dart`
