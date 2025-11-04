library;

import 'package:flutter/material.dart';

class JsonViewer extends StatefulWidget {
  final dynamic jsonObj;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;
  final void Function(List<GlobalKey>)? onAnchorsChanged;

  const JsonViewer(
    this.jsonObj, {
    super.key,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
    this.onAnchorsChanged,
  });

  @override
  JsonViewerState createState() => JsonViewerState();
}

class JsonViewerState extends State<JsonViewer> {
  final List<GlobalKey> _anchorsCollector = <GlobalKey>[];
  List<GlobalKey> _lastReportedAnchors = const <GlobalKey>[];
  @override
  Widget build(BuildContext context) {
    _anchorsCollector.clear();
    final Widget w = getContentWidget(
      widget.jsonObj,
      widget.unfold,
      widget.highlight,
      widget.highlightColor,
      _anchorsCollector,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final List<GlobalKey> snapshot = List<GlobalKey>.unmodifiable(_anchorsCollector);
      if (_didAnchorsChange(snapshot)) {
        _lastReportedAnchors = snapshot;
        widget.onAnchorsChanged?.call(snapshot);
      }
    });
    return w;
  }

  bool _didAnchorsChange(List<GlobalKey> next) {
    final List<GlobalKey> prev = _lastReportedAnchors;
    if (identical(prev, next)) return false;
    if (prev.length != next.length) return true;
    for (int i = 0; i < prev.length; i++) {
      if (!identical(prev[i], next[i])) return true;
    }
    return false;
  }

  static getContentWidget(
    dynamic content,
    bool unfold,
    String? highlight,
    Color highlightColor,
    List<GlobalKey> anchorsCollector,
  ) {
    if (content == null) {
      return Text('{}');
    } else if (content is List) {
      return JsonArrayViewer(
        content,
        notRoot: false,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
        anchorsCollector: anchorsCollector,
      );
    } else {
      return JsonObjectViewer(
        content,
        notRoot: false,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
        anchorsCollector: anchorsCollector,
      );
    }
  }
}

class JsonObjectViewer extends StatefulWidget {
  final Map<String, dynamic> jsonObj;
  final bool notRoot;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;
  final List<GlobalKey> anchorsCollector;

  const JsonObjectViewer(
    this.jsonObj, {
    super.key,
    this.notRoot = false,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
    required this.anchorsCollector,
  });

  @override
  JsonObjectViewerState createState() => JsonObjectViewerState();
}

class JsonObjectViewerState extends State<JsonObjectViewer> {
  Map<String, bool> openFlag = {};

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
      bool ex = isExtensible(entry.value);
      bool ink = isInkWell(entry.value);
      list.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ex
              ? InkWell(
                  onTap: () {
                    setState(() {
                      openFlag[entry.key] = !(openFlag[entry.key] ?? false);
                    });
                  },
                  child: ((openFlag[entry.key] ?? false)
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
                    entry.key,
                    TextStyle(color: Colors.purple[900]),
                    widget.highlight,
                    widget.highlightColor,
                    widget.anchorsCollector,
                    selectable: false,
                  ),
                  onTap: () {
                    setState(() {
                      openFlag[entry.key] = !(openFlag[entry.key] ?? false);
                    });
                  })
              : _buildHighlightedText(
                  entry.key,
                  TextStyle(
                    color: entry.value == null ? Colors.grey : Colors.purple[900],
                  ),
                  widget.highlight,
                  widget.highlightColor,
                  widget.anchorsCollector,
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
        list.add(getContentWidget(
          entry.value,
          widget.unfold,
          highlight: widget.highlight,
          highlightColor: widget.highlightColor,
          anchorsCollector: widget.anchorsCollector,
        ));
      }
    }
    return list;
  }

  static getContentWidget(dynamic content, bool unfold,
      {String? highlight, Color highlightColor = const Color(0xFFFFFF00), required List<GlobalKey> anchorsCollector}) {
    if (content is List) {
      return JsonArrayViewer(
        content,
        notRoot: true,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
        anchorsCollector: anchorsCollector,
      );
    } else {
      return JsonObjectViewer(
        content,
        notRoot: true,
        unfold: unfold,
        highlight: highlight,
        highlightColor: highlightColor,
        anchorsCollector: anchorsCollector,
      );
    }
  }

  static isInkWell(dynamic content) {
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
          '"${entry.value}"',
          TextStyle(color: Colors.redAccent),
          widget.highlight,
          widget.highlightColor,
          widget.anchorsCollector,
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
            'Array<${getTypeName(entry.value[0])}>[${entry.value.length}]',
            style: TextStyle(color: Colors.grey),
          ),
          onTap: () {
            setState(() {
              openFlag[entry.key] = !(openFlag[entry.key] ?? false);
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
          openFlag[entry.key] = !(openFlag[entry.key] ?? false);
        });
      },
    );
  }

  static isExtensible(dynamic content) {
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

  static getTypeName(dynamic content) {
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
}

class JsonArrayViewer extends StatefulWidget {
  final List<dynamic> jsonArray;

  final bool notRoot;
  final bool unfold;
  final String? highlight;
  final Color highlightColor;
  final List<GlobalKey> anchorsCollector;

  const JsonArrayViewer(
    this.jsonArray, {
    super.key,
    this.notRoot = false,
    this.unfold = false,
    this.highlight,
    this.highlightColor = const Color(0xFFFFFF00),
    required this.anchorsCollector,
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

  _getList() {
    List<Widget> list = [];
    int i = 0;
    for (dynamic content in widget.jsonArray) {
      bool ex = JsonObjectViewerState.isExtensible(content);
      bool ink = JsonObjectViewerState.isInkWell(content);
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
        list.add(JsonObjectViewerState.getContentWidget(
          content,
          widget.unfold,
          highlight: widget.highlight,
          highlightColor: widget.highlightColor,
          anchorsCollector: widget.anchorsCollector,
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
          '"$content"',
          TextStyle(color: Colors.redAccent),
          widget.highlight,
          widget.highlightColor,
          widget.anchorsCollector,
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
            'Array<${JsonObjectViewerState.getTypeName(content)}>[${content.length}]',
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
  String text,
  TextStyle baseStyle,
  String? highlight,
  Color highlightColor,
  List<GlobalKey>? anchorsCollector, {
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
    anchorsCollector?.add(key);
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
