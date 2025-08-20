import 'package:flutter/material.dart';
import 'package:manicure/third/flutter_aux/plugins/dump/model.dart';

class DumpItemWidget extends StatelessWidget {
  final HttpDumpRecord record;
  final VoidCallback? onTap;
  const DumpItemWidget(this.record, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
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
    );
  }

  static String _formatTime(DateTime time) {
    final String text = time.toString();
    return text.substring(text.indexOf(' ') + 1, text.indexOf('.'));
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
