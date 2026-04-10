# PixelPet 设计规格文档

**日期**：2026-04-10
**一句话愿景**：像拼豆一样画画，画完它就活过来陪你。

---

## 1. 项目概述

PixelPet 是一个全新独立的 macOS 桌面宠物创作工具。用户在方格画板上点色填格，点击"做成桌宠"后，像素画立刻变成一个浮在桌面上的小家伙——会跳、会眨眼、会冒爱心、可以随机跑动。

**目标用户**：任何年龄、任何背景，哪怕从未画过像素画的人。

---

## 2. 架构

### 2.1 项目结构

全新独立仓库 `PixelPet`，使用 Swift Package Manager，单 App 双模式（编辑模式 + 桌面模式）。

```
PixelPet/
├── Package.swift
├── Sources/
│   ├── PixelPetKit/                  # 共享库
│   │   ├── Model/
│   │   │   ├── PixelCanvas.swift     # 画布数据模型
│   │   │   ├── PetDefinition.swift   # 宠物定义（含像素数据）
│   │   │   ├── PetStore.swift        # 持久化（JSON + PNG）
│   │   │   ├── PetAnimator.swift     # 动画系统（复用）
│   │   │   └── PetState.swift        # 动画状态枚举（复用）
│   │   ├── View/
│   │   │   ├── CanvasEditorView.swift  # 画板 UI
│   │   │   ├── ColorPaletteView.swift  # 颜色面板
│   │   │   ├── PetListView.swift       # 宠物列表
│   │   │   └── PetView.swift           # 桌面宠物渲染（复用）
│   │   └── Window/
│   │       ├── PetWindow.swift           # 透明 NSPanel（复用）
│   │       ├── PetWindowController.swift # 宠物窗口控制器（小改）
│   │       └── PetHostManager.swift      # 管理所有活跃宠物窗口
│   └── PixelPetApp/                  # App 入口
│       ├── PixelPetApp.swift
│       ├── AppState.swift
│       └── EditorWindow.swift
├── build.sh
└── README.md
```

### 2.2 从 DesktopPetKit 复用的代码

| 文件 | 复用程度 |
|------|---------|
| `PetAnimator.swift` | 直接复用，新增双击触发爱心 |
| `PetWindow.swift` | 直接复用 |
| `PetWindowController.swift` | 小改：alpha map 从用户画布动态生成 |
| `PetView.swift` | 直接复用 |

### 2.3 多宠物架构

MVP 阶段：单进程多窗口，`PetHostManager` 持有所有 `PetWindowController` 实例，宠物间完全独立不通信。

未来扩展：`PetHostManager` 可为每对宠物注入 `PeerChannel` 接口，实现追逐/互动，不影响现有架构。

---

## 3. 画板编辑器 UI

### 3.1 布局

三栏式窗口（约 980×600）：

- **左侧工具栏**（60px）：画笔、橡皮、填充桶、取色器、撤销、重做
- **中间画板区**：帧 tab + 像素格子画板 + 操作提示
- **右侧面板**（210px）：画布尺寸、当前颜色、调色盘、宠物列表

顶部标题栏：App 名 + 文件名 + "新建"按钮 + "▶ 做成桌宠"按钮
底部状态栏：尺寸、工具、坐标、在线宠物数

### 3.2 视觉风格

- **风格**：Claymorphism（厚边框 3-4px、双阴影、圆角 16-24px）
- **字体**：Press Start 2P（标题/按钮）+ VT323（正文/标签，20px）
- **主色**：`#F97316` 橙色
- **CTA**：`#2563EB` 蓝色（"做成桌宠"按钮）
- **背景**：`#FFF7ED` 奶油白
- **面板背景**：`#FDECD3` 浅橙

### 3.3 画布尺寸

| 尺寸 | 格子大小 | 适合 |
|------|---------|------|
| 15×15 | 26px/格 | 超简单，心形、星星 |
| 25×25 | 21px/格 | 中等，小动物 |
| 32×32 | 17px/格 | 精细，复杂角色 |

切换尺寸时弹出内联确认 banner（不用弹窗），确认后清空画布重建格子。

### 3.4 画板交互

- 空格子：透明（棋盘格纹底，表示透明区域）
- 左键点击/拖动：填色
- 右键点击：擦除（恢复透明）
- 填充桶：flood fill 同色相连区域
- 取色器：点击已有颜色，切换为该颜色
- 撤销/重做：⌘Z / ⌘⇧Z

### 3.5 帧管理

- 默认只有"普通帧"
- 点击"+ 添加眨眼帧"创建第二张画布，用于眨眼动画
- 无眨眼帧时宠物静止待机，不眨眼

### 3.6 调色盘

内置 13 色精选（含红、橙、黄、绿、蓝、紫、粉、杏、黑、白、灰、浅青、深蓝）+ 1 透明格 + 1 自定义颜色（系统取色器）。

### 3.7 宠物列表

- 绿点：当前在桌面显示
- 灰点：已隐藏
- 点击条目：切换到该宠物的画布进行编辑
- 右键条目：隐藏 / 删除

---

## 4. 桌面宠物交互行为

### 4.1 基础行为

