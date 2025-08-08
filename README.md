# Flutter 组件库

这是一个收集和展示各种实用 Flutter 组件的项目。

## 组件列表

### 1. 图片轮播器
支持自动播放、手动控制、多种指示器、缩放、预加载、错误重试等功能的图片轮播组件。

### 2. 进度对话框
通用进度对话框组件，支持外部控制进度和错误处理。

### 3. 手机号输入框
带格式化和验证的手机号输入组件。

### 4. 形状标签组件
自定义形状的标签组件。

### 5. WebView 交互测试 ⭐
带有左侧工具栏的 WebView 页面，支持 Flutter 与 JavaScript 的双向通信。

#### 功能特性：
- **左侧工具栏**：设计列表，支持卡片化展示和选中高亮
- **中央 WebView**：加载本地 HTML 文件，支持 JavaScript 交互
- **双向通信**：Flutter ↔ JavaScript
- **加载状态和错误处理**：包含加载指示器和错误重试功能

#### 使用方法：
1. 点击左侧设计卡片切换设计
2. 在 WebView 中点击测试按钮验证交互

#### 技术实现：
- 使用 `flutter_inappwebview` 插件
- `evaluateJavascript` 实现 Flutter → JS 通信
- `window.flutter_inappwebview.callHandler` 实现 JS → Flutter 通信

### 6. 右侧半透明半圆
放在屏幕右侧中央的半透明半圆组件，支持自定义样式和内容。

### 7. 圆形菜单组件
按钮均匀分布在圆内的圆形菜单组件。

## 开发环境

- Flutter SDK: ^3.6.2
- Dart SDK: ^3.6.2

## 依赖包

- `flutter_inappwebview`: ^6.0.0 - WebView 功能
- `cached_network_image`: ^3.3.1 - 图片缓存
- `cupertino_icons`: ^1.0.8 - iOS 风格图标

## 运行项目

```bash
flutter pub get
flutter run
```

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── pages/
│   ├── home_page.dart        # 主页面
│   └── webview_page.dart     # WebView 交互测试页面
├── demos/                    # 组件演示
├── widgets/                  # 自定义组件
└── style/                    # 样式适配
```

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。