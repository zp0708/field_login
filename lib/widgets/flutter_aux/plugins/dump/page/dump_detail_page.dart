import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../model.dart';

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

  @override
  void initState() {
    _record = widget._record;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('复制链接', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(child: _buildView()),
        ],
      ),
    );
  }

  Widget _buildView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
      children: [
        _buildInfoRow('请求地址', _record.uri, Icons.link),
        _buildInfoRow('请求状态', _record.getStatusText(), Icons.info),
        _buildInfoRow('开始时间', _formatTime(_record.requestTime), Icons.schedule),
        if (_record.finishTime != null) _buildInfoRow('结束时间', _formatTime(_record.finishTime!), Icons.schedule),
        if (_record.dumpStatus == HttpDumpStatus.success)
          _buildInfoRow('请求耗时', '${_record.getCostTime()}ms', Icons.timer),
      ],
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
      ],
    );
  }

  Widget _buildResponseInfoCard() {
    return _buildInfoCard(
      title: '响应信息',
      icon: Icons.download,
      color: Colors.orange,
      children: [
        _buildDataSection('响应体', _record.responseBody, Icons.download_done),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '无' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(String title, String? data, IconData icon) {
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SelectableText(
              title == '响应体' ? _formatJson(data) : data,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'monospace',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final String text = time.toString();
    return text.substring(text.indexOf(' ') + 1, text.indexOf('.'));
  }

  String _formatJson(String? jsonText) {
    if (jsonText == null) {
      return '';
    }
    final dynamic object = jsonDecode(jsonText);
    return const JsonEncoder.withIndent('  ').convert(object);
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _record.uri));
  }
}
