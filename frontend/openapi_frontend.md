# Flutter Swagger Client Generation Guide

This guide outlines the **Hybrid Strategy** for managing network requests in TriTalk. We use automated code generation for standard REST endpoints while retaining manual control for complex streaming and audio features.

## 🏗 Architecture: The Hybrid Strategy

We use a two-pronged approach to balance **Type Safety** with **Flexibility**:

| Feature Type                                                     | Solution                                   | Why?                                                                                     |
| :--------------------------------------------------------------- | :----------------------------------------- | :--------------------------------------------------------------------------------------- |
| **Standard REST**<br>(Text Chat, Hints, Translations, Scene Gen) | **Generated Client**<br>(Swagger/Chopper)  | ✅ Strict Type Safety<br>✅ Single Source of Truth<br>✅ Zero Boilerplate                |
| **Streaming / Real-time**<br>(Voice Chat, Analysis Stream, TTS)  | **Manual Service**<br>(`StreamingService`) | ✅ Complex NDJSON parsing<br>✅ Audio Stream handling<br>✅ Multipart/Form Customization |

---

## Prerequisites

- **Flutter SDK / Dart SDK** installed.
- A valid **`swagger.json`** file from your backend (synced via `sync-spec.sh`).
- Packages: `swagger_dart_code_generator`, `chopper`, `json_serializable`, `build_runner`.

---

## Step 1: Configuration

### 1. `pubspec.yaml`

Ensure these dependencies are present:

```yaml
dependencies:
  # HTTP Client (runtime dependency)
  chopper: ^8.0.0
  # JSON handling (runtime dependency)
  json_annotation: ^4.8.1

dev_dependencies:
  # Build system
  build_runner: ^2.4.6
  # Code generators (only needed during build)
  swagger_dart_code_generator: ^4.0.2
  chopper_generator: ^8.0.0
  json_serializable: ^6.7.1
```

### 2. `build.yaml`

Located in the project root. This file tells the generator how to map `swagger.json` to Dart code.

```yaml
targets:
  $default:
    sources:
      - lib/**
      - swagger/**
      - $package$
    builders:
      swagger_dart_code_generator:
        options:
          input_folder: "swagger/"
          output_folder: "lib/swagger_generated_code/"
          with_converter: true
          separate_models: true
          override_to_string: false
      json_serializable:
        options:
          explicit_to_json: true
```

---

## Step 2: Implementation Details

### 1. The Auth Interceptor

Since the generated client doesn't know about Supabase, we must inject the Auth Token manually.

**File:** `lib/services/auth_interceptor.dart`

```dart
import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthInterceptor implements Interceptor {
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(Chain<BodyType> chain) async {
    // 1. Get current session
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    // 2. Inject Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      final request = chain.request;
      final modifiedRequest = request.copyWith(headers: {
        ...request.headers,
        'Authorization': 'Bearer $token',
      });
      return chain.proceed(modifiedRequest);
    }

    return chain.proceed(chain.request);
  }
}
```

### 2. Initializing the Client

Create a singleton provider for the generated `Swagger` client with environment-aware configuration.

**File:** `lib/services/client_provider.dart`

````dart
import 'package:chopper/chopper.dart';
import 'package:flutter/foundation.dart';
import '../swagger_generated_code/swagger.swagger.dart';
import 'auth_interceptor.dart';
import '../env.dart';

/// Provides a singleton instance of the generated Swagger API client.
///
/// Environment switching:
/// - Debug mode (flutter run): Uses [Env.localBackendUrl]
/// - Release mode (flutter build): Uses [Env.prodBackendUrl]
///
/// To force production URL in debug mode, use:
/// ```bash
/// flutter run --dart-define=USE_PROD=true
/// ```
class ClientProvider {
  static Swagger? _instance;

  static const bool _useProd = bool.fromEnvironment('USE_PROD', defaultValue: false);

  static String get _baseUrl {
    if (kReleaseMode || _useProd) {
      return Env.prodBackendUrl;
    }
    return Env.localBackendUrl;
  }

  static Swagger get client {
    _instance ??= Swagger.create(
      baseUrl: Uri.parse(_baseUrl),
      interceptors: [
        AuthInterceptor(),
        if (kDebugMode) HttpLoggingInterceptor(),
      ],
    );
    return _instance!;
  }
}
````

---

## Step 3: Usage Guide

### ✅ Scenario A: Standard Request (Use Generated Client)

**Use for:** `/chat/hint`, `/scene/generate`, `/common/translate`, `/chat/shadow`

```dart
import 'package:frontend/services/client_provider.dart';
import 'package:frontend/swagger_generated_code/swagger.swagger.dart';

Future<void> getHints() async {
  // 1. Use the generated 'ChatHintPost$RequestBody' (generated name for inline schema)
  final requestBody = ChatHintPost$RequestBody(
    sceneContext: "Ordering coffee",
    targetLanguage: "English",
    history: [],
  );

  // 2. Call the API using the singleton client
  final response = await ClientProvider.client.chatHintPost(body: requestBody);

  // 3. Handle Result (Type-Safe!)
  if (response.isSuccessful) {
    // response.body is ALREADY a typed object
    final hints = response.body?.hints ?? [];
    print("Hints: $hints");
  } else {
    print("Error: ${response.error}");
  }
}
```

### ⚠️ Scenario B: Streaming/Audio (Use Manual Service)

**Use for:** `/chat/analyze`, `/chat/send-voice`, `/tts/generate`

Continue using your existing `ApiService` (rename it to `StreamingService` to be clear).

```dart
// lib/services/streaming_service.dart

// ... standard http imports ...

Stream<VoiceStreamEvent> sendVoiceMessage(...) async* {
    // Current manual implementation handles:
    // - NDJSON parsing ({"type":"token"}...)
    // - Complex Multipart uploads
    // - Custom Stream Controllers
}
```

---

## Step 4: Workflows

### 1. Syncing Schema

When backend updates, pull the latest spec:

```bash
./sync-spec.sh
```

### 2. Generating Code

After syncing, regenerate the Dart files:

```bash
./generate-client.sh
```

### 3. File Uploads (Transcribe)

The generator supports file uploads if defined as `binary` in Swagger.

```dart
// Example for /chat/transcribe
// You may need to wrap your file bytes into a format Chopper accepts
// depending on the generated method signature (usually List<int> or MultipartFile).
```

_Note: If the generated transcribe method is clunky, feel free to keep it in the Manual Service for now._

---

## Troubleshooting

- **"Field not found"**: Run `./sync-spec.sh` then `./generate-client.sh`.
- **"Conflict" errors**: The script `./generate-client.sh` includes `--delete-conflicting-outputs` to handle this.
- **Null safety errors**: Check `swagger.json`. If a field is required in JSON but missing in runtime, parsing will fail.
