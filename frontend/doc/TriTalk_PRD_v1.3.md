# TriTalk 产品需求文档 (PRD)
> 产品名称: TriTalk - AI 语言练习伴侣
> 
> **版本**: 1.3
> 
> **日期**: 2026-01-29
> 
> **状态**: 草稿
> 

---

## **1. 产品概述**

### **1.1 产品愿景**

TriTalk 是一款 AI 驱动的语言学习应用，通过沉浸式角色扮演场景帮助用户提升口语能力。产品核心理念是：**学习语言最好的方式是实际使用它**。

### **1.2 目标用户**

- 希望提升口语表达能力的语言学习者
- 需要在特定场景（商务、旅行、社交等）练习对话的用户
- 追求自主学习、希望获得即时反馈的学习者

### **1.3 核心价值主张**

| **价值点** | **描述** |
| --- | --- |
| 🎭 **沉浸式场景** | 逼真的角色扮演场景，模拟真实生活对话 |
| 🎤 **发音评估** | 音素级发音分析 + 语调评估 |
| 📊 **智能反馈** | AI 即时语法纠正和地道表达建议 |
| 🔄 **跟读练习** | 可视化音高对比，科学练习发音 |
| ☁️ **多设备同步** | 学习进度云端同步，随处继续 |


### **1.4 市场定位与竞品分析**

#### **目标市场**

| 市场分类 | 描述 | 市场规模 |
| --- | --- | --- |
| **主要市场** | 中国、日本、韩国等亚洲市场的英语学习者 | 预计 2026 年达到 $180 亿 |
| **次要市场** | 欧美市场的多语言学习者 | 预计 2026 年达到 $120 亿 |
| **目标用户群** | 18-35 岁，追求高效学习的职场人士和学生 | - |

#### **竞品对比分析**

| 产品 | 核心功能 | 定价 | TriTalk 差异化优势 |
| --- | --- | --- | --- |
| **Duolingo** | 游戏化学习、词汇练习 | $6.99/月 | ✅ 更专注口语实战场景<br>✅ AI 发音评估更精准（音素级）<br>✅ 即时语法反馈 |
| **HelloTalk** | 真人语言交换 | $6.99/月 | ✅ 24/7 可用，无需等待真人<br>✅ 场景可控，针对性强<br>✅ 无社交压力 |
| **Elsa Speak** | 发音训练 | $11.99/月 | ✅ 场景更丰富（12+ 预置场景）<br>✅ 提供完整对话练习<br>✅ 支持自定义场景 |
| **Babbel** | 结构化课程 | $13.95/月 | ✅ AI 驱动，个性化学习路径<br>✅ 实时反馈，学习效率更高<br>✅ 价格更具竞争力 |

#### **核心竞争优势**

1. **🎯 场景化学习**：12+ 预置真实场景 + 无限自定义场景（Pro）
2. **🔬 专业发音评估**：音素级评分 + 音高可视化对比（Azure AI Speech）
3. **⚡ 即时反馈系统**：每条消息自动语法分析 + 地道表达建议
4. **🤖 AI 驱动**：基于 Gemini/Claude 的智能对话，自然流畅
5. **💰 高性价比**：Plus $9.99/月，低于主要竞品

---

## **2. 功能模块详解**

### **2.1 认证模块 (Auth)**

> 📁 frontend/lib/features/auth
> 

| **功能** | **描述** | **实现状态** |
| --- | --- | --- |
| Google 登录 | 使用 Google 账号快速登录 | ✅ 已完成 |
| Apple 登录 | 使用 Apple ID 登录（iOS） | ✅ 已完成 |
| 会话管理 | Token 刷新、登出处理 | ✅ 已完成 |

**技术实现**: 通过 Supabase Auth 实现，支持 RLS 行级安全策略。

---

### **2.2 引导模块 (Onboarding)**

> 📁 frontend/lib/features/onboarding
> 

