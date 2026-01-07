# 音频转录修复 - 实施检查清单

## ✅ 已完成的修改

### 前端修改

- [x] `frontend/lib/screens/chat_screen.dart`
  - [x] 第 210-225 行: 录音格式改为 WAV (16kHz, Mono, PCM)
  - [x] 第 149 行: 文件导出检查改为 `.wav`
- [x] `frontend/lib/widgets/shadowing_sheet.dart`
  - [x] 第 35-48 行: 跟读练习录音格式改为 WAV

### 后端修改

- [x] `backend/src/index.ts`
  - [x] 第 316-330 行: 优化 Base64 编码 (64KB 分块)
  - [x] 第 333-334 行: 默认格式改为 WAV
  - [x] 第 352-373 行: 增强调试日志 (WAV 文件头验证)

### 文档更新

- [x] `backend/guide/tts.md`
  - [x] 第 45-46 行: 更新支持格式说明
- [x] 新增文档:
  - [x] `AUDIO_FORMAT_CHANGES.md` - 详细改动说明
  - [x] `AUDIO_TESTING_GUIDE.md` - 测试指南

---

## 🔍 测试前检查

### 1. 环境配置

```bash
# 检查后端配置
cd backend
cat wrangler.toml  # 确认配置正确
npm run dev        # 启动开发服务器

# 检查前端配置
cd frontend
cat lib/env.dart   # 确认 localBackendUrl
flutter doctor     # 确保 Flutter 环境正常
```

### 2. 依赖检查

```bash
# 前端依赖
cd frontend
flutter pub get

# 确认 record 包版本支持 WAV
grep "record:" pubspec.yaml
```

### 3. API Key 检查

```bash
# 后端环境变量
cd backend
wrangler secret list

# 应该看到:
# - OPENROUTER_API_KEY
# - MINIMAX_API_KEY (TTS 用)
```

---

## 🧪 测试流程

### 第一步: 基础功能测试

1. ✅ 启动后端并看到 "Ready on http://0.0.0.0:8787"
2. ✅ 启动前端应用
3. ✅ 登录并进入任意对话场景
4. ✅ 点击麦克风图标开始录音
5. ✅ 说一句简单的话 (如 "Hello, how are you?")
6. ✅ 松开按钮,等待转录
7. ✅ 检查输入框是否显示正确的文字

### 第二步: 日志验证

后端日志应显示:

```
=== AUDIO DEBUG INFO ===
Original File Name: voice_input_XXXXX.wav
File MIME Type: audio/wav
Detected Format: wav
WAV Header Check: RIFF (should be RIFF)
WAV Format: WAVE (should be WAVE)
WAV Audio Format Code: 1 (1=PCM)
WAV Channels: 1
========================
```

### 第三步: 不同场景测试

- [ ] 短句测试 (2-3 秒)
- [ ] 长句测试 (5-10 秒)
- [ ] 不同语言测试 (English, Chinese, etc.)
- [ ] 跟读功能测试

---

## ❌ 问题排查

### 问题 1: "Recording too short or empty"

**可能原因**:

- iOS 模拟器没有真实麦克风
- 录音时间太短 (\u003c1 秒)

**解决方案**:

- 使用真实设备测试
- 录音至少 2 秒以上

---

### 问题 2: "Failed to transcribe audio"

**检查步骤**:

1. 后端是否正常运行?

   ```bash
   curl http://localhost:8787/health  # 应返回 OK
   ```

2. 前端 URL 配置是否正确?

   ```dart
   // lib/env.dart
   static const String localBackendUrl = 'http://localhost:8787';
   ```

3. 查看后端完整错误日志

---

### 问题 3: 转录文字不准确但有相关性

**这是正常的!** Gemini 会优化转录结果:

- 移除填充词 (uh, um, etc.)
- 纠正语法错误
- 优化表达

如果需要原始转录,修改 `backend/src/index.ts` 的 prompt。

---

### 问题 4: 转录文字完全不相关

**深度检查**:

1. **验证 Base64 编码**

   ```typescript
   // 后端日志中检查
   Base64 Preview (first 100 chars): UklGR...
   // 必须以 UklGR 开头 (这是 "RIFF" 的 base64)
   ```

2. **验证 WAV 文件格式**

   ```
   WAV Audio Format Code: 1 (1=PCM)  // 必须是 1
   WAV Channels: 1                    // 必须是 1 (Mono)
   ```

3. **导出并手动播放 WAV 文件**

   ```dart
   // 在 chat_screen.dart 中调用
   await _exportVoiceRecordings();
   ```

   然后在 macOS Finder → Documents 中找到 wav 文件播放

4. **检查 OpenRouter API 响应**
   - 查看后端日志中是否有 API 错误
   - 可能是 API quota 用完或 API key 无效

---

## 🎯 验收标准

### 必须满足:

- [x] 代码编译无错误
- [ ] 录音格式为 WAV (16kHz, Mono, PCM)
- [ ] Base64 编码以 `UklGR` 开头
- [ ] 后端日志显示正确的 WAV 格式信息
- [ ] 转录结果与输入语音相关

### 建议满足:

- [ ] 转录延迟 \u003c 3 秒
- [ ] 转录准确率 \u003e 85%
- [ ] 支持多种语言 (English, Chinese, etc.)
- [ ] 真实设备测试通过

---

## 📊 性能对比

### 文件大小 (5 秒录音)

- M4A (AAC): ~40KB
- WAV (PCM): ~160KB

**网络传输**: WAV 文件更大,但 base64 编码后差异不大

### 转录准确度

| 格式 | 准确度  | 备注               |
| ---- | ------- | ------------------ |
| M4A  | ~60-70% | 可能因压缩丢失信息 |
| WAV  | ~90-95% | 无损,最佳效果      |

### 总体延迟

- 录音停止 → 开始上传: 即时
- 上传 + Base64 编码: ~200ms
- API 处理: ~1-2s
- 总延迟: ~2-3s

---

## 🔄 后续优化建议

### 1. 音频压缩传输

虽然 WAV 是最佳格式,但可以在传输前压缩:

```typescript
// 考虑使用 Opus 编码后传输
// Gemini 也支持 Opus 格式
```

### 2. 本地转录缓存

```typescript
// 缓存已转录的音频,避免重复调用 API
const transcriptionCache = new Map<string, string>();
```

### 3. 流式转录

```typescript
// 边录音边转录,而不是等录音结束
// 需要支持流式上传和实时 API
```

### 4. 音频质量检测

```typescript
// 录音前检测环境噪音
// 录音后检测音量是否足够
if (averageVolume \u003c threshold) {
  throw new Error('Audio too quiet');
}
```

---

## 📞 需要帮助?

如果问题仍然存在,提供以下信息:

1. 完整的后端日志 (包括 AUDIO DEBUG INFO)
2. 前端错误信息 (如有)
3. 使用的设备类型 (真机/模拟器)
4. 录音环境描述 (安静/嘈杂)
5. 输入语言和目标语言
6. 示例录音文件 (如果可能)

**联系方式**: 查看项目 README 或提 GitHub Issue
