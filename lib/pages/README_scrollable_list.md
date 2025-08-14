# 滚动列表页面 (ScrollableListPage)

## 功能特性

这个页面实现了一个具有特殊滚动行为的列表，主要特性包括：

### 1. 智能工具条行为
- **固定高度**: 工具条高度为88像素
- **向下滚动**: 当列表向下滚动时，工具条保持固定位置，不向下移动
- **向上滚动**: 当列表向上滚动时，工具条会跟随列表向上滚动最多44像素的距离

### 2. GridView布局
- **4列布局**: 使用GridView.builder实现4列网格布局
- **统一间距**: 列间距和行间距都是10像素
- **响应式设计**: 自动适应不同屏幕尺寸

### 3. 滚动控制功能
- **滚动到指定位置**: 支持输入索引号滚动到指定项目
- **回到顶部**: 一键回到列表顶部
- **平滑动画**: 所有滚动操作都带有平滑的动画效果

### 4. 交互功能
- **项目详情**: 点击任意项目可查看详细信息
- **导航控制**: 包含返回按钮和功能按钮
- **视觉反馈**: 卡片悬停效果和点击反馈

## 技术实现

### 滚动监听
```dart
_scrollController.addListener(_onScroll);
```

### 工具条动画
使用`AnimationController`和`Transform.translate`实现工具条的平滑移动效果：

```dart
_toolbarAnimation = Tween<double>(
  begin: 0.0,
  end: maxScrollDistance,
).animate(CurvedAnimation(
  parent: _toolbarAnimationController,
  curve: Curves.easeInOut,
));
```

### 滚动计算
根据滚动偏移量动态计算工具条位置：

```dart
void _onScroll() {
  final scrollOffset = _scrollController.offset;
  
  if (scrollOffset <= 0) {
    // 在顶部，工具条完全显示
    _toolbarAnimationController.value = 0.0;
  } else if (scrollOffset <= maxScrollDistance) {
    // 在滚动范围内，工具条跟随滚动
    _toolbarAnimationController.value = scrollOffset / maxScrollDistance;
  } else {
    // 超过最大滚动距离，工具条完全隐藏
    _toolbarAnimationController.value = 1.0;
  }
}
```

## 使用方法

1. 在主页点击"滚动列表页面"进入
2. 向下滚动列表，观察工具条保持固定
3. 向上滚动列表，观察工具条跟随移动
4. 点击位置图标输入索引号，快速跳转到指定位置
5. 点击回到顶部按钮，快速返回列表顶部
6. 点击任意项目查看详细信息

## 自定义配置

可以通过修改以下常量来自定义行为：

```dart
static const double toolbarHeight = 88.0;        // 工具条高度
static const double maxScrollDistance = 44.0;    // 最大滚动距离
```

## 注意事项

- 确保在页面销毁时正确释放`ScrollController`和`AnimationController`
- 滚动到指定位置的计算基于网格项目的预估高度，可能需要根据实际内容调整
- 动画持续时间可以通过修改`Duration`来调整
