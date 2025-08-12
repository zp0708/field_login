import 'dart:ui';

import 'package:field_login/widgets/progress_timeline/widgets/shape_background_clipper.dart';
import 'package:field_login/widgets/progress_timeline/widgets/stage_item.dart';
import 'package:flutter/material.dart';

class ProgressOptionsWidget extends StatefulWidget {
  final List<ProgressStageOption> options;
  final ValueChanged<ProgressStageOption>? onOptionSelected;

  const ProgressOptionsWidget({
    super.key,
    required this.options,
    this.onOptionSelected,
  });

  @override
  State<ProgressOptionsWidget> createState() => _ShapeBackgroundButtonsState();
}

class _ShapeBackgroundButtonsState extends State<ProgressOptionsWidget> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShareBackgroundClipper(arrowWidth: 30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 174,
          alignment: Alignment.topCenter,
          height: 100,
          padding: EdgeInsets.all(10),
          color: Colors.white.withValues(alpha: 0.7),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                widget.options.length,
                (index) {
                  final option = widget.options[index];
                  return ProgressOptionWidget(
                    title: option.title,
                    icon: option.image,
                    highlight: index == _selectedIndex,
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                      widget.onOptionSelected?.call(option);
                    },
                  );
                },
              )),
        ),
      ),
    );
  }
}

class ProgressOptionWidget extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool highlight;

  const ProgressOptionWidget({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: highlight ? Color(0xFFB9E702) : null,
          border: highlight ? null : Border.all(color: Colors.black, width: 1),
        ),
        width: 72,
        height: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              icon,
              width: 36,
              height: 36,
            ),
            SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