| **功能** | **描述** |
| --- | --- |
| 欢迎引导 | 首次使用的产品介绍页面 |
| 语言选择 | 设置目标学习语言和母语 |

---

### **2.3 场景模块 (Scenes)**

> 📁 frontend/lib/features/scenes
> 

### **2.3.1 场景展示**

```
┌──────────────────────────────────────┐
│  场景列表 (Scene List)               │
│  ├── 标准场景 (预置)                 │
│  │   ├── ☕ 咖啡店                   │
│  │   ├── ✈️ 机场                    │
│  │   ├── 🏨 酒店                    │
│  │   └── ...                         │
│  └── 自定义场景 (用户创建)          │
└──────────────────────────────────────┘

```

### **2.3.2 场景功能**

| **功能** | **描述** | **API 端点** |
| --- | --- | --- |
| 场景浏览 | 查看预置和自定义场景 | - |
| 场景生成 | AI 生成自定义场景 | `POST /scene/generate` |
| 描述润色 | 优化用户输入的场景描述 | `POST /scene/polish` |
| 场景配置 | 设置角色分配 (用户/AI 角色) | - |
| 场景管理 | 添加、删除、排序场景 | - |
| 云端同步 | 自定义场景云端存储 | Supabase 直连 |

### **2.3.3 场景数据结构**

```dart
classScene {
String id;// 唯一标识
String key;// 场景键 (如 'coffee_shop')
String name;// 场景名称
String description;// 场景描述
String aiRole;// AI 扮演的角色
String userRole;// 用户扮演的角色
String context;// 场景上下文
bool isCustom;// 是否为自定义场景
}

```

---

### **2.4 聊天模块 (Chat)**

> 📁 frontend/lib/features/chat
> 

这是产品的**核心交互模块**，用户通过对话练习语言。

### **2.4.1 聊天核心功能**

![image.png](attachment:62a3f9ed-4fd0-4830-8b22-2bb86c4d504f:image.png)

### **2.4.2 消息交互功能**

| **功能** | **描述** | **API 端点** |
| --- | --- | --- |
| 发送文字消息 | 输入文字，获取 AI 回复 + 即时语法反馈 | `POST /chat/send` |
| 发送语音消息 | 录音 → 转文字 → AI 回复（流式） | `POST /chat/send-voice` |
| 语音转文字 | 音频转录为文字 | `POST /chat/transcribe` |
| 获取对话提示 | AI 建议下一句可以说什么 | `POST /chat/hint` |
| 消息优化 | 优化/润色用户准备发送的消息 | `POST /chat/optimize` |
| 删除消息 | 删除指定消息 | `DELETE /chat/messages` |
| 翻译消息 | 将消息翻译为用户母语 | `POST /common/translate` |

### **2.4.3 消息即时反馈系统 (Feedback Sheet)**

当用户发送消息后，系统会返回即时语法反馈：

> **NOTE：**以下所有反馈字段均来自 `POST /chat/send` 响应的 `feedback` 对象。
> 

| **反馈项** | **描述** | **API 端点** |
| --- | --- | --- |
| `is_perfect` | 是否完美无误 | `POST /chat/send`  |
| `corrected_text` | 修正后的文本 | `POST /chat/send`  |
| `native_expression` | 更地道的表达方式 | `POST /chat/send`  |
| `grammar_notes` | 语法要点说明 | `POST /chat/send`  |

内嵌跟读练习入口：

用户可在 Feedback Sheet 中直接点击 **native_expression** 或 **reference_answer** 旁的录音按钮，进入 **ShadowingSheet（跟读练习面板）**：

```
┌─────────────────────────────────────────────────┐
│  Native Expression                              │
│  "I'd love a large cappuccino, please!"        │
│                                    [🎤 跟读]    │  ← 点击进入 ShadowingSheet
├─────────────────────────────────────────────────┤
│  Reference Answer                               │
│  "Could I get a large cappuccino to go?"       │
│                                    [🎤 跟读]    │  ← 点击进入 ShadowingSheet
└─────────────────────────────────────────────────┘

```

