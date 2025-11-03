import 'package:field_login/widgets/random_moving_widget.dart';
import 'package:flutter/material.dart';

class RandomMovingDemo extends StatefulWidget {
  const RandomMovingDemo({super.key});

  @override
  State<RandomMovingDemo> createState() => _RandomMovingDemoState();
}

class _RandomMovingDemoState extends State<RandomMovingDemo> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Moving Children Demo',
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('随机移动子组件示例')),
        body: Center(
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
                gradient: RadialGradient(
              colors: [
                Color.fromARGB(255, 230, 230, 230),
                Colors.white,
              ],
            )),
            child: RandomMovingChildren(
              estimatedChildSize: const Size(60, 30), // 👈 提供大致尺寸
              speed: 30,
              collisionCheckIntervalMs: 1000,
              // 示例：5个彩色圆
              children: [
                _buildLable('指甲比较软'),
                _buildLable('下单 5 次'),
                _buildLable('粉色爱好者'),
                _buildLable('偏爱猫眼'),
                _buildLable('时间观念比较强'),
                _buildLable('指甲比较软'),
                _buildLable('下单 5 次'),
                _buildLable('粉色爱好者'),
                _buildLable('偏爱猫眼'),
                _buildLable('时间观念比较强'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLable(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }
}
