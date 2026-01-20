# Environment Configuration Refactor Plan: .env Implementation

This document outlines the steps to refactor the current Dart class-based environment configuration (`EnvLocal`, `EnvDev`, `EnvProd`) to a more standard and flexible `.env` file-based approach using `flutter_dotenv`.

## 1. Preparation & Dependencies (done)

- **Add Dependency**: Add `flutter_dotenv` to `pubspec.yaml`.
  ```yaml
  dependencies:
    flutter_dotenv: ^6.0.0
  ```

## 2. Create Environment Files

Create a new directory `assets/env/` to store environment-specific configurations.

Create the following files and migrate values from their respective Dart files:

- **`assets/env/.env.local`** (Migrate from `env_local.dart`)
- **`assets/env/.env.dev`** (Migrate from `env_dev.dart`)
- **`assets/env/.env.prod`** (Migrate from `env_prod.dart`)

**Key Format Example (.env.dev):**

```properties
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=...
BACKEND_URL=https://...
GOOGLE_OAUTH_IOS_CLIENT_ID=...
GOOGLE_OAUTH_WEB_CLIENT_ID=...
FORCE_CLOUD_TTS=false
REVENUE_CAT_APPLE_API_KEY=...
REVENUE_CAT_GOOGLE_API_KEY=...
SCENE_ASSETS_BASE_URL=...
```

## 3. Configuration Access (Assets)

Update `pubspec.yaml` to ensure Flutter bundles these files with the app.

```yaml
flutter:
  assets:
    - assets/env/
```

_Note: We include the folder to ensure all files within it are accessible._

## 4. Refactor `Env` Class (`lib/core/env/env.dart`)

Rewrite `Env` to replace the static switch-case logic with `dotenv` lookups.

- **Initialization**: Add an `init()` method that:
  1.  Reads the current environment name from `EnvConfig` (which still reads `--dart-define=ENV`).
  2.  Loads the corresponding file (e.g., `assets/env/.env.dev`).
- **Getters**: Change all getters to read from `dotenv.env`.
  - String values: `dotenv.env['KEY'] ?? ''`
  - Boolean values: Check string equality (e.g., `== 'true'`).

**Code Structure Preview:**

```dart
class Env {
  static Future<void> init() async {
    final envFile = 'assets/env/.env.${EnvConfig.name}';
    await dotenv.load(fileName: envFile);
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  // ... other getters
}
```

## 5. Main Entry Point Update (`lib/main.dart`)

Update the `main` function to initialize the `Env` class before running the app.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init(); // Add this line

  // Existing Supabase init...
  // runApp...
}
```

## 6. Cleanup

Delete the now obsolete files:

- `lib/core/env/env_local.dart`
- `lib/core/env/env_dev.dart`
- `lib/core/env/env_prod.dart`

## 7. Verification

Verify the setup by running the app in different modes:

1.  **Local**: `flutter run --dart-define=ENV=local` (Should load `.env.local`)
2.  **Dev**: `flutter run --dart-define=ENV=dev` (Should load `.env.dev`)
3.  **Prod**: `flutter build ios --dart-define=ENV=prod` (Verify build works)

## Security Note

- **Git Ignore**: Since these files contain API keys, ensure `assets/env/` (or specific files like `.env.prod`) are added to `.gitignore` if they contain sensitive secrets that shouldn't be in the repo.
  - _Decision point: Do you want to commit these files or ignore them?_ (Common practice for team repos is to commit generic dev/local envs but ignore prod, or use a separate secrets management solution. For now, we will assume standard migration.)
