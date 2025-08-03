# 图片轮播器组件

这是一个功能完整的Flutter图片轮播器组件，支持自动播放、手动控制、多种指示器样式等功能。

## 功能特性

1. **传入images数组，显示所有图片**
2. **无限滚动功能** - 支持无限循环滚动，左右滑动无边界
3. **自动轮播功能** - 可设置是否自动轮播及轮播间隔
4. **控制器支持** - 使用控制器控制轮播进度和自动播放逻辑，多个轮播器可共享控制器
5. **多种指示器** - 支持圆点、数字、线条三种指示器样式
6. **自定义样式** - 支持自定义图片构建器、圆角、尺寸等

## 使用方法

### 基础用法

```dart
import 'package:field_login/widgets/image_carousel/image_carousel.dart';

// 图片列表
final List<String> images = [
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
  'https://example.com/image3.jpg',
];

// 基础轮播器（无限滚动）
ImageCarousel(
  images: images,
  height: 200,
  autoPlay: true,
  autoPlayInterval: Duration(seconds: 3),
  infiniteScroll: true, // 默认启用无限滚动
)

// 普通模式（非无限滚动）
ImageCarousel(
  images: images,
  height: 200,
  autoPlay: true,
  infiniteScroll: false,
)
```
```

### 使用控制器

```dart
import 'package:field_login/widgets/image_carousel/image_carousel_controller.dart';

// 创建控制器
final controller = ImageCarouselController();

// 使用控制器
ImageCarousel(
  images: images,
  controller: controller,
  autoPlay: false,
)

// 控制器操作
controller.nextPage();           // 下一页
controller.previousPage();       // 上一页
controller.jumpToPage(2);        // 跳转到指定页
controller.startAutoPlay();      // 开始自动播放
controller.stopAutoPlay();       // 停止自动播放
controller.toggleAutoPlay();     // 切换自动播放状态
```

### 自定义指示器

```dart
ImageCarousel(
  images: images,
  indicatorType: CarouselIndicatorType.dots,     // 圆点指示器
  // indicatorType: CarouselIndicatorType.numbers, // 数字指示器
  // indicatorType: CarouselIndicatorType.lines,   // 线条指示器
  indicatorActiveColor: Colors.blue,
  indicatorInactiveColor: Colors.grey,
  indicatorSize: 10,
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
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(image, fit: BoxFit.cover),
      ),
    );
  },
)
```

## 组件参数

### ImageCarousel

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| images | List<String> | 必需 | 图片URL列表 |
| controller | ImageCarouselController? | null | 控制器 |
| autoPlay | bool | false | 是否自动播放 |
| autoPlayInterval | Duration | Duration(seconds: 3) | 自动播放间隔 |
| height | double? | null | 高度 |
| width | double? | null | 宽度 |
| fit | BoxFit | BoxFit.cover | 图片适配方式 |
| borderRadius | BorderRadius? | null | 圆角 |
| showIndicator | bool | true | 是否显示指示器 |
| indicatorType | CarouselIndicatorType | CarouselIndicatorType.dots | 指示器类型 |
| indicatorActiveColor | Color? | null | 指示器激活颜色 |
| indicatorInactiveColor | Color? | null | 指示器未激活颜色 |
| indicatorSize | double? | null | 指示器大小 |
| indicatorPadding | EdgeInsetsGeometry? | null | 指示器内边距 |
| onImageTap | VoidCallback? | null | 图片点击回调 |
| imageBuilder | Widget? Function(String, int)? | null | 自定义图片构建器 |
| infiniteScroll | bool | true | 是否启用无限滚动 |

### CarouselIndicatorType

- `dots` - 圆点指示器
- `numbers` - 数字指示器  
- `lines` - 线条指示器

## 控制器方法

### ImageCarouselController

| 方法 | 说明 |
|------|------|
| nextPage() | 下一页 |
| previousPage() | 上一页 |
| jumpToPage(int index) | 跳转到指定页 |
| animateToPage(int index) | 动画跳转到指定页 |
| startAutoPlay({Duration? interval}) | 开始自动播放 |
| stopAutoPlay() | 停止自动播放 |
| toggleAutoPlay({Duration? interval}) | 切换自动播放状态 |
| setAutoPlayInterval(Duration interval) | 设置自动播放间隔 |

## 示例

运行应用查看完整的演示效果，包括：

1. 基础轮播器
2. 自定义指示器
3. 共享控制器
4. 控制器操作

## 注意事项

1. 控制器需要在不需要时调用 `dispose()` 方法释放资源
2. 多个轮播器共享控制器时，只有创建控制器的组件需要调用 `dispose()`
3. 图片加载失败时会显示错误图标
4. 自动播放在图片数量为1时会自动禁用 