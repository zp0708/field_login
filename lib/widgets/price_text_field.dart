import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 自定义价格控制器：使用 buildTextSpan 分段渲染整数/小数
class PriceTextEditingController extends TextEditingController {
  final int maxFractionDigits;
  final TextStyle integerStyle;
  final TextStyle fractionStyle;
  final String? currencySymbol;
  final TextStyle? currencyStyle;

  PriceTextEditingController({
    super.text,
    this.maxFractionDigits = 2,
    TextStyle? integerStyle,
    TextStyle? fractionStyle,
    this.currencySymbol,
    this.currencyStyle,
  })  : integerStyle = integerStyle ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        fractionStyle = fractionStyle ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.normal);

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final base = style ?? const TextStyle(fontSize: 14);
    String valueText = text;

    final children = <InlineSpan>[];

    if (valueText.isEmpty) {
      return TextSpan(style: base, children: children);
    }

    if (currencySymbol != null) {
      valueText = valueText.replaceAll(currencySymbol!, '').trimLeft();
      children.add(TextSpan(text: currencySymbol!, style: base.merge(currencyStyle)));
    }

    String integerPart = valueText;
    String fractionPart = '';
    final dotIndex = valueText.indexOf('.');
    if (dotIndex >= 0) {
      integerPart = valueText.substring(0, dotIndex);
      fractionPart = valueText.substring(dotIndex + 1);
    }

    // 添加整数部分
    children.add(TextSpan(text: integerPart.isEmpty ? '' : integerPart, style: base.merge(integerStyle)));

    // 添加小数部分
    if (dotIndex >= 0) {
      children.add(TextSpan(text: '.', style: base.merge(fractionStyle)));
      if (fractionPart.isNotEmpty) {
        children.add(TextSpan(text: fractionPart, style: base.merge(fractionStyle)));
      }
    }

    return TextSpan(style: base, children: children);
  }
}

/// 金额输入框（人民币）
/// - 前缀人民币符号
/// - 整数 14 号，小数 12 号
/// - 最多 2 位小数，可编辑
class PriceTextField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final TextAlign textAlign;
  final String? currencySymbol;
  final TextStyle? currencyStyle;
  final TextStyle? integerStyle;
  final TextStyle? fractionStyle;

  const PriceTextField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText,
    this.textAlign = TextAlign.start,
    this.currencySymbol = '¥',
    this.currencyStyle,
    this.integerStyle,
    this.fractionStyle,
  });

  @override
  State<PriceTextField> createState() => _PriceTextFieldState();
}

class _PriceTextFieldState extends State<PriceTextField> {
  late final PriceTextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PriceTextEditingController(
      text: widget.initialValue != null ? '${widget.currencySymbol} ${widget.initialValue}' : widget.currencySymbol,
      currencySymbol: widget.currencySymbol,
      currencyStyle: widget.currencyStyle,
      integerStyle: widget.integerStyle,
      fractionStyle: widget.fractionStyle,
    );
    _controller.addListener(() => widget.onChanged?.call(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      textAlign: widget.textAlign,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        _PriceFormatter(
          maxFractionDigits: _controller.maxFractionDigits,
          currencySymbol: widget.currencySymbol,
        ),
      ],
      style: const TextStyle(fontSize: 14),
      cursorColor: theme.colorScheme.primary,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        isDense: true,
        hintText: widget.hintText ?? '请输入金额',
      ),
    );
  }
}

class _PriceFormatter extends TextInputFormatter {
  final int maxFractionDigits;
  final String? currencySymbol;

  const _PriceFormatter({
    required this.maxFractionDigits,
    this.currencySymbol,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (currencySymbol == null) return newValue;
    final prefix = '$currencySymbol ';
    // 如果用户清空了输入或删除到了前缀区域
    if (!newValue.text.startsWith(prefix)) {
      // 只保留用户输入的数字部分
      final numeric = newValue.text.replaceAll(prefix, '').replaceAll(RegExp('[^0-9.]'), '').trimLeft();

      // 重新拼接前缀
      final updated = prefix + numeric;

      // 设置光标在最后（防止跳动）
      return TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: updated.length),
      );
    }

    // ⚠️ 特殊情况：当用户试图删除前缀时，直接还原 oldValue，防止重复
    if (newValue.text.length < oldValue.text.length &&
        oldValue.text.startsWith(prefix) &&
        !newValue.text.startsWith(prefix)) {
      return oldValue;
    }

    // 正常输入时直接返回
    return newValue;
  }
}
