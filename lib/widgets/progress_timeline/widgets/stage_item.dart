/// 进度状态枚举
enum ProgressStatus {
  waiting, // 等待
  inProgress, // 进行中
  completed, // 完成
}

class ProgressStageOption {
  final String title;
  final String image;

  const ProgressStageOption({
    required this.title,
    required this.image,
  });
}

/// 进度阶段模型
class ProgressStage {
  final String id;
  final String title;
  final String doingImage;
  final String doneImage;
  final String undoImage;
  final ProgressStatus status;
  final String? timestamp;
  final List<ProgressStageOption>? options; // 用于存储选项，如"人工美甲"、"智能美甲"

  const ProgressStage({
    required this.id,
    required this.title,
    required this.doingImage,
    required this.doneImage,
    required this.undoImage,
    this.status = ProgressStatus.waiting,
    this.timestamp,
    this.options,
  });

  /// 复制并修改状态
  ProgressStage copyWith({
    String? id,
    String? title,
    String? icon,
    ProgressStatus? status,
    String? timestamp,
    List<ProgressStageOption>? options,
  }) {
    return ProgressStage(
      id: id ?? this.id,
      title: title ?? this.title,
      doingImage: doingImage,
      doneImage: doneImage,
      undoImage: undoImage,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      options: options,
    );
  }

  /// 获取连接线样式
  String get image {
    if (status == ProgressStatus.completed) {
      return doneImage; // 实线
    } else if (status == ProgressStatus.inProgress) {
      return doingImage; // 实线
    } else {
      return undoImage; // 虚线
    }
  }

  /// 获取连接线样式
  bool getConnectionLineStyle() {
    if (status == ProgressStatus.completed) {
      return false; // 实线
    } else if (status == ProgressStatus.inProgress) {
      return false; // 实线
    } else {
      return true; // 虚线
    }
  }
}
