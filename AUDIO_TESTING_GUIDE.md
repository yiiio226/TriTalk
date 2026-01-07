# 音频转录测试指南

## 快速测试步骤

### 1. 启动后端

```bash
cd backend
npm run dev
```

等待输出:

```
⎔ Starting local server...
Ready on http://0.0.0.0:8787
```

### 2. 启动前端

```bash
cd frontend
flutter run
```

### 3. 测试录音转录

1. 打开任意对话场景
2. 点击输入框旁边的 **麦克风图标** (智能语音输入)
3. 按住录音按钮说话
4. 松开后等待转录

**预期结果**:

- ✅ 转录的文字与你说的内容相关
- ✅ 文字自动填入输入框
- ✅ 显示 "Voice transcribed & optimized" 提示

### 4. 查看后端日志

在后端终端应该看到:

```
🎤 Audio file size: XXXXX bytes at /path/to/file.wav
=== AUDIO DEBUG INFO ===
Original File Name: voice_input_1234567890.wav
File MIME Type: audio/wav
Detected Format: wav
File Size (bytes): 128044
Base64 Length: 170728
WAV Header Check: RIFF (should be RIFF)
WAV Format: WAVE (should be WAVE)
WAV Audio Format Code: 1 (1=PCM)
WAV Channels: 1
========================
```

---

## 常见问题

### ❌ "Recording too short or empty"

**原因**: iOS 模拟器没有真实麦克风
**解决**: 使用真实设备测试

### ❌ "Failed to transcribe audio"

**检查**:

1. 后端是否正常运行 (`npm run dev`)
2. `frontend/lib/env.dart` 中的 `localBackendUrl` 是否正确
3. 后端日志中是否有 OpenRouter API 错误

### ❌ 转录文字仍然不相关

**可能原因**:

1. 录音音量太小
2. 背景噪音太大
3. 说话不清晰
4. 语言设置不匹配 (检查 Settings → Target Language)

**解决步骤**:

1. 使用清晰、缓慢的语速再试一次
2. 在安静的环境下录音
3. 录音时间保持在 2-10 秒
4. 查看后端完整日志

---

## 验证编码是否正确

### 方法 1: 检查 Base64 前缀

后端日志中的 `Base64 Preview` 应该以 `UklGR` 开头

- `UklGR` 是 "RIFF" 的 base64 编码
- 这证明 WAV 文件头被正确编码

### 方法 2: 验证文件大小

16kHz, Mono, 16-bit PCM 的 WAV 文件:

- 1 秒录音 ≈ 32KB
- 3 秒录音 ≈ 96KB
- 5 秒录音 ≈ 160KB

如果文件大小明显偏离,可能是编码问题。

---

## 调试命令

### 查看所有 WAV 文件

```bash
# iOS 真机/模拟器
find ~/Library/Developer/CoreSimulator -name "*.wav" -ls

# 导出的文件位置
ls -lh ~/Library/Mobile\ Documents/com~apple~CloudDocs/TriTalk/
```

### 手动测试 WAV 文件

如果前端导出了 WAV 文件,可以:

1. 用 macOS 的 QuickTime 播放测试
2. 使用 `file` 命令检查格式:

```bash
file voice_input_1234567890.wav
# 应输出: RIFF (little-endian) data, WAVE audio, Microsoft PCM, 16 bit, mono 16000 Hz
```

---

## 回滚方法

如果需要回到 m4a 格式:

1. **前端** (`chat_screen.dart` 和 `shadowing_sheet.dart`):

```dart
const RecordConfig(
  encoder: AudioEncoder.aacLc,  // 改回 aacLc
)
```

文件扩展名改为 `.m4a`

2. **后端** (`index.ts`):

```typescript
const fileName = audioBlob.name || "audio.m4a";
let audioFormat = "m4a"; // default
```

3. 重启前端和后端
