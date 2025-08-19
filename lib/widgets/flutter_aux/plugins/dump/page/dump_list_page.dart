import 'package:flutter/material.dart';
import '../manager.dart';
import '../model.dart';
import 'dump_detail_page.dart';

///
class HttpDumpListPage extends StatefulWidget {
  ///
  const HttpDumpListPage({super.key});

  @override
  State<HttpDumpListPage> createState() => _HttpDumpListPageState();
}

class _HttpDumpListPageState extends State<HttpDumpListPage> {
  late List<HttpDumpRecord> _list;

  @override
  void initState() {
    _list = DumpManager.getRecordList();
    DumpManager.setObserver(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    DumpManager.setObserver(null);
    super.dispose();
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
                SizedBox(width: 50),
                Text('自定义 AppBar', style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: _clear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('清空', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
          Expanded(
            child: _list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (_, int index) => _buildItem(index),
                    itemCount: _list.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final HttpDumpRecord record = _list[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(10),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTapItem(index),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // URI 部分
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.uri,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(record.dumpStatus, record.getStatusText()),
              ],
            ),

            const SizedBox(height: 12),

            // 请求信息行
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                _buildInfoChip(
                  icon: Icons.schedule,
                  text: _formatTime(record.requestTime),
                  color: Colors.blue.shade100,
                  textColor: Colors.blue.shade700,
                ),
                _buildInfoChip(
                  icon: Icons.timer,
                  text: '${record.getCostTime()}ms',
                  color: Colors.orange.shade100,
                  textColor: Colors.orange.shade700,
                ),
                _buildInfoChip(
                  icon: Icons.http,
                  text: record.method,
                  color: Colors.green.shade100,
                  textColor: Colors.green.shade700,
                ),
                _buildInfoChip(
                  icon: Icons.tag,
                  text: '${record.httpCode ?? "N/A"}',
                  color: _getHttpCodeColor(record.httpCode ?? 0).withValues(alpha: 0.1),
                  textColor: _getHttpCodeColor(record.httpCode ?? 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onTapItem(int index) {
    Navigator.of(context).push<dynamic>(MaterialPageRoute<dynamic>(builder: (_) => HttpDumpDetailPage(_list[index])));
  }

  static String _formatTime(DateTime time) {
    final String text = time.toString();
    return text.substring(text.indexOf(' ') + 1, text.indexOf('.'));
  }

  void _clear() {
    DumpManager.clear();
    setState(() {});
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.network_check,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无抓包记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始网络请求后，这里会显示抓包记录',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(HttpDumpStatus status, String statusText) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case HttpDumpStatus.requesting:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade700;
        icon = Icons.pending;
        break;
      case HttpDumpStatus.error:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade700;
        icon = Icons.error;
        break;
      case HttpDumpStatus.success:
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getHttpCodeColor(int httpCode) {
    if (httpCode >= 200 && httpCode < 300) return Colors.green;
    if (httpCode >= 300 && httpCode < 400) return Colors.blue;
    if (httpCode >= 400 && httpCode < 500) return Colors.orange;
    if (httpCode >= 500) return Colors.red;
    return Colors.grey;
  }
}
