import 'package:flutter/material.dart';

/// 锚点配置类
class AnchorConfig {
  final String id;
  final String title;
  final GlobalKey key;
  final double? offset; // 可选的偏移量

  AnchorConfig({
    required this.id,
    required this.title,
    required this.key,
    this.offset,
  });
}

/// 商品详情锚点定位控制器
class ProductDetailAnchorController extends ChangeNotifier {
  final ScrollController scrollController;
  final List<AnchorConfig> anchors;
  final double tabBarHeight;
  final double stickyOffset;

  int _currentActiveIndex = 0;
  bool _isScrollingToAnchor = false;

  ProductDetailAnchorController({
    required this.scrollController,
    required this.anchors,
    this.tabBarHeight = 60.0,
    this.stickyOffset = 100.0,
  }) {
    scrollController.addListener(_onScroll);
  }

  int get currentActiveIndex => _currentActiveIndex;
  bool get isScrollingToAnchor => _isScrollingToAnchor;

  /// 滚动到指定锚点
  Future<void> scrollToAnchor(int index) async {
    if (index < 0 || index >= anchors.length) return;

    _isScrollingToAnchor = true;
    _currentActiveIndex = index; // 立即更新激活状态
    notifyListeners();

    final anchor = anchors[index];
    final context = anchor.key.currentContext;

    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      // 计算目标偏移量：当前滚动位置 + 锚点相对位置 - tab栏高度 - 额外的偏移量
      final targetOffset = (scrollController.offset + position.dy - tabBarHeight - 20 - (anchor.offset ?? 0))
          .clamp(0.0, scrollController.position.maxScrollExtent);

      await scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    // 等待一小段时间再重置标志，避免滚动结束后立即触发滚动监听
    await Future.delayed(const Duration(milliseconds: 100));
    _isScrollingToAnchor = false;
    notifyListeners();
  }

  /// 滚动监听，更新当前激活的tab
  void _onScroll() {
    if (_isScrollingToAnchor) return;

    final scrollOffset = scrollController.offset;
    int newActiveIndex = 0;

    // 计算当前应该高亮的锚点
    for (int i = anchors.length - 1; i >= 0; i--) {
      final anchor = anchors[i];
      final context = anchor.key.currentContext;

      if (context != null) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final anchorTop = position.dy;

        // 如果锚点顶部在tab栏下方或者已经滚过tab栏位置，则选择此锚点
        if (anchorTop <= tabBarHeight + 50) {
          // 50px 的容错范围
          newActiveIndex = i;
          break;
        }
      }
    }

    if (newActiveIndex != _currentActiveIndex) {
      _currentActiveIndex = newActiveIndex;
      notifyListeners();
    }
  }

  /// 获取锚点位置偏移量
  double? getAnchorOffset(String anchorId) {
    final anchor = anchors.firstWhere(
      (anchor) => anchor.id == anchorId,
      orElse: () => anchors.first,
    );

    final context = anchor.key.currentContext;
    if (context != null) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      return position.dy + scrollController.offset;
    }
    return null;
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
