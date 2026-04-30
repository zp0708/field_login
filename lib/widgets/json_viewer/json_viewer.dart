import 'dart:async';

import 'package:flutter/material.dart';

///==============================================================
/// STYLE
///==============================================================
class JsonTreeStyle {
  final double fontSize;
  final double indent;
  final double vPadding;
  final Map<String, Color> colors;

  final Color matchColor;

  JsonTreeStyle({
    this.fontSize = 14,
    this.indent = 10,
    this.vPadding = 2,
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
    this.shrinkWrap = false,
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

  final bool shrinkWrap;

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
    if (!_scrollController.hasClients) return;
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
      widget.json,
      style: widget.style,
      showLineNumber: widget.showLineNumber,
      expandLevel: widget.expandLevel,
    );
  }

  @override
  void dispose() {
    _controller._refreshNotifier.removeListener(_update);
    _controller._indexNotifier.removeListener(_scrollToNode);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _fold(TreeNode node) {
    node.expanded = !node.expanded;
    _controller.rebuild();
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
            shrinkWrap: widget.shrinkWrap,
            physics: const ClampingScrollPhysics(),
            itemExtentBuilder: _controller.keyword.isEmpty
                ? null
                : (index, dimensions) => _controller.visibleNodes[index].height,
            itemBuilder: (_, index) {
              final node = _controller.visibleNodes[index];
              final keyword = _controller.keyword;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: style.vPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_controller._showLineNumber)
                      SizedBox(
                        width: _controller.lineNumberWidth,
                        child: Text(
                          '${node.index}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: style.fontSize, color: Colors.grey),
                        ),
                      ),
                    Expanded(
                      child: JsonHighlightedText(
                        keyword: keyword,
                        style: style,
                        node: node,
                        lineHeight: _controller.lineHeight,
                        arrowWidth: _controller.arrowWidth,
                        onTap: () => _fold(node),
                      ),
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
  double arrowWidth = 0;

  JsonTreeStyle _style = JsonTreeStyle();
  JsonTreeStyle get style => _style;

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
  ValueNotifier<int> get refresh => _refreshNotifier;

  /// Node 树根节点
  TreeNode? _root;

  /// 折叠或者展开所有行
  /// 当折叠时，小于 expandLevel 的行不会被折叠
  void unfold(bool unfold, {int expandLevel = -1}) {
    rebuild(unfold: unfold, expandLevel: expandLevel);
  }

  void json(
    dynamic json, {
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
      level: 1,
      expandLevel: expandLevel,
    );

    /// 这里计算当前 style 下每个数字占据的宽度和每行行高
    final painter = _painter(' ')..layout();
    arrowWidth = painter.width;
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

  void rebuild({bool? unfold, int expandLevel = -1}) {
    visibleNodes.clear();
    matchNodes.clear();
    _lastOffset = 0.0;
    final textStyle = TextStyle(fontSize: _style.fontSize);
    final painter = _painter();

    void walk(TreeNode node, bool isExpended) {
      /// 只有父 Node 是展开的才需要添加，否则只是搜索全部 Node
      if (isExpended) visibleNodes.add(node);
      if (unfold != null) node.expanded = unfold || node.level < expandLevel;

      /// 只有viewSize已设置且搜索状态下才需要测量
      if (viewSize.width > 0 && _keyword.isNotEmpty) {
        final text = '${' ' * node.level}${node.text}';
        node.matched = node.text.toLowerCase().contains(_keyword);
        if (node.matched) matchNodes.add(node);
        node.offset = _lastOffset;

        /// 只有展开时才需要类型 offset
        if (isExpended) {
          painter.text = TextSpan(text: text, style: textStyle);
          painter.layout(maxWidth: viewSize.width);
          node.height = painter.height + _style.vPadding * 2;
          _lastOffset += node.height;
        }
      }

      /// 搜索时需要全局搜索，没有展开的也需要匹配
      if ((node.expanded || _keyword.isNotEmpty) && node.hasChildren) {
        for (final child in node.children!) {
          walk(child, node.expanded);
        }
      }
    }

    if (_root != null) walk(_root!, true);
    _refreshNotifier.value += 1;
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

    if (matchNodes.isNotEmpty && _indexNotifier.value > (matchNodes.length - 1)) {
      _indexNotifier.value = matchNodes.length - 1;
    } else {
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
    _refreshNotifier.dispose();
    _indexNotifier.dispose();
    _debounce?.cancel();
    _debounce = null;
  }
}

///==============================================================
/// NODE
///==============================================================

/// 在使用递归处理TreeNode时确认每行的行号
int _seed = 0;

class TreeNode {
  TreeNode({
    required this.key,
    required this.value,
    required this.index,
    required this.level,
    this.expanded = false,
    this.children,
    this.type = 'dynamic',
    this.offset = 0,
    this.height = 44,
    this.matched = false,
  });

  /// 键值, 和运行时类型
  final String key, value, type;

  /// TreeNode 所在 行号和嵌套层级
  final int index, level;

  /// 所在行在 ListView 中的 offset，行高
  double offset, height;

  /// 是否匹配上关键词
  bool matched;

  /// 是否展开
  bool expanded;

  final List<TreeNode>? children;

  String get text => level == 1 ? value : '$key : $value';

  bool get hasChildren => children != null && children!.isNotEmpty;

  factory TreeNode.fromJson(
    dynamic json, {
    required String key,
    required int level,
    required int? expandLevel,
  }) {
    final expanded = expandLevel == null ? true : level < expandLevel;
    _seed += 1;
    final isMap = json is Map;
    if (isMap || json is List) {
      final entries = isMap ? json.entries : (json as List).asMap().entries;
      return TreeNode(
        key: key,
        value: isMap ? 'Map{${json.length}}' : 'List[${json.length}]',
        index: _seed,
        level: level,
        type: 'node',
        expanded: expanded,
        children: entries.map<TreeNode>((e) {
          return TreeNode.fromJson(
            e.value,
            key: e.key.toString(),
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
      type: json.runtimeType.toString(),
    );
  }
}

class JsonHighlightedText extends StatelessWidget {
  const JsonHighlightedText({
    super.key,
    required this.node,
    required this.style,
    this.keyword,
    this.onTap,
    this.lineHeight = 24.0,
    this.arrowWidth = 4.9,
  });

  final TreeNode node;
  final JsonTreeStyle style;
  final String? keyword;
  final VoidCallback? onTap;
  final double lineHeight;
  final double arrowWidth;

  @override
  Widget build(BuildContext context) {
    final keyStyle = TextStyle(color: style.color('key'));
    final valueStyle = TextStyle(color: style.color(node.type));

    final intent = node.level * 4 - (node.hasChildren ? 4 : 0);
    final List<InlineSpan> spans = [TextSpan(text: ' ' * intent)];

    if (node.hasChildren) {
      spans.add(WidgetSpan(
          child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: lineHeight,
          width: arrowWidth * 4,
          child: Icon(
            node.expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
            size: arrowWidth * 4,
          ),
        ),
      )));
    }

    if (!node.matched || keyword == null || keyword!.isEmpty) {
      spans.addAll([
        if (node.level != 1) TextSpan(text: node.key, style: keyStyle),
        if (node.level != 1) const TextSpan(text: ' : '),
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
      onTap: node.hasChildren ? onTap : null,
    );
  }
}
