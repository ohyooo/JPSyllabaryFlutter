# JPSyllabary Flutter

`JPSyllabary` 的 Flutter 跨平台版本，用于五十音记忆与发音练习。界面和主要功能转写自相邻的 Kotlin Multiplatform 项目 [`../JPSyllabary`](../JPSyllabary)。

## 功能

- 单字快测：随机显示平假名、片假名、浊音和半浊音，点击提示区域查看罗马音。
- 五十音表：支持平假名、片假名、罗马音和浊音分页，点击单元格短暂显示读音。
- 排序练习：可随机打乱或恢复五十音表顺序。
- 绕口令：每一行可横向切换平假名、片假名和罗马音，底部按钮可统一复位。
- 跟随系统语言显示中文或英文，跟随系统切换明暗主题。
- 支持 Android、iOS、Web、Windows、macOS 和 Linux。

## 环境要求

- Flutter 3.44 或更高版本
- Dart 3.12 或更高版本
- JDK 21（Android 构建使用 Gradle 9.6.1、Android Gradle Plugin 9.3.1）
- Android SDK 37、NDK 29.0.14206865（构建 Android 时）
- 目标平台对应的开发环境（例如 Android Studio/Android SDK、Xcode 或 Visual Studio）

先检查本机环境：

```bash
flutter doctor
```

## 启动方法

在本目录执行：

```bash
flutter pub get
flutter run
```

如果连接了多个设备，可先查看设备，再指定目标：

```bash
flutter devices
flutter run -d <device-id>
```

常见目标示例：

```bash
flutter run -d chrome
flutter run -d windows
```

## 检查与测试

```bash
flutter analyze
flutter test
```

## 项目结构

```text
lib/
├── main.dart             # Flutter 入口
└── src/
    ├── app.dart          # 应用壳层、导航与页面
    ├── kana_data.dart    # 假名、罗马音和绕口令数据
    └── strings.dart      # 中英文界面文案
assets/                   # 按钮图片与字体
```

原项目：[ohyooo/JPSyllabary](https://github.com/ohyooo/JPSyllabary)
