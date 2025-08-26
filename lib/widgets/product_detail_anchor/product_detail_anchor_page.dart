import 'package:flutter/material.dart';
import 'anchor_controller.dart';

/// 商品详情锚点定位页面
class ProductDetailAnchorPage extends StatefulWidget {
  final List<AnchorConfig> anchors;
  final Widget Function(BuildContext context, AnchorConfig anchor) contentBuilder;
  final double tabBarHeight;
  final double stickyOffset;
  final Color? tabBarBackgroundColor;
  final Color? activeTabColor;
  final Color? inactiveTabColor;
  final TextStyle? activeTabTextStyle;
  final TextStyle? inactiveTabTextStyle;

  const ProductDetailAnchorPage({
    super.key,
    required this.anchors,
    required this.contentBuilder,
    this.tabBarHeight = 60.0,
    this.stickyOffset = 100.0,
    this.tabBarBackgroundColor,
    this.activeTabColor,
    this.inactiveTabColor,
    this.activeTabTextStyle,
    this.inactiveTabTextStyle,
  });

  @override
  State<ProductDetailAnchorPage> createState() => _ProductDetailAnchorPageState();
}

class _ProductDetailAnchorPageState extends State<ProductDetailAnchorPage> {
  late ScrollController _scrollController;
  late ProductDetailAnchorController _anchorController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _anchorController = ProductDetailAnchorController(
      scrollController: _scrollController,
      anchors: widget.anchors,
      tabBarHeight: widget.tabBarHeight,
      stickyOffset: widget.stickyOffset,
    );
  }

  @override
  void dispose() {
    _anchorController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 固定的Tab栏
          Container(
            height: widget.tabBarHeight,
            color: widget.tabBarBackgroundColor ?? Theme.of(context).colorScheme.surface,
            child: _buildTabBar(),
          ),
          // 内容区域
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final anchor = widget.anchors[index];
                      return Container(
                        key: anchor.key,
                        child: widget.contentBuilder(context, anchor),
                      );
                    },
                    childCount: widget.anchors.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建Tab栏
  Widget _buildTabBar() {
    return AnimatedBuilder(
      animation: _anchorController,
      builder: (context, child) {
        return Row(
          children: widget.anchors.asMap().entries.map((entry) {
            final index = entry.key;
            final anchor = entry.value;
            final isActive = _anchorController.currentActiveIndex == index;

            return Expanded(
              child: GestureDetector(
                onTap: () => _anchorController.scrollToAnchor(index),
                child: Container(
                  height: widget.tabBarHeight,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (widget.activeTabColor ?? Theme.of(context).primaryColor.withOpacity(0.1))
                        : (widget.inactiveTabColor ?? Colors.transparent),
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      anchor.title,
                      style: isActive
                          ? (widget.activeTabTextStyle ??
                              TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ))
                          : (widget.inactiveTabTextStyle ??
                              TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontSize: 14,
                              )),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// 锚点内容区域包装器
class AnchorSection extends StatelessWidget {
  final AnchorConfig anchor;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AnchorSection({
    super.key,
    required this.anchor,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: anchor.key,
      padding: padding ?? const EdgeInsets.all(16.0),
      color: backgroundColor,
      child: child,
    );
  }
}
