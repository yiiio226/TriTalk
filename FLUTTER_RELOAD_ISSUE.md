# Flutter 热重载 vs 完全重启说明

## 问题现象

修改了代码,但运行时仍然使用旧的 m4a 格式:

```
File Name: voice_input_1767782135597.m4a  ❌
Detected Format: m4a  ❌
```

## 原因分析

### Flutter 热重载的限制

Flutter 的热重载 (`r` 键) **无法更新**某些类型的代码改动,包括:

1. ✅ UI Widget 改动 - 支持热重载
2. ✅ 函数逻辑改动 - 支持热重载
3. ❌ **常量定义** - 需要完全重启
4. ❌ **构造函数参数** - 需要完全重启
5. ❌ **枚举值** - 需要完全重启

### 我们的改动属于哪一类?

```dart
// 这是一个 const 构造函数调用
await _audioRecorder.start(
  const RecordConfig(           // ← const 常量!
    encoder: AudioEncoder.wav,  // ← 枚举值!
    sampleRate: 16000,
    numChannels: 1,
  ),
  path: path,
);
```

**因为使用了 `const RecordConfig` 和枚举 `AudioEncoder.wav`**,所以:

- ❌ 热重载 (`r`) **不会生效**
- ❌ 热重启 (`R`) **可能不够**
- ✅ 完全重启 (`flutter run`) **必须**

---

## 解决方案

### 方案 1: 完全重启 (推荐)

```bash
# 步骤 1: 停止当前运行的应用
# 在 flutter run 窗口按 'q' 退出

# 步骤 2: 完全重新运行
cd /Users/yibocui/Desktop/talk/TriTalk/frontend
flutter run

# 或者在 VS Code 中:
# - 点击 Debug 窗口的 "Stop" 按钮
# - 再次点击 "Run" 或 "Debug"
```

### 方案 2: 清理并重建 (最彻底)

如果方案 1 还不行,使用完全清理:

```bash
cd /Users/yibocui/Desktop/talk/TriTalk/frontend

# 清理构建缓存
flutter clean

# 重新获取依赖
flutter pub get

# 重新运行
flutter run
```

### 方案 3: 卸载并重装 (终极方案)

如果还是不行,说明旧版本已安装在设备上:

```bash
# iOS 真机: 在设备上长按应用图标,选择删除

# iOS 模拟器:
xcrun simctl uninstall booted com.your.app.identifier

# 然后重新运行:
flutter run
```

---

## 如何验证修改已生效?

### 1. 查看编译输出

运行 `flutter run` 后,应该看到:

```
Launching lib/main.dart...
Building...
✓ Built build/ios/iphoneos/Runner.app
```

### 2. 运行后测试录音

录音后查看后端日志,应该显示:

```
File Name: voice_input_XXXXX.wav  ✓
Detected Format: wav  ✓
WAV Header Check: RIFF  ✓
```

### 3. Base64 前缀检查

- **M4A**: `AAAAHGZ0eXBNNEEg...` ❌
- **WAV**: `UklGR...` ✅

---

## 常见错误模式

### 错误 1: 只按了 'r' (热重载)

```
Flutter run key commands.
r Hot reload.           ← 这个不够!❌
R Hot restart.          ← 可能不够!⚠️
```

**正确做法**: 按 `q` 退出,然后重新 `flutter run` ✅

### 错误 2: 代码修改后立即测试

```
1. 修改代码
2. 按 'r' 热重载
3. 测试 ← 仍然是旧版本!❌
```

**正确流程**:

```
1. 修改代码
2. 按 'q' 退出应用
3. flutter run
4. 等待编译完成 (看到 ✓ Built...)
5. 测试 ✅
```

### 错误 3: 使用了缓存的旧包

有时 Xcode 或 Flutter 缓存了旧的 build:

```bash
# 清理所有缓存
cd ios
rm -rf Pods/
pod cache clean --all
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 技术原理

### 为什么 const 无法热重载?

在 Dart 中,`const` 对象在**编译时**就已经确定:

```dart
// 编译时常量 - 存储在 compiled binary 中
const config = RecordConfig(encoder: AudioEncoder.wav);

// 运行时对象 - 可以热重载
final config = RecordConfig(encoder: AudioEncoder.wav);
```

**热重载**只能更新运行时代码,无法修改已编译的二进制文件中的常量。

### RecordConfig 为什么要用 const?

```dart
// record package 的设计
class RecordConfig {
  const RecordConfig({...});  // ← 构造函数是 const
}

// 所以调用时必须用 const
const RecordConfig(...)  // ✓
RecordConfig(...)        // ✗ 编译错误
```

---

## 快速检查命令

运行这些命令确认环境状态:

```bash
# 1. 检查 Flutter 版本
flutter --version

# 2. 检查 record 包版本
cd frontend
grep "record:" pubspec.yaml

# 3. 检查是否有其他 flutter 进程
ps aux | grep flutter

# 4. 检查设备连接
flutter devices

# 5. 清理并重新获取
flutter clean && flutter pub get
```

---

## 总结

| 改动类型       | 热重载 (r) | 热重启 (R) | 完全重启 |
| -------------- | ---------- | ---------- | -------- |
| UI Widget      | ✅         | ✅         | ✅       |
| 函数逻辑       | ✅         | ✅         | ✅       |
| **const 常量** | ❌         | ⚠️         | ✅       |
| **枚举值**     | ❌         | ⚠️         | ✅       |
| 添加新文件     | ❌         | ✅         | ✅       |

**我们的情况**: 修改了 `const RecordConfig` 和 `AudioEncoder.wav` 枚举
**必须**: 完全重启 (`flutter run`)

---

## 验证成功的标志

✅ 后端日志显示:

```
File Name: voice_input_XXXXX.wav
Detected Format: wav
WAV Header Check: RIFF
Base64 Preview: UklGR...
```

✅ 转录结果相关且准确

❌ 如果仍显示 m4a,说明还在用旧版本!
