import 'package:flutter/material.dart';
import '../image_carousel_controller.dart';

/// 控制按钮覆盖层组件
class ControlButtonsOverlay extends StatelessWidget {
  final ImageCarouselController controller;
  final double buttonSize;
  final IconData? previousIcon;
  final IconData? nextIcon;
  final Color? buttonColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool showPreviousButton;
  final bool showNextButton;
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;

  const ControlButtonsOverlay({
    super.key,
    required this.controller,
    this.buttonSize = 40,
    this.previousIcon = Icons.chevron_left,
    this.nextIcon = Icons.chevron_right,
    this.buttonColor,
    this.backgroundColor,
    this.borderRadius,
    this.showPreviousButton = true,
    this.showNextButton = true,
    this.onPreviousTap,
    this.onNextTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Row(
        children: [
          // 左侧按钮区域
          if (showPreviousButton)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) {
                      final canGoPrevious = controller.currentIndex > 0;
                      return Opacity(
                        opacity: canGoPrevious ? 1.0 : 0.5,
                        child: _buildControlButton(
                          context,
                          icon: previousIcon ?? Icons.chevron_left,
                          onTap: canGoPrevious ? (onPreviousTap ?? () => controller.previousPage()) : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          // 中间空白区域
          if (showPreviousButton && showNextButton) const Spacer(),

          // 右侧按钮区域
          if (showNextButton)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, child) {
                      final canGoNext = controller.currentIndex < controller.totalCount - 1;
                      return Opacity(
                        opacity: canGoNext ? 1.0 : 0.5,
                        child: _buildControlButton(
                          context,
                          icon: nextIcon ?? Icons.chevron_right,
                          onTap: canGoNext ? (onNextTap ?? () => controller.nextPage()) : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.black.withOpacity(0.5),
        borderRadius: borderRadius ?? BorderRadius.circular(buttonSize / 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(buttonSize / 2),
          onTap: onTap,
          child: Icon(
            icon,
            color: buttonColor ?? Colors.white,
            size: buttonSize * 0.5,
          ),
        ),
      ),
    );
  }
}
