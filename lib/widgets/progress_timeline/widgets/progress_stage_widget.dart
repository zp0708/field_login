import 'package:field_login/widgets/progress_timeline/widgets/stage_item.dart';
import 'package:flutter/material.dart';

class ProgressStageWidget extends StatelessWidget {
  final ProgressStage stage;

  const ProgressStageWidget({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 17),
          // 阶段图标
          Image.asset(
            stage.image,
            width: 72,
            height: 72,
          ),
          const SizedBox(height: 12),

          // 状态图标
          getStatusIcon(stage),

          const SizedBox(height: 12),

          // 阶段标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              stage.title,
              style: TextStyle(
                color: getStatusColor(stage),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 时间戳
          if (stage.timestamp != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                stage.timestamp!,
                style: TextStyle(
                  color: getStatusColor(stage),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 获取状态颜色
  Color getStatusColor(ProgressStage stage) {
    switch (stage.status) {
      case ProgressStatus.waiting:
        return Colors.grey;
      case ProgressStatus.inProgress:
        return Colors.black;
      case ProgressStatus.completed:
        return Colors.black;
    }
  }

  /// 获取状态图标
  Widget getStatusIcon(ProgressStage stage) {
    switch (stage.status) {
      case ProgressStatus.waiting:
        return Image.asset('assets/icons/order_status_undo.png', width: 16, height: 16);
      case ProgressStatus.inProgress:
        return Image.asset('assets/icons/order_status_doing.png', width: 16, height: 16);
      case ProgressStatus.completed:
        return Image.asset('assets/icons/order_status_done.png', width: 16, height: 16);
    }
  }
}