跟读练习支持：

- 发音评估 (准确度、流利度、完整度)
- 音高对比可视化
- 单词级发音评分
- 练习历史记录

详见

2.5.2 跟读练习面板。

---

### **2.5 学习模块 (Study)**

> 📁 frontend/lib/features/study
> 

### **2.5.1 语法分析面板 (Analysis Sheet)**

> 📁 frontend/lib/features/study/presentation/widgets/analysis_sheet.dart (36KB)
> 

深度语法分析功能，提供流式加载体验。

> **NOTE：**以下所有分析项均由 **同一个 API 端点**: (`POST /chat/analyze`) 返回，以流式  **NDJSON 格式** 逐块推送。
> 

| **分析项** | **描述** | **返回类型** |
| --- | --- | --- |
| 摘要 (Summary) | 对话质量总结 | `{"type":"summary",...}` |
| 句子结构 | 句法成分拆解 | `{"type":"structure",...}` |
| 语法反馈 | 详细语法解析和例句 | `{"type":"grammar",...}` |
| 词汇学习 | 重点词汇、词性、例句 | `{"type":"vocabulary",...}` |
| 地道表达 | 习语和常用短语 | `{"type":"idioms",...}` |
| 语用分析 | 语境和语气分析 | `{"type":"pragmatic",...}` |
| 情感标签 | 表达的情感分类 | `{"type":"emotion",...}` |

### **2.5.2 跟读练习面板 (Shadowing Sheet)**

> 📁 frontend/lib/features/study/presentation/widgets/shadowing_sheet.dart (82KB)
> 

**核心口语训练功能**，通过跟读模仿提升发音：

```
┌─────────────────────────────────────────┐
│  跟读目标文本                           │
│  "I'd like a large cappuccino, please" │
├─────────────────────────────────────────┤
│  🎤 录音按钮                            │
├─────────────────────────────────────────┤
│  发音评分                               │
│  ├── 准确度: 92%                        │
│  ├── 流利度: 88%                        │
│  └── 完整度: 95%                        │
├─────────────────────────────────────────┤
│  音高对比图 (Pitch Contour)             │
│  [可视化: 用户 vs 原生说话者]           │
├─────────────────────────────────────────┤
│  单词级评估                             │
│  I'd(✅) like(✅) a(✅) large(⚠️)...    │
└─────────────────────────────────────────┘

```

| **功能** | **描述** | **API 端点** |
| --- | --- | --- |
| 发音评估 | 音素级发音准确度分析 | `POST /speech/assess` |
| 音高对比 | 可视化用户与原生发音的语调差异 | - |
| 单词评分 | 每个单词的发音评分（红黄绿灯） | - |
| 历史记录 | 同一句子的练习历史 | `GET /shadowing/history` |
| 练习保存 | 保存练习记录到云端 | `POST /shadowing/save` |

### **2.5.3 词汇收藏 (Vocab Service)**

> 📁 frontend/lib/features/study/data/vocab_service.dart
> 

| **功能** | **描述** |
| --- | --- |
| 收藏词汇 | 将学习中的词汇加入收藏 |
| 词汇播放 | TTS 播放单词发音 |
| 同步存储 | 云端同步词汇收藏列表 |

### **2.5.4 笔记功能 (Note Service)**

> 📁 frontend/lib/features/study/data/note_service.dart
> 

| **功能** | **描述** |
| --- | --- |
| 保存句子 | 保存重要句子到笔记 |
| 笔记管理 | 查看、删除已保存笔记 |

---

### **2.6 语音模块 (Speech)**

> 📁 frontend/lib/features/speech
> 

### **2.6.1 发音评估服务 (Speech Assessment)**

使用 **Azure AI Speech Pronunciation Assessment API** 实现：

| **评估维度** | **描述** |
| --- | --- |
| 准确度 (Accuracy) | 发音的准确程度 |
| 流利度 (Fluency) | 语速和停顿的自然程度 |
| 完整度 (Completeness) | 是否读完整个句子 |
| 韵律 (Prosody) | 语调和重音的自然程度 |

