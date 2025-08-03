# Flutter 组件库

这是一个Flutter组件库项目，收集和展示各种实用的Flutter组件。

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── pages/
│   └── home_page.dart          # 首页，展示所有组件
├── demos/                      # 组件演示页面
│   ├── carousel_demo.dart      # 图片轮播器演示
│   ├── progress_demo.dart      # 进度对话框演示
│   ├── phone_input_demo.dart   # 手机号输入框演示
│   └── shape_tab_demo.dart    # 形状标签组件演示
├── widgets/                    # 组件库
│   ├── image_carousel/        # 图片轮播器组件
│   │   ├── image_carousel.dart
│   │   ├── image_carousel_controller.dart
│   │   ├── carousel_indicator.dart
│   │   └── README.md
│   ├── progress_dialog/       # 进度对话框组件
│   │   ├── progress_dialog.dart
│   │   └── progress_controller.dart
│   ├── phone_input_widget.dart # 手机号输入框组件
│   ├── shape_tab_widget/      # 形状标签组件
│   │   └── shape_tab_widget.dart
│   ├── background_widget.dart # 背景组件
│   ├── clip_shadow_path.dart  # 阴影路径组件
│   ├── login_tab_widget.dart  # 登录标签组件
│   └── ...
└── style/
    └── adapt.dart             # 适配工具
```

## 已实现的组件

### 1. 图片轮播器 (ImageCarousel)
- **功能**: 支持自动播放、手动控制、多种指示器的图片轮播组件
- **特性**:
  - 传入images数组显示所有图片
  - 可设置自动轮播及间隔时间
  - 控制器支持手动控制
  - 多种指示器样式（圆点、数字、线条）
- **位置**: `lib/widgets/image_carousel/`

### 2. 进度对话框 (ProgressDialog)
- **功能**: 通用进度对话框组件，支持外部控制进度和错误处理
- **特性**:
  - 基础进度对话框
  - 外部控制进度
  - 文件上传模拟
  - 错误处理演示
- **位置**: `lib/widgets/progress_dialog/`

### 3. 手机号输入框 (PhoneInputWidget)
- **功能**: 带格式化和验证的手机号输入组件
- **特性**:
  - 手机号格式化
  - 输入验证
  - 自定义样式
  - 实时格式化
- **位置**: `lib/widgets/phone_input_widget.dart`

### 4. 形状标签组件 (ShapeTabWidget)
- **功能**: 自定义形状的标签组件
- **特性**:
  - 自定义形状
  - 多种样式
  - 灵活配置
  - 动画效果
- **位置**: `lib/widgets/shape_tab_widget/`

## 使用方法

### 运行项目
```bash
flutter run
```

### 查看组件演示
1. 启动应用后会看到首页，展示所有组件
2. 点击有演示的组件可以跳转到对应的演示页面
3. 在演示页面可以查看组件的各种功能和用法

### 使用组件
```dart
// 图片轮播器
import 'package:field_login/widgets/image_carousel/image_carousel.dart';

ImageCarousel(
  images: ['image1.jpg', 'image2.jpg'],
  autoPlay: true,
  height: 200,
)

// 进度对话框
import 'package:field_login/widgets/progress_dialog/progress_dialog.dart';

ProgressDialog.show(context, message: '处理中...');

// 手机号输入框
import 'package:field_login/widgets/phone_input_widget.dart';

PhoneInputWidget(
  controller: controller,
  onChanged: (value) => print(value),
)

// 形状标签组件
import 'package:field_login/widgets/shape_tab_widget/shape_tab_widget.dart';

ShapeTabWidget(
  tabs: ['标签1', '标签2'],
  selectedIndex: 0,
  onTabSelected: (index) => print(index),
)
```

## 开发计划

- [x] 图片轮播器组件
- [x] 进度对话框组件
- [x] 手机号输入框组件
- [x] 形状标签组件
- [ ] 更多组件...

## 技术栈

- Flutter 3.x
- Dart 3.x
- Material Design 3

## 贡献

欢迎提交Issue和Pull Request来改进这个组件库！

## 许可证

MIT License
