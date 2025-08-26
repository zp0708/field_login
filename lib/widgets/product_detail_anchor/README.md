# 商品详情锚点定位组件

这是一个功能完整的商品详情页面锚点定位组件，支持标签页导航和滚动高亮功能。

## 功能特性

1. **标签页导航**: 顶部显示可点击的标签页，支持快速跳转到对应内容区域
2. **滚动高亮**: 页面滚动时自动高亮当前可见区域对应的标签页
3. **平滑动画**: 点击标签页时提供平滑的滚动动画效果
4. **自定义配置**: 支持自定义锚点映射关系、样式和偏移量

## 核心组件

### AnchorController
负责管理滚动位置和标签页状态的控制器。

### ProductDetailAnchorPage
主要的锚点定位页面组件，提供完整的UI结构。

### AnchorConfig
锚点配置类，定义锚点的ID、标题、键值和偏移量。

## 使用示例

```dart
import 'package:flutter/material.dart';
import 'widgets/product_detail_anchor/product_detail_anchor.dart';

class MyProductPage extends StatefulWidget {
  @override
  State<MyProductPage> createState() => _MyProductPageState();
}

class _MyProductPageState extends State<MyProductPage> {
  late List<AnchorConfig> _anchors;

  @override
  void initState() {
    super.initState();
    _anchors = [
      AnchorConfig(
        id: 'overview',
        title: '商品概览',
        key: GlobalKey(),
      ),
      AnchorConfig(
        id: 'details',
        title: '商品详情',
        key: GlobalKey(),
      ),
      // 添加更多锚点...
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('商品详情')),
      body: ProductDetailAnchorPage(
        anchors: _anchors,
        contentBuilder: _buildSectionContent,
        tabBarHeight: 60.0,
        stickyOffset: 100.0,
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, AnchorConfig anchor) {
    // 根据anchor.id返回对应的内容Widget
    switch (anchor.id) {
      case 'overview':
        return _buildOverviewSection();
      case 'details':
        return _buildDetailsSection();
      default:
        return Container();
    }
  }
}
```

## 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| anchors | List<AnchorConfig> | 必需 | 锚点配置列表 |
| contentBuilder | Widget Function(BuildContext, AnchorConfig) | 必需 | 内容构建器 |
| tabBarHeight | double | 60.0 | 标签页高度 |
| stickyOffset | double | 100.0 | 吸顶偏移量 |
| tabBarBackgroundColor | Color? | null | 标签页背景色 |
| activeTabColor | Color? | null | 激活标签页颜色 |
| inactiveTabColor | Color? | null | 非激活标签页颜色 |

## 更新日志

### v1.1.0 - 2024-08-25
- **修复**: 解决了 CustomScrollView 滚动时 tab 不能正确高亮的问题
- **改进**: 优化了滚动检测算法，使用从后向前遍历的方式更准确地确定当前激活的锚点
- **改进**: 调整了滚动阈值，提供更好的用户体验
- **改进**: 在点击 tab 时立即更新激活状态，避免延迟感

## 特点

- **响应式设计**: 适配不同屏幕尺寸
- **性能优化**: 使用 AnimatedBuilder 减少不必要的重建
- **灵活配置**: 支持自定义样式和行为
- **易于使用**: 简洁的API设计，易于集成

## 演示

运行项目后，在首页选择"商品详情锚点定位"即可查看完整的演示效果。