**评估粒度**:

- 句子级评分
- 单词级评分（红黄绿灯反馈）
- 音素级分析（Phoneme-level）

### **2.6.2 语音合成服务 (TTS)**

| **服务** | **描述** | **API 端点** |
| --- | --- | --- |
| 流式 TTS | 大段文本流式语音合成 | `POST /tts/gcp/generate` |
| 单词 TTS | 单词发音播放 | `POST /tts/word` |

使用 **GCP Gemini TTS** 实现高质量语音合成。

---

### **2.7 个人中心模块 (Profile)**

> 📁 frontend/lib/features/profile
> 

| **功能** | **描述** |
| --- | --- |
| 个人信息 | 查看账号信息 |
| 语言设置 | 切换学习语言/母语 |
| 收藏管理 | 查看收藏的词汇和句子 |
| 设置 | 应用设置项 |

---

### **2.8 订阅模块 (Subscription)**

> 📁 frontend/lib/features/subscription
> 

| **功能** | **描述** |
| --- | --- |
| 订阅计划 | 查看可用订阅方案 |
| 支付集成 | 处理订阅支付 |
| 订阅状态 | 管理当前订阅状态 |

### **2.8.1 付费墙触发策略**

| 触发场景 | 免费用户限额 | 触发时机 | 展示内容 |
| --- | --- | --- | --- |
| **对话次数** | 3次/天 | 第4次尝试对话时 | "今日对话次数已用完，升级 Plus 解锁无限对话" |
| **语音输入** | 3次/天 | 第4次点击语音按钮时 | "升级 Plus 享受无限语音输入" |
| **自定义场景** | 不可用 | 点击"创建场景"按钮时 | "自定义场景是 Plus 会员专属功能" |
| **TTS 朗读** | 3次/天 | 第4次点击朗读按钮时 | "升级 Pro 享受无限 AI 朗读" |
| **发音评估** | 3次/天 | 第4次进入跟读练习时 | "升级 Plus 获得更多发音评估次数（20次/天）" |
| **深度分析** | 3次/天 | 第4次点击"分析"按钮时 | "升级 Plus 解锁无限语法分析" |

**触发逻辑**：
- 每日限额在用户本地时区的 00:00 重置
- 限额计数存储在 `user_profiles.daily_*_count` 字段
- 后端 API 验证限额，前端同步显示剩余次数
- 付费用户跳过所有限额检查

---

## **3. 系统架构**

### **3.1 技术架构图**

![image.png](attachment:6519e058-a41c-4518-a912-753d8f2728de:image.png)

### **3.2 前端架构**

采用 **Clean Architecture** 分层架构：

```
features/
├── feature_name/
│   ├── data/           # 数据层 (API 调用、本地存储)
│   │   ├── services/   # 业务服务
│   │   └── datasources/# 数据源
│   ├── domain/         # 领域层 (模型、仓库接口)
│   │   ├── models/     # 数据模型
│   │   └── repositories/
│   └── presentation/   # 表现层 (UI)
│       ├── pages/      # 页面
│       ├── widgets/    # 组件
│       └── notifiers/  # 状态管理

```

### **3.3 后端 API 概览**

| **类别** | **端点数量** | **主要功能** |
| --- | --- | --- |
| 聊天 | 6 | 消息发送、转录、提示、优化 |
| 场景 | 2 | 场景生成、描述润色 |
| 语音 | 3 | TTS、发音评估 |
| 跟读 | 2 | 历史保存、历史查询 |
| 通用 | 1 | 翻译 |
| 系统 | 4 | 健康检查、文档 |

---

## **4. 数据模型**

### **4.1 核心数据表（详细定义）**

#### **users 表**（Supabase Auth 自动管理）

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | uuid | PK | 用户唯一标识 |
| `email` | text | UNIQUE | 用户邮箱 |
| `created_at` | timestamp | NOT NULL | 创建时间 |

