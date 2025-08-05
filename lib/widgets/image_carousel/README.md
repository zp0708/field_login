# ImageCarousel 覆盖层系统

ImageCarousel 支持覆盖层系统，允许您灵活地在轮播图上添加自定义UI。

## 使用方法

### 基础用法

```dart
ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    // 您的自定义Widget列表
  ],
)
```

### 使用内置覆盖层组件

#### 指示器覆盖层

```dart
import 'package:your_app/widgets/image_carousel/overlays/indicator_overlay.dart';

ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    IndicatorOverlay(
      controller: controller,
      type: CarouselIndicatorType.dots,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
    ),
  ],
)
```

#### 页码显示覆盖层

```dart
import 'package:your_app/widgets/image_carousel/overlays/page_counter_overlay.dart';

ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    PageCounterOverlay(
      controller: controller,
      backgroundColor: Colors.black54,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
)
```

#### 控制按钮覆盖层

```dart
import 'package:your_app/widgets/image_carousel/overlays/control_buttons_overlay.dart';

ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    ControlButtonsOverlay(
      controller: controller,
      buttonSize: 40,
      backgroundColor: Colors.black54,
      buttonColor: Colors.white,
    ),
  ],
)
```

### 多覆盖层组合

```dart
ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    IndicatorOverlay(
      controller: controller,
      type: CarouselIndicatorType.progress,
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      size: 8,
    ),
    PageCounterOverlay(
      controller: controller,
      backgroundColor: Colors.black54,
    ),
    ControlButtonsOverlay(
      controller: controller,
      buttonSize: 36,
      backgroundColor: Colors.black54,
      buttonColor: Colors.white,
    ),
  ],
)
```

## 内置覆盖层组件

### IndicatorOverlay

指示器覆盖层，支持多种指示器类型。

**参数：**
- `controller` (ImageCarouselController) - 轮播图控制器
- `type` (CarouselIndicatorType) - 指示器类型，默认 `dots`
- `activeColor` (Color?) - 激活状态颜色
- `inactiveColor` (Color?) - 非激活状态颜色
- `size` (double?) - 指示器大小
- `padding` (EdgeInsetsGeometry?) - 指示器内边距
- `enableAnimation` (bool) - 是否启用动画，默认 `true`
- `animationDuration` (Duration) - 动画时长，默认 300ms
- `onIndicatorTap` (VoidCallback?) - 点击指示器回调

### PageCounterOverlay

页码显示覆盖层，显示当前页码和总页数。

**参数：**
- `controller` (ImageCarouselController) - 轮播图控制器
- `textStyle` (TextStyle?) - 文本样式
- `backgroundColor` (Color?) - 背景颜色
- `borderRadius` (BorderRadius?) - 背景圆角
- `padding` (EdgeInsetsGeometry?) - 内边距，默认 `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`
- `separator` (String) - 分隔符，默认 `' / '`
- `showTotal` (bool) - 是否显示总页数，默认 `true`
- `formatter` (String Function(int current, int total)?) - 自定义格式化函数

### ControlButtonsOverlay

控制按钮覆盖层，提供上一页、下一页等控制功能。

**参数：**
- `controller` (ImageCarouselController) - 轮播图控制器
- `buttonSize` (double) - 按钮大小，默认 `40`
- `previousIcon` (IconData?) - 上一页按钮图标，默认 `Icons.chevron_left`
- `nextIcon` (IconData?) - 下一页按钮图标，默认 `Icons.chevron_right`
- `buttonColor` (Color?) - 按钮颜色
- `backgroundColor` (Color?) - 按钮背景颜色
- `borderRadius` (BorderRadius?) - 按钮圆角
- `showPreviousButton` (bool) - 是否显示上一页按钮，默认 `true`
- `showNextButton` (bool) - 是否显示下一页按钮，默认 `true`
- `onPreviousTap` (VoidCallback?) - 上一页按钮点击回调
- `onNextTap` (VoidCallback?) - 下一页按钮点击回调

## 自定义覆盖层

您也可以创建自定义的覆盖层组件：

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
      // 设置位置
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          // 您的自定义UI
          return YourCustomWidget();
        },
      ),
    );
  }
}

// 使用自定义覆盖层
ImageCarousel(
  images: images,
  overlaysBuilder: (controller) => [
    CustomOverlay(controller: controller),
  ],
)
```

## 优势

### Builder 方式的优势

1. **正确的初始化时机** - 覆盖层在 controller 准备好后才进行初始化
2. **访问控制器** - 可以直接访问 ImageCarouselController 来控制轮播图
3. **响应式更新** - 使用 ListenableBuilder 来监听控制器状态变化
4. **类型安全** - 编译时就能确保参数类型正确
5. **简洁高效** - 一次调用返回所有 Widget，避免多次映射
6. **组件化** - 内置覆盖层组件，易于使用和定制

### 使用场景

- **指示器** - 显示当前页面位置
- **页码显示** - 显示当前页码和总页数
- **控制按钮** - 提供上一页、下一页等控制功能
- **自定义UI** - 任何需要访问控制器的自定义Widget

## 注意事项

1. **覆盖层位置**：覆盖层在 ImageCarousel 的 Stack 中渲染，使用 `Positioned` 来控制位置
2. **控制器访问**：覆盖层可以通过 `ListenableBuilder` 来监听控制器状态变化
3. **性能考虑** - 避免在覆盖层中执行昂贵的操作
4. **布局冲突**：确保多个覆盖层不会相互遮挡
5. **初始化时机**：覆盖层在 controller 准备好后才进行初始化，确保不会出现空指针错误

## 最佳实践

1. **使用 ListenableBuilder** - 确保UI能够响应控制器状态变化
2. **合理布局** - 使用 Positioned 来精确控制覆盖层位置
3. **性能优化** - 避免在 builder 中创建复杂的Widget树
4. **错误处理** - 在访问控制器属性前进行空值检查
5. **返回列表** - overlaysBuilder 必须返回 Widget 列表
6. **组件复用** - 优先使用内置覆盖层组件，减少重复代码 