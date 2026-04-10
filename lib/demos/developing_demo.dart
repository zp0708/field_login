import 'package:field_login/widgets/bottom_arc_widget.dart';
import 'package:flutter/material.dart';

class DevelopingDemo extends StatefulWidget {
  const DevelopingDemo({super.key});

  @override
  State<DevelopingDemo> createState() => _DevelopingDemoState();
}

class _DevelopingDemoState extends State<DevelopingDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          width: 800,
          height: 400,
          child: IrregularGradientCard(),
        ),
      ),
    );
  }
}
