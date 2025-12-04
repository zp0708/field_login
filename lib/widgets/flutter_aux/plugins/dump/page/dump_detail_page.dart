import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import '../model.dart';
import '../../../flutter_aux.dart';
import 'dump_item.dart';
import './json_viewer.dart';

///
class HttpDumpDetailPage extends StatefulWidget {
  ///
  const HttpDumpDetailPage(this._record, {super.key});

  final HttpDumpRecord _record;

  @override
  State<HttpDumpDetailPage> createState() => _HttpDumpDetailPageState();
}

class _HttpDumpDetailPageState extends State<HttpDumpDetailPage> {
  late HttpDumpRecord _record;
  late TextEditingController _searchController;
  String _keyword = '';
  bool _unfold = false;
  final JsonViewerController _jsonController = JsonViewerController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _record = widget._record;
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _unfold = true;
        _keyword = _searchController.text.trim();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text('接口数据', style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: _copyLink,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.deepOrange,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('复制链接', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          _buildSearchBar(),
          Expanded(child: _buildView()),
        ],
      ),
    );
  }

  Widget _buildView() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 基本信息卡片
          _buildBasicInfoCard(),

          const SizedBox(height: 16),

          // 请求信息卡片
          _buildRequestInfoCard(),

          const SizedBox(height: 16),

          // 响应信息卡片
          _buildResponseInfoCard(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildInfoCard(
      title: '基本信息',
      icon: Icons.info_outline,
      color: Colors.blue,
      children: [DumpItemWidget(_record)],
    );
  }

  Widget _buildRequestInfoCard() {
    return _buildInfoCard(
      title: '请求信息',
      icon: Icons.upload,
      color: Colors.green,
      children: [
        _buildDataSection(title: '请求头', data: _record.requestHeader, icon: Icons.view_headline),
        _buildDataSection(title: '请求参数', data: _record.requestQuery, icon: Icons.query_stats),
        _buildDataSection(title: '请求体', data: _record.requestBody, icon: Icons.description),
        _buildDataSectionRow('LogId', _record.logId),
      ],
    );
  }

  Widget _buildResponseInfoCard() {
    print('object');
    return _buildInfoCard(
      title: '响应信息',
      icon: Icons.download,
      color: Colors.orange,
      children: [
        _buildDataSection(
          title: '响应体',
          data: _record.response,
          icon: Icons.download_done,
          showCopy: true,
          highlight: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // 卡片内容
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(top: 5),
      alignment: Alignment.center,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.blue,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                hintText: '搜索响应体',
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.blue),
                suffixIcon: _keyword.isEmpty
                    ? null
                    : InkWell(
                        onTap: () {
                          _searchController.clear();
                        },
                        child: Icon(Icons.clear, size: 18, color: Colors.blue),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (_keyword.isNotEmpty)
            AnimatedBuilder(
              animation: _jsonController,
              builder: (_, __) {
                final int len = _jsonController.length;
                final int idx = len == 0 ? 0 : _jsonController.currentIndex;
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.yellow.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.shade600),
                      ),
                      child: Text(
                        '${len == 0 ? 0 : (idx + 1)}/$len',
                        style: const TextStyle(fontSize: 10, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: '上一处',
                      icon: const Icon(Icons.keyboard_arrow_up, size: 18, color: Colors.blue),
                      onPressed: len == 0 ? null : _goPrevHighlight,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                    ),
                    IconButton(
                      tooltip: '下一处',
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue),
                      onPressed: len == 0 ? null : _goNextHighlight,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDataSectionRow(String title, String? data) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(data),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () => _copyData(data),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  '复制',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection({
    required String title,
    dynamic data,
    required IconData icon,
    bool showCopy = false,
    bool highlight = false,
  }) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 5),
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            if (showCopy)
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _unfold = !_unfold;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_unfold ? Icons.unfold_less : Icons.unfold_more, size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        _unfold ? '收起' : '展开',
                        style: const TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            if (showCopy)
              // 复制按钮
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: GestureDetector(
                  onTap: () => _copyData(data),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '复制',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _buildCodeViewer(data: data, unfold: !showCopy, highlight: highlight),
        ),
      ],
    );
  }

  void _copyLink() {
    _copyData(_toCurlCommand());
  }

  String _toCurlCommand() {
    final StringBuffer cmd = StringBuffer('curl');

    // Method
    cmd.write(' -X ${_record.method}');

    // URL
    cmd.write(' ${_record.uri}');

    // Headers
    cmd.write(' ${_record.cURLHeader}');

    // Data (body)
    if (_record.requestBody != null) {
      String data = _record.requestBody ?? '';
      if (data is Map) {
        data = data.toString();
      }
      cmd.write(' -d \'$data\'');
    }

    return cmd.toString();
  }

  Widget _buildCodeViewer({
    dynamic data,
    bool unfold = false,
    bool highlight = false,
  }) {
    final isJson = data is Map;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 代码显示区域
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: _buildJsonViewer(
            data: data,
            unfold: unfold,
            highlight: highlight,
          ),
        ),
        // 操作按钮栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              // 复制按钮
              GestureDetector(
                onTap: () {
                  if (isJson) {
                    _copyData(json.encode(data));
                  } else {
                    _copyData(data.toString());
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '复制',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 数据类型标识
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isJson ? Colors.blue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isJson ? 'JSON' : 'TEXT',
                  style: TextStyle(
                    fontSize: 10,
                    color: isJson ? Colors.blue.shade700 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJsonViewer({
    dynamic data,
    bool unfold = false,
    bool highlight = false,
  }) {
    // 判断是否为 JSON 数据
    if (data is! Map) {
      return SelectableText(
        data.toString(),
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'monospace',
          height: 1.4,
        ),
      );
    }
    return JsonViewer(
      data,
      unfold: _unfold || unfold,
      highlight: highlight ? _keyword : null,
      highlightColor: const Color(0xFFFFFF00),
      controller: highlight ? _jsonController : null,
    );
  }

  void _goPrevHighlight() {
    if (_jsonController.length == 0) return;
    _jsonController.goPrev();
    _scrollToCurrentAnchor();
  }

  void _goNextHighlight() {
    if (_jsonController.length == 0) return;
    _jsonController.goNext();
    _scrollToCurrentAnchor();
  }

  void _scrollToCurrentAnchor() {
    final GlobalKey? key = _jsonController.currentAnchor;
    if (key == null) return;
    final BuildContext? ctx = key.currentContext;
    if (ctx != null) {
      final RenderObject? renderObject = ctx.findRenderObject();
      if (renderObject != null) {
        final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
        final RevealedOffset revealed = viewport.getOffsetToReveal(renderObject, 0.1);
        final double target = revealed.offset.clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
        );
        return;
      }
      // 兜底：如果无法获取 viewport，则退回 ensureVisible
      Scrollable.ensureVisible(ctx,
          alignment: 0.1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }

  // 复制数据到剪贴板
  void _copyData(String data) {
    Clipboard.setData(ClipboardData(text: data));
    FlutterAux.onMessage('数据已复制到剪贴板');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _jsonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
