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
  String get display => '组件详情面板';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _DetailPage();
  }

  @override
  bool get isOverlay => true;

  @override
  String get tips => '点击任意组件查看详细信息和构建链';
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

  Widget _buildWidgetCard(_DetailModel model, BuildContext context, int index) {
    final String widgetType = model.element.widget.toStringShort();
    final bool isTopLevel = index < 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return _OptimizedDetailContent(element: model.element);
            }));
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isTopLevel ? const Color(0xFF3498DB).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                width: isTopLevel ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, model.colors[0], model.colors[1], model.colors[2]),
                        Color.fromARGB(255, model.colors[0], model.colors[1], model.colors[2]).withValues(alpha: 0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(255, model.colors[0], model.colors[1], model.colors[2])
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widgetType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.layers,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '层级 ${index + 1}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (isTopLevel) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3498DB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '顶层',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
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
      backgroundColor: const Color(0xFF2C3E50),
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C3E50),
              const Color(0xFF34495E),
            ],
          ),
        ),
        child: Column(
          children: <Widget>[
            _buildSearchSection(),
            Expanded(
              child: _buildWidgetList(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3498DB).withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.widgets,
              color: Color(0xFF3498DB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '组件构建链',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '深度: ${widget.elements.length} 层',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: search_bar.SearchBar(
        placeHolder: '搜索 Widget 类型...',
        onChangeHandle: _textChange,
      ),
    );
  }

  Widget _buildWidgetList() {
    if (_showList.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemBuilder: (_, index) {
            _DetailModel model = _showList[index];
            return _buildWidgetCard(model, context, index);
          },
          itemCount: _showList.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
            ),
            child: Icon(
              Icons.search_off,
              size: 48,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '未找到匹配的 Widget',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请尝试修改搜索关键词',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptimizedDetailContent extends StatelessWidget {
  const _OptimizedDetailContent({required this.element});

  final Element element;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C3E50),
              const Color(0xFF34495E),
            ],
          ),
        ),
        child: FutureBuilder<List<String>>(
          future: _getDetailInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState();
            } else if (snapshot.hasData) {
              return _buildContent(snapshot.data!);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3498DB).withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF3498DB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Widget 详细信息',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
          ),
          SizedBox(height: 16),
          Text(
            '正在加载组件信息...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '加载失败',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<String> renderData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            title: 'Widget 信息',
            icon: Icons.widgets,
            color: const Color(0xFF3498DB),
            child: _buildWidgetInfo(),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: 'RenderObject 详情',
            icon: Icons.account_tree,
            color: const Color(0xFF27AE60),
            child: _buildRenderObjectInfo(renderData),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildWidgetInfo() {
    final widgetInfo = element.widget.toStringDeep();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPropertyRow('类型', element.widget.runtimeType.toString()),
        const SizedBox(height: 12),
        _buildPropertyRow('状态', element.dirty ? '脏数据' : '干净数据'),
        const SizedBox(height: 16),
        const Text(
          '详细描述',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              widgetInfo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRenderObjectInfo(List<String> renderData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (element.renderObject != null) ...[
          _buildPropertyRow('类型', element.renderObject.runtimeType.toString()),
          const SizedBox(height: 12),
          _buildPropertyRow('需要重绘', element.renderObject!.debugNeedsPaint.toString()),
          const SizedBox(height: 16),
        ],
        const Text(
          'RenderObject 树结构',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: .1),
              width: 1,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: renderData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    renderData[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                      height: 1.3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>> _getDetailInfo() async {
    if (element.renderObject == null) {
      return ['RenderObject is null'];
    }

    final String renderString = element.renderObject!.toStringDeep();
    return renderString.split('\n');
  }
}
