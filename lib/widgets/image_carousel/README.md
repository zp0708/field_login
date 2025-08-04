# Image Carousel 图片轮播器组件

一个功能丰富的Flutter图片轮播器组件，支持无限滚动、自动播放、自定义指示器、图片查看器等功能。

## 功能特性

### 基础功能
- ✅ 无限滚动模式
- ✅ 自动播放控制
- ✅ 多种指示器类型（圆点、数字、线条、进度条）
- ✅ 自定义图片构建器
- ✅ 图片查看器弹窗
- ✅ 控制器外部控制

### 新增功能
- ✅ 手势控制（缩放、双击）
- ✅ 图片预加载
- ✅ 错误重试机制
- ✅ 自定义占位符和错误组件
- ✅ 动画指示器
- ✅ 暂停/恢复自动播放
- ✅ 用户交互检测
- ✅ 状态信息获取

## 快速开始

### 基础使用

```dart
import 'package:field_login/widgets/image_carousel/image_carousel.dart';

ImageCarousel(
  images: [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
  ],
  height: 200,
  autoPlay: true,
  autoPlayInterval: const Duration(seconds: 3),
)
```

### 高级使用

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  width: double.infinity,
  autoPlay: true,
  autoPlayInterval: const Duration(seconds: 2),
  infiniteScroll: true,
  borderRadius: BorderRadius.circular(12),
  showIndicator: true,
  indicatorType: CarouselIndicatorType.dots,
  indicatorActiveColor: Colors.blue,
  indicatorInactiveColor: Colors.grey,
  enableZoom: true,
  minScale: 0.5,
  maxScale: 3.0,
  enablePreload: true,
  preloadCount: 2,
  enableErrorRetry: true,
  maxRetryCount: 3,
  retryDelay: const Duration(seconds: 2),
  placeholder: CustomPlaceholder(),
  errorWidget: CustomErrorWidget(),
  onImageViewer: (index) {
    // 处理图片查看
  },
)
```

## API 文档

### ImageCarousel 参数

#### 基础参数
- `images` (List<String>) - 图片URL列表
- `controller` (ImageCarouselController?) - 外部控制器
- `autoPlay` (bool) - 是否自动播放，默认 false
- `autoPlayInterval` (Duration) - 自动播放间隔，默认 3秒
- `height` (double?) - 轮播器高度
- `width` (double?) - 轮播器宽度
- `fit` (BoxFit) - 图片适配方式，默认 BoxFit.cover
- `borderRadius` (BorderRadius?) - 圆角设置

#### 指示器参数
- `showIndicator` (bool) - 是否显示指示器，默认 true
- `indicatorType` (CarouselIndicatorType) - 指示器类型
- `indicatorActiveColor` (Color?) - 激活状态颜色
- `indicatorInactiveColor` (Color?) - 非激活状态颜色
- `indicatorSize` (double?) - 指示器大小
- `indicatorPadding` (EdgeInsetsGeometry?) - 指示器内边距

#### 新增功能参数
- `enableGestureControl` (bool) - 启用手势控制，默认 true
- `enablePreload` (bool) - 启用预加载，默认 true
- `preloadCount` (int) - 预加载数量，默认 2
- `enableErrorRetry` (bool) - 启用错误重试，默认 true
- `maxRetryCount` (int) - 最大重试次数，默认 3
- `retryDelay` (Duration) - 重试延迟，默认 2秒
- `placeholder` (Widget?) - 自定义占位符
- `errorWidget` (Widget?) - 自定义错误组件
- `enableZoom` (bool) - 启用缩放，默认 false
- `minScale` (double) - 最小缩放比例，默认 0.5
- `maxScale` (double) - 最大缩放比例，默认 3.0

#### 回调函数
- `onImageTap` (VoidCallback?) - 图片点击回调
- `onImageViewer` (Function(int index)?) - 图片查看器回调
- `imageBuilder` (Widget? Function(String image, int index)?) - 自定义图片构建器

### ImageCarouselController 方法

#### 基础控制
- `setCurrentIndex(int index)` - 设置当前索引
- `nextPage()` - 下一页
- `previousPage()` - 上一页
- `jumpToPage(int index)` - 跳转到指定页面

#### 自动播放控制
- `startAutoPlay({Duration? interval})` - 开始自动播放
- `stopAutoPlay()` - 停止自动播放
- `toggleAutoPlay({Duration? interval})` - 切换自动播放状态
- `pauseAutoPlay()` - 暂停自动播放
- `resumeAutoPlay()` - 恢复自动播放
- `togglePause()` - 切换暂停状态

#### 状态管理
- `setAutoPlayInterval(Duration interval)` - 设置播放间隔
- `setPauseAfterInteraction(Duration duration)` - 设置交互后暂停时间
- `getStatus()` - 获取状态信息
- `reset()` - 重置控制器状态

### CarouselIndicatorType 枚举

- `dots` - 圆点指示器
- `numbers` - 数字指示器
- `lines` - 线条指示器
- `progress` - 进度条指示器

## 使用示例

### 1. 基础轮播器

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  autoPlay: true,
  autoPlayInterval: const Duration(seconds: 3),
)
```

