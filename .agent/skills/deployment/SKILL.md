---
name: deployment
description: Deployment workflows for TriTalk Flutter app and Node.js backend. Use when building releases or deploying to production. | TriTalk Flutter 应用和 Node.js 后端的部署流程。在构建发布版本或部署到生产环境时使用。
---

# Deployment Skill

Deployment procedures for TriTalk applications.

## When to use

- Building release versions
- Deploying to app stores
- Updating backend services

---

## Flutter App Deployment

### Pre-deployment Checklist

- [ ] All tests passing
- [ ] Version number updated in `pubspec.yaml`
- [ ] Changelog updated
- [ ] No debug code or print statements
- [ ] App icons and splash screens correct

### iOS Build

```bash
# Clean and get dependencies
cd frontend
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Open Xcode for archive
open ios/Runner.xcworkspace
```

Then in Xcode: Product → Archive → Distribute App

### Android Build

```bash
cd frontend
flutter clean
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

## Backend Deployment

### Pre-deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] API documentation updated
- [ ] Rate limits configured

### Deploy Steps

```bash
cd backend

# Install production dependencies
npm ci --production

# Run database migrations
npm run migrate

# Start with PM2
pm2 start ecosystem.config.js --env production
```

---

## Rollback Procedures

### Flutter App
- Submit hotfix version to stores
- Enable over-the-air updates if configured

### Backend
```bash
# Rollback to previous deployment
pm2 reload ecosystem.config.js --update-env

# If database rollback needed
npm run migrate:rollback
```

## Post-Deployment Verification

- [ ] Health check endpoints responding
- [ ] Critical user flows working
- [ ] Error monitoring active
- [ ] Performance metrics normal
