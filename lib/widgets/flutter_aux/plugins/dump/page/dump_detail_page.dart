import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    _record = widget._record;
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
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
        _buildDataSection('请求头', _record.requestHeader, Icons.view_headline),
        _buildDataSection('请求参数', _record.requestQuery, Icons.query_stats),
        _buildDataSection('请求体', _record.requestBody, Icons.description),
        _buildDataSectionRow('LogId', _record.logId),
      ],
    );
  }

  Widget _buildResponseInfoCard() {
    return _buildInfoCard(
      title: '响应信息',
      icon: Icons.download,
      color: Colors.orange,
      children: [
        _buildDataSection('响应体', _record.responseBody, Icons.download_done, true),
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
      child: TextField(
        controller: _searchController,
        cursorColor: Colors.blue,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: '搜索 JSON 关键字',
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

  Widget _buildDataSection(String title, String? data, IconData icon, [bool showCopy = false]) {
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
              GestureDetector(
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
            if (showCopy)
              // 复制按钮
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
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: _buildCodeViewer(title, data, showCopy),
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

  Widget _buildCodeViewer(String title, String data, bool unfold) {
    final dynamic json = _tryDecodeJson(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 代码显示区域
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: _buildJsonViewer(data, json, unfold),
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
              const Spacer(),
              // 数据类型标识
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: json != null ? Colors.blue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  json != null ? 'JSON' : 'TEXT',
                  style: TextStyle(
                    fontSize: 10,
                    color: json != null ? Colors.blue.shade700 : Colors.grey.shade600,
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

  Widget _buildJsonViewer(String text, dynamic json, bool unfold) {
    // 判断是否为 JSON 数据
    if (json == null || json is! Map<String, dynamic>) {
      return SelectableText(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontFamily: 'monospace',
          height: 1.4,
        ),
      );
    }
    return JsonViewer(
      key: ValueKey('jsonviewer_${_unfold ? "1" : "0"}'),
      json,
      unfold: _unfold || unfold,
      highlight: _keyword,
      highlightColor: const Color(0xFFFFFF00),
    );
  }

  // 检查是否为有效的 JSON
  dynamic _tryDecodeJson(String text) {
    if (text == 'null') return null;
    try {
      return jsonDecode(text);
    } catch (e) {
      return null;
    }
  }

  // 复制数据到剪贴板
  void _copyData(String data) {
    Clipboard.setData(ClipboardData(text: data));
    FlutterAux.onMessage('数据已复制到剪贴板');
  }
}
