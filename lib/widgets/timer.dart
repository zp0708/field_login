import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settlement/providers/settlement_providers.dart';
import '../style/adapt.dart';

class SettlementHeaderTime extends ConsumerWidget {
  const SettlementHeaderTime({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用当前时间 + 30分钟作为绝对过期时间来演示倒计时功能
    final expireTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (30 * 60); // 30分钟后过期
    final notifier = ref.read(settlementProvider.notifier);

    if (expireTime > 0) {
      return _SettlementTimeWight(
          expireTime: expireTime,
          onTimeOver: () {
            // 当倒计时结束时，重新加载产品数据
            notifier.refreshProducts();
          });
    }
    return const SizedBox.shrink();
  }
}

class _SettlementTimeWight extends StatefulWidget {
  final VoidCallback? onTimeOver;
  final int expireTime;
  const _SettlementTimeWight({
    super.key,
    this.expireTime = 0,
    this.onTimeOver,
  });

  @override
  State<_SettlementTimeWight> createState() => _SettlementTimeWightState();
}

class _SettlementTimeWightState extends State<_SettlementTimeWight> {
  Timer? _timer;
  bool _hasExpired = false;
  String _currentTimeText = '';

  @override
  void initState() {
    super.initState();
    if (widget.expireTime > 0) {
      _updateTimeText();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeText();

        // 检查是否过期，如果过期则触发回调
        final end = DateTime.fromMillisecondsSinceEpoch(widget.expireTime * 1000);
        final difference = end.difference(DateTime.now());

        if ((difference.isNegative || difference.inSeconds <= 0) && !_hasExpired) {
          _hasExpired = true;
          _timer?.cancel();

          // 在下一帧触发回调，避免在构建期间更新状态
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onTimeOver?.call();
          });
        }
      }
    });
  }

  void _updateTimeText() {
    final end = DateTime.fromMillisecondsSinceEpoch(widget.expireTime * 1000);
    final difference = end.difference(DateTime.now());

    if (difference.isNegative || difference.inSeconds <= 0) {
      _currentTimeText = '0秒';
    } else {
      _currentTimeText = _formatDuration(difference);
    }

    setState(() {});
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    if (minutes > 0) {
      return '$minutes分$seconds秒';
    } else {
      return '$seconds秒';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 4.dp),
      child: RichText(
        text: TextSpan(
          text: '将在',
          style: TextStyle(
            color: Color(0xFF8C8E87),
            fontSize: 10.dp,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: _currentTimeText,
              style: TextStyle(
                color: Color(0xFFF61616),
                fontSize: 14.dp,
                fontWeight: FontWeight.w400,
              ),
            ),
            TextSpan(
              text: '后取消支付',
              style: TextStyle(
                color: Color(0xFF8C8E87),
                fontSize: 14.dp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
