import 'package:field_login/widgets/animated_digit.dart/animated_flip_counter.dart';
import 'package:field_login/widgets/flutter_aux/flutter_aux.dart';
import 'package:flutter/material.dart';

class AnimatedDigitDemo extends StatefulWidget {
  const AnimatedDigitDemo({super.key});

  @override
  State<AnimatedDigitDemo> createState() => _AnimatedDigitDemoState();
}

class _AnimatedDigitDemoState extends State<AnimatedDigitDemo> {
  double _value = 18.12;

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
        child: AnimatedFlipCounter(
          value: _value,
          textStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
          // smallStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          fractionDigits: 2,
          duration: Duration(seconds: 1),
          prefix: '¥',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('+'),
        onPressed: () => setState(() {
          _value += 13.12;
        }),
      ),
    );
  }
}