#### **user_profiles 表**

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `user_id` | uuid | PK, FK(users.id) | 用户 ID |
| `learning_language` | text | NOT NULL | 学习语言（如 'en'） |
| `native_language` | text | NOT NULL | 母语（如 'zh'） |
| `subscription_tier` | text | DEFAULT 'free' | 订阅等级（free/plus/pro） |
| `subscription_expires_at` | timestamp | NULL | 订阅到期时间 |
| `daily_chat_count` | int | DEFAULT 0 | 今日对话次数 |
| `daily_voice_count` | int | DEFAULT 0 | 今日语音输入次数 |
| `daily_tts_count` | int | DEFAULT 0 | 今日 TTS 朗读次数 |
| `daily_assessment_count` | int | DEFAULT 0 | 今日发音评估次数 |
| `daily_reset_at` | timestamp | NOT NULL | 每日重置时间 |
| `created_at` | timestamp | DEFAULT now() | 创建时间 |
| `updated_at` | timestamp | DEFAULT now() | 更新时间 |

#### **scenes 表**

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | uuid | PK | 场景 ID |
| `user_id` | uuid | FK(users.id), NULL | 创建者 ID（NULL 表示预置场景） |
| `key` | text | UNIQUE | 场景键（如 'coffee_shop'） |
| `name` | text | NOT NULL | 场景名称 |
| `description` | text | NOT NULL | 场景描述 |
| `ai_role` | text | NOT NULL | AI 角色 |
| `user_role` | text | NOT NULL | 用户角色 |
| `context` | text | NOT NULL | 场景上下文 |
| `is_custom` | boolean | DEFAULT false | 是否自定义 |
| `sort_order` | int | DEFAULT 0 | 排序顺序 |
| `created_at` | timestamp | DEFAULT now() | 创建时间 |

#### **chat_history 表**

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | uuid | PK | 消息 ID |
| `user_id` | uuid | FK(users.id) | 用户 ID |
| `scene_key` | text | NOT NULL | 场景键 |
| `role` | text | NOT NULL | 'user' 或 'assistant' |
| `content` | text | NOT NULL | 消息内容 |
| `feedback_json` | jsonb | NULL | 即时反馈数据 |
| `audio_url` | text | NULL | 语音消息 URL（如有） |
| `created_at` | timestamp | DEFAULT now() | 创建时间 |

**索引**：
```sql
CREATE INDEX idx_chat_history_user_scene ON chat_history(user_id, scene_key, created_at DESC);
```

#### **favorites 表**

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | uuid | PK | 收藏 ID |
| `user_id` | uuid | FK(users.id) | 用户 ID |
| `type` | text | NOT NULL | 'word' 或 'sentence' |
| `content` | text | NOT NULL | 收藏内容 |
| `translation` | text | NULL | 翻译 |
| `source_scene` | text | NULL | 来源场景 |
| `notes` | text | NULL | 用户笔记 |
| `created_at` | timestamp | DEFAULT now() | 创建时间 |

**索引**：
```sql
CREATE INDEX idx_favorites_user_type ON favorites(user_id, type, created_at DESC);
```

### **4.2 跟读历史记录结构**

```css
interface ShadowingPractice {
id: string;
user_id: string;
target_text: string;      // 跟读目标文本
source_type: 'ai_message' | 'native_expression' | 'reference_answer' | 'custom';
source_id?: string;       // 来源消息 ID
scene_key?: string;       // 场景标识
accuracy_score: number;
fluency_score: number;
completeness_score: number;
prosody_score?: number;
feedback_json: object;    // 详细反馈数据
created_at: timestamp;
}

```

---

## **5. 用户旅程**

### **5.1 新用户首次使用**

用户新用户首次体验

![image.png](attachment:24f1d141-553e-474e-a36c-afbee726b6fc:image.png)

### **5.2 日常学习流程**

