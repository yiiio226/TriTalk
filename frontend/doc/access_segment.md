# 🔊 影子跟读智能分段与缓存实现规范

## 1. 智能分段逻辑 (后端)

我们需要根据 Azure Speech API 检测到的自然停顿来智能分割影子跟读文本，而不是基于固定的单词数量。

### 1.1 分段算法

我们将处理 Azure 发音评估响应中的 `Words` 列表。

**规则：**

1.  **识别潜在断点**：查找 `Feedback.Prosody.Break.BreakLength` > **300ms** (3000000 单位) 的单词。
2.  **过滤约束**：
    - **最小长度**：每个分段必须包含至少 **3 个单词**（以避免片段过短）。
    - **最大分段数**：每句话最多 **5 个分段**（以避免过于碎片化）。
3.  **合并策略**：
    - 如果分段太短（< 3 个单词），将其与前一个或后一个分段合并（优先选择停顿较短的一侧）。
    - 如果超过 5 个分段，优先保留 `BreakLength` 最大的断点，合并其他的。
4.  **回退机制**：如果没有找到有效的断点（例如用户语速非常快或文本很短），则将整个文本视为 **1 个分段**。

### 1.2 数据结构更新

更新 `/chat/shadow` 端点响应 (`ShadowResult`) 以包含计算出的分段。

```typescript
// backend/src/types/shadow.ts (或等效文件)

interface SmartSegment {
  text: string; // 该分段的文本内容
  startIndex: number; // 起始单词索引
  endIndex: number; // 结束单词索引
  score: number; // 该分段的平均发音分数
  hasError: boolean; // 分段是否包含红色/黄色单词
}

interface ShadowResult {
  // ... 现有字段 ...
  segments: SmartSegment[]; // 新字段
}
```

## 2. 缓存策略 (前端)

我们将使用 **混合缓存策略** 来最大化复用和性能。

### 2.1 缓存键设计

- **消息缓存**: `{messageId}.wav` (用于整句播放)
- **分段缓存**: `seg_{hash}.wav` (用于单个分段播放)

**分段键公式：**
`Key = "seg_" + SHA256(segmentText + languageCode).substring(0, 16) + ".wav"`

> **注意**：为了简化缓存管理，我们在键中排除了 `voiceName`，假设 `voiceName` 的更改很少见，或者每种语言的默认设置足以满足影子跟读练习的需求。

### 2.2 播放逻辑

当用户点击分段进行播放时：

1.  **检查分段缓存**：查找 `seg_{hash}.wav`。
    - 如果存在 -> 立即播放。
2.  **回退到流式传输**：
    - 使用分段文本调用 `StreamingTtsService`。
    - 将结果保存到 `seg_{hash}.wav` 以供下次使用。

_这解耦了分段播放与完整消息音频，允许“Good morning”被缓存一次并在不同的对话中重复使用。_

## 3. UI 可视化 (前端)

更新 `ShadowingSheet` 以清晰地显示分段。

### 3.1 视觉设计 (分段波形)

将当前的连续绿线替换为 **分段音高轮廓**：

```
 [ 分段 1 (92) ]   [ 分段 2 (68) ]   [ 分段 3 (45) ]
 ┌────────────────┐   ┌────────────────┐   ┌────────────────┐
 │    ~~~~🟢~~~~   │   │    ~~~~🟡~~~~   │   │    ~~~~🔴~~~~   │
 └───────┬────────┘   └────────┬───────┘   └───────┬────────┘
         │ 分隔符               │ 分隔符             │
```

- **分隔符**：分段之间的垂直分隔线。
- **颜色编码**：
  - 🟢 **绿色** (分数 ≥ 80)
  - 🟡 **黄色** (60 ≤ 分数 < 80)
  - 🔴 **红色** (分数 < 60)
- **交互**：点击某个部分 _仅_ 播放该分段的音频。

### 3.2 实现细节

- **组件**：创建 `SegmentedPitchContour` widget。
- **Props**：
  - `segments`: `SmartSegment` 列表（包含分数、文本、持续时间/单词数比率）。
  - `onSegmentTap(index)`: 播放音频的回调。
  - `currentPlayingIndex`: 高亮显示当前活动分段。

```dart
// Widget 伪代码
Row(
  children: segments.map((seg) => Expanded(
    flex: seg.wordCount, // 使用单词数作为宽度的代理
    child: InkWell(
      onTap: () => playSegment(seg),
      child: Container(
        decoration: borderStyle,
        child: PitchCurve(color: getColor(seg.score)),
      ),
    ),
  )).toList(),
)
```

## 4. 实现状态

### ✅ 已完成 (2026-01-18)

#### 后端

- ✅ **Azure Speech Service** (`backend/src/services/azure-speech.ts`)
  - 添加了 `BreakInfo` 接口以捕获 Azure 韵律停顿数据
  - 添加了 `SmartSegment` 接口用于分段表示
  - 更新了 `WordAssessment` 以包含可选的 `break` 字段
  - 更新了 `PronunciationAssessmentResult` 以包含 `segments` 数组
  - 实现了 `calculateSmartSegments()` 算法：
    - 查找 > 300ms (3000000 单位) 的停顿
    - 每个分段至少 3 个单词
    - 最多 5 个分段
    - 如果没有有效停顿，则回退到单个分段
  - 更新了 `transformAssessmentResult()` 从 Azure 响应中提取 Break 数据

