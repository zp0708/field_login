import 'package:field_login/widgets/floating_widgets.dart';
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
        appBar: AppBar(
          title: const Text('随机移动子组件示例'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('返回'),
            ),
          ],
        ),
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
            child: FloatingWidgets(
              estimatedChildSize: const Size(60, 30), // 👈 提供大致尺寸
              speed: 30,
              collisionCheckIntervalMs: 200,
              curve: Curves.easeOut,
              children: [
                _buildLable('指甲比较软'),
                _buildLable('下单 5 次'),
                _buildLable('粉色爱好者'),
                _buildImage('assets/image_robot_fault.png', Size(40, 40)),
                _buildLable('时间观念比较强'),
                _buildLable('指甲比较软'),
                _buildLable('下单 5 次'),
                _buildImage('assets/image_robot_big.png', Size(80, 80)),
                _buildLable('粉色爱好者'),
                _buildLable('偏爱猫眼'),
                _buildImage('assets/image_robot_normal.png', Size(40, 40)),
                _buildLable('时间观念比较强'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String assets, Size size) {
    return Image.asset(
      assets,
      width: size.width,
      height: size.height,
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
