---
name: deployment
description: Deployment workflows for TriTalk Flutter app and Node.js backend. Use when building releases or deploying to production. | TriTalk Flutter 应用和 Node.js 后端的部署流程。在构建发布版本或部署到生产环境时使用。
---

# Deployment Skill | 部署技能

Deployment procedures for TriTalk applications.
TriTalk 应用的部署流程。

## When to use | 何时使用

- Building release versions | 构建发布版本
- Deploying to app stores | 部署到应用商店
- Updating backend services | 更新后端服务

---

## Flutter App Deployment | Flutter 应用部署

### Pre-deployment Checklist | 部署前检查清单

- [ ] All tests passing | 所有测试通过
- [ ] Version number updated in `pubspec.yaml` | `pubspec.yaml` 中版本号已更新
- [ ] Changelog updated | 更新日志已更新
- [ ] No debug code or print statements | 无调试代码或 print 语句
- [ ] App icons and splash screens correct | 应用图标和启动页正确

### iOS Build | iOS 构建

```bash
# Clean and get dependencies | 清理并获取依赖
cd frontend
flutter clean
flutter pub get

# Build iOS release | 构建 iOS 发布版
flutter build ios --release

# Open Xcode for archive | 打开 Xcode 归档
open ios/Runner.xcworkspace
```

Then in Xcode 然后在 Xcode 中: Product → Archive → Distribute App

### Android Build | Android 构建

```bash
cd frontend
flutter clean
flutter pub get

# Build APK | 构建 APK
flutter build apk --release

# Build App Bundle (for Play Store) | 构建 App Bundle（用于 Play 商店）
flutter build appbundle --release
```

Output locations | 输出位置:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

## Backend Deployment | 后端部署

### Pre-deployment Checklist | 部署前检查清单

- [ ] Environment variables configured | 环境变量已配置
- [ ] Database migrations ready | 数据库迁移已准备
- [ ] API documentation updated | API 文档已更新
- [ ] Rate limits configured | 限流已配置

### Deploy Steps | 部署步骤

```bash
cd backend

# Install production dependencies | 安装生产依赖
npm ci --production

# Run database migrations | 运行数据库迁移
npm run migrate

# Start with PM2 | 使用 PM2 启动
pm2 start ecosystem.config.js --env production
```

---

## Rollback Procedures | 回滚流程

### Flutter App | Flutter 应用
- Submit hotfix version to stores | 向商店提交热修复版本
- Enable over-the-air updates if configured | 如已配置，启用 OTA 更新

### Backend | 后端
```bash
# Rollback to previous deployment | 回滚到上一个部署
pm2 reload ecosystem.config.js --update-env

# If database rollback needed | 如需数据库回滚
npm run migrate:rollback
```

## Post-Deployment Verification | 部署后验证

- [ ] Health check endpoints responding | 健康检查端点响应正常
- [ ] Critical user flows working | 关键用户流程正常工作
- [ ] Error monitoring active | 错误监控已激活
- [ ] Performance metrics normal | 性能指标正常
