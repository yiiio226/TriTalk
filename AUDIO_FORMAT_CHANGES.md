# 音频转录格式修改总结

## 问题描述

转录回来的文字完全不相关,怀疑是 m4a 格式支持的问题。

## 解决方案

将录音格式从 **m4a** 改为 **WAV (PCM 16-bit, 16kHz, Mono)**

---

## 修改内容

### 1. 前端修改 (Flutter)

#### 文件: `frontend/lib/screens/chat_screen.dart`

**修改点 1**: 录音配置 (第 210-225 行)

- ✅ 文件扩展名: `.m4a` → `.wav`
- ✅ 添加 `RecordConfig` 参数:
  - `encoder: AudioEncoder.wav` - 使用 WAV 编码器
  - `sampleRate: 16000` - 16kHz 采样率(语音识别最佳)
  - `numChannels: 1` - 单声道音频

**修改点 2**: 文件导出逻辑 (第 149 行)

- ✅ 文件类型检查: `.m4a` → `.wav`

#### 文件: `frontend/lib/widgets/shadowing_sheet.dart`

**修改点**: 跟读练习录音配置 (第 35-48 行)

- ✅ 同样从 m4a 改为 wav
- ✅ 添加相同的 `RecordConfig` 参数

---

### 2. 后端修改 (Cloudflare Workers)

#### 文件: `backend/src/index.ts`

**修改点 1**: Base64 编码优化 (第 316-330 行)

```typescript
// 之前: 逐字节拼接,可能导致大文件问题
for (let i = 0; i < uint8Array.length; i++) {
  binary += String.fromCharCode(uint8Array[i]);
}

// 现在: 使用 64KB 分块处理
const CHUNK_SIZE = 65536;
for (let i = 0; i < uint8Array.length; i += CHUNK_SIZE) {
  const chunk = uint8Array.subarray(
    i,
    Math.min(i + CHUNK_SIZE, uint8Array.length)
  );
  binary += String.fromCharCode.apply(null, Array.from(chunk));
}
```

**原因**:

- 直接拼接大量字节可能会导致内存问题
- 分块处理更可靠,特别是对于二进制音频数据

**修改点 2**: 默认格式 (第 333-334 行)

- ✅ 默认格式: `m4a` → `wav`
- ✅ 默认文件名: `audio.m4a` → `audio.wav`

**修改点 3**: 增强调试日志 (第 352-373 行)
新增以下调试信息:

- ✅ MIME 类型检查
- ✅ WAV 文件头验证 (RIFF/WAVE 签名)
- ✅ WAV 格式代码检查 (应为 1 = PCM)
- ✅ 声道数检查

---

### 3. 文档更新

#### 文件: `backend/guide/tts.md`

**修改点**: 支持格式说明 (第 45-46 行)

```markdown
1. **输入**: 用户录音文件 (wav/mp3/webm/ogg/flac/aac/m4a)。
   - **推荐格式**: WAV (PCM 16-bit, 16kHz, Mono) - 最佳转录准确度
```

---

## 技术说明

### 为什么选择 WAV?

1. **无损格式**: WAV 是无压缩的 PCM 格式,保留所有音频信息
2. **广泛支持**: 所有语音识别服务都支持 WAV
3. **更好的兼容性**: Gemini 2.0 Flash Lite 对 WAV 的支持最好
4. **标准化**: 16kHz/Mono 是语音识别的行业标准

### 编码流程验证

#### 前端 (Flutter)

1. 录音 → WAV 文件 (16kHz, Mono, PCM)
2. 通过 MultipartRequest 发送到后端

#### 后端 (Workers)

1. 接收 WAV 文件
2. 读取为 ArrayBuffer
3. 转换为 Uint8Array
4. **分块处理** 转为 base64
5. 验证 WAV 文件头 (RIFF/WAVE)
6. 发送到 Gemini API

#### Gemini API

```json
{
  "type": "input_audio",
  "input_audio": {
    "data": "<base64_wav_data>",
    "format": "wav"
  }
}
```

---

## 验证步骤

运行应用后,查看后端日志应显示:

```
=== AUDIO DEBUG INFO ===
Original File Name: voice_input_1234567890.wav
File MIME Type: audio/wav
Detected Format: wav
File Size (bytes): 128044
Base64 Length: 170728
Base64 Preview (first 100 chars): UklGRlyUAQBXQVZFZm10IBAAAAABAAEAgD...
WAV Header Check: RIFF (should be RIFF)
WAV Format: WAVE (should be WAVE)
WAV Audio Format Code: 1 (1=PCM)
WAV Channels: 1
========================
```

---

## 潜在问题排查

如果转录仍然不准确,检查:

1. **文件大小**: 确保录音文件 > 1000 字节 (已有检查)
2. **WAV 格式**: 查看日志确认是 PCM 格式
3. **Base64 编码**: 前 100 个字符应以 `UklGR` 开头 (RIFF 的 base64)
4. **网络传输**: 确保 FormData 正确发送
5. **Gemini API**: 查看 OpenRouter 返回的错误信息

---

## 下一步

如果问题仍然存在:

1. 检查本地开发 URL 是否正确 (查看 `lib/env.dart`)
2. 使用真实设备测试 (iOS 模拟器麦克风可能有问题)
3. 查看 Cloudflare Workers 日志的完整输出
4. 尝试更短/更清晰的录音测试
