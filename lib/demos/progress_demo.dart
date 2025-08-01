import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/progress_dialog/progress_dialog.dart';
import '../widgets/progress_dialog/progress_controller.dart';
import '../style/adapt.dart';

class ProgressDemo extends StatefulWidget {
  const ProgressDemo({super.key});

  @override
  State<ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<ProgressDemo> {
  final ProgressController _controller = ProgressController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('进度对话框演示'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ProgressDialog 通用进度对话框',
              style: TextStyle(
                fontSize: 24.dp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.dp),

            // 基础用法
            ElevatedButton(
              onPressed: () => _showBasicDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('基础用法（无进度条）'),
            ),
            SizedBox(height: 16.dp),

            // 外部控制进度
            ElevatedButton(
              onPressed: () => _showControlledProgressDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('外部控制进度'),
            ),
            SizedBox(height: 16.dp),

            // 模拟文件上传
            ElevatedButton(
              onPressed: () => _showFileUploadDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('模拟文件上传'),
            ),
            SizedBox(height: 16.dp),

            // 错误处理演示
            ElevatedButton(
              onPressed: () => _showErrorHandlingDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('错误处理演示'),
            ),
            SizedBox(height: 16.dp),

            // 模拟数据处理
            ElevatedButton(
              onPressed: () => _showDataProcessingDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('模拟数据处理'),
            ),
            SizedBox(height: 16.dp),

            // 自定义文本和图标
            ElevatedButton(
              onPressed: () => _showCustomDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(16.dp),
              ),
              child: const Text('自定义文本和图标'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBasicDialog() async {
    // 显示对话框（不显示进度条）
    ProgressDialog.show(
      context,
      showProgress: false,
    );

    // 显示2秒后关闭
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop();
    }

    _showSnackBar('基础操作完成');
  }

  void _showControlledProgressDialog() async {
    // 显示对话框
    _showDialog(showProgress: true);
    _controller.reset();

    // 模拟外部控制进度
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.updateProgress(i / 10);
    }

    // 完成
    _controller.finish();

    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.of(context).pop();
    }
    _showSnackBar('外部控制进度完成');
  }

  void _showFileUploadDialog() async {
    _showDialog(showProgress: true);
    _controller.reset();

    // 模拟文件上传过程
    final steps = [
      {'name': '准备上传', 'duration': 300},
      {'name': '上传中', 'duration': 1500},
      {'name': '验证文件', 'duration': 800},
      {'name': '处理完成', 'duration': 400},
    ];

    final stepProgress = 1.0 / steps.length;

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final startProgress = i * stepProgress;

      // 模拟步骤内的进度
      for (int j = 0; j <= 10; j++) {
        await Future.delayed(Duration(milliseconds: (step['duration'] as int) ~/ 10));
        final currentStepProgress = j / 10;
        final totalCurrentProgress = startProgress + (currentStepProgress * stepProgress);
        _controller.updateProgress(totalCurrentProgress);
      }
    }

    _controller.finish();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
    _showSnackBar('文件上传完成');
  }

  void _showErrorHandlingDialog() async {
    _showDialog(showProgress: true);
    _controller.reset();

    // 模拟正常进度
    for (int i = 0; i <= 5; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controller.updateProgress(i / 5);
    }

    // 模拟错误
    _controller.setError('操作过程中发生错误：网络连接失败');

    await Future.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
    _showSnackBar('错误处理演示完成', isError: true);
  }

  void _showDataProcessingDialog() async {
    _showDialog(showProgress: true);
    _controller.reset();

    // 第一步：数据验证
    _controller.updateProgress(0.0);
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      _controller.updateProgress(i / 10 * 0.3);
    }

    // 第二步：数据处理
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _controller.updateProgress(0.3 + (i / 10 * 0.4));
    }

    // 第三步：保存结果
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _controller.updateProgress(0.7 + (i / 10 * 0.3));
    }

    _controller.finish();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
    _showSnackBar('数据处理完成');
  }

  void _showCustomDialog() async {
    // 显示对话框
    _showDialog(showProgress: true);
    _controller.reset();

    // 模拟自定义操作进度
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      _controller.updateProgress(i / 10);
    }

    // 完成操作
    _controller.finish();

    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pop();
    _showSnackBar('自定义对话框完成');
  }

  void _showDialog({bool showProgress = false}) {
    ProgressDialog.show(
      context,
      statusStream: _controller.statusStream,
      showProgress: showProgress,
      onFinish: () => Navigator.of(context).pop(),
      onError: () => Navigator.of(context).pop(),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
