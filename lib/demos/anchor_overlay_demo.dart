import 'package:flutter/material.dart';
import 'package:field_login/widgets/anchor_overlay.dart';

class AnchorOverlayDemo extends StatefulWidget {
  const AnchorOverlayDemo({super.key});

  @override
  State<AnchorOverlayDemo> createState() => _AnchorOverlayDemoState();
}

class _AnchorOverlayDemoState extends State<AnchorOverlayDemo> {
  bool _showOverlay = false;
  String? _selected;

  List<String> get _allOptions => const [
        'Apple',
        'Banana',
        'Blueberry',
        'Cherry',
        'Coconut',
        'Grape',
        'Kiwi',
        'Lemon',
        'Mango',
        'Orange',
        'Peach',
        'Pear',
        'Pineapple',
        'Strawberry',
        'Watermelon',
      ];

  List<String> get _filteredOptions => _allOptions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 仅用于点击空白处关闭 overlay，避免通过外层强制“显示”引发的尺寸测量时序问题
      behavior: HitTestBehavior.deferToChild,
      onTap: () {
        if (_showOverlay) {
          setState(() {
            _showOverlay = false;
          });
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('AnchorOverlay Demo')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('点击下方按钮展开下拉选择（使用 AnchorOverlay 锚定显示）'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showOverlay = true;
                    });
                  },
                  child: const Text('显示 Overlay'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showOverlay = false;
                    });
                  },
                  child: const Text('隐藏 Overlay'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selected != null)
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('已选择'),
                  subtitle: Text(_selected!),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selected = null;
                        _showOverlay = false;
                      });
                    },
                  ),
                ),
              ),
            AnchorOverlay(
              showOverlay: _showOverlay,
              offset: const Offset(0, 4),
              overlayBuilder: (context) {
                final options = _filteredOptions;
                if (options.isEmpty) {
                  return _buildOverlayContainer(
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('无匹配项'),
                    ),
                  );
                }
                return _buildOverlayContainer(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final text = options[index];
                      return ListTile(
                        dense: true,
                        title: Text(text),
                        onTap: () {
                          setState(() {
                            _selected = text;
                            _showOverlay = false;
                          });
                        },
                      );
                    },
                  ),
                );
              },
              child: _AnchorButton(
                label: _selected ?? '请选择一个水果',
                onTap: () {
                  setState(() {
                    _showOverlay = true;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('更多内容（用于测试随滚动移动效果）'),
            const SizedBox(height: 12),
            for (int i = 0; i < 20; i++)
              Card(
                child: ListTile(
                  title: Text('List Item #$i'),
                  subtitle: const Text('滚动观察浮层是否跟随输入框位置'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayContainer({required Widget child}) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: child,
      ),
    );
  }
}

class _AnchorButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AnchorButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade400),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}
