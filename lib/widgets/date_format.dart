/// 服务状态枚举
enum ServiceStatus {
  waiting, // 待服务
  inProgress, // 服务中
  completed, // 服务完成
  cancelled, // 服务取消
}

/// 服务时间提醒日期格式化工具类
/// 根据不同的服务状态和时间差异，返回相应的格式化字符串
class ServiceTimeFormatter {
  /// 格式化服务时间显示
  ///
  /// [serviceStatus] 服务状态
  /// [planStartTime] 服务预约开始时间
  /// [planEndTime] 实际服务开始时间
  /// [startTime] 实际服务开始时间
  /// [endTime] 实际服务结束时间
  /// [currentTime] 当前时间（可选，默认为DateTime.now()）
  static String formatServiceTime({
    required ServiceStatus serviceStatus,
    required DateTime? startTime,
    required DateTime? endTime,
    required DateTime planStartTime,
    required DateTime planEndTime,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final duration = planEndTime.difference(planStartTime);
    switch (serviceStatus) {
      case ServiceStatus.waiting:
        return _formatWaitingService(now, planStartTime);
      case ServiceStatus.inProgress:
        return _formatInProgressService(
          now,
          planStartTime,
          startTime!,
          duration,
        );
      case ServiceStatus.completed:
        return _formatCompletedService(
          startTime!,
          endTime!,
        );
      case ServiceStatus.cancelled:
        return '无服务时间提醒';
    }
  }

  /// 格式化待服务状态的时间显示
  static String _formatWaitingService(DateTime currentTime, DateTime serviceStartTime) {
    final difference = serviceStartTime.difference(currentTime);

    if (difference.isNegative) {
      // 超过服务开始时间
      final overdueDifference = currentTime.difference(serviceStartTime);
      final overdueText = _formatTimeDifference(overdueDifference);
      return '已推迟$overdueText';
    } else {
      // 服务开始时间未到
      final remainingText = _formatTimeDifference(difference);
      return '$remainingText后';
    }
  }

  /// 格式化服务中状态的时间显示
  static String _formatInProgressService(
    DateTime currentTime,
    DateTime planStartTime,
    DateTime startTime,
    Duration? duration,
  ) {
    final serviceDiff = currentTime.difference(startTime);
    final serviceDiffText = _formatTimeDifference(serviceDiff);

    // 在服务结束时间内
    if (duration != null) {
      final expectedEndTime = startTime.add(duration);
      if (currentTime.isBefore(expectedEndTime)) {
        final remaining = expectedEndTime.difference(currentTime);
        final remainingText = _formatMinutesDifference(remaining);
        return '剩余$remainingText';
      } else {
        // 超出服务结束时间
        final overtime = currentTime.difference(expectedEndTime);
        final overtimeText = _formatMinutesDifference(overtime);
        return '已超时$overtimeText';
      }
    }

    return '已服务$serviceDiffText';
  }

  /// 格式化服务完成状态的时间显示
  static String _formatCompletedService(DateTime actualStartTime, DateTime actualEndTime) {
    final totalDuration = actualEndTime.difference(actualStartTime);
    final durationText = _formatMinutesDifference(totalDuration);
    return '共服务$durationText';
  }

  /// 格式化时间差异为文本
  static String _formatTimeDifference(Duration duration) {
    final absDuration = Duration(
      days: duration.inDays.abs(),
      hours: duration.inHours.abs() % 24,
      minutes: duration.inMinutes.abs() % 60,
    );

    if (absDuration.inDays > 0) {
      // 24小时以上，单位为天（最高到999天）
      final days = absDuration.inDays > 999 ? 999 : absDuration.inDays;
      return '$days天';
    } else if (absDuration.inHours > 0) {
      // 60分钟及以上，单位为小时
      return '${absDuration.inHours}小时';
    } else {
      // 60分钟以内，单位为分钟
      final minutes = absDuration.inMinutes > 999 ? 999 : absDuration.inMinutes;
      return '$minutes分钟';
    }
  }

  static String _formatMinutesDifference(Duration duration) {
    // 60分钟以内，单位为分钟
    final minutes = duration.inMinutes > 999 ? 999 : duration.inMinutes;
    return '$minutes分钟';
  }
}
