import 'package:flutter/material.dart';
import '../../../style/adapt.dart';
import '../models/settlement_status.dart';

/// Widget that displays the current settlement status
class SettlementStatusIndicator extends StatelessWidget {
  final SettlementStatus status;
  final VoidCallback? onStatusToggle;

  const SettlementStatusIndicator({
    super.key,
    required this.status,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCreated = status == SettlementStatus.created;
    final statusColor = isCreated ? Colors.blue : Colors.orange;
    final backgroundColor = isCreated ? Colors.blue[50] : Colors.orange[50];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.dp),
      margin: EdgeInsets.all(16.dp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.dp),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCreated ? Icons.edit : Icons.pending_actions,
            color: statusColor,
            size: 20.dp,
          ),
          SizedBox(width: 8.dp),
          Expanded(
            child: Text(
              status.displayName,
              style: TextStyle(
                fontSize: 14.dp,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onStatusToggle != null) ...[
            SizedBox(width: 8.dp),
            GestureDetector(
              onTap: onStatusToggle,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.dp, vertical: 4.dp),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.dp),
                  border: Border.all(color: statusColor, width: 0.5),
                ),
                child: Text(
                  '切换状态',
                  style: TextStyle(
                    fontSize: 12.dp,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
