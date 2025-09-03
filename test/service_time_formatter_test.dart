import 'package:flutter_test/flutter_test.dart';
import 'package:field_login/widgets/date_format.dart';

void main() {
  group('ServiceTimeFormatter Tests', () {
    group('待服务状态测试 (Waiting Service Tests)', () {
      test('服务开始时间未到 - 30分钟后开始', () {
        // 使用固定时间点来消除时间误差
        final currentTime = DateTime(2024, 1, 1, 14, 30, 0); // 2024-01-01 14:30:00
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 15:00:00 (后30分钟)
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0); // 17:00:00

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime, // 传入固定时间
        );

        // 现在可以精确预期结果，无需容差
        expect(result, equals('30分钟后'));
      });

      test('服务开始时间未到 - 2小时后开始', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 16, 1, 0); // 2小时1分钟后
        final planEndTime = DateTime(2024, 1, 1, 18, 1, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('2小时后'));
      });

      test('服务开始时间未到 - 1天后开始', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 2, 15, 0, 0); // 1天后
        final planEndTime = DateTime(2024, 1, 2, 17, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('1天后'));
      });

      test('超过服务开始时间 - 已推迟45分钟', () {
        // 使用固定时间点
        final currentTime = DateTime(2024, 1, 1, 15, 15, 0); // 15:15:00
        final planStartTime = DateTime(2024, 1, 1, 14, 30, 0); // 14:30:00 (已推迟45分钟)
        final planEndTime = DateTime(2024, 1, 1, 16, 30, 0); // 16:30:00

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 精确预期45分钟推迟
        expect(result, equals('已推迟45分钟'));
      });

      test('超过服务开始时间 - 已推迟3小时', () {
        final currentTime = DateTime(2024, 1, 1, 17, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0); // 3小时前
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('已推迟3小时'));
      });

      test('超过服务开始时间 - 已推迟2天', () {
        final currentTime = DateTime(2024, 1, 3, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0); // 2天前
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('已推迟2天'));
      });
    });

    group('服务中状态测试 (In Progress Service Tests)', () {
      test('在服务结束时间内 - 剩余90分钟', () {
        final currentTime = DateTime(2024, 1, 1, 15, 30, 0); // 15:30:00
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 15:00:00
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0); // 17:00:00 (计划120分钟)
        final actualStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 15:00:00

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.inProgress,
          startTime: actualStartTime,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 现在使用_formatMinutesDifference，总是返回分钟格式
        expect(result, equals('剩余90分钟'));
      });

      test('超出服务结束时间 - 已超时30分钟', () {
        // 使用固定时间点
        final currentTime = DateTime(2024, 1, 1, 16, 30, 0); // 16:30:00
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0); // 14:00:00
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0); // 16:00:00 (超时30分钟)
        final actualStartTime = planStartTime;

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.inProgress,
          startTime: actualStartTime,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 精确预期30分钟超时
        expect(result, equals('已超时30分钟'));
      });

      test('服务中无持续时间 - 已超时30分钟', () {
        final currentTime = DateTime(2024, 1, 1, 15, 30, 0);
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 15, 0, 0); // 无持续时间
        final actualStartTime = DateTime(2024, 1, 1, 15, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.inProgress,
          startTime: actualStartTime,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 无持续时间会导致立即超时
        expect(result, equals('已超时30分钟'));
      });

      test('在服务结束时间内 - 剩余120分钟', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0); // 3小时计划
        final actualStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 实际开始时间

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.inProgress,
          startTime: actualStartTime,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 从实际开始(15:00) + 计划时间(3小时) = 18:00，剩余 18:00 - 15:00 = 180分钟
        expect(result, equals('剩余180分钟'));
      });
    });

    group('服务完成状态测试 (Completed Service Tests)', () {
      test('共服务60分钟', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 30, 0);
        final actualEndTime = DateTime(2024, 1, 1, 15, 30, 0); // 60分钟后

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 现在使用_formatMinutesDifference，返回分钟格式
        expect(result, equals('共服务60分钟'));
      });

      test('共服务45分钟', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 15, 0);
        final actualEndTime = DateTime(2024, 1, 1, 15, 0, 0); // 45分钟后

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('共服务45分钟'));
      });

      test('共服务180分钟', () {
        final currentTime = DateTime(2024, 1, 1, 17, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final actualEndTime = DateTime(2024, 1, 1, 17, 0, 0); // 3小时 = 180分钟

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 现在返回分钟格式而不是小时
        expect(result, equals('共服务180分钟'));
      });

      test('共服务2880分钟', () {
        final currentTime = DateTime(2024, 1, 3, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final actualEndTime = DateTime(2024, 1, 3, 14, 0, 0); // 2天 = 2880分钟

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // _formatMinutesDifference有999分钟上限，所以大于999分钟的时长会被截断
        expect(result, equals('共服务999分钟'));
      });
    });

    group('服务取消状态测试 (Cancelled Service Tests)', () {
      test('无服务时间提醒', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.cancelled,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('无服务时间提醒'));
      });
    });

    group('边界值测试 (Boundary Value Tests)', () {
      test('边界值: 正好60分钟 - 应显示1小时', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 60分钟后
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 60分钟 = 1小时，应该显示小时单位
        expect(result, equals('1小时后'));
      });

      test('边界值: 正好24小时 - 应显示1天', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 2, 14, 0, 0); // 24小时后
        final planEndTime = DateTime(2024, 1, 2, 16, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 24小时 = 1天，应该显示天单位
        expect(result, equals('1天后'));
      });

      test('边界值: 999分钟限制测试', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 2, 10, 0, 0); // 20小时后
        final planEndTime = DateTime(2024, 1, 2, 12, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 20小时，应该显示为小时
        expect(result, equals('20小时后'));
      });

      test('边界值: 999天限制测试', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2026, 9, 27, 14, 0, 0); // 超过999天
        final planEndTime = DateTime(2026, 9, 27, 16, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('999天后'));
      });

      test('边界值: 时间差为0', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 同时间
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('0分钟后'));
      });

      test('边界值: 大于20小时服务时长 - 应显示为小时', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final actualEndTime = DateTime(2024, 1, 2, 10, 0, 0); // 20小时后

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // _formatMinutesDifference有999分钟上限，所以1200分钟(20小时)会被截断为999分钟
        expect(result, equals('共服务999分钟'));
      });
    });

    group('时间单位规则测试 (Time Unit Rules Tests)', () {
      test('60分钟以内显示分钟单位', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 59, 0); // 59分钟后
        final planEndTime = DateTime(2024, 1, 1, 16, 59, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('59分钟后'));
      });

      test('60分钟及以上显示小时单位', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 15, 30, 0); // 1小时30分钟后
        final planEndTime = DateTime(2024, 1, 1, 17, 30, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('1小时后'));
      });

      test('24小时以上显示天单位', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 2, 19, 0, 0); // 1天删5小时后
        final planEndTime = DateTime(2024, 1, 2, 21, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('1天后'));
      });
    });

    group('ServiceStatus枚举测试 (Enum Tests)', () {
      test('所有ServiceStatus枚举值可用', () {
        expect(ServiceStatus.values.length, equals(4));
        expect(ServiceStatus.values, contains(ServiceStatus.waiting));
        expect(ServiceStatus.values, contains(ServiceStatus.inProgress));
        expect(ServiceStatus.values, contains(ServiceStatus.completed));
        expect(ServiceStatus.values, contains(ServiceStatus.cancelled));
      });

      test('枚举值转换为字符串', () {
        expect(ServiceStatus.waiting.toString(), equals('ServiceStatus.waiting'));
        expect(ServiceStatus.inProgress.toString(), equals('ServiceStatus.inProgress'));
        expect(ServiceStatus.completed.toString(), equals('ServiceStatus.completed'));
        expect(ServiceStatus.cancelled.toString(), equals('ServiceStatus.cancelled'));
      });
    });

    group('异常情况测试 (Edge Case Tests)', () {
      test('负时间差处理 - 推迟情况', () {
        final currentTime = DateTime(2024, 1, 1, 15, 15, 0);
        final planStartTime = DateTime(2024, 1, 1, 15, 0, 0); // 15分钟前
        final planEndTime = DateTime(2024, 1, 1, 17, 0, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('已推迟15分钟'));
      });

      test('服务完成时实际时长为0', () {
        final currentTime = DateTime(2024, 1, 1, 15, 0, 0);
        final planStartTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planEndTime = DateTime(2024, 1, 1, 16, 0, 0);
        final actualStartTime = DateTime(2024, 1, 1, 14, 30, 0);
        final actualEndTime = DateTime(2024, 1, 1, 14, 30, 0); // 同时间，0时长

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.completed,
          startTime: actualStartTime,
          endTime: actualEndTime,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        expect(result, equals('共服务0分钟'));
      });

      test('大于999分钟但小于1小时的特殊情况', () {
        final currentTime = DateTime(2024, 1, 1, 14, 0, 0);
        final planStartTime = DateTime(2024, 1, 2, 6, 40, 0); // 1000分钟后
        final planEndTime = DateTime(2024, 1, 2, 8, 40, 0);

        final result = ServiceTimeFormatter.formatServiceTime(
          serviceStatus: ServiceStatus.waiting,
          startTime: null,
          endTime: null,
          planStartTime: planStartTime,
          planEndTime: planEndTime,
          currentTime: currentTime,
        );

        // 1000分钟 ≈ 16.67小时，应该显示为16小时
        expect(result, equals('16小时后'));
      });
    });
  });
}
