import 'package:field_login/widgets/progress_timeline/widgets/shape_background_buttons.dart';
import 'package:flutter/material.dart';

/// 进度状态枚举
enum ProgressStatus {
  waiting, // 等待
  inProgress, // 进行中
  completed, // 完成
}

/// 进度阶段模型
class ProgressStage {
  final String id;
  final String title;
  final IconData icon;
  final ProgressStatus status;
  final String? timestamp;
  final Map<String, dynamic>? options; // 用于存储选项，如"人工美甲"、"智能美甲"

  const ProgressStage({
    required this.id,
    required this.title,
    required this.icon,
    this.status = ProgressStatus.waiting,
    this.timestamp,
    this.options,
  });

  /// 复制并修改状态
  ProgressStage copyWith({
    String? id,
    String? title,
    IconData? icon,
    ProgressStatus? status,
    String? timestamp,
    Map<String, dynamic>? options,
  }) {
    return ProgressStage(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      options: options ?? this.options,
    );
  }

  /// 获取状态颜色
  Color getStatusColor() {
    switch (status) {
      case ProgressStatus.waiting:
        return Colors.grey;
      case ProgressStatus.inProgress:
        return Colors.black;
      case ProgressStatus.completed:
        return Colors.black;
    }
  }

  /// 获取状态图标
  Widget getStatusIcon() {
    switch (status) {
      case ProgressStatus.waiting:
        return Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 16);
      case ProgressStatus.inProgress:
        return Icon(Icons.check_box, color: Colors.black, size: 16);
      case ProgressStatus.completed:
        return Icon(Icons.check_box, color: Colors.black, size: 16);
    }
  }

  /// 获取连接线颜色
  Color getConnectionLineColor() {
    if (status == ProgressStatus.completed) {
      return Colors.black;
    } else if (status == ProgressStatus.inProgress) {
      return Colors.black;
    } else {
      return Colors.grey.withOpacity(0.3);
    }
  }

  /// 获取连接线样式
  bool getConnectionLineStyle() {
    if (status == ProgressStatus.completed) {
      return false; // 实线
    } else if (status == ProgressStatus.inProgress) {
      return false; // 实线
    } else {
      return true; // 虚线
    }
  }
}

/// 进度时间线组件
class ProgressTimeline extends StatefulWidget {
  final List<ProgressStage> stages;
  final ValueChanged<ProgressStage>? onStageTap;
  final ValueChanged<ProgressStage>? onOptionSelected;
  final double height;
  final Color backgroundColor;

  const ProgressTimeline({
    super.key,
    required this.stages,
    this.onStageTap,
    this.onOptionSelected,
    this.height = 120,
    this.backgroundColor = const Color(0xFFE8F5E8), // 浅绿色背景
  });

  @override
  State<ProgressTimeline> createState() => _ProgressTimelineState();
}

class _ProgressTimelineState extends State<ProgressTimeline> {
  final _stageSpace = 18;
  final _stageWidth = 100;
  final _top = 109.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final length = widget.stages.length;
        return Stack(
          children: [
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(widget.stages.length, (index) {
                  final stage = widget.stages[index];
                  return _buildStage(stage, index);
                }),
              ),
            ),
            ...List.generate(
              length - 1,
              (index) {
                final stage = widget.stages[index];
                final centerX = _calculateStageCenterPosition(constraints.maxWidth, index);
                final width = _calculateStageWidth(constraints.maxWidth, index);
                return Positioned(
                  left: centerX + _stageSpace,
                  top: _top,
                  child: _buildConnectionLine(stage, width),
                );
              },
            ),
            Positioned(
              left: _calculateStageCenterPosition(constraints.maxWidth, 2) - 87,
              top: 0,
              child: ShapeBackgroundButtons(),
            ),
          ],
        );
      }),
    );
  }

  // 计算每个阶段的中心位置
  // width 容器宽度
  // index 阶段索引
  double _calculateStageCenterPosition(double width, int index) {
    final length = widget.stages.length;
    if (length == 1) {
      return width * 0.5;
    }
    // stage之间的空间
    final margin = (width - length * _stageWidth) / (length - 1);
    // 每个 stage 的中心点就是前面所有 stage 加上间距再加上本身宽度一半
    return index * (_stageWidth + margin) + _stageWidth * 0.5;
  }

  // 计算连线的宽度
  // width 容器宽度
  // index 阶段索引
  double _calculateStageWidth(double width, int index) {
    final length = widget.stages.length;
    if (length == 1) {
      return 0.0;
    }
    // stage之间的空间
    final margin = (width - length * _stageWidth) / (length - 1);
    return _stageWidth + margin - 2 * _stageSpace;
  }

  Widget _buildStage(ProgressStage stage, int index) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 17),
          // 阶段图标
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: stage.getStatusColor().withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stage.icon,
              color: stage.getStatusColor(),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),

          // 状态图标
          stage.getStatusIcon(),

          const SizedBox(height: 12),

          // 阶段标题
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              stage.title,
              style: TextStyle(
                color: stage.getStatusColor(),
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
                  color: stage.getStatusColor(),
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

  Widget _buildConnectionLine(ProgressStage stage, double width) {
    final isDashed = stage.getConnectionLineStyle();
    final color = stage.getConnectionLineColor();

    if (isDashed) {
      // 虚线连接线
      return SizedBox(
        width: width,
        height: 2,
        child: CustomPaint(
          painter: DashedLinePainter(
            color: color,
            dashWidth: 4,
            dashSpace: 4,
          ),
        ),
      );
    } else {
      // 实线连接线
      return Container(
        width: width,
        height: 2,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }
  }
}

/// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 4,
    this.dashSpace = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    final totalWidth = size.width;
    final dashLength = dashWidth + dashSpace;
    final dashCount = (totalWidth / dashLength).floor();
    final remainingWidth = totalWidth - (dashCount * dashLength);

    for (int i = 0; i < dashCount; i++) {
      final startX = i * dashLength;
      final endX = startX + dashWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX, size.height / 2),
        paint,
      );
    }

    // 绘制剩余的虚线
    if (remainingWidth > dashWidth) {
      final startX = dashCount * dashLength;
      final endX = startX + dashWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
