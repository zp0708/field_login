library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class JsonViewerController extends ChangeNotifier {
  final List<GlobalKey> _anchors = <GlobalKey>[];
  int _currentIndex = 0;
  bool _notifyScheduled = false;

  List<GlobalKey> get anchors => List<GlobalKey>.unmodifiable(_anchors);
  int get length => _anchors.length;
  int get currentIndex => _currentIndex;
  GlobalKey? get currentAnchor => _anchors.isEmpty ? null : _anchors[_currentIndex];

  void addAnchor(GlobalKey key) {
    _anchors.add(key);
    if (_anchors.length == 1) {
      _currentIndex = 0;
    }
    _notifySafely();
  }

  void clearAnchors() {
    if (_anchors.isEmpty) return;
    _anchors.clear();
    _currentIndex = 0;
    _notifySafely();
  }

  void goNext() {
    if (_anchors.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _anchors.length;
    _notifySafely();
  }

  void goPrev() {
    if (_anchors.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + _anchors.length) % _anchors.length;
    _notifySafely();
  }

  void clampIndex() {
    if (_anchors.isEmpty) {
      _currentIndex = 0;
    } else {
      if (_currentIndex >= _anchors.length) _currentIndex = _anchors.length - 1;
      if (_currentIndex < 0) _currentIndex = 0;
    }
    _notifySafely();
  }

  void _notifySafely() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
      return;
    }
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      notifyListeners();
    });
  }
}

class JsonViewerScope extends InheritedNotifier<JsonViewerController> {
  const JsonViewerScope({
    super.key,
    required JsonViewerController super.notifier,
    required super.child,
  });

  static JsonViewerController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<JsonViewerScope>()?.notifier;
  }

  // 不建立依赖关系的读取，避免子节点因为收集锚点而跟随重建
  static JsonViewerController? read(BuildContext context) {
    final InheritedElement? element = context.getElementForInheritedWidgetOfExactType<JsonViewerScope>();
    final JsonViewerScope? scope = element?.widget as JsonViewerScope?;
    return scope?.notifier;
  }
}

class JsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;
  final JsonViewerController? controller;

  const JsonViewer(
    this.jsonObj, {
    super.key,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
    this.controller,
  });

  @override
  JsonViewerState createState() => JsonViewerState();
}

class JsonViewerState extends State<JsonViewer> {
  @override
  Widget build(BuildContext context) {
    widget.controller?.clearAnchors();
    final Widget w = _buildContentWidget(
      widget.jsonObj,
      widget.unfold,
      widget.highlight,
      widget.highlightColor,
    );
    if (widget.controller != null) {
      return JsonViewerScope(notifier: widget.controller!, child: w);
    }
    return w;
  }
}

Widget _buildContentWidget(
  dynamic content,
  bool unfold,
  String? highlight,
  Color highlightColor,
) {
  if (content == null) {
    return const Text('{}');
  } else if (content is List) {
    return JsonArrayViewer(
      content,
      notRoot: false,
      unfold: unfold,
      highlight: highlight,
      highlightColor: highlightColor,
    );
  } else {
    return JsonObjectViewer(
      content,
      notRoot: false,
      unfold: unfold,
      highlight: highlight,
      highlightColor: highlightColor,
    );
  }
}

