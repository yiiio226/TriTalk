#!/bin/bash

# 1. Clean previous generated code to avoid conflicts
echo "🧹 Cleaning old generated code..."
rm -rf lib/swagger_generated_code/*

# 2. Run the build runner
# --delete-conflicting-outputs ensures that old files don't block the build
echo "🏭 Generating new client code..."
dart run build_runner build --delete-conflicting-outputs

# 3. Optional: formatting and fixing
echo "✨ Formatting code..."
dart fix --apply

echo "✅ Done! Client code generated in lib/swagger_generated_code/"
