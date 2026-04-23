import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

///==============================================================
/// STYLE
///==============================================================
class JsonTreeStyle {
  final double fontSize;
  final double indent;
  final double hPadding;
  final double vPadding;
  final Map<String, Color> colors;

  final Color matchColor;

  JsonTreeStyle({
    this.fontSize = 18,
    this.indent = 10,
    this.hPadding = 4,
    this.vPadding = 4,
    this.matchColor = Colors.yellowAccent,
  }) : colors = {
          'key': const Color(0xFF4A148C),
          'bool': Colors.purple,
          'String': Colors.redAccent,
          'int': Colors.teal,
          'double': Colors.teal,
          'node': Colors.grey,
        };

  Color color(String type) => colors[type] ?? Colors.black;
}

///==============================================================
/// VIEW
///==============================================================
typedef JsonTreeSearchBuilder = Widget Function(
    BuildContext context, JsonTreeController controller);

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
    this.expandLevel,
  });

  final dynamic json;

  final JsonTreeStyle? style;

  final JsonTreeSearchBuilder? searchBuilder;

  final bool showLineNumber;

  final int? expandLevel;

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
      defaultExpandLevel: widget.expandLevel,
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

  @override
  Widget build(BuildContext context) {
    final features = const TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    final textStyle = TextStyle(fontSize: _style.fontSize, color: Colors.black).merge(features);
    final searchBar = widget.searchBuilder?.call(context, controller);
    return DefaultTextStyle(
      style: textStyle,
      child: Column(
        children: [
          if (searchBar != null) searchBar,
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                controller.viewSize = Size(constraints.maxWidth, constraints.maxHeight);

                return ListView.builder(
                  controller: controller.scrollController,
                  itemCount: controller.visibleNodes.length,
                  itemExtentBuilder: controller.keyword.isEmpty
                      ? null
                      : (index, dimensions) => controller.visibleNodes[index].height,
                  itemBuilder: (_, index) {
                    final node = controller.visibleNodes[index];
                    final keyword = controller.keyword;
                    final showArrow = node.children.isNotEmpty;
                    final arrowWidth = showArrow ? 0.0 : 16.0;
                    return Container(
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
                              width: controller.lineNumberWidth,
                              child: Text(
                                '${node.index}',
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: _style.fontSize, color: Colors.grey),
                              ),
                            ),
                          SizedBox(width: node.level * _style.indent + arrowWidth),
                          if (node.children.isNotEmpty)
                            InkWell(
                              onTap: () {
                                node.expanded = !node.expanded;
                                controller.rebuild();
                              },
                              child: Container(
                                padding: EdgeInsets.only(top: 2),
                                height: controller.lineHeight,
                                width: controller.lineHeight,
                                child: Icon(
                                  node.expanded
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_right,
                                  size: controller.lineHeight - 2,
                                ),
                              ),
                            ),
                          Expanded(
                            child: HighlightedText(keyword: keyword, style: _style, node: node),
                          ),
                        ],
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
    _seed = 0;
    root = TreeNode.fromJson(
      json,
      key: 'root',
      level: 0,
      defaultExpandLevel: defaultExpandLevel,
    );
    final painter = _painter('8')..layout();
    lineNumberWidth = painter.width * _seed.toString().length;
    lineHeight = painter.height;
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

  double lineNumberWidth = 0;

  double lineHeight = 0;

  int currentIndex = -1;

  Size viewSize = Size.zero;

  Timer? _debounce;

  String _keyword = '';

  int get total => matchNodes.length;

  int get currentDisplay => currentIndex < 0 ? 0 : currentIndex + 1;

  String get keyword => _keyword;

  TextPainter _painter([String? text]) {
    return TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: style.fontSize)),
      textDirection: TextDirection.ltr,
    );
  }

  double _lastOffset = 0.0;

  void rebuild() {
    visibleNodes.clear();
    matchNodes.clear();
    _lastOffset = 0.0;
    final textStyle = TextStyle(fontSize: style.fontSize);
    final painter = _painter();

    void walk(TreeNode node) {
      visibleNodes.add(node);

      if (viewSize.width > 0 && _keyword.isNotEmpty) {
        node.expanded = true;
        final text = node.text;
        node.matched = node.text.toLowerCase().contains(_keyword);
        if (node.matched) matchNodes.add(node);
        painter.text = TextSpan(text: text, style: textStyle);
        final maxWidth = _maxSelectableTextWidth(node.level);
        painter.layout(maxWidth: maxWidth);
        node.offset = _lastOffset;
        node.height = painter.height + style.vPadding * 2;
        _lastOffset += node.height;
      } else {
        node.matched = false;
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
    final width = viewSize.width -
        style.hPadding * 2 -
        (showLineNumber ? lineNumberWidth : 0.0) -
        level * style.indent -
        lineHeight;

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
    final target = (node.offset - viewSize.height * 0.5).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );
    scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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
    required this.key,
    required this.value,
    required this.index,
    required this.level,
    required this.children,
    required this.expanded,
    this.type = 'dynamic',
    this.offset = 0,
    this.height = 44,
    this.matched = false,
  });

  final String key;

  final String value;

  final int level;

  final String type;

  final int index;

  bool expanded;

  double offset;

  double height;

  /// 是否匹配上关键词
  bool matched;

  final List<TreeNode> children;

  String get text => '$key : $value';

  factory TreeNode.fromJson(
    dynamic json, {
    required String key,
    required int level,
    required int? defaultExpandLevel,
  }) {
    final expanded = defaultExpandLevel == null ? true : level < defaultExpandLevel;
    _seed += 1;
    if (json is Map) {
      return TreeNode(
        key: key,
        value: 'Map{${json.length}}',
        index: _seed,
        level: level,
        type: 'node',
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
        key: key,
        value: 'List[${json.length}]',
        index: _seed,
        level: level,
        type: 'node',
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
      key: key,
      value: '$json',
      index: _seed,
      level: level,
      expanded: expanded,
      type: json.runtimeType.toString(),
      children: [],
    );
  }
}

class HighlightedText extends StatelessWidget {
  const HighlightedText({super.key, required this.node, required this.style, this.keyword});

  final TreeNode node;
  final JsonTreeStyle style;
  final String? keyword;

  @override
  Widget build(BuildContext context) {
    final keyStyle = TextStyle(color: style.color('key'), fontSize: style.fontSize);
    final valueStyle = TextStyle(color: style.color(node.type), fontSize: style.fontSize);

    final List<InlineSpan> spans = [];

    if (!node.matched || keyword == null || keyword!.isEmpty) {
      spans.addAll([
        TextSpan(text: node.key, style: keyStyle),
        const TextSpan(text: ' : '),
        TextSpan(text: node.value, style: valueStyle),
      ]);
    } else {
      final text = node.text;
      final lowerText = text.toLowerCase();
      int start = 0;

      while (true) {
        final index = lowerText.indexOf(keyword!, start);
        final textStyle = start > node.key.length ? valueStyle : keyStyle;
        if (index < 0) {
          spans.add(TextSpan(text: text.substring(start), style: keyStyle));
          break;
        }
        if (index > start) {
          spans.add(TextSpan(text: text.substring(start, index), style: textStyle));
        }
        spans.add(
          TextSpan(
            text: text.substring(index, index + keyword!.length),
            style: textStyle.copyWith(backgroundColor: style.matchColor),
          ),
        );
        start = index + keyword!.length;
        if (start >= text.length) {
          break;
        }
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: TextStyle(fontSize: style.fontSize),
        children: spans,
      ),
    );
  }
}
