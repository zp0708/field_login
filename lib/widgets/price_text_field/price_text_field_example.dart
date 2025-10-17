import 'package:field_login/widgets/price_text_field/rich/src/controller.dart';
import 'package:field_login/widgets/price_text_field/rich/src/models/match_target_item.dart';
import 'package:flutter/material.dart';

class PriceTextFieldExample extends StatefulWidget {
  const PriceTextFieldExample({super.key});

  @override
  State<PriceTextFieldExample> createState() => _PriceTextFieldState();
}

class _PriceTextFieldState extends State<PriceTextFieldExample> {
  late RichTextController _controller;

  @override
  void initState() {
    _controller = RichTextController(
      deleteOnBack: true,
      targetMatches: [
        MatchTargetItem(regex: RegExp(r"#123"), style: TextStyle(color: Colors.red)),
      ],
      onMatch: (obj) => {print(obj)},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text('data'),
        ),
        body: TextField(
          controller: _controller,
        ),
      ),
    );
  }
}
