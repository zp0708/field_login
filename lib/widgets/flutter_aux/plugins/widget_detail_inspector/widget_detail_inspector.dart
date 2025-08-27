import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide SearchBar;
import '../../utils/hit_test.dart';
import '../pluggable.dart';
import '../../utils/binding_ambiguate.dart';
import '../../widgets/inspector_overlay.dart';

// There was a conflict between the naming of material.SearchBar and ume's SearchBar.
import 'search_bar.dart' as search_bar;

class WidgetDetailInspector extends Pluggable {
  @override
  String get name => 'widget_detail';

  @override
  String get display => '组件详情';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _DetailPage();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '点击组件查看组件详情';
}

class _DetailPage extends StatefulWidget {
  const _DetailPage();

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage> with WidgetsBindingObserver {
  _DetailPageState() : selection = WidgetInspectorService.instance.selection;

  final window = bindingAmbiguate(WidgetsBinding.instance)!.window;

  Offset? _lastPointerLocation;

  final InspectorSelection selection;

  void _inspectAt(Offset? position) {
    final List<RenderObject> selected = HitTest.hitTest(position);
    setState(() {
      selection.candidates = selected;
    });
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
    }
    Future.delayed(Duration(milliseconds: 100), () async {
      if (context.mounted) {
        setState(() {});
        // ignore: use_build_context_synchronously
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) {
              return _InfoPage(
                elements: selection.currentElement!.debugGetDiagnosticChain(),
              );
            },
          ),
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selection.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    GestureDetector gesture = GestureDetector(
      onTap: _handleTap,
      onPanDown: _handlePanDown,
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
    children.add(gesture);
    children.add(
      InspectorOverlay(
        selection: selection,
        needDescription: false,
        needEdges: false,
      ),
    );
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        textDirection: TextDirection.ltr,
        children: children,
      ),
    );
  }
}

class _DetailModel {
  List<int> colors = [
    Random().nextInt(256),
    Random().nextInt(256),
    Random().nextInt(256),
  ];
  Element element;

  _DetailModel(this.element);
}

class _InfoPage extends StatefulWidget {
  const _InfoPage({required this.elements});

  final List<Element> elements;

  @override
  __InfoPageState createState() => __InfoPageState();
}

class __InfoPageState extends State<_InfoPage> {
  List<_DetailModel> _showList = <_DetailModel>[];
  late List<_DetailModel> _originalList;

  @override
  void initState() {
    super.initState();
    for (var f in widget.elements) {
      _showList.add(_DetailModel(f));
    }
    _originalList = _showList;
  }

  Widget _dot(List<int> colors) {
    Color randomColor = Color.fromARGB(
      255,
      colors[0],
      colors[1],
      colors[2],
    );
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: randomColor,
      ),
      width: 10,
      height: 10,
    );
  }

  Widget _cell(_DetailModel model, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return Scaffold(
            body: _DetailContent(element: model.element),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(44),
              child: AppBar(
                elevation: 0.0,
                title: Text("widget_detail"),
              ),
            ),
          );
        }));
      },
      child: Container(
        margin: const EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: 12,
          right: 12,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _dot(model.colors),
            ),
            Expanded(
              child: Text(
                model.element.widget.toStringShort(),
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _textChange(String query) {
    query = query.trim();
    List<_DetailModel> infoList = [];
    for (var model in _originalList) {
      var regExp = RegExp(query, caseSensitive: false);
      if (regExp.hasMatch(model.element.widget.toStringShort())) {
        infoList.add(model);
      }
    }
    setState(() {
      _showList = infoList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: 10,
            ),
            child: search_bar.SearchBar(
              placeHolder: '请输入要搜索的widget',
              onChangeHandle: _textChange,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanDown: (_) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, index) {
                  _DetailModel model = _showList[index];
                  return _cell(model, context);
                },
                itemCount: _showList.length,
              ),
            ),
          ),
        ],
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          elevation: 0.0,
          title: RichText(
            text: TextSpan(
              text: 'widget_build_chain',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19,
                fontWeight: FontWeight.w500,
                fontFamily: "PingFang SC",
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '  depth: ${widget.elements.length}',
                  style: TextStyle(color: Colors.black, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.element});

  final Element element;

  Widget _titleWidget(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }

  Future<List<String>> getInfo() async {
    Completer<List<String>> completer = Completer();
    String string = element.renderObject!.toStringDeep();
    List<String> list = string.split("\n");
    completer.complete(list);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getInfo(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titleWidget("Widget Description"),
              Container(
                constraints: BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                child: SingleChildScrollView(
                  child: Text(
                    element.widget.toStringDeep(),
                  ),
                ),
              ),
              _titleWidget("RenderObject Description"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 12, left: 12),
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (_, index) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          (snapshot.data as List<String>)[index],
                        ),
                      );
                    },
                    itemCount: (snapshot.data as List<String>).length,
                  ),
                ),
              ),
            ],
          );
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
