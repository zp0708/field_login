import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field_login/pages/widgets/background_clipper.dart';
import 'package:field_login/pages/widgets/toolbar_item.dart';
import 'package:field_login/style/adapt.dart';
import 'package:flutter/material.dart';

class LeftToolsBar extends StatefulWidget {
  final ValueChanged<ToolbarItem>? onItemTap;

  const LeftToolsBar({
    super.key,
    required this.items,
    this.onItemTap,
  });

  final List<ToolbarItem> items;

  @override
  State<LeftToolsBar> createState() => _LeftToolsBarState();
}

class _LeftToolsBarState extends State<LeftToolsBar> with SingleTickerProviderStateMixin {
  bool isExpanded = true;
  final double _arrowWidth = 28;
  final double _toolbarWidth = 208;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.items.length * 150.0 + 30;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      left: isExpanded ? 0 : -(_toolbarWidth - _arrowWidth),
      top: 0,
      bottom: 0,
      width: _toolbarWidth,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ClipPath(
          clipBehavior: Clip.hardEdge,
          clipper: ToolsBackgroundClipper(arrowWidth: _arrowWidth),
          child: Container(
            height: min(h, 700),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 350),
                    opacity: isExpanded ? 1.0 : 0.0,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final bool selected = item.selected;
                        return _buildItem(item, selected);
                      },
                    ),
                  ),
                ),
                _buildButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    return InkWell(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: SizedBox(
        width: _arrowWidth,
        height: 80.dp,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 350),
          turns: isExpanded ? 0 : 0.5,
          child: Icon(
            Icons.chevron_left,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildItem(ToolbarItem item, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          for (var i = 0; i < widget.items.length; i++) {
            widget.items[i].selected = false;
          }
          item.selected = true;
        });
        widget.onItemTap?.call(item);
      },
      child: Container(
        height: 140,
        width: 140,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: selected ? Border.all(color: Colors.greenAccent.shade400, width: 1) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: item.url,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 28,
                child: Container(
                  alignment: Alignment.center,
                  width: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(
                          alpha: 0.7,
                        ),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
