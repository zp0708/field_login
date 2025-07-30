import 'dart:math';

import 'package:flutter/material.dart';
import './painters/tab_background_painter.dart';
import './painters/tab_left_painter.dart';
import './painters/tab_right_painter.dart';
import './painters/tab_center_painter.dart';
import './painters/tab_painter.dart';

// 一个自定义的标签形状组件，使用 CustomPaint 绘制特殊形状
class ShapeTabWidget extends StatefulWidget {
  final List<String> titles;

  // 点击回调
  final void Function(String, int)? onSelectItem;

  // 是否可用，false 时不可点击
  final bool enable;

  // 未选中的字体配置
  final TextStyle? textStyle;

  // 选择的标题样式
  final TextStyle? selectedTextStyle;

  final double shapeWidth;

  // 内间距
  final double padding;

  // 背景色向下延伸，处理下方组件有圆角的情况
  final double extendBottom;

  // 圆角
  final double cornerRadius;

  // 不规则形状背景的颜色
  final Color shapeColor;

  // 背景色
  final Color backgroundColor;

  const ShapeTabWidget({
    super.key,
    this.titles = const [],
    this.textStyle,
    this.selectedTextStyle,
    this.shapeWidth = 70,
    this.padding = 4,
    this.cornerRadius = 20,
    this.shapeColor = Colors.white,
    this.backgroundColor = const Color(0xFFF5FFCE),
    this.onSelectItem,
    this.enable = true,
    this.extendBottom = 0,
  });

  @override
  State<ShapeTabWidget> createState() => _ShapeTabWidgetState();
}

class _ShapeTabWidgetState extends State<ShapeTabWidget> {
  var selectIndex = 0;

  double getPainterLeft(double width) {
    if (selectIndex == 0) return 0;
    if (selectIndex == widget.titles.length - 1) {
      return selectIndex * width - widget.shapeWidth * 0.5;
    }
    return selectIndex * width - widget.shapeWidth * 0.5;
  }

  double getPainterWidth(double width) {
    if (selectIndex == 0) return width + widget.shapeWidth * 0.5;
    if (selectIndex == widget.titles.length - 1) {
      return width + widget.shapeWidth * 0.5;
    }
    return width + widget.shapeWidth;
  }

  TabPainter getPainter() {
    if (selectIndex == 0) {
      return TabLeftPainter(
        shapeWidth: widget.shapeWidth,
        top: widget.padding,
        cornerRadius: widget.cornerRadius,
        color: widget.shapeColor,
      );
    }
    if (selectIndex == widget.titles.length - 1) {
      return TabRightPainter(
        shapeWidth: widget.shapeWidth,
        top: widget.padding,
        cornerRadius: widget.cornerRadius,
        color: widget.shapeColor,
      );
    }
    return TabCenterPainter(
      shapeWidth: widget.shapeWidth,
      top: widget.padding,
      cornerRadius: widget.cornerRadius,
      color: widget.shapeColor,
    );
  }

  void onSelectIndex(int index) {
    if (selectIndex == index || !widget.enable) return;
    setState(() {
      selectIndex = index;
    });
    if (widget.onSelectItem != null) {
      widget.onSelectItem!(widget.titles[index], index);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 使用 SizedBox 限定大小，CustomPaint 绘制自定义形状
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / max(widget.titles.length, 1);
        return CustomPaint(
          painter: TabBackgroundPainter(
            top: widget.padding,
            cornerRadius: widget.cornerRadius,
            color: widget.backgroundColor,
            extendBottom: widget.extendBottom,
          ),
          child: Stack(
            children: [
              Positioned(
                left: getPainterLeft(width),
                top: 0,
                bottom: 0,
                width: getPainterWidth(width),
                child: CustomPaint(painter: getPainter()),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  widget.titles.length,
                  (index) => Expanded(
                    child: InkWell(
                      onTap: () => onSelectIndex(index),
                      child: Center(
                        child: Text(
                          widget.titles[index],
                          style: selectIndex == index ? widget.selectedTextStyle : widget.textStyle,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
