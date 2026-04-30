
import 'json_viewer.dart';
import 'package:flutter/material.dart';

class JsonSearchBar extends StatefulWidget {
  const JsonSearchBar({
    super.key,
    required this.jsonController,
    this.hintText,
  });

  final JsonTreeController jsonController;

  final String? hintText;

  @override
  State<JsonSearchBar> createState() => _JsonSearchBarState();
}

class _JsonSearchBarState extends State<JsonSearchBar> {
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.blue, width: 1),
    );
    return Row(
      children: [
        Expanded(
          child: TextField(
            autofocus: true,
            controller: _editController,
            onChanged: (value) {
              widget.jsonController.search(value);
              if (value.isEmpty || widget.jsonController.keyword.isEmpty) {
                setState(() {});
              }
            },
            cursorColor: Colors.blue,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              hintText: widget.hintText,
              prefixIcon: Icon(Icons.search, size: 18, color: Colors.blue),
              suffixIcon: _editController.text.isEmpty
                  ? null
                  : InkWell(
                      onTap: () {
                        _editController.clear();
                        widget.jsonController.search('');
                        setState(() {});
                      },
                      child: Icon(Icons.clear, size: 18, color: Colors.blue),
                    ),
              border: border,
              enabledBorder: border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
          ),
        ),
        if (_editController.text.isNotEmpty)
          Row(
            children: [
              SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber.shade600),
                ),
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    widget.jsonController.index,
                    widget.jsonController.refresh,
                  ]),
                  builder: (context, child) {
                    return Text(
                      '${widget.jsonController.currentDisplay}/${widget.jsonController.total}',
                      style: const TextStyle(fontSize: 10, color: Colors.black87),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: '上一处',
                icon: const Icon(Icons.keyboard_arrow_up, size: 18, color: Colors.blue),
                onPressed: () => widget.jsonController.prev(),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minimumSize: Size(32, 32),
                ),
              ),
              IconButton(
                tooltip: '下一处',
                icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.blue),
                onPressed: () => widget.jsonController.next(),
                padding: EdgeInsets.zero,
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  minimumSize: Size(32, 32),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
