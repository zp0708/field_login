import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settlement/providers/settlement_providers.dart';
import 'settlement/providers/timer_provider.dart';
import '../style/adapt.dart';

/// Approach 2: Provider-based timer with better separation of concerns
class SettlementHeaderTimeV2 extends ConsumerWidget {
  final int? customExpireSeconds; // 允许自定义过期时间

  const SettlementHeaderTimeV2({
    super.key,
    this.customExpireSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用自定义时间或默认30分钟
    final expireSeconds = customExpireSeconds ?? (30 * 60);

    // 创建定时器提供者，并设置过期回调
    final timerProvider = timerProviderFamily((
      seconds: expireSeconds,
      onExpired: () {
        // 在这里刷新settlement provider
        ref.read(settlementProvider.notifier).refreshProducts();
      },
    ));

    final timerState = ref.watch(timerProvider);

    if (timerState.hasExpired) {
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
              text: timerState.formattedTime,
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

/// Approach 3: Hook-based timer (requires flutter_hooks)
/// 如果你想使用flutter_hooks的话，这是一个更简洁的方案
/*
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettlementHeaderTimeV3 extends HookConsumerWidget {
  final int? customExpireSeconds;
  
  const SettlementHeaderTimeV3({
    super.key,
    this.customExpireSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expireSeconds = customExpireSeconds ?? (30 * 60);
    final remainingSeconds = useState(expireSeconds);
    
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingSeconds.value <= 0) {
          timer.cancel();
          // 刷新provider
          ref.read(settlementProvider.notifier).refreshProducts();
          return;
        }
        remainingSeconds.value--;
      });
      
      return timer.cancel;
    }, []);
    
    if (remainingSeconds.value <= 0) {
      return const SizedBox.shrink();
    }
    
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    final timeText = minutes > 0 ? '$minutes分$seconds秒' : '$seconds秒';
    
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
              text: timeText,
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
*/
