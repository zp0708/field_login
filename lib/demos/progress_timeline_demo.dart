import 'package:flutter/material.dart';
import '../widgets/progress_timeline/progress_timeline.dart';

class ProgressTimelineDemo extends StatefulWidget {
  const ProgressTimelineDemo({super.key});

  @override
  State<ProgressTimelineDemo> createState() => _ProgressTimelineDemoState();
}

class _ProgressTimelineDemoState extends State<ProgressTimelineDemo> {
  late List<ProgressStage> _stages;

  @override
  void initState() {
    super.initState();
    _initStages();
  }

  void _initStages() {
    _stages = [
      ProgressStage(
        id: '1',
        title: '修剪本甲',
        icon: Icons.content_cut,
        status: ProgressStatus.completed,
        timestamp: '今天 09:03',
      ),
      ProgressStage(
        id: '2',
        title: '美甲定制',
        icon: Icons.brush,
        status: ProgressStatus.completed,
        timestamp: '今天 09:28',
      ),
      ProgressStage(
        id: '3',
        title: '选择美甲工艺',
        icon: Icons.construction,
        status: ProgressStatus.inProgress,
        timestamp: '今天 09:45',
        options: {
          'manual': {
            'text': '人工美甲',
            'icon': Icons.person,
            'selected': true,
          },
          'smart': {
            'text': '智能美甲',
            'icon': Icons.smart_toy,
            'selected': false,
          },
        },
      ),
      ProgressStage(
        id: '4',
        title: '保湿护理',
        icon: Icons.water_drop,
        status: ProgressStatus.waiting,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('服务进度时间线'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetStages,
            icon: const Icon(Icons.refresh),
            tooltip: '重置进度',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE8F5E8),
              const Color(0xFFF0F8F0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题和说明
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.spa,
                          color: Colors.green.shade600,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '美甲服务进度',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '点击状态图标可以切换进度状态：等待 → 进行中 → 完成 → 等待',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '进行中的阶段会显示选项供选择',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 进度时间线
              ProgressTimeline(
                stages: _stages,
                height: 300,
                onStageTap: (stage) {
                  _showStageInfo(stage);
                },
                onOptionSelected: (stage) {
                  _showOptionInfo(stage);
                },
              ),

              const SizedBox(height: 20),

              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _nextStage,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('下一步'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStage,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('上一步'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetStages() {
    setState(() {
      _initStages();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('进度已重置'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _nextStage() {
    final currentIndex = _stages.indexWhere(
      (stage) => stage.status == ProgressStatus.inProgress,
    );

    if (currentIndex != -1 && currentIndex < _stages.length - 1) {
      setState(() {
        // 完成当前阶段
        _stages[currentIndex] = _stages[currentIndex].copyWith(
          status: ProgressStatus.completed,
        );

        // 开始下一个阶段
        _stages[currentIndex + 1] = _stages[currentIndex + 1].copyWith(
          status: ProgressStatus.inProgress,
          timestamp: '今天 ${_getCurrentTime()}',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已完成：${_stages[currentIndex].title}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已经是最后一个阶段了'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _previousStage() {
    final currentIndex = _stages.indexWhere(
      (stage) => stage.status == ProgressStatus.inProgress,
    );

    if (currentIndex > 0) {
      setState(() {
        // 重置当前阶段
        _stages[currentIndex] = _stages[currentIndex].copyWith(
          status: ProgressStatus.waiting,
          timestamp: null,
        );

        // 回到上一个阶段
        _stages[currentIndex - 1] = _stages[currentIndex - 1].copyWith(
          status: ProgressStatus.inProgress,
          timestamp: '今天 ${_getCurrentTime()}',
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('回到：${_stages[currentIndex - 1].title}'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已经是第一个阶段了'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showStageInfo(ProgressStage stage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stage.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态: ${_getStatusText(stage.status)}'),
            if (stage.timestamp != null) Text('时间: ${stage.timestamp}'),
            if (stage.options != null) ...[
              const SizedBox(height: 8),
              const Text('选项:'),
              ...stage.options!.entries.map((entry) {
                final option = entry.value;
                return Text('  • ${option['text']}');
              }),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOptionInfo(ProgressStage stage) {
    final selectedOption =
        stage.options?.entries.firstWhere((entry) => entry.value['selected'] == true, orElse: () => MapEntry('', {}));

    if (selectedOption != null && selectedOption.key.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已选择：${selectedOption.value['text']}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _getStatusText(ProgressStatus status) {
    switch (status) {
      case ProgressStatus.waiting:
        return '等待';
      case ProgressStatus.inProgress:
        return '进行中';
      case ProgressStatus.completed:
        return '完成';
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
