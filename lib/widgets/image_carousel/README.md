# ImageCarousel 图片轮播器

一个功能丰富的Flutter图片轮播组件，支持自动播放、手势控制、预加载、错误重试、Hero动画等功能。提供高度可定制的配置选项和灵活的UI配置。

## ✨ 特性

- 🎯 **配置分离**：功能配置和UI配置分离，语义更清晰
- 🎮 **手势控制**：支持点击、缩放、滑动等手势操作
- 🔄 **自动播放**：支持自动轮播，可自定义播放间隔
- 🖼️ **Hero动画**：支持Hero动画，提供平滑的过渡效果
- 💾 **缓存支持**：内置图片缓存，提升加载性能
- 🔄 **错误重试**：网络错误自动重试机制
- 📱 **预加载**：智能预加载，提升用户体验
- 🎨 **高度定制**：支持自定义占位符、错误组件、图片构建器等
- 🏗️ **覆盖层系统**：灵活的覆盖层系统，支持自定义UI

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  cached_network_image: ^3.3.1
```

## 🚀 快速开始

### 基础用法

```dart
import 'package:flutter/material.dart';
import 'package:your_app/widgets/image_carousel/image_carousel.dart';

class MyWidget extends StatelessWidget {
  final List<String> images = [
    'https://picsum.photos/400/200?random=1',
    'https://picsum.photos/400/200?random=2',
    'https://picsum.photos/400/200?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return ImageCarousel(
      images: images,
      height: 200,
      borderRadius: BorderRadius.circular(12),
      onImageTap: (image, index) {
        print('点击了第 ${index + 1} 张图片');
      },
    );
  }
}
```

### 使用配置选项（推荐）

```dart
// 创建功能配置
final options = ImageCarouselOptions(
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 3),
  enableZoom: true,
  enableHeroAnimation: true,
  minScale: 0.8,
  maxScale: 4.0,
);

// 使用分离的配置方式
ImageCarousel(
  images: images,
  options: options,
  borderRadius: BorderRadius.circular(12),
  placeholder: Container(
    color: Colors.grey[200],
    child: Center(child: CircularProgressIndicator()),
  ),
  onImageTap: (image, index) => handleTap(image, index),
)
```

### 使用命名参数（兼容）

```dart
ImageCarousel.withOptions(
  images: images,
  autoPlay: true,
  height: 200,
  borderRadius: BorderRadius.circular(12),
  placeholder: myPlaceholder,
  onImageTap: (image, index) => handleTap(image, index),
)
```

## ⚙️ 配置选项

### 功能配置 (ImageCarouselOptions)

```dart
ImageCarouselOptions(
  // 自动播放
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 3),
  
  // 尺寸设置
  height: 200,
  width: double.infinity,
  
  // 图片适配
  fit: BoxFit.cover,
  
  // 缓存和预加载
  enableCache: true,
  enablePreload: true,
  preloadCount: 2,
  
  // 错误处理
  enableErrorRetry: true,
  maxRetryCount: 3,
  retryDelay: Duration(seconds: 2),
  
  // 手势控制
  enableGestureControl: true,
  enableZoom: true,
  minScale: 0.5,
  maxScale: 3.0,
  
  // Hero动画
  enableHeroAnimation: true,
  heroTagPrefix: 'my_carousel',
  
  // 滚动设置
  infiniteScroll: true,
)
```

### UI配置（直接参数）

```dart
ImageCarousel(
  images: images,
  options: options,
  
  // UI相关配置
  borderRadius: BorderRadius.circular(12),
  placeholder: myPlaceholder,
  errorWidget: myErrorWidget,
  onImageTap: (image, index) => handleTap(image, index),
  imageBuilder: (image, index) => myCustomWidget,
  overlaysBuilder: (controller) => myOverlays,
)
```

## 🎨 自定义UI

### 自定义占位符

```dart
ImageCarousel(
  images: images,
  placeholder: Container(
    color: Colors.grey[200],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 8),
          Text('加载中...'),
        ],
      ),
    ),
  ),
)
```

### 自定义错误组件

```dart
ImageCarousel(
  images: images,
  errorWidget: Container(
    color: Colors.red[100],
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 8),
          Text('加载失败'),
          ElevatedButton(
            onPressed: () => retry(),
            child: Text('重试'),
          ),
        ],
      ),
    ),
  ),
)
```

### 自定义图片构建器

```dart
ImageCarousel(
  images: images,
  imageBuilder: (image, index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          image,
          fit: BoxFit.cover,
        ),
      ),
    );
  },
)
```

## 🏗️ 覆盖层系统

### 基础用法

```dart
ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    // 您的自定义Widget列表
  ],
)
```

### 使用内置覆盖层

```dart
import 'package:your_app/widgets/image_carousel/overlays/carousel_indicator.dart';
import 'package:your_app/widgets/image_carousel/overlays/page_counter_overlay.dart';
import 'package:your_app/widgets/image_carousel/overlays/control_buttons_overlay.dart';

ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    // 指示器
    Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: CarouselIndicator(
        currentIndex: controller.currentIndex,
        totalCount: images.length,
        type: CarouselIndicatorType.dots,
        activeColor: Colors.white,
        inactiveColor: Colors.white.withOpacity(0.5),
      ),
    ),
    
    // 页码显示
    PageCounterOverlay(
      controller: controller,
    ),
    
    // 控制按钮
    ControlButtonsOverlay(
      controller: controller,
      showPreviousButton: true,
      showNextButton: true,
    ),
  ],
)
```

### 自定义覆盖层

```dart
class CustomOverlay extends StatelessWidget {
  final ImageCarouselController controller;
  