- ✅ **API Schema** (`backend/src/schemas.ts`)
  - 为 OpenAPI 文档添加了 `SmartSegmentSchema`
  - 更新了 `PronunciationAssessmentResponseSchema` 以包含分段

- ✅ **API 端点** (`backend/src/server.ts`)
  - 更新了 `/speech/assess` 以在响应中返回分段

#### 前端

- ✅ **数据模型**
  - `pronunciation_result.dart` 中的 `SmartSegment` 类
  - `message.dart` 中的 `SmartSegmentFeedback` 类
  - 更新了 `PronunciationResult` 以包含 `segments` 字段
  - 更新了 `VoiceFeedback` 以包含 `smartSegments` 字段

- ✅ **ShadowingSheet 更新** (`shadowing_sheet.dart`)
  - 更新了 `_analyzeAudio()` 以转换并存储来自发音结果的智能分段
  - 更新了 `_playSegmentAudio()` 以在可用时使用智能分段
  - 添加了在没有分段数据时回退到固定 3 分段方法的逻辑
  - 使用 `_segmentCachePaths` 映射添加了分段音频缓存
  - 首次播放：流式传输音频并缓存到 WAV 文件
  - 后续播放：使用 `playCached()` 进行即时播放

- ✅ **向后兼容性**
  - 所有新字段都是可选的/可空的
  - 历史数据继续使用固定的 3 分段回退机制
  - 无需数据库迁移

- ✅ **分段缓存**
  - 缓存键格式：`seg_{messageId}_{segmentIndex}`
  - 使用 `StreamingTtsService.onCacheSaved` 回调存储缓存路径
  - 每次播放前检查缓存以避免重复的 TTS API 调用
  - 注意：尚未实现基于哈希的缓存（用于跨消息复用）

### ⏸️ 未实现 (超出范围)

#### UI 可视化 (第 3 节)

- ❌ 分段音高轮廓 widget
- ❌ 颜色编码的分段可视化 (🟢🟡🔴)
- ❌ 交互式分段分隔符
- **原因**：目前的固定音高轮廓 UI 既适用于智能分段（通过 `_playSegmentAudio`），又保持了视觉一致性。UI 增强可以在未来的迭代中进行。

### 当前用户体验

| 场景             | 行为                                                   |
| ---------------- | ------------------------------------------------------ |
| **新的发音评估** | ✅ Azure 根据自然停顿返回智能分段                      |
| **播放分段音频** | ✅ 可用时使用智能分段文本，否则回退到固定的 3 分段拆分 |
| **历史练习数据** | ✅ 使用固定的 3 分段回退机制（不存储分段）             |
| **视觉反馈**     | ⏸️ 使用现有的音高轮廓（尚未在视觉上分段）              |

### 技术说明

#### 为什么 `/speech/assess` 不使用 Swagger Client

该端点使用 `app.post()` 而不是 `createRoute()`，因为：

- 它处理 `multipart/form-data` 文件上传
- `@hono/zod-openapi` 对二进制文件类型的支持有限
- 前端使用手动 HTTP 调用 (`SpeechAssessmentService`) 以便更好地控制文件编码

#### 数据流

```
Backend /speech/assess
  ↓ 返回 JSON 格式的分段
SpeechAssessmentService (HTTP)
  ↓ 解析为 PronunciationResult.fromJson()
ShadowingSheet._analyzeAudio()
  ↓ 转换为 SmartSegmentFeedback
VoiceFeedback 存储 smartSegments
  ↓ 被 _playSegmentAudio() 使用
StreamingTtsService 播放分段文本
```

### 未来增强

如果需要，考虑实现：

1. **分段音高轮廓 UI** - 与分段边界匹配的视觉表示
2. **分段级缓存** - 常用分段的基于哈希的缓存键
3. **分段统计** - 跟踪用户最纠结的分段
4. ~~**数据库存储** - 将分段存储在 `shadowing_practices` 表中用于历史分析~~ ✅ 已实现 (2026-01-18)

---

## 5. 分段数据存储 (2026-01-18)

### ✅ 已完成

分段数据现在持久化到数据库中，以供历史分析。

#### 迁移

```sql
-- 20260118100000_add_segments_to_shadowing_practices.sql
ALTER TABLE shadowing_practices
ADD COLUMN segments JSONB DEFAULT NULL;
```

#### Schema 更新

- **Backend**: `ShadowingPracticeSaveSchema` 现在包含可选的 `segments` 字段
- **Backend**: `ShadowingHistoryResponseSchema` 返回 `segments` (对于历史数据可为空)
- **Frontend**: `ShadowingPractice` 模型包含 `segments` 字段
- **Frontend**: `ShadowingHistoryService.savePractice()` 接受 `segments` 参数

#### 向后兼容性

| 场景                  | 行为                                           |
| --------------------- | ---------------------------------------------- |
| **新练习**            | ✅ 分段保存到数据库                            |
| **历史数据 (迁移前)** | ✅ `segments` 为 `NULL`，回退到 3 分段拆分有效 |
| **前端显示**          | ✅ 如果可用则使用智能分段，否则回退            |

#### 数据流

```
/speech/assess 返回 segments
    ↓
ShadowingSheet._analyzeAudio() 提取 SmartSegmentFeedback
    ↓
ShadowingHistoryService.savePractice(segments: ...)
    ↓
Backend /shadowing/save 存储到 shadowing_practices.segments (JSONB)
    ↓
/shadowing/history 返回 segments (旧记录为 null)
    ↓
ShadowingPractice.fromJson() 解析 segments
```
