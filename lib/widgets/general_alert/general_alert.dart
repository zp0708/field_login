import 'package:field_login/style/adapt.dart';
import 'package:flutter/material.dart';

/// 打开一个 Alert 弹窗
///
/// showAlert(context,
///   titleText: '确认跳过排队',
///   detailText: '前序还有未安排的排队顾客，确认跳过前序排队顾客吗？',
///   actions: [
///     AlertAction('取消'.tr(), onPress: () => print('取消')),
///     AlertAction('确定'.tr(), fill: true, onPress: () => print('确定')),
///     AlertAction('取消', onPress: () => print('取消')),
///     AlertAction('确定', fill: true, onPress: () => print('确定'), builder: (context) {
///       return Container(
///         height: 48.dp,
///         alignment: Alignment.center,
///         decoration: BoxDecoration(
///           borderRadius: BorderRadius.all(Radius.circular(8.0)),
///           border: Border.all(width: 1, color: Colors.black)
///         ),
///         child: Text('自定义按钮'),
///       );
///      })
///    ]
///   );
Future<void> showAlert(
  BuildContext context, {
  List<AlertAction>? actions,
  String? titleText,
  String? detailText,
  ValueChanged<int>? onSelect,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '关闭',
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
      return GeneralAlert(
        titleText: titleText,
        detailText: detailText,
        onSelect: onSelect,
        actions: actions,
      );
    },
  );
}

class GeneralAlert extends StatelessWidget {
  final String? titleText;
  final String? detailText;
  final ValueChanged<int>? onSelect;
  final List<AlertAction>? actions;

  const GeneralAlert({
    super.key,
    this.titleText,
    this.detailText,
    this.onSelect,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    if (titleText != null) {
      widgets.add(SizedBox(height: 10.dp));
      widgets.add(
        Text(
          titleText!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.dp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (detailText != null) {
      widgets.add(SizedBox(height: 30.dp));
      widgets.add(
        Text(
          detailText!,
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
                Navigator.of(context).pop();
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
          padding: EdgeInsets.symmetric(horizontal: 40.dp, vertical: 30.dp),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(16.dp),
            ),
          ),
          width: 440.dp,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets,
          ),
        ),
      ),
    );
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
