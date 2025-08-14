import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../widgets/scrollable_toolbar.dart';

class ScrollableListPage extends StatefulWidget {
  const ScrollableListPage({super.key});

  @override
  State<ScrollableListPage> createState() => _ScrollableListPageState();
}

class _ScrollableListPageState extends State<ScrollableListPage> {
  late ScrollController _scrollController;
  late EasyRefreshController _refreshController;

  // 模拟数据
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _refreshController = EasyRefreshController(controlFinishLoad: true, controlFinishRefresh: true);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // 加载初始数据
  void _loadInitialData() {
    _items = List.generate(
      100,
      (index) => {
        'id': index,
        'title': '项目 ${index + 1}',
        'color': Colors.primaries[index % Colors.primaries.length],
        'icon': Icons.emoji_emotions,
      },
    );
  }

  // 刷新数据
  Future<void> _onRefresh() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1500));

    // 生成新的随机数据
    _items = List.generate(
      100,
      (index) => {
        'id': index,
        'title': '刷新项目 ${index + 1}',
        'color': Colors.primaries[(index + DateTime.now().millisecondsSinceEpoch % 100) % Colors.primaries.length],
        'icon': Icons.emoji_emotions,
      },
    );

    setState(() {
      _isLoading = false;
    });

    _refreshController.finishRefresh();
  }

  // 加载更多数据
  Future<void> _onLoad() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1000));

    // 添加更多数据
    final startIndex = _items.length;
    final newItems = List.generate(
      20,
      (index) => {
        'id': startIndex + index,
        'title': '加载项目 ${startIndex + index + 1}',
        'color': Colors.primaries[(startIndex + index) % Colors.primaries.length],
        'icon': Icons.emoji_emotions,
      },
    );

    setState(() {
      _items.addAll(newItems);
      _isLoading = false;
    });

    _refreshController.finishLoad();
  }

  // 滚动到指定index
  void _scrollToIndex(int index) {
    if (index >= 0 && index < _items.length) {
      // 计算目标位置
      final itemHeight = (MediaQuery.of(context).size.width - 50) / 4 + 20; // 4列，间距10
      final targetOffset = index * itemHeight;

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('滚动列表页面'),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GridView.builder(
                clipBehavior: Clip.none,
                controller: _scrollController,
                padding: const EdgeInsets.only(
                  top: 108,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0, // 调整为1.0避免溢出
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Container(
                    alignment: Alignment.center,
                    child: Text('$index'),
                  );
                },
              ),
            ),
            _buildContent(),
            ScrollableToolbar(
              scrollController: _scrollController,
              height: 88,
              maxScrollDistance: 44,
              child: _buildToolbar(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 16),
            // 标题
            const Expanded(
              child: Text(
                '滚动列表页面',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 刷新按钮
            IconButton(
              onPressed: _isLoading ? null : _onRefresh,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: '刷新数据',
            ),
            // 滚动到指定位置的按钮
            IconButton(
              onPressed: () => _showScrollToDialog(),
              icon: const Icon(Icons.location_on),
              tooltip: '滚动到指定位置',
            ),
            // 滚动到顶部的按钮
            IconButton(
              onPressed: () => _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              icon: const Icon(Icons.vertical_align_top),
              tooltip: '回到顶部',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned.fill(
      child: EasyRefresh(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoad: _onLoad,
        header: ClassicHeader(
          triggerOffset: 170,
          pullIconBuilder: (context, state, animation) {
            return Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Icon(Icons.arrow_upward),
            );
          },
          textBuilder: (context, state, text) {
            return Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(text),
            );
          },
          messageBuilder: (context, state, text, dateTime) {
            return Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Text(text),
            );
          },
          dragText: '下拉刷新',
          armedText: '释放刷新',
          readyText: '正在刷新...',
          processingText: '刷新中...',
          processedText: '刷新完成',
          noMoreText: '没有更多数据',
          failedText: '刷新失败',
          messageText: '最后更新于 {time}',
        ),
        footer: const ClassicFooter(
          dragText: '上拉加载',
          armedText: '释放加载',
          readyText: '正在加载...',
          processingText: '加载中...',
          processedText: '加载完成',
          noMoreText: '没有更多数据',
          failedText: '加载失败',
          messageText: '最后更新于 {time}',
        ),
        child: SizedBox.shrink(),
      ),
    );
  }

  void _showScrollToDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('滚动到指定位置'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('请输入要滚动到的项目编号 (0-${_items.length - 1}):'),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '项目编号',
                hintText: '例如: 50',
              ),
              onSubmitted: (value) {
                final index = int.tryParse(value);
                if (index != null) {
                  Navigator.pop(context);
                  _scrollToIndex(index);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = textController.text;
              final index = int.tryParse(value);
              if (index != null) {
                Navigator.pop(context);
                _scrollToIndex(index);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
