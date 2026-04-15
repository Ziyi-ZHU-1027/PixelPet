# PixelPet 发版 SOP

> 适用对象：项目维护者本人，或任何没有上下文的 AI 助手。
> 每次发布新版本，按本文档从头到尾执行一遍。

---

## 项目基本信息

| 项目 | 说明 |
|------|------|
| 仓库 | https://github.com/Ziyi-ZHU-1027/PixelPet |
| 下载页 | https://Ziyi-ZHU-1027.github.io/PixelPet/ |
| appcast | https://Ziyi-ZHU-1027.github.io/PixelPet/appcast.xml |
| 本地路径 | `/Users/zhuziyi/Desktop/PixelPet/` |
| 自动更新框架 | Sparkle 2.x（私钥存在 macOS Keychain，公钥写在 build.sh） |
| 签名方式 | ad-hoc（`-`），无需 Apple 开发者账号 |

---

## 发版前：改代码

正常开发，改完后确认：

```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift test        # 所有测试通过
swift build       # Build complete!
```

---

## 第一步：确定新版本号

版本号格式：`X.Y.Z`（语义化版本）

- **Z**（patch）：修 bug，如 `1.0.0` → `1.0.1`
- **Y**（minor）：加新功能，如 `1.0.0` → `1.1.0`
- **X**（major）：重大变化，如 `1.0.0` → `2.0.0`

---

## 第二步：修改所有版本号引用（共 4 处）

> ⚠️ 这是最容易漏掉的步骤，必须全部改完再继续。

### 2.1 `build.sh` — 第 10 行

```bash
# 打开 /Users/zhuziyi/Desktop/PixelPet/build.sh
# 找到这一行，改成新版本号：
VERSION="1.0.0"   # ← 改这里，例如改成 "1.1.0"
```

### 2.2 `docs/index.html` — 共 3 处

打开 `/Users/zhuziyi/Desktop/PixelPet/docs/index.html`，搜索旧版本号（如 `1.0.0`），改以下 3 处：

**第 1 处：下载按钮的 href（zip 文件名）**
```html
<!-- 找到这行，改版本号 -->
<a class="btn-download" href="https://github.com/Ziyi-ZHU-1027/PixelPet/releases/latest/download/PixelPet-1.0.0.zip">
<!-- 改成新版本，例如： -->
<a class="btn-download" href="https://github.com/Ziyi-ZHU-1027/PixelPet/releases/latest/download/PixelPet-1.1.0.zip">
```

**第 2 处：版本号显示文字**
```html
<!-- 找到这行，改版本号 -->
<p class="version-note">v1.0.0 · macOS 13 Ventura 及以上</p>
<!-- 改成新版本，例如： -->
<p class="version-note">v1.1.0 · macOS 13 Ventura 及以上</p>
```

**第 3 处：安装说明里的 zip 文件名**
```html
<!-- 找到这行，改版本号 -->
<li>点击上方"下载 PixelPet"按钮，下载 <code>PixelPet-1.0.0.zip</code></li>
<!-- 改成新版本，例如： -->
<li>点击上方"下载 PixelPet"按钮，下载 <code>PixelPet-1.1.0.zip</code></li>
```

### 快速验证：没有遗漏

```bash
# 确认旧版本号已全部替换（输出应为空）
grep -r "1\.0\.0" /Users/zhuziyi/Desktop/PixelPet/docs/ /Users/zhuziyi/Desktop/PixelPet/build.sh
```

如果有输出，说明还有遗漏，继续修改。

---

## 第三步：运行发版脚本

```bash
cd /Users/zhuziyi/Desktop/PixelPet
bash release.sh
```

脚本会自动完成：
1. `swift build -c release` 编译 release 版本
2. 打包成 `PixelPet-X.Y.Z.zip`
3. 用 Sparkle 私钥对 zip 签名（私钥在 Keychain，无需手动操作）
4. 生成/更新 `docs/appcast.xml`

脚本结束后，当前目录会出现 `PixelPet-X.Y.Z.zip` 文件。

---

## 第四步：在 GitHub 创建 Release

1. 打开：https://github.com/Ziyi-ZHU-1027/PixelPet/releases/new

2. 填写：
   - **Tag version**：`vX.Y.Z`（例如 `v1.1.0`，注意有小写 `v`）
   - **Target**：`main`
   - **Release title**：`vX.Y.Z` 或写更新说明（例如 `v1.1.0 — 修复眨眼帧 bug`）
   - **Description**：写这次改了什么（用户看的）

3. **Attach files**：把 `PixelPet-X.Y.Z.zip` 拖进去上传

4. 点 **Publish release**

---

## 第五步：推送 appcast.xml 和下载页更新

```bash
cd /Users/zhuziyi/Desktop/PixelPet
git add docs/appcast.xml docs/index.html
git commit -m "release: vX.Y.Z"
git push origin main
```

---

## 第六步：验证

等 1-2 分钟 GitHub Pages 部署完成后：

**验证下载页：**
打开 https://Ziyi-ZHU-1027.github.io/PixelPet/
- 确认页面显示的版本号是新版本
- 确认下载按钮指向新的 zip 文件名

**验证 appcast：**
打开 https://Ziyi-ZHU-1027.github.io/PixelPet/appcast.xml
- 确认 `<sparkle:version>` 是新版本号
- 确认 `url` 里的 zip 文件名是新版本
- 确认 `edSignature` 有值（不为空）

**验证自动更新（可选）：**
用旧版本的 App 启动，等待 Sparkle 检查更新（或在 App 菜单找"检查更新"），应该弹出更新提示。

---

## 完整检查清单

```
发版前
  [ ] swift test 全部通过
  [ ] swift build 通过

版本号（共 4 处）
  [ ] build.sh 第 10 行 VERSION=
  [ ] docs/index.html 下载按钮 href 里的 zip 文件名
  [ ] docs/index.html version-note 显示文字
  [ ] docs/index.html 安装说明里的 zip 文件名

执行
  [ ] bash release.sh 成功，生成 PixelPet-X.Y.Z.zip
  [ ] GitHub 创建 Release，上传 zip，Tag 格式 vX.Y.Z
  [ ] git push（包含 appcast.xml 和 index.html）

验证
  [ ] 下载页版本号正确
  [ ] appcast.xml 版本号正确，edSignature 有值
```

---

## 常见问题

**Q：`sign_update` 工具找不到？**
```bash
cd /Users/zhuziyi/Desktop/PixelPet
swift package resolve
# 然后重新运行 bash release.sh
```

**Q：私钥丢失了怎么办（换了电脑或 Keychain 被清空）？**
```bash
# 重新生成密钥对
/Users/zhuziyi/Desktop/PixelPet/.build/artifacts/sparkle/Sparkle/bin/generate_keys
# 会输出新的公钥，把它更新到 build.sh 里的 SPARKLE_PUBLIC_KEY
# 注意：旧版本的用户将无法通过 Sparkle 自动更新到新版本，需要手动下载
```

**Q：想换 Apple 开发者证书签名？**
只需改 `build.sh` 第 16 行：
```bash
# 现在：
SIGN_IDENTITY="-"
# 换成（替换为你的证书名）：
SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
```
其他所有代码不需要改动。

**Q：appcast.xml 只保留最新一条，旧版本用户能升级吗？**
能。Sparkle 只需要看到比当前版本更新的条目就会提示升级。如果想支持跨版本升级历史，可以在 appcast.xml 里保留多个 `<item>`，按时间倒序排列。