  const CustomOverlay({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.currentIndex + 1}/${controller.totalCount}',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
```

## 🎮 控制器使用

### 基础控制

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late ImageCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImageCarouselController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageCarousel(
          images: images,
          controller: _controller,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _controller.previousPage(),
              child: Text('上一张'),
            ),
            ElevatedButton(
              onPressed: () => _controller.nextPage(),
              child: Text('下一张'),
            ),
            ElevatedButton(
              onPressed: () => _controller.jumpToPage(0),
              child: Text('第一张'),
            ),
          ],
        ),
      ],
    );
  }
}
```

### 控制器方法

```dart
// 页面控制
controller.nextPage();           // 下一页
controller.previousPage();       // 上一页
controller.jumpToPage(index);    // 跳转到指定页面

// 自动播放控制
controller.startAutoPlay();      // 开始自动播放
controller.stopAutoPlay();       // 停止自动播放
controller.pauseAutoPlay();      // 暂停自动播放
controller.resumeAutoPlay();     // 恢复自动播放

// 状态获取
controller.currentIndex;         // 当前索引
controller.totalCount;           // 总数量
controller.isAutoPlaying;        // 是否正在自动播放
controller.isPaused;            // 是否暂停
```

## 📋 配置模板

### 基础配置模板

```dart
class CarouselConfigs {
  // 基础配置
  static const ImageCarouselOptions basic = ImageCarouselOptions(
    autoPlay: true,
    height: 200,
    enableCache: true,
  );
  
  // 高级配置
  static const ImageCarouselOptions advanced = ImageCarouselOptions(
    autoPlay: true,
    enableZoom: true,
    enableHeroAnimation: true,
    minScale: 0.8,
    maxScale: 4.0,
  );
  
  // 全屏配置
  static const ImageCarouselOptions fullscreen = ImageCarouselOptions(
    autoPlay: false,
    enableZoom: true,
    enableHeroAnimation: true,
    minScale: 0.5,
    maxScale: 5.0,
  );
}
```

### UI配置模板

```dart
class CarouselUI {
  static Widget get defaultPlaceholder => Container(
    color: Colors.grey[200],
    child: Center(child: CircularProgressIndicator()),
  );
  
  static Widget get defaultErrorWidget => Container(
    color: Colors.red[100],
    child: Center(child: Text('加载失败')),
  );
  
  static BorderRadius get defaultBorderRadius => BorderRadius.circular(12);
}
```

## 🔧 高级用法

### Hero动画

```dart
ImageCarousel(
  images: images,
  options: ImageCarouselOptions(
    enableHeroAnimation: true,
    heroTagPrefix: 'my_carousel',
  ),
  onImageTap: (image, index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(
          images: images,
          initialIndex: index,
        ),
      ),
    );
  },
)
```

### 缩放功能

```dart
ImageCarousel(
  images: images,
  options: ImageCarouselOptions(
    enableZoom: true,
    minScale: 0.5,
    maxScale: 3.0,
  ),
)
```

### 错误重试

```dart
ImageCarousel(
  images: images,
  options: ImageCarouselOptions(
    enableErrorRetry: true,
    maxRetryCount: 5,
    retryDelay: Duration(seconds: 3),
  ),
  errorWidget: Container(
    color: Colors.red[100],
    child: Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48),
          Text('加载失败'),
          ElevatedButton(
            onPressed: () => retry(),
            child: Text('重试'),
          ),
        ],
      ),
    ),
  ),
)
```

## 📱 最佳实践

### 1. 性能优化

```dart
// 使用const构造函数
const ImageCarouselOptions basic = ImageCarouselOptions(
  autoPlay: true,
  height: 200,
);

// 复用配置
final commonOptions = ImageCarouselOptions(
  enableCache: true,
  enablePreload: true,
  preloadCount: 2,
);
```

### 2. 错误处理

```dart
ImageCarousel(
  images: images,
  options: ImageCarouselOptions(
    enableErrorRetry: true,
    maxRetryCount: 3,
  ),
  errorWidget: Container(
    color: Colors.red[100],
    child: Center(
      child: Column(
        children: [
          Icon(Icons.error_outline),
          Text('网络错误，请检查网络连接'),
          ElevatedButton(
            onPressed: () => retry(),
            child: Text('重试'),
          ),
        ],
      ),
    ),
  ),
)
```

### 3. 内存管理

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late ImageCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ImageCarouselController();
  }

  @override
  void dispose() {
    _controller.dispose(); // 重要：释放资源
    super.dispose();
  }
}
```

## 🐛 常见问题

### Q: 图片加载失败怎么办？
A: 检查网络连接，确保图片URL有效，可以设置 `enableErrorRetry: true` 启用自动重试。

### Q: 如何禁用自动播放？
A: 设置 `autoPlay: false` 或调用 `controller.stopAutoPlay()`。

### Q: 如何自定义图片显示效果？
A: 使用 `imageBuilder` 参数来自定义图片构建逻辑。

### Q: 如何添加页面指示器？
A: 使用 `overlaysBuilder` 参数添加自定义指示器组件。

### Q: 如何实现图片预览？
A: 使用 `onImageTap` 回调结合Hero动画实现图片预览功能。

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 支持

如果您在使用过程中遇到问题，请：

1. 查看本文档
2. 搜索已有的 Issue
3. 创建新的 Issue 并详细描述问题

---

**ImageCarousel** - 让图片轮播更简单、更强大！ 🚀 