bool _isInkWell(dynamic content) {
  if (content == null) {
    return false;
  } else if (content is int) {
    return false;
  } else if (content is String) {
    return false;
  } else if (content is bool) {
    return false;
  } else if (content is double) {
    return false;
  } else if (content is List) {
    if (content.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
  return true;
}

bool _isExtensible(dynamic content) {
  if (content == null) {
    return false;
  } else if (content is int) {
    return false;
  } else if (content is String) {
    return false;
  } else if (content is bool) {
    return false;
  } else if (content is double) {
    return false;
  }
  return true;
}

String _getTypeName(dynamic content) {
  if (content is int) {
    return 'int';
  } else if (content is String) {
    return 'String';
  } else if (content is bool) {
    return 'bool';
  } else if (content is double) {
    return 'double';
  } else if (content is List) {
    return 'List';
  }
  return 'Object';
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;

  const JsonObjectViewer(
    this.jsonObj, {
    super.key,
    this.notRoot = false,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
  });

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  Map<String, bool> openFlag = {};

  @override
  void didUpdateWidget(covariant JsonObjectViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unfold != widget.unfold) {
      // 展开策略变化时，清空局部覆盖，让默认策略生效
      openFlag.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: EdgeInsets.only(left: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getList(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  _getList() {
    List<Widget> list = [];
    for (MapEntry entry in widget.jsonObj.entries) {
      bool ex = _isExtensible(entry.value);
      bool ink = _isInkWell(entry.value);
      list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ex
              ? InkWell(
                  onTap: () {
                    setState(() {
                      openFlag[entry.key] = !(openFlag[entry.key] ?? (ex ? widget.unfold : false));
                    });
                  },
                  child: ((openFlag[entry.key] ?? (ex ? widget.unfold : false))
                      ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                      : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700])),
                )
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
          (ex && ink)
              ? InkWell(
                  child: _buildHighlightedText(
                    context,
                    entry.key,
                    TextStyle(color: Colors.purple[900]),
                    widget.highlight,
                    widget.highlightColor,
                    selectable: false,
                  ),
                  onTap: () {
                    setState(() {
                      final bool base = openFlag[entry.key] ?? (ex ? widget.unfold : false);
                      openFlag[entry.key] = !base;
                    });
                  })
              : _buildHighlightedText(
                  context,
                  entry.key,
                  TextStyle(
                    color: entry.value == null ? Colors.grey : Colors.purple[900],
                  ),
                  widget.highlight,
                  widget.highlightColor,
                  selectable: false,
                ),
          Text(
            ':',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 3),
          getValueWidget(entry)
        ],
      ));
      list.add(const SizedBox(height: 4));
      if (openFlag[entry.key] ?? (ex ? widget.unfold : false)) {
        list.add(_getContentWidget(
          entry.value,
          widget.unfold,
          highlight: widget.highlight,
          highlightColor: widget.highlightColor,
        ));
      }
    }
    return list;
  }

  Widget _getContentWidget(
    dynamic content,
    bool unfold, {
    String? highlight,
    Color highlightColor = const Color(0xFFFFFF00),
  }) {
    if (content is List) {
      return JsonArrayViewer(
        content,
        notRoot: true,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
      );
    } else {
      return JsonObjectViewer(
        content,
        notRoot: true,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
      );
    }
  }

  getValueWidget(MapEntry entry) {
    if (entry.value == null) {
      return Expanded(
        child: Text(
          'undefined',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else if (entry.value is int) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (entry.value is String) {
      return Expanded(
        child: _buildHighlightedText(
          context,
          '"${entry.value}"',
          TextStyle(color: Colors.redAccent),
          widget.highlight,
          widget.highlightColor,
          selectable: true,
        ),
      );
    } else if (entry.value is bool) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.purple),
        ),
      );
    } else if (entry.value is double) {
      return Expanded(
        child: Text(
          entry.value.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (entry.value is List) {
      if (entry.value.isEmpty) {
        return Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return InkWell(
          child: Text(
            'Array<${_getTypeName(entry.value[0])}>[${entry.value.length}]',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              final bool base = openFlag[entry.key] ?? widget.unfold;
              openFlag[entry.key] = !base;
            });
          },
        );
      }
    }
    return InkWell(
      child: Text(
        'Object',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        setState(() {
          final bool base = openFlag[entry.key] ?? widget.unfold;
          openFlag[entry.key] = !base;
        });
      },
    );
  }
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool notRoot;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;

  const JsonArrayViewer(
    this.jsonArray, {
    super.key,
    this.notRoot = false,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
  });

  @override
  JsonArrayViewerState createState() => JsonArrayViewerState();
}

class JsonArrayViewerState extends State<JsonArrayViewer> {
  late List<bool> openFlag;

