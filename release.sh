#!/bin/bash
# release.sh — 一键发版脚本
# 用法：bash release.sh
# 前提：已在 build.sh 里改好 VERSION

set -e

cd "$(dirname "$0")"

# 读取 VERSION（从 build.sh 里提取）
VERSION=$(grep '^VERSION=' build.sh | cut -d'"' -f2)
APP_NAME="PixelPet"
APP_DIR="${APP_NAME}.app"
ZIP_NAME="${APP_NAME}-${VERSION}.zip"

echo "📦 发版 v${VERSION}..."

# 1. 先 build
bash build.sh

# 2. 清除隔离属性，让用户双击就能打开，无需右键
echo "🔓  清除 Gatekeeper 隔离标记..."
xattr -cr "$APP_DIR"

# 3. 打 zip（排除 .DS_Store）
echo "🗜  打包 zip..."
ditto -c -k --keepParent --sequesterRsrc "$APP_DIR" "$ZIP_NAME"

# 3. 用 Sparkle 的 sign_update 工具对 zip 签名，生成 appcast 条目
SIGN_UPDATE=".build/artifacts/sparkle/Sparkle/bin/sign_update"
if [ ! -f "$SIGN_UPDATE" ]; then
    echo "❌ sign_update 工具未找到，请先运行 swift package resolve"
    exit 1
fi

echo "✍️  签名更新包..."
SIGNATURE_OUTPUT=$("$SIGN_UPDATE" "$ZIP_NAME" 2>&1)
ED_SIGNATURE=$(echo "$SIGNATURE_OUTPUT" | grep -o 'edSignature="[^"]*"' | head -1)
FILE_SIZE=$(stat -f%z "$ZIP_NAME")

# 4. 生成 appcast.xml
DOWNLOAD_URL="https://github.com/Ziyi-ZHU-1027/PixelPet/releases/download/v${VERSION}/${ZIP_NAME}"
PUB_DATE=$(date -u "+%a, %d %b %Y %H:%M:%S +0000")

mkdir -p docs
cat > docs/appcast.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>PixelPet Updates</title>
        <link>https://Ziyi-ZHU-1027.github.io/PixelPet/appcast.xml</link>
        <description>PixelPet 更新日志</description>
        <item>
            <title>v${VERSION}</title>
            <pubDate>${PUB_DATE}</pubDate>
            <sparkle:version>${VERSION}</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
            <enclosure
                url="${DOWNLOAD_URL}"
                length="${FILE_SIZE}"
                type="application/octet-stream"
                ${ED_SIGNATURE}
            />
        </item>
    </channel>
</rss>
EOF

echo ""
echo "✅ 完成！接下来："
echo ""
echo "1. 在 GitHub 创建 Release v${VERSION}，上传 ${ZIP_NAME}"
echo "   https://github.com/Ziyi-ZHU-1027/PixelPet/releases/new"
echo ""
echo "2. 推送 appcast.xml 到 GitHub Pages："
echo "   git add docs/appcast.xml && git commit -m 'release: v${VERSION}' && git push"
echo ""
echo "3. 确认 GitHub Pages 已开启（Settings → Pages → Source: main /docs）"
