#!/bin/bash
echo "Building Tritalk AAB..."

# Extract version info from pubspec.yaml
VERSION_LINE=$(grep "^version:" pubspec.yaml)
VERSION_NAME=$(echo "$VERSION_LINE" | sed 's/version: //;s/+.*//')
VERSION_CODE=$(echo "$VERSION_LINE" | sed 's/.*+//')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Version Info (from pubspec.yaml):"
echo "   Version Name: $VERSION_NAME"
echo "   Version Code: $VERSION_CODE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Clean and prepare
flutter clean && flutter pub get

# Force update local.properties with correct version from pubspec.yaml
# This ensures the version code is not stale/cached
echo "🔄 Updating android/local.properties with version info..."
if [ -f "android/local.properties" ]; then
    # Update or add flutter.versionName
    if grep -q "flutter.versionName=" android/local.properties; then
        sed -i '' "s/flutter.versionName=.*/flutter.versionName=$VERSION_NAME/" android/local.properties
    else
        echo "flutter.versionName=$VERSION_NAME" >> android/local.properties
    fi
    # Update or add flutter.versionCode
    if grep -q "flutter.versionCode=" android/local.properties; then
        sed -i '' "s/flutter.versionCode=.*/flutter.versionCode=$VERSION_CODE/" android/local.properties
    else
        echo "flutter.versionCode=$VERSION_CODE" >> android/local.properties
    fi
    echo "✅ local.properties updated:"
    grep "flutter.version" android/local.properties
fi

# Build AAB for Google Play using 'global' flavor
echo "🚀 Building Tritalk..."
flutter build appbundle --release \
  --dart-define=ENV=prod \
  --obfuscate \
  --split-debug-info=build/debug-info/global

echo "✅ Tritalk build completed!"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
