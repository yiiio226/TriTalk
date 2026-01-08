# Flutter Swagger Client Generation Guide

This guide outlines the end-to-end process for generating Dart/Flutter client code from a `swagger.json` file using `swagger_dart_code_generator` and `chopper`.

## Prerequisites

- **Flutter SDK / Dart SDK** installed.
- A valid **`swagger.json`** file from your backend.

---

## Step 1: Add Dependencies

Add the necessary packages to your `pubspec.yaml` file. This setup uses **Chopper** as the HTTP client, which is robust and widely used.

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Core generator package
  swagger_dart_code_generator: ^4.0.2
  # HTTP Client
  chopper: ^8.0.0
  # JSON handling
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  # Build system
  build_runner: ^2.4.6
  # Generators
  chopper_generator: ^8.0.0
  json_serializable: ^6.7.1
```

Run the following command to install dependencies:

```bash
flutter pub get
```

---

## Step 2: Configure `build.yaml`

Create a `build.yaml` file in the root of your project (same level as `pubspec.yaml`) if it doesn't already exist. This file tells the generator where to look for the Swagger file and how to configure the output.

```yaml
targets:
  $default:
    sources:
      - lib/**
      - swagger/**
      - $package$
    builders:
      # Configure the swagger code generator
      swagger_dart_code_generator:
        options:
          # Directory containing your swagger.json
          input_folder: "swagger/"
          # Target directory for generated code
          output_folder: "lib/swagger_generated_code/"
          # Use Chopper for HTTP requests
          with_converter: true
          separate_models: true
          # Optional: Null safety and overriding toString
          override_to_string: false

      # Ensure other builders work correctly
      json_serializable:
        options:
          explicit_to_json: true
```

---

## Step 3: Prepare the Swagger File

1.  Create a directory named `swagger` in your project root (matching the `input_folder` in `build.yaml`).
2.  Place your `swagger.json` file inside this directory.

**Directory Structure:**

```
project_root/
├── pubspec.yaml
├── build.yaml
├── swagger/
│   └── swagger.json
└── lib/
```

---

## Step 4: Create a Generation Script

It is best practice to wrap the generation commands in a shell script for consistency. Create a file named `generate-client.sh` in your project root.

```bash
#!/bin/bash

# 1. Clean previous generated code to avoid conflicts
echo "Cleaning old generated code..."
rm -rf lib/swagger_generated_code/*

# 2. Run the build runner
# --delete-conflicting-outputs ensures that old files don't block the build
echo "Generating new client code..."
dart run build_runner build --delete-conflicting-outputs

# 3. Optional: formatting and fixing
echo "Formatting code..."
dart fix --apply

echo "Done!"
```

**Make the script executable:**

```bash
chmod +x generate-client.sh
```

---

## Step 5: Execute Generation

Run the script you just created:

```bash
./generate-client.sh
```

After the script finishes, check `lib/swagger_generated_code/`. You should see several files, including:

- `swagger.swagger.dart`: The main entry point for the client.
- `swagger.models.swagger.dart`: Data models.
- `swagger.swagger.chopper.dart`: Chopper service implementation.

_(Note: The main class name `Swagger` depends on your input filename. If your file is `api.json`, the class will be `Api`.)_

---

## Step 6: Usage Example

Here is how to initialize and use the generated client in your Flutter app.

### 1. Initialization

Create a global or scoped instance of the client.

```dart
import 'package:chopper/chopper.dart';
import 'package:your_app/swagger_generated_code/swagger.swagger.dart';

// Create the client instance using the factory method
final validationService = Swagger.create(
  baseUrl: Uri.parse('https://api.yourdomain.com'),

  // Optional: Add interceptors for auth tokens, logging, etc.
  interceptors: [
    (Request request) async {
      // Add Auth Header example
      return request.copyWith(headers: {
        ...request.headers,
        'Authorization': 'Bearer YOUR_TOKEN'
      });
    },
    HttpLoggingInterceptor(),
  ],
);
```

### 2. Making API Calls

The generated methods return a `Response<T>`, which wraps the actual data and HTTP status.

```dart
Future<void> fetchUserData() async {
  // Call the endpoint (method names match your Swagger Operation IDs)
  final response = await validationService.apiUserGetProfileGet();

  if (response.isSuccessful) {
    // Access the parsed model directly
    final userProfile = response.body;
    print("User Name: ${userProfile?.name}");
  } else {
    // Handle errors
    print("Error: ${response.error}");
  }
}
```

---

## Best Practices

1.  **Git Integration**: It is generally recommended to **commit** the generated code so that the project is immediately runnable after cloning without needing to run generators. However, if you prefer a cleaner repo, add `lib/swagger_generated_code/` to `.gitignore`.
2.  **Updating the API**: When your backend API updates, simply replace `swagger/swagger.json` with the new version and run `./generate-client.sh` again.
3.  **Operation IDs**: Ensure your Backend Swagger/OpenAPI spec has unique and meaningful `operationId` fields for each endpoint. This results in clean Dart method names (e.g., `getUser` instead of `api_v1_user_get`).

---

## Step 7: Syncing Schema from Backend

With the dual-upload strategy in place, you can choose to sync the latest development schema or a stable versioned schema.

### Prerequisites

Create a sync script `sync-spec.sh` in your project root:

```bash
#!/bin/bash

# Configuration
# TODO: Replace with your actual R2 public domain or access URL
BASE_URL="https://[YOUR_R2_DOMAIN]/lib/tritalk"
TARGET_FILE="swagger/swagger.json"

VERSION=$1

if [ -z "$VERSION" ]; then
  # Default to latest if no version is provided
  URL="$BASE_URL/latest/swagger.json"
  echo "📥 Fetching LATEST schema from: $URL"
else
  # Fetch specific version
  URL="$BASE_URL/$VERSION/swagger.json"
  echo "📥 Fetching version $VERSION schema from: $URL"
fi

# Download file
curl -s -o "$TARGET_FILE" "$URL"

if [ $? -eq 0 ]; then
  echo "✅ Automatically updated $TARGET_FILE"
  echo "🚀 You can now run ./generate-client.sh"
else
  echo "❌ Failed to download schema. Please check the URL or version."
  exit 1
fi
```

Make it executable: `chmod +x sync-spec.sh`

### Usage

**Option 1: Development Mode (Latest)**
Fetches the code from the `main` branch deployment.

```bash
./sync-spec.sh
./generate-client.sh
```

**Option 2: Release/Stable Mode (Specific Version)**
Fetches a specific version derived from the backend's `package.json`.

```bash
./sync-spec.sh v0.1.0
./generate-client.sh
```
