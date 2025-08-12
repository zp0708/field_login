import 'dart:ui';

import 'package:field_login/widgets/progress_timeline/widgets/shape_background_clipper.dart';
import 'package:flutter/material.dart';

class ShapeBackgroundButtons extends StatelessWidget {
  const ShapeBackgroundButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ShareBackgroundClipper(arrowWidth: 60),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 174,
          height: 100,
          color: Colors.white.withValues(alpha: 0.7),
          child: Text('data'),
        ),
      ),
    );
  }
}
