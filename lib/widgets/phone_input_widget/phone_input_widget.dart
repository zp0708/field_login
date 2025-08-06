import 'package:field_login/widgets/phone_input_widget/keyboard_listener_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../style/adapt.dart';

class PhoneInputWidget extends StatefulWidget {
  final String? initialValue;
  final String? hintText;
  final String? title;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool hasError;
  final String? errorText;
  final bool enabled;
  final TextEditingController? controller;

  const PhoneInputWidget({
    super.key,
    this.initialValue,
    this.hintText = '请输入手机号',
    this.title,
    this.onChanged,
    this.onSubmitted,
    this.hasError = false,
    this.errorText,
    this.enabled = true,
    this.controller,
  });

  @override
  State<PhoneInputWidget> createState() => _PhoneInputWidgetState();
}

class _PhoneInputWidgetState extends State<PhoneInputWidget> with KeyboardListenerMixin {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = widget.controller ?? TextEditingController();

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void onKeyboardVisibilityChanged(bool visible, double keyboardHeight) {
    print("Keyboard is now ${visible ? "visible" : "hidden"}, $keyboardHeight");
  }

  Color _getBorderColor() {
    if (widget.hasError) {
      return Colors.red;
    } else if (_isFocused) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _formatPhoneNumber(String text) {
    // 移除所有非数字字符
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // 限制长度为11位
    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }

    // 格式化手机号：139 1234 5678
    if (digitsOnly.length <= 3) {
      return digitsOnly;
    } else if (digitsOnly.length <= 7) {
      return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3)}';
    } else {
      return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 7)} ${digitsOnly.substring(7)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 12.dp),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.dp),
            border: Border.all(
              color: _getBorderColor(),
              width: 1.5.dp,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone,
                color: _getBorderColor(),
                size: 20.dp,
              ),
              SizedBox(width: 12.dp),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  style: TextStyle(
                    fontSize: 16.dp,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.dp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    // 格式化手机号
                    String formatted = _formatPhoneNumber(value);
                    if (formatted != value) {
                      _controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                    widget.onChanged?.call(formatted);
                  },
                  onSubmitted: widget.onSubmitted,
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged?.call('');
                  },
                  child: Icon(
                    Icons.cancel,
                    color: Colors.grey[400],
                    size: 20.dp,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