| 触发 | 行为 |
|------|------|
| 单击 | 跳跃一下（正弦缓动，50px，1/6秒） |
| 双击 | 冒出 5 颗爱心粒子，向上飘散消失 |
| 有眨眼帧 | 每隔 2–5 秒随机眨眼一次（3帧） |
| 无眨眼帧 | 静止待机，不眨眼 |
| 拖拽 | 跟随鼠标，松开停在原地；拖拽时暂停跑动 |
| 右键 | 弹出菜单 |
| 透明区域 | 点击穿透到桌面 |

### 4.2 右键菜单

- **打开编辑器**：聚焦编辑器窗口并切换到该宠物
- **随机跑动**：toggle 开关（默认关闭），状态持久化
- **隐藏**：从桌面消失，列表绿点变灰
- **删除宠物**：弹确认弹窗，确认后从列表和磁盘删除

### 4.3 随机跑动

- 默认**关闭**，右键菜单可开启
- 每 3–8 秒随机选一个屏幕内的目标点
- 以每帧 2–4px 匀速移动，移动时同步跳跃动画（hop 感）
- 到达后停顿 1–3 秒，再选下一个点
- 不会跑出屏幕边缘
- 单击时中断移动执行跳跃，之后恢复
- 拖拽时暂停，松手后恢复
- 开关状态保存到 `PetDefinition.isWandering`

### 4.4 "做成桌宠"流程

1. 点击"▶ 做成桌宠"
2. 弹出命名弹窗（默认"未命名宠物 N"，可修改）
3. 确认后：
   - 画布渲染成 NSImage（普通帧 + 可选眨眼帧）
   - `PetStore.save()` 写入磁盘
   - `PetHostManager.spawn()` 创建 NSPanel
   - 宠物出现在屏幕中央，执行一次跳跃（"活过来"）
   - 宠物列表新增条目，绿点亮起

### 4.5 窗口尺寸

每格渲染 8px：

| 画布 | 显示大小 | NSPanel |
|------|---------|---------|
| 15×15 | 120×120 px | 200×200 |
| 25×25 | 200×200 px | 280×280 |
| 32×32 | 256×256 px | 320×320 |

---

## 5. 数据模型与持久化

### 5.1 PetDefinition

```swift
struct PetDefinition: Codable, Identifiable {
    let id:           UUID
    var name:         String
    var canvasSize:   Int             // 15 / 25 / 32
    var pixels:       [[String?]]     // [y][x] → hex，nil = 透明
    var blinkPixels:  [[String?]]?    // 眨眼帧，nil = 无
    var isWandering:  Bool            // 随机跑动开关
    var isVisible:    Bool            // 是否在桌面显示
    var lastPosition: CGPoint?        // 上次桌面位置
    let createdAt:    Date
}
```

### 5.2 磁盘结构

```
~/Library/Application Support/PixelPet/
├── pets.json                  # 所有宠物的完整定义列表
└── pets/
    └── {uuid}/
        ├── normal.png         # 预渲染普通帧（桌面宠物直接用）
        └── blink.png          # 预渲染眨眼帧（可选）
```

- `pets.json`：保留像素数组，供编辑器重新打开修改
- PNG 文件：预渲染好，桌面宠物直接加载，无需重新渲染

### 5.3 PixelCanvas

```swift
@MainActor
final class PixelCanvas: ObservableObject {
    @Published var pixels: [[Color?]]  // [y][x]，nil = 透明
    let size: Int

    func setPixel(x: Int, y: Int, color: Color?)
    func fill(x: Int, y: Int, color: Color?)    // flood fill
    func clear()
    func toNSImage(scale: Int = 8) -> NSImage   // 每格 8px 渲染
    func toHexArray() -> [[String?]]            // 序列化
    static func from(hexArray: [[String?]]) -> PixelCanvas
}
```

### 5.4 PetStore

```swift
final class PetStore {
    static let shared = PetStore()

    func loadAll() -> [PetDefinition]
    func save(_ pet: PetDefinition)           // 新增或更新，写 JSON + PNG
    func delete(id: UUID)                     // 删除宠物 + 清理文件夹
    func update(_ pet: PetDefinition)         // 更新字段（isWandering 等）
    func renderAndSave(_ pet: PetDefinition) -> (normal: NSImage, blink: NSImage?)
}
```

### 5.5 完整数据流

```
画画阶段
  用户点格子 → PixelCanvas.setPixel() 更新内存

做成桌宠
  点击按钮 → 命名弹窗 → 确认
  → canvas.toNSImage() 渲染
  → PetStore.save() 写 pets.json + PNG
  → PetHostManager.spawn() 创建窗口
  → 宠物出现屏幕中央，执行跳跃

App 重启
  → PetStore.loadAll() 读取 pets.json
  → 对每个 isVisible == true 的宠物
    → 读取 normal.png / blink.png
    → PetHostManager.spawn() 恢复到 lastPosition

切换跑动开关
  → PetDefinition.isWandering 更新
  → PetStore.update() 立即写回 pets.json
```

---

## 6. 平台要求

- macOS 13.0+
- Swift 5.9+
- Xcode Command Line Tools
