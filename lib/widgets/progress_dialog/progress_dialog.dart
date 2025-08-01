import 'dart:async';
import 'package:flutter/material.dart';
import '../../style/adapt.dart';

enum ProgressStatus {
  loading,
  finished,
  error,
}

class ProgressDialog extends StatefulWidget {
  final VoidCallback? onFinish;
  final VoidCallback? onError;
  final Widget? loadingIcon;
  final Widget? finishedIcon;
  final Widget? errorIcon;
  final bool showProgress;
  final Stream<Map<String, dynamic>>? statusStream;

  const ProgressDialog({
    super.key,
    this.onFinish,
    this.onError,
    this.loadingIcon,
    this.finishedIcon,
    this.errorIcon,
    this.showProgress = false,
    this.statusStream,
  });

  static Future<void> show(
    BuildContext context, {
    Stream<Map<String, dynamic>>? statusStream,
    bool showProgress = false,
    Widget? loadingIcon,
    Widget? finishedIcon,
    Widget? errorIcon,
    VoidCallback? onFinish,
    VoidCallback? onError,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ProgressDialog(
          statusStream: statusStream,
          showProgress: showProgress,
          loadingIcon: loadingIcon,
          finishedIcon: finishedIcon,
          errorIcon: errorIcon,
          onFinish: () {
            Navigator.of(context).pop();
            onFinish?.call();
          },
          onError: () {
            Navigator.of(context).pop();
            onError?.call();
          },
        ),
      ),
    );
  }

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ProgressStatus _status = ProgressStatus.loading;
  double _progress = 0.0;
  String? _errorMessage;
  StreamSubscription? _statusSubscription;

  @override
  void initState() {
    super.initState();

    // 初始化旋转动画控制器
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // 开始旋转动画
    _controller.repeat();

    // 监听状态流
    if (widget.statusStream != null) {
      _statusSubscription = widget.statusStream!.listen((data) {
        setState(() {
          _status = data['status'] ?? ProgressStatus.loading;
          _progress = data['progress'] ?? 0.0;
          _errorMessage = data['errorMessage'];
        });

        // 根据状态控制动画
        if (_status == ProgressStatus.loading) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _statusSubscription?.cancel();
    super.dispose();
  }

  String _getBottomText() {
    switch (_status) {
      case ProgressStatus.loading:
        return '处理中...';
      case ProgressStatus.finished:
        return '完成';
      case ProgressStatus.error:
        return _errorMessage ?? '失败';
    }
  }

  Widget _getIcon() {
    switch (_status) {
      case ProgressStatus.loading:
        return widget.loadingIcon ??
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                'assets/loading-big.png',
                width: 48.dp,
                height: 48.dp,
              ),
            );
      case ProgressStatus.finished:
        return widget.finishedIcon ??
            Image.asset(
              'assets/finish-big.png',
              width: 48.dp,
              height: 48.dp,
            );
      case ProgressStatus.error:
        return widget.errorIcon ??
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48.dp,
            );
    }
  }

  Color _getStatusColor() {
    switch (_status) {
      case ProgressStatus.loading:
        return Colors.blue;
      case ProgressStatus.finished:
        return Colors.green;
      case ProgressStatus.error:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          width: 148.dp,
          padding: EdgeInsets.all(20.dp),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12.dp),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.dp),
              _getIcon(),
              SizedBox(height: 22.dp),

              // 进度条
              if (widget.showProgress && _status == ProgressStatus.loading) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[600],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                ),
                SizedBox(height: 8.dp),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.dp,
                  ),
                ),
                SizedBox(height: 8.dp),
              ],

              Text(
                _getBottomText(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.dp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