1. **选择场景** → 进入对话
2. **发送消息** (文字/语音) → 获得即时语法反馈
3. **查看分析** → 深度学习语法和词汇
4. **跟读练习** → 提升发音准确度
5. **收藏词汇** → 巩固学习内容

---

## **6. 非功能性需求**

### **6.1 性能要求**

| **指标** | **目标** |
| --- | --- |
| API 响应时间 | < 500ms (非流式) |
| TTS 首字节延迟 | < 300ms |
| 发音评估延迟 | < 2s |
| 应用启动时间 | < 2s |

### **6.2 安全要求**

- **认证**: Supabase Auth + JWT
- **数据隔离**: PostgreSQL RLS 策略
- **API 安全**: Cloudflare Workers 隐藏 LLM API 密钥
- **传输加密**: HTTPS 全程加密

### **6.3 可用性要求**

- **离线支持**: 对话历史本地缓存
- **多设备同步**: 云端数据实时同步
- **错误恢复**: 网络异常时的优雅降级

### **6.4 可扩展性要求**

| 指标 | 目标 | 实现方式 |
| --- | --- | --- |
| 并发用户数 | 支持 10,000+ 同时在线 | Cloudflare Workers 自动扩展 |
| 数据库连接池 | 支持 100+ 并发查询 | Supabase 连接池管理 |
| API 限流 | 100 req/min/user | Cloudflare Rate Limiting |
| 水平扩展 | 无状态架构 | Workers + Supabase 无服务器架构 |

### **6.5 国际化与本地化**

| 语言 | 支持状态 | 覆盖范围 | 优先级 |
| --- | --- | --- | --- |
| 简体中文 | ✅ 完整支持 | UI + 场景内容 | P0 |
| 英语 | ✅ 完整支持 | UI + 场景内容 | P0 |
| 日语 | 🔄 计划中 | UI + 场景内容 | P1 |
| 韩语 | 🔄 计划中 | UI + 场景内容 | P2 |
| 西班牙语 | 🔄 计划中 | UI + 场景内容 | P2 |

**技术实现**：
- 使用 Flutter `intl` 包管理多语言
- 所有文本内容外部化到 `.arb` 文件
- 支持 RTL（从右到左）语言（如阿拉伯语）

### **6.6 可访问性要求**

| 要求 | 标准 | 实施方式 |
| --- | --- | --- |
| 屏幕阅读器支持 | WCAG 2.1 AA | 所有 UI 元素提供语义化标签 |
| 字体大小调整 | 系统级支持 | 支持系统字体缩放（100%-200%） |
| 色彩对比度 | WCAG 2.1 AA | 文字与背景对比度 ≥ 4.5:1 |
| 键盘导航 | 完整支持 | 所有功能可通过键盘操作（Web 版） |
| 语音控制 | iOS/Android 原生 | 支持系统级语音控制 |

### **6.7 数据隐私与合规**

| 合规要求 | 实施方式 | 状态 |
| --- | --- | --- |
| **GDPR 合规** | 提供数据导出和删除功能 | ✅ 已实施 |
| **CCPA 合规** | 用户数据透明化和控制权 | ✅ 已实施 |
| **数据加密** | 传输层 TLS 1.3，存储层 AES-256 | ✅ 已实施 |
| **隐私政策** | 明确说明数据收集和使用 | ⏳ 待完善 |
| **Cookie 政策** | Web 版 Cookie 同意横幅 | 🔄 计划中 |

**数据保留策略**：
- **活跃用户数据**：永久保留
- **注销用户数据**：30 天后自动删除
- **匿名化分析数据**：保留 2 年用于产品改进
- **支付数据**：仅存储订阅状态，不存储支付信息（由 RevenueCat 管理）

---

## **7. 商业模式与订阅 (Business Model & Subscription)**

### **7.1 订阅分级体系**

TriTalk 采用 **Freemium** 模式，确保核心体验免费，高级功能付费。

