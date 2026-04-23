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
class JsonTreeView extends StatefulWidget {
  const JsonTreeView({
    super.key,
    required this.json,
    this.style,
    this.controller,
    this.showLineNumber = false,
    this.expandLevel,
  });

  /// 需要展示的 JSON 数据
  final dynamic json;

  /// Json Tree 样式
  final JsonTreeStyle? style;

  /// 是否显示行号
  final bool showLineNumber;

  /// 默认展开层级
  /// null = 全展开
  final int? expandLevel;

  /// 控制器，自定义搜索 bar 的时候使用 controller 来控制视图
  final JsonTreeController? controller;

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  late JsonTreeController _controller;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = widget.controller ?? JsonTreeController();
    _controller._refreshNotifier.addListener(_update);
    _controller._indexNotifier.addListener(_scrollToNode);
    WidgetsBinding.instance.addPostFrameCallback((_) => _setup());
  }

  void _update() => setState(() {});

  void _scrollToNode() {
    final node = _controller.matchNodes[_controller._indexNotifier.value];
    final target = (node.offset - _controller.viewSize.height * 0.5).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _setup() {
    _controller.json(
      json: widget.json,
      style: widget.style,
      showLineNumber: widget.showLineNumber,
      expandLevel: widget.expandLevel,
    );
  }

  @override
  void dispose() {
    _controller._refreshNotifier.removeListener(_update);
    _controller._indexNotifier.addListener(_scrollToNode);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _controller.style;
    final features = const TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    final textStyle = TextStyle(fontSize: style.fontSize, color: Colors.black).merge(features);
    return DefaultTextStyle(
      style: textStyle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _controller.viewSize = Size(constraints.maxWidth, constraints.maxHeight);
          return ListView.builder(
            controller: _scrollController,
            itemCount: _controller.visibleNodes.length,
            itemExtentBuilder: _controller.keyword.isEmpty
                ? null
                : (index, dimensions) => _controller.visibleNodes[index].height,
            itemBuilder: (_, index) {
              final node = _controller.visibleNodes[index];
              final keyword = _controller.keyword;
              final showArrow = node.hasChildren;
              final arrowWidth = showArrow ? 0.0 : 16.0;
              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: style.vPadding,
                  horizontal: style.hPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showLineNumber)
                      SizedBox(
                        width: _controller.lineNumberWidth,
                        child: Text(
                          '${node.index}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: style.fontSize, color: Colors.grey),
                        ),
                      ),
                    SizedBox(width: node.level * style.indent + arrowWidth),
                    if (node.hasChildren)
                      InkWell(
                        onTap: () {
                          node.expanded = !node.expanded;
                          _controller.rebuild();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 2),
                          height: _controller.lineHeight,
                          width: _controller.lineHeight,
                          child: Icon(
                            node.expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                            size: _controller.lineHeight - 2,
                          ),
                        ),
                      ),
                    Expanded(
                      child: JsonHighlightedText(keyword: keyword, style: style, node: node),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

///==============================================================
/// CONTROLLER
///==============================================================
class JsonTreeController {
  JsonTreeController();

  bool _showLineNumber = false;
  double lineNumberWidth = 0;
  double lineHeight = 0;

  JsonTreeStyle _style = JsonTreeStyle();
  JsonTreeStyle get style => _style;

  TreeNode? _root;
  final visibleNodes = <TreeNode>[];
  final matchNodes = <TreeNode>[];

  Size viewSize = Size.zero;

  Timer? _debounce;
  String _keyword = '';
  String get keyword => _keyword;

  int get total => matchNodes.length;
  int get currentDisplay => _indexNotifier.value + 1;

  final _indexNotifier = ValueNotifier<int>(-1);
  final _refreshNotifier = ValueNotifier<int>(-1);

  ValueNotifier<int> get index => _indexNotifier;

  void json({
    dynamic json,
    JsonTreeStyle? style,
    bool showLineNumber = false,
    int? expandLevel,
  }) {
    if (style != null) _style = style;
    _showLineNumber = showLineNumber;
    _seed = 0;
    _root = TreeNode.fromJson(
      json,
      key: 'root',
      level: 0,
      expandLevel: expandLevel,
    );
    final painter = _painter('8')..layout();
    lineNumberWidth = painter.width * _seed.toString().length;
    lineHeight = painter.height;
    rebuild();
  }

  TextPainter _painter([String? text]) {
    return TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: _style.fontSize)),
      textDirection: TextDirection.ltr,
    );
  }

  double _lastOffset = 0.0;

  void rebuild({bool unfold = false}) {
    visibleNodes.clear();
    matchNodes.clear();
    _lastOffset = 0.0;
    final textStyle = TextStyle(fontSize: _style.fontSize);
    final painter = _painter();

    void walk(TreeNode node, bool parentExpended) {
      if (parentExpended) visibleNodes.add(node);

      if (unfold) node.expanded = true;

      if (viewSize.width > 0 && _keyword.isNotEmpty) {
        final text = node.text;
        node.matched = node.text.toLowerCase().contains(_keyword);
        if (node.matched) matchNodes.add(node);
        if (parentExpended) {
          painter.text = TextSpan(text: text, style: textStyle);
          final maxWidth = _maxSelectableTextWidth(node.level);
          painter.layout(maxWidth: maxWidth);
          node.offset = _lastOffset;
          node.height = painter.height + _style.vPadding * 2;
          _lastOffset += node.height;
        }
      }

      if ((node.expanded || _keyword.isNotEmpty) && node.hasChildren) {
        for (final child in node.children!) {
          walk(child, node.expanded);
        }
      }
    }

    if (_root != null) walk(_root!, true);
    _refreshNotifier.value += 1; 
  }

  double _maxSelectableTextWidth(int level) {
    final width = viewSize.width -
        _style.hPadding * 2 -
        (_showLineNumber ? lineNumberWidth : 0.0) -
        level * _style.indent -
        lineHeight;

    return math.max(0, width).toDouble();
  }

  void search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _search(text);
    });
  }

  void _search(String text) {
    _keyword = text.trim().toLowerCase();

    if (_keyword.isEmpty) {
      matchNodes.clear();
      rebuild();
      return;
    }

    rebuild(unfold: true);

    if (matchNodes.isNotEmpty) {
      _indexNotifier.value = 0; 
    }
  }

  void next() {
    if (matchNodes.isEmpty) return;
    int idx = _indexNotifier.value + 1; 
    if (idx >= matchNodes.length) idx = 0;
    _indexNotifier.value = idx; 
  }

  void prev() {
    if (matchNodes.isEmpty) return;
    int idx = _indexNotifier.value - 1; 
    if (idx < 0) idx = matchNodes.length - 1;
    _indexNotifier.value = idx;
  }

  void dispose() {
    _debounce?.cancel();
    _debounce = null;
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

  final List<TreeNode>? children;

  String get text => '$key : $value';

  bool get hasChildren => children != null && children!.isNotEmpty;

  factory TreeNode.fromJson(
    dynamic json, {
    required String key,
    required int level,
    required int? expandLevel,
  }) {
    final expanded = expandLevel == null ? true : level < expandLevel;
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
            expandLevel: expandLevel,
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
            expandLevel: expandLevel,
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

class JsonHighlightedText extends StatelessWidget {
  const JsonHighlightedText({super.key, required this.node, required this.style, this.keyword});

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
