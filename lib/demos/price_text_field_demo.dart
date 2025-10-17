import 'package:flutter/material.dart';
import 'package:field_login/widgets/price_text_field.dart';

class PriceTextFieldDemo extends StatefulWidget {
  const PriceTextFieldDemo({super.key});

  @override
  State<PriceTextFieldDemo> createState() => _PriceTextFieldDemoState();
}

class _PriceTextFieldDemoState extends State<PriceTextFieldDemo> {
  String _value = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PriceTextField Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('演示：带人民币符号的金额输入，整数字号14，小数字号12，最多2位小数'),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('基本用法'),
                  const SizedBox(height: 12),
                  PriceTextField(
                    hintText: '请输入金额',
                    initialValue: '120.56',
                    onChanged: (v) => setState(() => _value = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blue),
              title: const Text('当前值'),
              subtitle: Text(_value.isEmpty ? '（空）' : _value),
              trailing: TextButton(
                onPressed: () => setState(() => _value = ''),
                child: const Text('清空显示'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
