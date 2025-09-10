import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settlement/providers/settlement_providers.dart';
import '../style/adapt.dart';

/// Approach 4: Stream-based timer - 最优雅的解决方案
class SettlementHeaderTimeV3 extends ConsumerWidget {
  final int? customExpireSeconds;

  const SettlementHeaderTimeV3({
    super.key,
    this.customExpireSeconds,
  });

  /// 创建倒计时流
  Stream<int> _createCountdownStream(int initialSeconds) async* {
    for (int i = initialSeconds; i >= 0; i--) {
      yield i;
      if (i > 0) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0秒';

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return minutes > 0 ? '$minutes分$seconds秒' : '$seconds秒';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expireSeconds = customExpireSeconds ?? (30 * 60);

    return StreamBuilder<int>(
      stream: _createCountdownStream(expireSeconds),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final remainingSeconds = snapshot.data!;

        // 当倒计时结束时刷新provider
        if (remainingSeconds <= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(settlementProvider.notifier).refreshProducts();
          });
          return const SizedBox.shrink();
        }

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
                  text: _formatTime(remainingSeconds),
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
      },
    );
  }
}

/// Approach 5: 使用 Riverpod 的 StreamProvider
final countdownStreamProvider = StreamProvider.family<int, int>((ref, initialSeconds) {
  return Stream.periodic(const Duration(seconds: 1), (count) {
    final remaining = initialSeconds - count;
    if (remaining <= 0) {
      // 当倒计时结束时触发刷新
      Future.microtask(() {
        ref.read(settlementProvider.notifier).refreshProducts();
      });
    }
    return remaining;
  }).takeWhile((remaining) => remaining >= 0);
});

class SettlementHeaderTimeV4 extends ConsumerWidget {
  final int? customExpireSeconds;

  const SettlementHeaderTimeV4({
    super.key,
    this.customExpireSeconds,
  });

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return '0秒';

    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return minutes > 0 ? '$minutes分$seconds秒' : '$seconds秒';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expireSeconds = customExpireSeconds ?? (30 * 60);
    final countdownAsync = ref.watch(countdownStreamProvider(expireSeconds));

    return countdownAsync.when(
      data: (remainingSeconds) {
        if (remainingSeconds <= 0) {
          return const SizedBox.shrink();
        }

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
                  text: _formatTime(remainingSeconds),
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
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
