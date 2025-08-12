import 'package:field_login/widgets/progress_timeline/widgets/dash_line_painter.dart';
import 'package:field_login/widgets/progress_timeline/widgets/progress_stage_widget.dart';
import 'package:field_login/widgets/progress_timeline/widgets/shape_background_buttons.dart';
import 'package:field_login/widgets/progress_timeline/widgets/stage_item.dart';
import 'package:flutter/material.dart';

/// 进度时间线组件
class ProgressTimeline extends StatefulWidget {
  final List<ProgressStage> stages;
  final void Function(ProgressStage value, ProgressStageOption option)? onOptionSelected;
  final double height;
  final Color backgroundColor;

  const ProgressTimeline({
    super.key,
    required this.stages,
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
  // top 是 stage 的上间距加上状态图标中心高度
  final _top = 109.0;

  @override
  Widget build(BuildContext context) {
    final optionIndex = widget.stages.indexWhere((stage) => stage.options != null);
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
                children: List.generate(
                  widget.stages.length,
                  (index) {
                    final stage = widget.stages[index];
                    return ProgressStageWidget(stage: stage);
                  },
                ),
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
            if (optionIndex != -1)
              Positioned(
                left: _calculateStageCenterPosition(constraints.maxWidth, optionIndex) - 87,
                top: 0,
                child: ShapeBackgroundButtons(
                  options: widget.stages[optionIndex].options!,
                  onOptionSelected: (option) {
                    widget.onOptionSelected?.call(widget.stages[optionIndex], option);
                  },
                ),
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

  Widget _buildConnectionLine(ProgressStage stage, double width) {
    final isDashed = stage.getConnectionLineStyle();
    final color = _getConnectionLineColor(stage);

    if (isDashed) {
      // 虚线连接线
      return SizedBox(
        width: width,
        height: 1,
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
        height: 1,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      );
    }
  }

  /// 获取连接线颜色
  Color _getConnectionLineColor(ProgressStage stage) {
    if (stage.status == ProgressStatus.completed) {
      return Colors.black;
    } else if (stage.status == ProgressStatus.inProgress) {
      return Colors.black;
    } else {
      return Colors.grey.withValues(alpha: 0.3);
    }
  }
}
