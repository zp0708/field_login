import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'pluggable.dart';

class SlowAnimationPlugin extends Pluggable {
  @override
  String get name => 'slow_animation';

  @override
  String get display => '慢动画';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return _SlowAnimation();
  }
}

class _SlowAnimation extends StatefulWidget {
  const _SlowAnimation();

  @override
  State<_SlowAnimation> createState() => _SlowAnimationState();
}

class _SlowAnimationState extends State<_SlowAnimation> with SingleTickerProviderStateMixin {
  double _animationFactor = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationFactor = timeDilation;

    _animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this)
      ..forward()
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.repeat();
        }
      });

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);

    WidgetsBinding.instance.addPostFrameCallback((_) => _animationController.forward());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            alignment: Alignment.center,
            turns: _animation,
            child: const FlutterLogo(
              size: 100,
            ),
          ),
          Slider(
            max: 10,
            min: 0.1,
            activeColor: Colors.blue,
            value: _animationFactor,
            onChanged: (value) {
              setState(() {
                _animationFactor = value;
              });
              timeDilation = value;
            },
          ),
          Text(
            '${(1.0 / _animationFactor).toStringAsFixed(2)} x',
            style: const TextStyle(color: Colors.blue, fontSize: 20),
          ),
          SizedBox(height: 30),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
            onPressed: () {
              setState(() {
                _animationFactor = 1;
              });
              timeDilation = 1;
            },
            icon: const Icon(Icons.rotate_left, size: 20),
            label: const Text('Reset', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
