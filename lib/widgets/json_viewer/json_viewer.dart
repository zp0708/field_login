import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///==============================================================
/// STYLE
///==============================================================
class JsonTreeStyle {
  final double fontSize;
  final double indent;
  final double hPadding;
  final double vPadding;
  final double lineNumberWidth;
  final Map<String, Color> colors;

  final Color matchColor;

  JsonTreeStyle({
    this.fontSize = 14,
    this.indent = 18,
    this.hPadding = 6,
    this.vPadding = 6,
    this.lineNumberWidth = 44,
    this.matchColor = Colors.yellowAccent,
  }) : colors = {
         'key': const Color(0xFF4A148C),
         'bool': Colors.purple,
         'String': Colors.redAccent,
         'int': Colors.teal,
         'double': Colors.teal,
       };

  Color color(String type) => colors[type] ?? Colors.white;
}

///==============================================================
/// VIEW
///==============================================================
typedef JsonTreeSearchBuilder =
    Widget Function(BuildContext context, JsonTreeController controller);

class JsonTreeView extends StatefulWidget {
  const JsonTreeView({
    super.key,
    required this.json,
    this.style,
    this.searchBuilder,

    /// 是否显示行号
    this.showLineNumber = false,

    /// 默认展开层级
    /// null = 全展开
    this.defaultExpandLevel,
  });

  final dynamic json;

  final JsonTreeStyle? style;

  final JsonTreeSearchBuilder? searchBuilder;

  final bool showLineNumber;

  final int? defaultExpandLevel;

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  late JsonTreeController controller;
  late JsonTreeStyle _style;