| 计费方式 | 🆓 Free (免费版) | ⭐ Plus (进阶版) | 💎 Pro (专业版) |
| --- | --- | --- | --- |
| **月付价格** | 免费 | **$9.99 /月** | **$24.99 /月** |
| **年付价格** | - | **$71.99 /年** (省 40%) | **$179.99 /年** (省 40%) |
| **定价逻辑** | 体验核心流 | 高性价比，满足日练 | 极致体验，母语环境 |

### **7.2 详细权益矩阵 (Entitlements)**

| 功能模块 | 功能项 | 🆓 Free | ⭐ Plus | 💎 Pro | 限额说明 |
| --- | --- | --- | --- | --- | --- |
| **对话练习** | AI 对话次数 | 3次/天 | ✅ **无限** | ✅ **无限** | 文本 Token 成本较低 |
|  | 语音输入 | 3次/天 | ✅ **无限** | ✅ **无限** | STT 成本可控 |
| **跟读练习** | 发音评估 | 3次/天 | 20次/天 | 100次/天 | 评估 API 成本较高 |
|  | 音高分析 | ❌ | ✅ | ✅ | 高级视觉反馈 |
| **TTS 语音** | AI 朗读 | 3次/天 | 100次/天 | ✅ **无限** | **关键成本点** |
| **场景功能** | 预置场景 | 5个 | 全部 (12个) | 全部 (12个) | 内容解锁 |
|  | 自定义场景 | ❌ | 30个/月 | ✅ **无限** | 创作自由度 |
| **辅助功能** | 语法/润色 | 3次/天 | ✅ **无限** | ✅ **无限** | - |

> 成本控制策略:
> 
> - **Plus 用户**: 限制 TTS 100次/天，防止 API (如 Azure Speech) 费用倒挂。100句足以覆盖 1.5 小时高强度练习。
> - **Pro 用户**: 针对高净值用户放开限制，提供极致体验。

### **7.3 试用与支付流程**

- **平台**: Apple App Store (IAP) & Google Play Store (Billing)。
- **服务商**: RevenueCat 统一管理。
- **试用**: 提供 **7天免费试用** (自动续订)，提高转化率。
- **支付墙 (Paywall)**: 在用户触发每日限额 (如第4次对话) 或点击锁定的高级功能 (如自定义场景) 时弹出。

### **7.4 收入与成本模型**

#### **盈亏平衡分析**（基于 [成本分析文档](cost_analysis.md)）

| DAU 规模 | 付费转化率 | 月收入（Plus @ $9.99） | 月收入（Pro @ $24.99） | 月总成本 | 净利润 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| 100 DAU | 5% | $50 | $125 | $165 | **-$15** | ❌ 亏损 |
| 1,000 DAU | 8% | $799 | $1,999 | $2,400 | **$398** | ✅ 微盈利 |
| 5,000 DAU | 10% | $4,995 | $12,495 | $12,000 | **$5,490** | ✅ 盈利 |
| 10,000 DAU | 12% | $11,988 | $29,988 | $24,000 | **$17,976** | ✅ 健康盈利 |

**关键假设**：
- Plus/Pro 用户比例为 2:1（67% Plus，33% Pro）
- 成本基于 50% TTS 缓存命中率
- GCP $25,000 赠金可覆盖初期 6-12 个月

**盈亏平衡点**：约 **800-1,000 DAU**（假设 8-10% 付费转化率）

#### **成本优化策略**（详见 [cost_analysis.md](cost_analysis.md)）

| 策略 | 影响服务 | 预估节省 | 实施优先级 |
| --- | --- | --- | --- |
| **TTS 音频缓存** | GCP TTS | 50-90% | P0 |
| **发音评估限额控制** | Azure Speech | 30-50% | P0 |
| **本地 TTS Fallback** | GCP TTS | 20-40% | P1 |
| **批量请求合并** | All APIs | 10-20% | P2 |
| **CDN 缓存层（R2）** | GCP TTS | 额外 10-20% | P2 |

**当前优势**：
- ✅ GCP $25,000 赠金覆盖初期成本
- ✅ Cloudflare Workers 免费额度充足（100K 请求/天）
- ✅ Supabase Free Tier 支持 500 DAU

