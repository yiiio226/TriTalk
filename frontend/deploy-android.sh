#!/bin/bash
#
# TriTalk Android 部署脚本
# 用于发布到 Google Play Internal Testing
#

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📱 TriTalk Android 部署"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 显示当前版本信息
VERSION_LINE=$(grep "^version:" "$SCRIPT_DIR/pubspec.yaml")
VERSION_NAME=$(echo "$VERSION_LINE" | sed 's/version: //;s/+.*//')
echo "📦 pubspec.yaml 版本: $VERSION_NAME"
echo "   (versionCode 将自动从 Google Play 获取并递增)"
echo ""

# 进入 android 目录执行 Fastlane
cd "$SCRIPT_DIR/android"

echo "🚀 开始部署到 Google Play Internal Testing..."
echo ""

bundle exec fastlane deploy_internal

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 部署完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
