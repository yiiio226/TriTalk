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
