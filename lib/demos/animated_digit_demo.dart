import 'package:field_login/widgets/animated_digit.dart/animated_digit_widget.dart';
import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:flutter/material.dart';

class AnimatedDigitDemo extends StatefulWidget {
  const AnimatedDigitDemo({super.key});

  @override
  State<AnimatedDigitDemo> createState() => _AnimatedDigitDemoState();
}

class _AnimatedDigitDemoState extends State<AnimatedDigitDemo> {
  double _value = 198.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedDigit Demo'),
        actions: [
          IconButton(
            onPressed: () => FlutterAux.show(context),
            icon: Icon(Icons.auto_fix_high),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: AnimatedDigitWidget(
          value: _value,
          prefix: '¥',
          fractionDigits: 2,
          loop: false,
          valueColors: [
            ValueColor(condition: () => _value > 100, color: Colors.yellow),
            ValueColor(condition: () => _value > 200, color: Colors.blue),
            ValueColor(condition: () => _value > 500, color: Colors.pink),
            ValueColor(condition: () => _value > 1000, color: Colors.red),
          ],
          textStyle: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // height: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () => setState(() {
          _value += 15.13;
        }),
      ),
    );
  }
}
