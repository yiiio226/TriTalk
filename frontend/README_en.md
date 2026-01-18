**English** | [中文](README.md)

# TriTalk Frontend

TriTalk is a modern, AI-powered language learning application built with Flutter.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / Xcode (for mobile emulators)

### Setup

```bash
cd frontend
flutter pub get
# Run with local backend (dev) or production URL
flutter run
```

## 🔄 OpenAPI Integration

TriTalk uses OpenAPI to ensure type-safe communication with the backend.

### Sync Client

When the backend API changes, you can generate the updated client code:

```bash
cd frontend

# Pull latest spec + generate code
./sync-spec.sh

# Pull specific version (e.g. pinned v1.0.0)
./sync-spec.sh 1.0.0
```

> 📖 Detailed Documentation: [openapi_frontend.md](openapi_frontend.md)

## 🏗 Architecture

TriTalk follows a comprehensive Feature-First, Layered architecture utilizing Riverpod for state management.

- **[Current Architecture Guide](guide/Architecture.md)**: Detailed breakdown of the project structure and layers.
- **[Cache Strategy](doc/cache_strategy_en.md)**: Detailed guide on caching architecture, CacheManager, and caching rules for each module.

## 🎤 Voice Features

### Shadowing Smart Segmentation

Intelligently segment shadowing text based on natural pauses detected by Azure Speech API.

> 📖 Detailed Spec: [doc/access_segment_en.md](doc/access_segment_en.md)
