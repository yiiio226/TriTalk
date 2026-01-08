# OpenAPI 前端指南

本文档描述 Flutter 前端如何使用自动生成的 API 客户端，以及与后端同步的工作流程。

---

## 🏗 架构：混合策略

| 类型          | 方案                    | 适用接口                                                |
| ------------- | ----------------------- | ------------------------------------------------------- |
| **标准 REST** | 生成的 Swagger Client   | `/chat/hint`, `/scene/generate`, `/common/translate` 等 |
| **流式/音频** | 手动 `StreamingService` | `/chat/send-voice`, `/tts/generate`, `/chat/analyze`    |

---

## 📁 核心文件结构

| 文件                                 | 描述                           |
| ------------------------------------ | ------------------------------ |
| `swagger/swagger.json`               | OpenAPI 规范文件（从 R2 同步） |
| `lib/swagger_generated_code/`        | 自动生成的客户端代码           |
| `lib/services/client_provider.dart`  | 客户端单例封装                 |
| `lib/services/auth_interceptor.dart` | Supabase Token 注入            |
| `sync-spec.sh`                       | 同步 OpenAPI 规范脚本          |
| `generate-client.sh`                 | 生成客户端代码脚本             |

---

## 🔄 同步与生成工作流

### 拉取最新规范

```bash
cd frontend
./sync-spec.sh
```

> 此脚本会自动下载最新的 `swagger.json` 并触发代码生成。

### 拉取指定版本

```bash
./sync-spec.sh 1.0.0
```

### 仅重新生成代码

如果 `swagger.json` 已存在，可以单独运行：

```bash
./generate-client.sh
```

---

## 🎯 使用方式

### 标准请求（使用生成的客户端）

```dart
import 'package:frontend/services/client_provider.dart';

final response = await ClientProvider.client.chatHintPost(body: requestBody);
if (response.isSuccessful) {
  final hints = response.body?.hints ?? [];
}
```

### 流式/音频请求（使用手动服务）

继续使用 `StreamingService` 处理复杂的流式和音频接口。

---

## ⚠️ 常见问题

| 问题          | 解决方案                                                           |
| ------------- | ------------------------------------------------------------------ |
| 字段找不到    | 运行 `./sync-spec.sh`                                              |
| 构建冲突      | 运行 `./generate-client.sh`（包含 `--delete-conflicting-outputs`） |
| Null 安全错误 | 检查 `swagger.json` 中字段是否正确标记为 required                  |
