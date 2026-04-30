import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Style configuration for the JSON tree.
class JsonTreeStyle {
  final double fontSize;
  final double indent;
  final double vPadding;
  final Map<String, Color> colors;
  final Color matchColor;

  JsonTreeStyle({
    this.fontSize = 14,
    this.vPadding = 2,
    this.matchColor = Colors.yellowAccent,
    double? indent,
    Color? keyColor,
    Color? boolColor,
    Color? stringColor,
    Color? numColor,
  })  : indent = indent ?? fontSize * 1.0,
        colors = {
          'key': keyColor ?? const Color(0xFF4A148C),
          'bool': boolColor ?? Colors.purple,
          'String': stringColor ?? Colors.redAccent,
          'int': numColor ?? Colors.teal,
          'double': numColor ?? Colors.teal,
          'node': Colors.grey,
        };

  Color color(String type) => colors[type] ?? Colors.black;
}

/// Data model for a node in the JSON tree.
class TreeNode {
  final String key;
  final String value;
  final String type;
  final int index;
  final int level;
  final List<TreeNode>? children;

  bool expanded;
  bool matched;
  double offset = 0;
  double height = 0;

  TreeNode({
    required this.key,
    required this.value,
    required this.type,
    required this.index,
    required this.level,
    this.expanded = false,
    this.matched = false,
    this.children,
  });

  bool get hasChildren => children != null && children!.isNotEmpty;
  String get text => level == 1 ? value : '$key : $value';
}

/// Helper for generating sequential indices without global state.
class _Counter {
  int value = 0;
}

/// Controller for managing the JSON tree state and operations.
class JsonTreeController {
  JsonTreeStyle _style = JsonTreeStyle();
  JsonTreeStyle get style => _style;

  bool _showLineNumber = false;
  double _lineNumberWidth = 0;
  double _lineHeight = 0;

  double get lineNumberWidth => _lineNumberWidth;
  double get lineHeight => _lineHeight;

  final List<TreeNode> visibleNodes = [];
  final List<TreeNode> matchNodes = [];

  Size viewSize = Size.zero;
  String _keyword = '';
  String get keyword => _keyword;

  // Granular notifiers for UI components like search bars
  final ValueNotifier<int> _indexNotifier = ValueNotifier<int>(-1);
  final ValueNotifier<int> _refreshNotifier = ValueNotifier<int>(-1);

  /// notifier with _indexNotifier&_refreshNotifier
  Listenable get notifier => Listenable.merge([_indexNotifier, _refreshNotifier]);

  int get total => matchNodes.length;
  int get currentDisplay => _indexNotifier.value + 1;

  TreeNode? _root;
  Timer? _debounce;

  /// Initializes or updates the JSON data.
  void json(
    dynamic json, {
    JsonTreeStyle? style,
    bool showLineNumber = false,
    int? expandLevel,
    bool notify = true,
  }) {
    if (style != null) _style = style;
    _showLineNumber = showLineNumber;

    final counter = _Counter();
    _root = _buildTree(json, 'root', 1, expandLevel, counter);

    // Initial measurements
    final painter = _painter('8');
    painter.layout();
    _lineNumberWidth = painter.width * counter.value.toString().length;
    _lineHeight = painter.height;

    rebuild(notify: notify);
  }

  /// Builds the tree recursively.
  TreeNode _buildTree(dynamic json, String key, int level, int? expandLevel, _Counter counter) {
    counter.value++;
    final currentIndex = counter.value;
    final expanded = expandLevel == null ? true : level < expandLevel;

    if (json is Map || json is List) {
      final isMap = json is Map;
      final entries = isMap ? json.entries : (json as List).asMap().entries;
      final children = <TreeNode>[];

      final node = TreeNode(
        key: key,
        value: isMap ? 'Map{${json.length}}' : 'List[${json.length}]',
        type: 'node',
        index: currentIndex,
        level: level,
        expanded: expanded,
        children: children,
      );

      for (final entry in entries) {
        children
            .add(_buildTree(entry.value, entry.key.toString(), level + 1, expandLevel, counter));
      }
      return node;
    }

    return TreeNode(
      key: key,
      value: '$json',
      type: json.runtimeType.toString(),
      index: currentIndex,
      level: level,
    );
  }

