import 'package:field_login/widgets/floating_widgets/floating_widgets.dart';
import 'package:field_login/widgets/floating_widgets/floating_widgets_aware.dart';
import 'package:field_login/widgets/floating_widgets/floating_widgets_controller.dart';
import 'package:flutter/material.dart';

class RandomMovingDemo extends StatefulWidget {
  const RandomMovingDemo({super.key});

  @override
  State<RandomMovingDemo> createState() => _RandomMovingDemoState();
}

class _RandomMovingDemoState extends State<RandomMovingDemo> {
  late FloatingWidgetsController _controller;
  final RouteObserver<PageRoute<dynamic>> _routeObserver = RouteObserver<PageRoute<dynamic>>();

  @override
  void initState() {
    super.initState();
    _controller = FloatingWidgetsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('随机移动子组件示例'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('返回'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 控制按钮区域
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return ElevatedButton(
                      onPressed: () => _controller.toggle(),
                      child: Text(_controller.isAnimating ? '暂停动画' : '播放动画'),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () => _navigateToTestPage(),
                  child: const Text('跳转到测试页面'),
                ),
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    return Switch(
                      value: _controller.autoPauseEnabled,
                      onChanged: (value) => _controller.setAutoPauseEnabled(value),
                    );
                  },
                ),
                const Text('自动暂停'),
              ],
            ),
          ),
          // 动画状态显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return Text(
                  '动画状态: ${_controller.isAnimating ? "播放中" : "已暂停"} | '
                  '自动暂停: ${_controller.autoPauseEnabled ? "开启" : "关闭"}',
                  style: const TextStyle(fontSize: 14),
                );
              },
            ),
          ),
          // 浮动组件区域
          Expanded(
            child: Center(
              child: FloatingWidgetsAware(
                controller: _controller,
                // routeObserver: _routeObserver,
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Color.fromARGB(255, 230, 230, 230),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: FloatingWidgets(
                    controller: _controller,
                    estimatedChildSize: const Size(60, 30),
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
          ),
        ],
      ),
    );
  }

  void _navigateToTestPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const _TestPage(),
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

// 测试页面，用于测试路由感知功能
class _TestPage extends StatelessWidget {
  const _TestPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('路由测试页面'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_back,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              '这是测试页面',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '当你 push 到这个页面时，原页面的动画应该自动暂停；\n'
                '当你 pop 回去时，动画应该自动恢复。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('返回上一页'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
