import 'dart:async';

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

  final Color keyColor;
  final Color valueColor;
  final Color lineColor;
  final Color matchColor;
  final Color currentColor;

  const JsonTreeStyle({
    this.fontSize = 14,
    this.indent = 18,
    this.hPadding = 12,
    this.vPadding = 10,
    this.lineNumberWidth = 44,
    this.keyColor = Colors.blue,
    this.valueColor = Colors.black87,
    this.lineColor = Colors.grey,
    this.matchColor = const Color(0x30FFEB3B),
    this.currentColor = const Color(0x40FF9800),
  });
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
    this.style = const JsonTreeStyle(),
    this.searchBuilder,

    /// 是否显示行号
    this.showLineNumber = false,

    /// 默认展开层级
    /// null = 全展开
    this.defaultExpandLevel,
  });

  final dynamic json;

  final JsonTreeStyle style;

  final JsonTreeSearchBuilder? searchBuilder;

  final bool showLineNumber;

  final int? defaultExpandLevel;

  @override
  State<JsonTreeView> createState() => _JsonTreeViewState();
}

class _JsonTreeViewState extends State<JsonTreeView> {
  late JsonTreeController controller;

  @override
  void initState() {
    super.initState();

    controller = JsonTreeController(
      json: widget.json,
      style: widget.style,
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
    return Column(
      children: [
        widget.searchBuilder != null
            ? widget.searchBuilder!(context, controller)
            : _defaultSearchBar(),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.visibleNodes.length,
            itemBuilder: (_, index) {
              final node = controller.visibleNodes[index];

              final style = widget.style;

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
                    vertical: style.vPadding,
                    horizontal: style.hPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.showLineNumber)
                        SizedBox(
                          width: style.lineNumberWidth,
                          child: Text(
                            '${index + 1}',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: style.fontSize, color: style.lineColor),
                          ),
                        ),
                      SizedBox(width: node.level * style.indent),
                      SizedBox(
                        width: 18,
                        child: node.children.isEmpty
                            ? null
                            : Icon(
                                node.expanded
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                size: 18,
                              ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SelectableText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: node.key,
                                style: TextStyle(color: style.keyColor, fontSize: style.fontSize),
                              ),
                              const TextSpan(text: ' : '),
                              TextSpan(
                                text: node.display,
                                style: TextStyle(color: style.valueColor, fontSize: style.fontSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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

  final matchIds = <int>[];

  bool loading = false;

  int currentIndex = -1;

  Timer? _debounce;

  int _token = 0;

  int get total => matchIds.length;

  int get currentDisplay => currentIndex < 0 ? 0 : currentIndex + 1;

  void rebuild() {
    visibleNodes.clear();

    void walk(TreeNode node) {
      visibleNodes.add(node);

      if (node.expanded) {
        for (final child in node.children) {
          walk(child);
        }
      }
    }

    walk(root);

    onRefresh();
  }

  void search(String text) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _search(text);
    });
  }

  Future<void> _search(String text) async {
    final keyword = text.trim();

    if (keyword.isEmpty) {
      matchIds.clear();
      currentIndex = -1;
      rebuild();
      return;
    }

    loading = true;
    onRefresh();

    final token = ++_token;

    final result = await compute(_searchWorker, {
      'tree': root.toMap(),
      'keyword': keyword.toLowerCase(),
    });

    if (token != _token) {
      return;
    }

    matchIds
      ..clear()
      ..addAll(List<int>.from(result['matches']));

    root.expandByIds(Set<int>.from(result['expandIds']));

    currentIndex = matchIds.isEmpty ? -1 : 0;

    loading = false;

    rebuild();

    next();
  }

  void next() {
    if (matchIds.isEmpty) return;

    currentIndex++;

    if (currentIndex >= matchIds.length) {
      currentIndex = 0;
    }

    _jump();
  }

  void prev() {
    if (matchIds.isEmpty) return;

    currentIndex--;

    if (currentIndex < 0) {
      currentIndex = matchIds.length - 1;
    }

    _jump();
  }

  void _jump() {
    final id = matchIds[currentIndex];

    final index = visibleNodes.indexWhere((e) => e.id == id);

    if (index < 0) return;

    scrollController.animateTo(
      index * 48,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    onRefresh();
  }

  bool isMatch(int id) => matchIds.contains(id);

  bool isCurrent(int id) {
    if (currentIndex < 0) {
      return false;
    }

    return matchIds[currentIndex] == id;
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
  });

  final int id;

  final String key;

  final String display;

  final int level;

  bool expanded;

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
      children: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': '$key $display'.toLowerCase(),
      'children': children.map((e) => e.toMap()).toList(),
    };
  }

  void expandByIds(Set<int> ids) {
    expanded = ids.contains(id);

    for (final child in children) {
      child.expandByIds(ids);
    }
  }
}

///==============================================================
/// SEARCH WORKER
///==============================================================
Map<String, dynamic> _searchWorker(Map<String, dynamic> args) {
  final tree = args['tree'] as Map<String, dynamic>;

  final keyword = args['keyword'] as String;

  final matches = <int>[];
  final expandIds = <int>{};

  bool dfs(Map<String, dynamic> node) {
    final text = node['text'] as String;

    final id = node['id'] as int;

    final children = List<Map<String, dynamic>>.from(node['children']);

    bool self = text.contains(keyword);

    bool childHit = false;

    for (final child in children) {
      if (dfs(child)) {
        childHit = true;
      }
    }

    if (self) {
      matches.add(id);
    }

    if (childHit) {
      expandIds.add(id);
    }

    return self || childHit;
  }

  dfs(tree);

  return {'matches': matches, 'expandIds': expandIds.toList()};
}