  TextPainter _painter([String? text]) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: _style.fontSize,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
  }

  /// Expands or collapses all nodes.
  void unfold(bool unfold, {int expandLevel = -1}) {
    rebuild(unfold: unfold, expandLevel: expandLevel);
  }

  /// Rebuilds the lists of visible and matched nodes.
  void rebuild({bool? unfold, int expandLevel = -1, bool notify = true}) {
    visibleNodes.clear();
    matchNodes.clear();
    double currentOffset = 0.0;

    final painter = _painter();
    final textStyle = TextStyle(
      fontSize: _style.fontSize,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    void walk(TreeNode node, bool isVisible) {
      if (unfold != null) {
        node.expanded = unfold || node.level < expandLevel;
      }

      if (isVisible) {
        visibleNodes.add(node);
      }

      // Search and layout calculation (only when width is known and keyword is present)
      if (viewSize.width > 0 && _keyword.isNotEmpty) {
        final lowerText = node.text.toLowerCase();
        node.matched = lowerText.contains(_keyword);
        if (node.matched) {
          matchNodes.add(node);
        }
        node.offset = currentOffset;

        if (isVisible) {
          painter.text = TextSpan(text: node.text, style: textStyle);
          final double indentPadding = node.level * _style.indent;
          final double lineNumberPadding = _showLineNumber ? _lineNumberWidth : 0;
          final double availableWidth = viewSize.width - indentPadding - lineNumberPadding;

          painter.layout(maxWidth: availableWidth > 0 ? availableWidth : 0);
          node.height = painter.height + _style.vPadding * 2;
          currentOffset += node.height;
        }
      }

      if (node.hasChildren && (node.expanded || _keyword.isNotEmpty)) {
        for (final child in node.children!) {
          walk(child, isVisible && node.expanded);
        }
      }
    }

    if (_root != null) {
      walk(_root!, true);
    }

    if (notify) _refreshNotifier.value += 1;
  }

  /// Performs a debounced search.
  void search(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _doSearch(text));
  }

  void _doSearch(String text) {
    _keyword = text.trim().toLowerCase();

    if (_keyword.isEmpty) {
      matchNodes.clear();
      _indexNotifier.value = -1;
      rebuild();
      return;
    }

    // Automatically expand to show search results
    rebuild(unfold: true);

    if (matchNodes.isNotEmpty) {
      _indexNotifier.value = 0;
    } else {
      _indexNotifier.value = -1;
    }
  }

  void next() {
    if (matchNodes.isEmpty) return;
    _indexNotifier.value = (_indexNotifier.value + 1) % matchNodes.length;
  }

  void prev() {
    if (matchNodes.isEmpty) return;
    _indexNotifier.value = (_indexNotifier.value - 1 + matchNodes.length) % matchNodes.length;
  }

  void dispose() {
    _debounce?.cancel();
    _indexNotifier.dispose();
    _refreshNotifier.dispose();
  }
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

  /// The JSON data to display.
  final dynamic json;

  /// Styling options.
  final JsonTreeStyle? style;

  /// Whether to show line numbers.
  final bool showLineNumber;

  /// Default expand level (null = fully expanded).
  final int? expandLevel;

  /// Whether the list should shrink wrap.
  final bool shrinkWrap;

  /// Optional controller.
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
    _controller._refreshNotifier.addListener(_refresh);
    _controller._indexNotifier.addListener(_scrollToNode);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _refresh() {
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  void _initData() {
    _controller.json(
      widget.json,
      style: widget.style,
      showLineNumber: widget.showLineNumber,
      expandLevel: widget.expandLevel,
    );
  }

  void _scrollToNode() {
    if (!_scrollController.hasClients || _controller.matchNodes.isEmpty) return;
    final index = _controller._indexNotifier.value;
    if (index < 0 || index >= _controller.matchNodes.length) return;

    final node = _controller.matchNodes[index];
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

  @override
  void didUpdateWidget(JsonTreeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.json != oldWidget.json) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
    }
  }

  @override
  void dispose() {
    _controller._refreshNotifier.removeListener(_refresh);
    _controller._indexNotifier.removeListener(_scrollToNode);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleNode(TreeNode node) {
    node.expanded = !node.expanded;
    _controller.rebuild();
  }

  @override
  Widget build(BuildContext context) {
    final style = _controller.style;
    return DefaultTextStyle(
      style: TextStyle(
        fontSize: style.fontSize,
        color: Colors.black,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (_controller.viewSize != constraints.biggest) {
            _controller.viewSize = constraints.biggest;
            _controller.rebuild(notify: false);
          }
          final nodes = _controller.visibleNodes;

          return ListView.builder(
            controller: _scrollController,
            itemCount: nodes.length,
            padding: EdgeInsets.zero,
            shrinkWrap: widget.shrinkWrap,
            physics: const ClampingScrollPhysics(),
            itemExtentBuilder:
                _controller.keyword.isEmpty ? null : (index, _) => nodes[index].height,
            itemBuilder: (context, index) {
              final node = nodes[index];
              return _JsonTreeNodeWidget(
                node: node,
                style: style,
                keyword: _controller.keyword,
                showLineNumber: widget.showLineNumber,
                lineNumberWidth: _controller.lineNumberWidth,
                lineHeight: _controller.lineHeight,
                arrowWidth: style.indent,
                onToggle: () => _toggleNode(node),
              );
            },
          );
        },
      ),
    );
  }
}

