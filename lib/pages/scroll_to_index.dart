import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';

class SliverGridEasyRefreshScrollDemo extends StatefulWidget {
  const SliverGridEasyRefreshScrollDemo({super.key});

  @override
  State<SliverGridEasyRefreshScrollDemo> createState() =>
      _SliverGridEasyRefreshScrollDemoState();
}

class _SliverGridEasyRefreshScrollDemoState
    extends State<SliverGridEasyRefreshScrollDemo> {
  final ScrollController scrollController = ScrollController();
  final EasyRefreshController easyRefreshController =
      EasyRefreshController(controlFinishRefresh: true,controlFinishLoad: true);

  final List<int> items = List.generate(30, (i) => i);

  /// Grid 参数
  final int crossAxisCount = 4;
  final double mainAxisSpacing = 10;
  final double crossAxisSpacing = 10;
  final double itemHeight = 220;

  /// Header 参数
  final double minHeaderHeight = 44;
  final double maxHeaderHeight = 88;

  /// 刷新
  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      items.clear();
      items.addAll(List.generate(30, (i) => i));
    });
    easyRefreshController.finishRefresh();
  }

  /// 加载更多
  Future<void> _onLoad() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      final start = items.length;
      items.addAll(List.generate(20, (i) => start + i));
    });
    easyRefreshController.finishLoad();
  }

  /// 滚动到指定 Grid index
  void scrollToIndex(int index) {
    if (index < 0 || index >= items.length) return;

    final rowIndex = index ~/ crossAxisCount;
    final rowHeight = itemHeight + mainAxisSpacing;

    // header 收起后的高度差
    final shrinkAmount = maxHeaderHeight - minHeaderHeight;

    // 目标 offset = 收缩量 + 行高 * 行数
    final targetOffset = shrinkAmount + rowIndex * rowHeight;

    scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SliverGridEasyRefreshScrollDemo'),
      ),
      body: EasyRefresh(
        controller: easyRefreshController,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        header: ClassicHeader(
          position: IndicatorPosition.locator,
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            // 吸顶 Header
            SliverPersistentHeader(
              pinned: true,
              delegate: _CustomHeaderDelegate(
                minExtentHeight: minHeaderHeight,
                maxExtentHeight: maxHeaderHeight,
              ),
            ),
            const HeaderLocator.sliver(),
            // SliverGrid 内容
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  crossAxisSpacing: crossAxisSpacing,
                  childAspectRatio: 100 / itemHeight,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Container(
                      color: Colors.blue[(index % 9 + 1) * 100],
                      alignment: Alignment.center,
                      child: Text(
                        'Item ${items[index]}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    );
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),

      // 浮动按钮：点击滚到 index 35
      floatingActionButton: FloatingActionButton(
        onPressed: () => scrollToIndex(29),
        child: const Icon(Icons.arrow_downward),
      ),
    );
  }
}

class _CustomHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minExtentHeight;
  final double maxExtentHeight;

  _CustomHeaderDelegate({
    required this.minExtentHeight,
    required this.maxExtentHeight,
  });

  @override
  double get minExtent => minExtentHeight;

  @override
  double get maxExtent => maxExtentHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.orange,
      alignment: Alignment.center,
      child: Text(
        'Header (收起: ${shrinkOffset.toStringAsFixed(1)} px)',
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