  @override
  void initState() {
    super.initState();
    _style = widget.style ?? JsonTreeStyle();
    controller = JsonTreeController(
      json: widget.json,
      style: _style,
      showLineNumber: widget.showLineNumber,
      defaultExpandLevel: widget.defaultExpandLevel,
      onRefresh: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _defaultSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.search,
            decoration: const InputDecoration(
              hintText: '搜索...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${controller.currentDisplay}/${controller.total}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final features = const TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    final textStyle = TextStyle(fontSize: _style.fontSize, color: Colors.black).merge(features);
    return DefaultTextStyle(
      style: textStyle,
      child: Column(
        children: [
          widget.searchBuilder != null
              ? widget.searchBuilder!(context, controller)
              : _defaultSearchBar(),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                controller.viewSize = Size(constraints.maxWidth, constraints.maxHeight);

                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.visibleNodes.length,
                  itemBuilder: (_, index) {
                    final node = controller.visibleNodes[index];
                    final keyword = controller.keyword;
                    return GestureDetector(
                      onTap: () {
                        if (node.children.isNotEmpty) {
                          node.expanded = !node.expanded;
                          controller.rebuild();
                        }
                      },
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: _style.vPadding,
                          horizontal: _style.hPadding,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.showLineNumber)
                              SizedBox(
                                width: _style.lineNumberWidth,
                                child: Text(
                                  '${index + 1}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontSize: _style.fontSize, color: Colors.grey),
                                ),
                              ),
                            SizedBox(width: node.level * _style.indent),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: node.children.isEmpty
                                  ? null
                                  : Icon(
                                      node.expanded
                                          ? Icons.keyboard_arrow_down
                                          : Icons.keyboard_arrow_right,
                                      size: 16,
                                    ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: 
                              SelectableText.rich(
                                _buildNodeTextSpan(keyword: keyword, style: _style, node: node),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

///==============================================================
/// CONTROLLER
///==============================================================
class JsonTreeController {
  JsonTreeController({
    required dynamic json,
    required this.style,
    required this.showLineNumber,
    required this.defaultExpandLevel,
    required this.onRefresh,
  }) {
    root = TreeNode.fromJson(json, key: 'root', level: 0, defaultExpandLevel: defaultExpandLevel);

    rebuild();
  }

  final JsonTreeStyle style;

  final bool showLineNumber;

  final int? defaultExpandLevel;

  final VoidCallback onRefresh;

  final scrollController = ScrollController();

  late TreeNode root;

  final visibleNodes = <TreeNode>[];

  final matchNodes = <TreeNode>[];

  int currentIndex = -1;

  Size viewSize = Size.zero;

  Timer? _debounce;

  String _keyword = '';

  int get total => matchNodes.length;

  int get currentDisplay => currentIndex < 0 ? 0 : currentIndex + 1;

  String get keyword => _keyword;

  TextPainter _painter() {
    return TextPainter(
      text: TextSpan(text: null, style: TextStyle(fontSize: style.fontSize)),
      textDirection: TextDirection.ltr,
    );
  }

  double _lastOffset = 0.0;

  void rebuild() {
    visibleNodes.clear();
    matchNodes.clear();
    _lastOffset = 0.0;
    final textStyle = TextStyle(fontSize: style.fontSize);

    void walk(TreeNode node) {
      visibleNodes.add(node);
      if (_keyword.isNotEmpty) {
        bool match = node.display.toLowerCase().contains(_keyword);
        if (match) matchNodes.add(node);
      }
      if (viewSize.width > 0) {
        final painter = _painter();
        final t = '${node.key} : ${node.display}';
        painter.text = TextSpan(text: t, style: textStyle);
        final maxWidth = _maxSelectableTextWidth(node.level);
        painter.layout(maxWidth: maxWidth);
        node.offset = _lastOffset;
        final height = painter.height;
        _lastOffset += (height + style.vPadding * 2);
      }

      if (node.expanded) {
        for (final child in node.children) {
          walk(child);
        }
      }
    }

    walk(root);

    onRefresh();
  }

  double _maxSelectableTextWidth(int level) {
    final width =
        viewSize.width -
        style.hPadding * 2 -
        (showLineNumber ? style.lineNumberWidth : 0) -
        level * style.indent -
        18 -
        4;

    return math.max(0, width).toDouble();
  }

  void search(String text) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _search(text);
    });
  }

  Future<void> _search(String text) async {
    _keyword = text.trim();

    if (_keyword.isEmpty) {
      matchNodes.clear();
      currentIndex = -1;
      rebuild();
      return;
    }

    onRefresh();
    rebuild();

    if (currentIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currentIndex >= 0) {
          _jump();
        }
      });
    }
  }

  void next() {
    if (matchNodes.isEmpty) return;

    currentIndex++;

    if (currentIndex >= matchNodes.length) {
      currentIndex = 0;
    }

    _jump();
  }

  void prev() {
    if (matchNodes.isEmpty) return;

    currentIndex--;

    if (currentIndex < 0) {
      currentIndex = matchNodes.length - 1;
    }

    _jump();
  }

  void _jump() {
    final node = matchNodes[currentIndex];
    final target = (node.offset - viewSize.height * 0.5).clamp(0.0, scrollController.position.maxScrollExtent);
    scrollController.jumpTo(
      target,
      // duration: const Duration(milliseconds: 250),
      // curve: Curves.easeOut,
    );

    onRefresh();
  }

  void dispose() {
    _debounce?.cancel();
    scrollController.dispose();
  }
}

///==============================================================
/// NODE
///==============================================================
int _seed = 0;

class TreeNode {
  TreeNode({
    required this.id,
    required this.key,
    required this.display,
    required this.level,
    required this.children,
    required this.expanded,
    this.type = 'dynamic',
    this.offset = 0,
  });

  final int id;

  final String key;

  final String display;

  final int level;

  final String type;

  bool expanded;

  double offset;

  final List<TreeNode> children;

  factory TreeNode.fromJson(
    dynamic json, {
    required String key,
    required int level,
    required int? defaultExpandLevel,
  }) {
    final id = _seed++;

    final expanded = defaultExpandLevel == null ? true : level < defaultExpandLevel;

    if (json is Map) {
      return TreeNode(
        id: id,
        key: key,
        display: '{${json.length}}',
        level: level,
        expanded: expanded,
        children: json.entries.map<TreeNode>((e) {
          return TreeNode.fromJson(
            e.value,
            key: e.key.toString(),
            level: level + 1,
            defaultExpandLevel: defaultExpandLevel,
          );
        }).toList(),
      );
    }

    if (json is List) {
      return TreeNode(
        id: id,
        key: key,
        display: '[${json.length}]',
        level: level,
        expanded: expanded,
        children: json.asMap().entries.map<TreeNode>((e) {
          return TreeNode.fromJson(
            e.value,
            key: '[${e.key}]',
            level: level + 1,
            defaultExpandLevel: defaultExpandLevel,
          );
        }).toList(),
      );
    }

    return TreeNode(
      id: id,
      key: key,
      display: '$json',
      level: level,
      expanded: expanded,
      type: json.runtimeType.toString(),
      children: [],
    );
  }

  void expandByIds(Set<int> ids) {
    expanded = ids.contains(id);

    for (final child in children) {
      child.expandByIds(ids);
    }
  }
}

TextSpan _buildNodeTextSpan({
  required TreeNode node,
  required JsonTreeStyle style,
  required String keyword,
}) {
  final keyTextStyle = TextStyle(color: style.color('key'), fontSize: style.fontSize);
  final valueTextStyle = TextStyle(color: style.color(node.type), fontSize: style.fontSize);

  return TextSpan(
    style: TextStyle(fontSize: style.fontSize),
    children: [
      ..._buildHighlightedSpans(node.key, keyTextStyle, keyword, style.matchColor),
      const TextSpan(text: ' : '),
      ..._buildHighlightedSpans(node.display, valueTextStyle, keyword, style.matchColor),
    ],
  );
}

List<InlineSpan> _buildHighlightedSpans(
  String text,
  TextStyle baseStyle,
  String keyword,
  Color highlightColor,
) {
  if (keyword.isEmpty) {
    return [TextSpan(text: text, style: baseStyle)];
  }

  final lowerText = text.toLowerCase();
  final lowerKeyword = keyword.toLowerCase();
  final spans = <InlineSpan>[];
  var start = 0;

  while (true) {
    final index = lowerText.indexOf(lowerKeyword, start);

    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start), style: baseStyle));
      break;
    }

    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
    }

    spans.add(
      TextSpan(
        text: text.substring(index, index + lowerKeyword.length),
        style: baseStyle.copyWith(backgroundColor: highlightColor),
      ),
    );

    start = index + lowerKeyword.length;

    if (start >= text.length) {
      break;
    }
  }

  return spans;
}