### **7.5 用户增长策略**

| 策略 | 目标指标 | 实施方式 | 预期效果 |
| --- | --- | --- | --- |
| **免费试用** | 转化率 +30% | 7 天 Plus 免费试用（自动续订） | 降低决策门槛 |
| **推荐奖励** | 病毒系数 K > 0.5 | 推荐好友获得 1 周 Plus 会员 | 病毒式增长 |
| **限时优惠** | 首月转化率 +20% | 首月 5 折优惠（$4.99） | 促进快速决策 |
| **学习打卡** | 7 日留存 +15% | 连续打卡 7 天送 3 天 Plus | 养成使用习惯 |
| **社交分享** | 自然增长 +10% | 分享学习成果到社交媒体 | 品牌曝光 |

**增长漏斗**：
```
下载 → 注册 → 首次对话 → 触发付费墙 → 开始试用 → 付费转化
100%     80%      60%         40%           20%         8-12%
```

### **7.6 用户留存机制**

| 机制 | 目标留存率 | 实施方式 | 优先级 |
| --- | --- | --- | --- |
| **每日提醒** | 次日留存 60%+ | 智能推送学习提醒（本地时区 19:00） | P0 |
| **成就系统** | 7 日留存 40%+ | 解锁徽章、等级系统（Bronze/Silver/Gold） | P1 |
| **学习报告** | 30 日留存 25%+ | 每周学习总结邮件（对话数、发音进步） | P1 |
| **连续打卡** | 长期留存 | 连续打卡奖励（3/7/30 天里程碑） | P1 |
| **社交功能** | 长期留存 | 学习小组、排行榜（未来规划） | P3 |

**关键留存指标**：
- **D1 留存**：60%+（行业平均 40%）
- **D7 留存**：40%+（行业平均 20%）
- **D30 留存**：25%+（行业平均 10%）
- **付费用户留存**：80%+（月度）

## **8. 未来规划**

| **功能** | **优先级** | **状态** |
| --- | --- | --- |
| 学习统计仪表盘 | P1 | 计划中 |
| 多用户对话模式 | P2 | 计划中 |
| 离线 TTS | P2 | 计划中 |
| 学习打卡系统 | P2 | 计划中 |
| 社区分享功能 | P3 | 待评估 |

---

## **9. 附录**

### **9.1 相关文档**

| **文档** | **路径** |
| --- | --- |
| 主 README | **README.md** |
| 后端文档 | **backend/README.md** |
| 开发指南 | **backend/docs/development_guide.md** |
| 安全文档 | **backend/docs/security.md** |
|  |  |

### **9.2 技术栈汇总**

| **层级** | **技术** |
| --- | --- |
| 前端 | Flutter (Dart), Riverpod, SharedPreferences |
| 后端 | Cloudflare Workers, TypeScript, Hono |
| 数据库 | Supabase (PostgreSQL) |
| AI/LLM | OpenRouter (Gemini/Claude/GPT) |
| TTS | GCP Gemini TTS |
| 发音评估 | Azure AI Speech |
| 认证 | Supabase Auth (Google/Apple) |

### **9.3 文档更新日志**

| 版本 | 日期 | 更新内容 |
| --- | --- | --- |
| **v1.3** | 2026-01-29 | ✅ 新增市场定位与竞品分析（1.4）<br>✅ 新增付费墙触发策略（2.8.1）<br>✅ 扩展数据模型详细定义（4.1）<br>✅ 新增收入与成本模型（7.4）<br>✅ 新增用户增长策略（7.5）<br>✅ 新增用户留存机制（7.6）<br>✅ 扩展非功能性需求（6.4-6.7） |
| **v1.2** | 2026-01-29 | 整合定价策略和订阅模式 |
| **v1.1** | 2026-01-24 | 初始版本 |

---

**文档维护者**: TriTalk Product Team  
**最后更新**: 2026-01-29  
**下次审查**: 2026-02-15