### 2. 带控制器的轮播器

```dart
final controller = ImageCarouselController();

ImageCarousel(
  images: imageList,
  controller: controller,
  height: 200,
)

// 外部控制
ElevatedButton(
  onPressed: () => controller.nextPage(),
  child: Text('下一页'),
)
```

### 3. 自定义指示器

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  indicatorType: CarouselIndicatorType.progress,
  indicatorActiveColor: Colors.green,
  indicatorInactiveColor: Colors.grey[300],
  indicatorSize: 12,
)
```

### 4. 缩放功能

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  enableZoom: true,
  minScale: 0.5,
  maxScale: 3.0,
  onImageViewer: (index) {
    // 处理图片查看
  },
)
```

### 5. 错误重试

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  enableErrorRetry: true,
  maxRetryCount: 3,
  retryDelay: const Duration(seconds: 2),
  errorWidget: Container(
    color: Colors.red[100],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, color: Colors.red),
        Text('加载失败'),
      ],
    ),
  ),
)
```

### 6. 预加载功能

```dart
ImageCarousel(
  images: imageList,
  height: 200,
  enablePreload: true,
  preloadCount: 2,
  placeholder: Container(
    color: Colors.grey[200],
    child: Center(child: CircularProgressIndicator()),
  ),
)
```

### 7. 高级控制器使用

```dart
final controller = ImageCarouselController();

// 开始自动播放
controller.startAutoPlay(interval: const Duration(seconds: 2));

// 暂停自动播放
controller.pauseAutoPlay();

// 恢复自动播放
controller.resumeAutoPlay();

// 获取状态信息
final status = controller.getStatus();
print('当前索引: ${status['currentIndex']}');
print('总数量: ${status['totalCount']}');
print('自动播放: ${status['isAutoPlaying']}');
```

## 组件结构

```
image_carousel/
├── image_carousel.dart              # 主组件
├── image_carousel_controller.dart   # 控制器
├── carousel_indicator.dart          # 指示器组件
├── image_viewer_dialog.dart         # 图片查看器
└── README.md                        # 文档
```

## 演示

运行应用并进入"图片轮播器"页面，可以查看完整的功能演示，包括：

1. **基础轮播器** - 无限滚动和普通模式
2. **自定义指示器** - 圆点、数字、线条、进度条
3. **共享控制器** - 多个轮播器共享控制器
4. **控制器操作** - 外部控制轮播器
5. **缩放功能** - 图片缩放和手势控制
6. **错误重试** - 错误处理和重试机制
7. **预加载功能** - 图片预加载和占位符
8. **高级指示器** - 动画指示器和进度条
9. **进度条指示器测试** - 在不同布局中的测试
10. **约束测试** - 各种布局约束下的表现
11. **控制器状态信息** - 详细的状态信息

## 更新日志

### v2.0.0 (最新)
- ✨ 新增缩放功能
- ✨ 新增图片预加载
- ✨ 新增错误重试机制
- ✨ 新增自定义占位符和错误组件
- ✨ 新增动画指示器
- ✨ 新增暂停/恢复自动播放
- ✨ 新增用户交互检测
- ✨ 新增状态信息获取
- ✨ 新增进度条指示器类型
- 🐛 修复无限滚动模式下的同步问题
- 🐛 优化控制器状态管理
- 🐛 修复布局约束问题

### v1.0.0
- 🎉 初始版本发布
- ✨ 基础轮播功能
- ✨ 自动播放控制
- ✨ 多种指示器类型
- ✨ 图片查看器
- ✨ 控制器外部控制

## 贡献

欢迎提交 Issue 和 Pull Request 来改进这个组件。

## 许可证

MIT License 