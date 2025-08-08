import 'dart:ui';

import 'package:field_login/style/adapt.dart';
import 'package:flutter/material.dart';

const double _arrowWidth = 28;

class LeftToolsBar extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>>? onItemTap;

  const LeftToolsBar({
    super.key,
    required this.leftToolbarItems,
    this.onItemTap,
  });

  final List<Map<String, dynamic>> leftToolbarItems;

  @override
  State<LeftToolsBar> createState() => _LeftToolsBarState();
}

class _LeftToolsBarState extends State<LeftToolsBar> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      left: isExpanded ? 0 : -(204 - _arrowWidth - 20),
      top: 50,
      bottom: 50,
      width: 204,
      child: Row(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.dp, sigmaY: 20.dp),
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  // border: Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: widget.leftToolbarItems.length,
                          itemBuilder: (context, index) {
                            final item = widget.leftToolbarItems[index];
                            final bool selected = item['selected'] == true;
                            final Color baseColor = item['color'] as Color;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  for (var i = 0; i < widget.leftToolbarItems.length; i++) {
                                    widget.leftToolbarItems[i]['selected'] = i == index;
                                  }
                                });
                                widget.onItemTap?.call(item);
                              },
                              child: Container(
                                height: 120,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: selected ? Border.all(color: Colors.greenAccent.shade400, width: 2) : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [baseColor.withOpacity(0.85), baseColor.withOpacity(0.55)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.85),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.brush, size: 16, color: baseColor.darken()),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.55)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item['name'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                              if (selected)
                                                const Icon(Icons.check_circle,
                                                    color: Colors.lightGreenAccent, size: 16),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: SizedBox(
                        width: _arrowWidth,
                        height: 80.dp,
                        child: AnimatedRotation(
                          duration: const Duration(milliseconds: 350),
                          turns: isExpanded ? 0 : 0.5,
                          child: Icon(
                            Icons.chevron_left,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _ColorDarken on Color {
  Color darken([double amount = .2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

// 自定义裁剪器 - 波浪形
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    final radius1 = 20.dp;
    final radius2 = 6.dp;

    // 右箭头部分宽度
    final arrowWidth = _arrowWidth.dp;
    final arrowHeight = 80.dp;
    final centerY = size.height * 0.5;

    // 起点左上角
    path.moveTo(0, 0);
    path.lineTo(size.width - arrowWidth - radius1, 0);

    path.quadraticBezierTo(size.width - arrowWidth, 0, size.width - arrowWidth, radius1);
    path.lineTo(size.width - arrowWidth, centerY - arrowHeight * 0.5);
    path.lineTo(size.width - radius2, centerY - arrowHeight * 0.5);

    path.quadraticBezierTo(size.width, centerY - arrowHeight * 0.5, size.width, centerY - arrowHeight * 0.5 + radius2);

    path.lineTo(size.width, centerY + arrowHeight * 0.5 - radius2);

    path.quadraticBezierTo(size.width, centerY + arrowHeight * 0.5, size.width - radius2, centerY + arrowHeight * 0.5);

    path.lineTo(size.width - arrowWidth, centerY + arrowHeight * 0.5);

    path.lineTo(size.width - arrowWidth, size.height - radius1);

    path.quadraticBezierTo(size.width - arrowWidth, size.height, size.width - arrowWidth - radius1, size.height);

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
