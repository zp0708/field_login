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
        appBar: AppBar(title: const Text('随机移动子组件示例')),
        body: Center(
          child: SizedBox(
            width: 320,
            height: 520,
            child: RandomMovingChildren(
              // 示例：5个彩色圆
              childrenBuilders: [
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
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