/// Internal widget for rendering a single tree node.
class _JsonTreeNodeWidget extends StatelessWidget {
  final TreeNode node;
  final JsonTreeStyle style;
  final String keyword;
  final bool showLineNumber;
  final double lineNumberWidth;
  final double lineHeight;
  final double arrowWidth;
  final VoidCallback onToggle;

  const _JsonTreeNodeWidget({
    required this.node,
    required this.style,
    required this.keyword,
    required this.showLineNumber,
    required this.lineNumberWidth,
    required this.lineHeight,
    required this.arrowWidth,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: style.vPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLineNumber)
            SizedBox(
              width: lineNumberWidth,
              child: Text(
                '${node.index}',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: style.fontSize, color: Colors.grey),
              ),
            ),
          Expanded(
            child: JsonHighlightedText(
              node: node,
              style: style,
              keyword: keyword,
              onTap: node.hasChildren ? onToggle : null,
              lineHeight: lineHeight,
              arrowWidth: arrowWidth,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for rendering text with search highlighting.
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
    final matchBgStyle = TextStyle(backgroundColor: style.matchColor);

    final double indentSize = (node.level - 1) * style.indent;

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: indentSize),
          SizedBox(
            width: style.indent,
            height: lineHeight,
            child: node.hasChildren
                ? Icon(
                    node.expanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    size: style.fontSize,
                  )
                : null,
          ),
          Expanded(
            child: SelectableText.rich(
              TextSpan(
                style: TextStyle(fontSize: style.fontSize),
                children: _buildSpans(keyStyle, valueStyle, matchBgStyle),
              ),
              onTap: node.hasChildren ? onTap : null,
            ),
          ),
        ],
      ),
    );
  }

  List<InlineSpan> _buildSpans(TextStyle keyStyle, TextStyle valueStyle, TextStyle matchBgStyle) {
    if (keyword == null || keyword!.isEmpty || !node.matched) {
      if (node.level != 1) {
        return [
          TextSpan(text: node.key, style: keyStyle),
          const TextSpan(text: ' : '),
          TextSpan(text: node.value, style: valueStyle),
        ];
      }
      return [TextSpan(text: node.value, style: valueStyle)];
    }

    final List<InlineSpan> spans = [];
    if (node.level == 1) {
      _highlightText(node.value, keyword!, valueStyle, matchBgStyle, spans);
    } else {
      _highlightText(node.key, keyword!, keyStyle, matchBgStyle, spans);
      spans.add(TextSpan(text: ' : ', style: keyStyle));
      _highlightText(node.value, keyword!, valueStyle, matchBgStyle, spans);
    }
    return spans;
  }

  void _highlightText(String text, String keyword, TextStyle baseStyle, TextStyle matchStyle,
      List<InlineSpan> spans) {
    final lowerText = text.toLowerCase();
    int start = 0;
    while (true) {
      final index = lowerText.indexOf(keyword, start);
      if (index < 0) {
        if (start < text.length) {
          spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        }
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + keyword.length),
        style: baseStyle.merge(matchStyle),
      ));
      start = index + keyword.length;
    }
  }
}