  @override
  Widget build(BuildContext context) {
    if (widget.notRoot) {
      return Container(
        padding: EdgeInsets.only(left: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _getList(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _getList(),
    );
  }

  @override
  void initState() {
    super.initState();
    openFlag = List.filled(widget.jsonArray.length, widget.unfold);
  }

  @override
  void didUpdateWidget(covariant JsonArrayViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unfold != widget.unfold || oldWidget.jsonArray.length != widget.jsonArray.length) {
      openFlag = List.filled(widget.jsonArray.length, widget.unfold);
    }
  }

  _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = _isExtensible(content);
      bool ink = _isInkWell(content);
      list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ex
              ? ((openFlag[i])
                  ? Icon(Icons.arrow_drop_down, size: 14, color: Colors.grey[700])
                  : Icon(Icons.arrow_right, size: 14, color: Colors.grey[700]))
              : const Icon(
                  Icons.arrow_right,
                  color: Color.fromARGB(0, 0, 0, 0),
                  size: 14,
                ),
          (ex && ink)
              ? getInkWell(i)
              : Text(
                  '[$i]',
                  style: TextStyle(
                    color: content == null ? Colors.grey : Colors.purple[900],
                  ),
                ),
          Text(
            ':',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 3),
          getValueWidget(content, i)
        ],
      ));
      list.add(const SizedBox(height: 4));
      if (ex && openFlag[i]) {
        list.add(_buildContentWidget(
          content,
          widget.unfold,
          widget.highlight,
          widget.highlightColor,
        ));
      }
      i++;
    }
    return list;
  }

  getInkWell(int index) {
    return InkWell(
      child: Text('[$index]', style: TextStyle(color: Colors.purple[900])),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }

  getValueWidget(dynamic content, int index) {
    if (content == null) {
      return Expanded(
        child: Text(
          'undefined',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else if (content is int) {
      return Expanded(
        child: Text(
          content.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (content is String) {
      return Expanded(
        child: _buildHighlightedText(
          context,
          '"$content"',
          TextStyle(color: Colors.redAccent),
          widget.highlight,
          widget.highlightColor,
          selectable: true,
        ),
      );
    } else if (content is bool) {
      return Expanded(
        child: Text(
          content.toString(),
          style: TextStyle(color: Colors.purple),
        ),
      );
    } else if (content is double) {
      return Expanded(
        child: Text(
          content.toString(),
          style: TextStyle(color: Colors.teal),
        ),
      );
    } else if (content is List) {
      if (content.isEmpty) {
        return Text(
          'Array[0]',
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return InkWell(
          child: Text(
            'Array<${_getTypeName(content)}>[${content.length}]',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              openFlag[index] = !(openFlag[index]);
            });
          },
        );
      }
    }
    return InkWell(
      child: Text(
        'Object',
        style: TextStyle(color: Colors.grey),
      ),
      onTap: () {
        setState(() {
          openFlag[index] = !(openFlag[index]);
        });
      },
    );
  }
}

// 高亮工具：将命中片段用背景色标记
Widget _buildHighlightedText(
  BuildContext context,
  String text,
  TextStyle baseStyle,
  String? highlight,
  Color highlightColor, {
  bool selectable = false,
}) {
  if (highlight == null || highlight.isEmpty) {
    if (selectable) {
      return SelectableText(
        text,
        style: baseStyle,
      );
    }
    return Text(text, style: baseStyle);
  }
  final String query = highlight.toLowerCase();
  final String lower = text.toLowerCase();
  final List<InlineSpan> spans = <InlineSpan>[];
  int start = 0;
  while (true) {
    final int index = lower.indexOf(query, start);
    if (index < 0) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: baseStyle,
        ),
      );
      break;
    }
    if (index > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ),
      );
    }
    final String match = text.substring(index, index + query.length);
    final GlobalKey key = GlobalKey();
    final JsonViewerController? controller = JsonViewerScope.read(context);
    controller?.addAnchor(key);
    spans.add(WidgetSpan(
      alignment: PlaceholderAlignment.baseline,
      baseline: TextBaseline.alphabetic,
      child: Container(
        key: key,
        color: highlightColor.withOpacity(0.6),
        child: Text(match, style: baseStyle.copyWith(color: Colors.black)),
      ),
    ));
    start = index + query.length;
    if (start >= text.length) {
      break;
    }
  }
  if (selectable) {
    return SelectableText.rich(TextSpan(
      children: spans,
      style: baseStyle,
    ));
  }
  return RichText(
    text: TextSpan(children: spans, style: baseStyle),
    maxLines: null,
  );
}
