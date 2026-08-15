# DeepFry 🍟

一个跨平台（iOS + Android）移动 App 模板，基于 **Flutter 3.47** 构建。

## 快速开始

```bash
# 进入项目目录
cd deepfry

# 获取依赖
flutter pub get

# 运行（会自动启动已连接的模拟器/真机）
flutter run
```

### 在 iOS 模拟器运行

1. 确保已安装 Xcode 和 CocoaPods
2. 启动模拟器：`open -a Simulator`
3. 运行：`flutter run`

### 在 Android 模拟器运行

1. 安装 Android Studio，打开后安装 Android SDK
2. 创建 Android 虚拟设备 (AVD) 并启动
3. 运行：`flutter run`

## 项目结构

```
lib/
├── main.dart              # App 入口，配置主题
├── pages/
│   ├── home_page.dart     # 首页 — 功能卡片列表
│   └── settings_page.dart # 设置 — 主题切换 & 关于
test/
└── widget_test.dart       # 基础冒烟测试
```

## 如何添加新功能

1. 在 `lib/pages/` 下新建页面文件，例如 `my_feature_page.dart`
2. 在 `home_page.dart` 中增加一张卡片，点击跳转到新页面
3. 运行 `flutter run` 热重载即可看到效果

## 技术栈

| 层 | 选择 |
|---|---|
| 框架 | Flutter 3.47 (Dart 3.13) |
| UI 库 | Material Design 3 |
| 主题 | 内置亮色 / 暗色双主题 |
| 状态管理 | StatefulWidget（内置，可替换为 Provider / Riverpod） |

## 常见问题

**Q: flutter doctor 显示 Android 工具链缺失？**
A: 安装 Android Studio，首次启动时会自动下载 Android SDK。完成后运行 `flutter doctor --android-licenses` 接受许可。

**Q: 如何修改 App 图标？**
A: 替换 `android/app/src/main/res/` 和 `ios/Runner/Assets.xcassets/AppIcon.appiconset/` 下的图标文件。

**Q: 如何添加网络请求？**
A: 在 `pubspec.yaml` 的 `dependencies` 中添加 `http` 或 `dio` 包，然后运行 `flutter pub get`。