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
      final prefix = '$currencySymbol ';
      valueText = valueText.replaceAll(prefix, '').trimLeft();
      children.add(TextSpan(text: prefix, style: base.merge(currencyStyle)));
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
        PriceFormatter(
          maxFractionDigits: _controller.maxFractionDigits,
          currencySymbol: widget.currencySymbol,
          maxIntegerDigits: 4,
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

// 自定义输入格式化器，用于在右对齐时添加固定的货币符号前缀，
// 并限制整数和小数位数。
class PriceFormatter extends TextInputFormatter {
  final int? maxFractionDigits;
  final int? maxIntegerDigits;
  final String? currencySymbol;

  const PriceFormatter({
    this.maxFractionDigits,
    this.maxIntegerDigits,
    this.currencySymbol,
  });

  // 定义固定的前缀，例如 '¥ '
  String get _prefix => currencySymbol != null ? '$currencySymbol ' : '';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (currencySymbol == null) {
      // 如果没有设置货币符号，则不进行格式化
      return newValue;
    }

    // 1. 获取用户输入的纯净数字部分 (移除前缀)
    // 同时也移除任何非数字、非点、非前缀的字符，以保持输入清洁
    final String cleanValue = newValue.text.replaceAll(_prefix, '').replaceAllMapped(RegExp(r'[^0-9.]'), (match) => '');

    // 2. 检查数值有效性 (多个小数点)

    // 2.1. 阻止输入多个小数点
    if (cleanValue.contains('.') && cleanValue.indexOf('.') != cleanValue.lastIndexOf('.')) {
      return oldValue;
    }

    // 2.2. 阻止非法起始字符
    // 允许空字符串，或者以数字开头，或者只输入一个点 '.'
    if (cleanValue.isNotEmpty && !cleanValue.startsWith(RegExp(r'[0-9]')) && cleanValue != '.') {
      return oldValue;
    }

    // 3. 检查整数和小数位数限制
    final parts = cleanValue.split('.');
    final integerPart = parts[0];

    // 3.1. 检查整数位数限制 (新增逻辑)
    if (maxIntegerDigits != null && integerPart.length > maxIntegerDigits!) {
      // 如果整数位数超过限制，则返回旧值
      return oldValue;
    }

    // 3.2. 检查小数位数限制
    if (maxFractionDigits != null && parts.length > 1) {
      final fractionalPart = parts[1];
      if (fractionalPart.length > maxFractionDigits!) {
        // 如果小数位数超过限制，则返回旧值
        return oldValue;
      }
    }

    // 4. 重新格式化并调整光标位置
    // 如果纯净值为空，返回只包含前缀但没有数字的值，并将光标放在前缀末尾
    if (cleanValue.isEmpty) {
      return TextEditingValue(
        text: _prefix,
        selection: TextSelection.collapsed(offset: _prefix.length),
      );
    }

    final String formattedText = _prefix + cleanValue;

    // 调整光标位置：
    // newCursorOffset 是在新文本中光标应在的位置
    int newCursorOffset = newValue.selection.end;

    // 如果用户是在文本中间操作 (例如删除)
    // 这是一个简化处理，主要确保光标落在数字部分之后
    if (!newValue.text.startsWith(_prefix)) {
      // 如果格式化器强制添加了前缀，光标位置需要加上前缀的长度
      newCursorOffset = cleanValue.length + _prefix.length;
    } else {
      // 如果前缀存在且格式正确，我们尝试保持光标在数字部分的相对位置
      final prefixLength = _prefix.length;

      // 光标相对于纯净值末尾的位置
      final relativePosition = oldValue.text.length - oldValue.selection.end;

      // 新的光标位置应该在新文本长度 - 相对位置
      newCursorOffset = formattedText.length - relativePosition;

      // 如果发生了粘贴或大量修改，确保光标不会跑到前缀里面
      if (newCursorOffset < prefixLength) {
        newCursorOffset = formattedText.length;
      }
    }

    // 确保光标不超过新文本的长度
    newCursorOffset = newCursorOffset.clamp(_prefix.length, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}
