#!/bin/bash
set -e

echo "Building PixelPet..."
swift build -c release

APP_NAME="PixelPet"
APP_DIR="${APP_NAME}.app"
EXECUTABLE=".build/release/PixelPetApp"
VERSION="1.0.2"  # ← 每次发版前改这里

# 签名方式：
#   现在（免费）:        SIGN_IDENTITY="-"
#   以后（开发者账号）:   SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
SIGN_IDENTITY="-"

APPCAST_URL="https://Ziyi-ZHU-1027.github.io/PixelPet/appcast.xml"
SPARKLE_PUBLIC_KEY="zqZ4aQOFSDfZXJLI2/jfxGbX0mVNXKduT3nNHNQA2mI="

# Clean previous build
rm -rf "$APP_DIR"

# Create bundle structure
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Frameworks"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/$APP_NAME"

# Copy Sparkle.framework
SPARKLE_FRAMEWORK=".build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"
if [ -d "$SPARKLE_FRAMEWORK" ]; then
    cp -R "$SPARKLE_FRAMEWORK" "$APP_DIR/Contents/Frameworks/"
else
    echo "❌ Sparkle.framework not found. Run: swift package resolve"
    exit 1
fi

# Write Info.plist
cat > "$APP_DIR/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.pixelpet.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
    <key>SUFeedURL</key>
    <string>${APPCAST_URL}</string>
    <key>SUPublicEDKey</key>
    <string>${SPARKLE_PUBLIC_KEY}</string>
    <key>SUEnableAutomaticChecks</key>
    <true/>
</dict>
</plist>
EOF

# Fix rpath: SPM sets @loader_path but Sparkle lives in ../Frameworks
# Change to @executable_path/../Frameworks so dyld finds it correctly
install_name_tool \
    -rpath "@loader_path" "@executable_path/../Frameworks" \
    "$APP_DIR/Contents/MacOS/$APP_NAME"

# Code sign（先签 framework，再签整个 app）
codesign --force --deep --sign "$SIGN_IDENTITY" \
    "$APP_DIR/Contents/Frameworks/Sparkle.framework"
codesign --force --deep --sign "$SIGN_IDENTITY" "$APP_DIR"

echo ""
echo "✅ 打包完成：$APP_DIR (v${VERSION})"
echo "发版步骤："
echo "  1. 改 build.sh 里的 VERSION"
echo "  2. 运行 bash release.sh 生成 zip + 更新 appcast.xml"
echo "  3. 把 appcast.xml 推到 GitHub Pages"
