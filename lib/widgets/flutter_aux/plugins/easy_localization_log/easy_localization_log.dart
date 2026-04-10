import 'dart:math';
// ignore: depend_on_referenced_packages
import 'package:easy_logger/easy_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:manicure/third/flutter_aux/flutter_aux.dart';
import '../pluggable.dart';
import 'youdao_translator.dart';

class EasyLocalizationLog extends Pluggable {
  @override
  String get name => 'easy_localization_log';

  @override
  String get display => '国际化';

  @override
  Size get size => const Size(400, 500);

  @override
  Widget build(BuildContext context) {
    return const _EasyLocalizationLogWidget();
  }
}

class MissingKeyItem {
  final int index;
  final String key;
  String? translated;

  MissingKeyItem({
    required this.index,
    required this.key,
    this.translated,
  });
}

class _EasyLocalizationLogWidget extends StatefulWidget {
  const _EasyLocalizationLogWidget();

  @override
  State<_EasyLocalizationLogWidget> createState() => _EasyLocalizationLogWidgetState();
}

class _EasyLocalizationLogWidgetState extends State<_EasyLocalizationLogWidget> {
  final List<MissingKeyItem> _items = [];

  late YoudaoTranslator _translator;

  int _translateIndex = -1;
  bool _isStop = true;
  bool _translate = false;

  @override
  void initState() {
    super.initState();

    _translator = YoudaoTranslator(
      appKey: '66a33c2b8b0cfb9b',
      appSecret: 'zw9E6qwGwPoNfo5hiYxZTGyQOlZNIDr0',
    );

    // ⬇️ 绑定自定义日志方法
    EasyLocalization.logger.printer = _customLogPrinter;
  }

  @override
  void dispose() {
    EasyLocalization.logger.printer = easyLogDefaultPrinter;
    super.dispose();
  }

  /// 捕获 missing-key 日志
  void _customLogPrinter(
    Object object, {
    String? name,
    StackTrace? stackTrace,
    LevelMessages? level,
  }) {
    final text = object.toString();

    final match = RegExp(r'Localization key \[(.+?)\] not found').firstMatch(text);

    if (match != null) {
      final key = match.group(1)!;
      _addMissingKey(key);
    }

    // 保留原 debug 行为
    debugPrint(text);
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  /// 把 missing key 加入列表 & 自动翻译
  void _addMissingKey(String key) {
    if (_items.any((e) => e.key == key)) return;

    final item = MissingKeyItem(
      index: _items.length,
      key: key,
    );
    _items.add(item);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => {});
      }
    });
    if (_isStop) {
      _tryTranslate(max(_translateIndex, 0));
    }
  }

  void _tryTranslate(int index) {
    if (_translateIndex >= _items.length - 1 || !_translate) {
      _isStop = true;
      return;
    }
    _isStop = false;
    final item = _items[index];
    _translateIndex = index;
    _translator.translate(item.key).then((value) async {
      if (value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              item.translated = value;
            });
          }
        });
      }
      await Future.delayed(Duration(seconds: 1));
      // 继续翻译下一个
      _tryTranslate(index + 1);
    });
  }

  /// 复制按钮
  void _copyAll(bool translated) {
    final buffer = StringBuffer();
    for (var item in _items) {
      buffer.writeln(
        '"${item.key}": "${translated ? item.translated : item.key}",',
      );
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    FlutterAux.onMessage('已复制全部');
  }

  /// 清空
  void _clearAll() {
    setState(() => _items.clear());
    _translateIndex = -1;
  }

  void _onTranslate(bool? v) {
    setState(() => _translate = v ?? false);
    if (_translate) {
      _tryTranslate(max(_translateIndex, 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部按钮栏
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Text('翻译'),
              Checkbox(value: _translate, onChanged: _onTranslate),
              Spacer(),
              ElevatedButton(
                onPressed: () => _copyAll(false),
                child: const Text("复制ZH"),
              ),
              if (_translate)
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: ElevatedButton(
                    onPressed: () => _copyAll(true),
                    child: const Text("复制EN"),
                  ),
                ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _clearAll,
                child: const Text("清空"),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final item = _items[i];
              return ListTile(
                title: Text(item.key),
                subtitle: _translate ? Text(item.translated ?? "(翻译中...)") : null,
                trailing: IconButton(
                  onPressed: () {
                    final text = '"${item.key}": "${item.translated ?? item.key}"';
                    Clipboard.setData(ClipboardData(text: text));
                    FlutterAux.onMessage('已复制');
                  },
                  icon: const Icon(Icons.copy),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
