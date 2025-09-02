import 'package:flutter/material.dart';
import '../../style/adapt.dart';

/// 打开一个 Alert 弹窗
///
/// 基础使用
/// final result = await showAlert<String>(context,
///   title: '确认跳过排队',
///   detail: '前序还有未安排的顾客，确认跳过前序排队顾客吗',
///   actions: [
///     AlertAction('取消'),
///     AlertAction('确定', fill: true),
///   ]
/// );
/// print(result); // 返回 '确定' 或者 '取消'
///
/// [T] T 可以是 String int AlertAction，默认是返回 int（按钮在 actions 中的位置）
/// [padding] 默认是EdgeInsets.symmetric(horizontal: 40.dp, vertical: 30.dp)
/// [title] alert 的标题，String 类型
/// [titleBuilder] 构建自定义标题类型
/// [detail] alert 的内容，String 类型
/// [detailBuilder] 构建自定义内容
/// [actions] 底部按钮 AlertAction 类型
Future<T?> showAlert<T>(
  BuildContext context, {
  List<AlertAction>? actions,
  String? title,
  String? detail,
  WidgetBuilder? titleBuilder,
  WidgetBuilder? detailBuilder,
  EdgeInsets? padding,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Color(0xB3000000),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    pageBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return GeneralAlert<T>(
        title: title,
        detail: detail,
        titleBuilder: titleBuilder,
        detailBuilder: detailBuilder,
        actions: actions,
        padding: padding,
      );
    },
  );
}

class GeneralAlert<T> extends StatelessWidget {
  final String? title;
  final String? detail;
  final WidgetBuilder? titleBuilder;
  final WidgetBuilder? detailBuilder;
  final List<AlertAction>? actions;
  final EdgeInsets? padding;

  const GeneralAlert({
    super.key,
    this.title,
    this.detail,
    this.titleBuilder,
    this.detailBuilder,
    this.actions,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    if (titleBuilder != null) {
      widgets.add(titleBuilder!(context));
    } else if (title != null) {
      widgets.add(SizedBox(height: 10.dp));
      widgets.add(
        Text(
          title!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.dp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (detailBuilder != null) {
      widgets.add(detailBuilder!(context));
    } else if (detail != null) {
      widgets.add(SizedBox(height: 30.dp));
      widgets.add(
        Text(
          detail!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.dp,
            color: Colors.black,
          ),
        ),
      );
    }

    if (actions != null && actions!.isNotEmpty) {
      widgets.add(SizedBox(height: 44.dp));
      final List<Widget> rowWidgets = [];
      for (int i = 0; i < actions!.length; i++) {
        final action = actions![i];
        rowWidgets.add(
          Expanded(
            child: _build(
              context,
              action,
              () {
                action.onPress?.call();
                Navigator.of(context).pop(_getResult(action, i));
              },
            ),
          ),
        );
        rowWidgets.add(SizedBox(width: 10.dp));
      }
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.max,
          children: rowWidgets,
        ),
      );
    }

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Container(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 40.dp, vertical: 30.dp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(16.dp),
            ),
          ),
          width: 440.dp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgets,
          ),
        ),
      ),
    );
  }

  Object _getResult(AlertAction action, int index) {
    if (T == String) {
      return action.title;
    } else if (T == int) {
      return index;
    } else if (T == AlertAction) {
      return action;
    }
    return index;
  }

  Widget _build(BuildContext context, AlertAction action, VoidCallback onPressed) {
    if (action.builder != null) {
      return InkWell(
        onTap: onPressed,
        child: action.builder?.call(context),
      );
    }
    if (action.fill) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          // padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.dp), // 矩形，无圆角
          ),
          backgroundColor: Colors.purple,
        ),
        child: Text(
          action.title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.dp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.dp), // 矩形，无圆角
        ),
        side: BorderSide(color: Colors.black, width: 0.5.dp), // 边框颜色和宽度
      ),
      child: Text(
        action.title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14.dp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class AlertAction {
  final bool fill;
  final String title;
  final VoidCallback? onPress;
  final WidgetBuilder? builder;

  const AlertAction(
    this.title, {
    this.fill = false,
    this.onPress,
    this.builder,
  });
}
