import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../style/adapt.dart';
import '../providers/settlement_providers.dart';

/// Widget that provides selection controls (select all, clear all)
class SelectionControls extends ConsumerWidget {
  const SelectionControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAllSelected = ref.watch(isAllProductsSelectedProvider);
    final selectedCount = ref.watch(selectedProductsCountProvider);
    final notifier = ref.read(settlementProvider.notifier);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 12.dp),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (isAllSelected) {
                notifier.clearAllSelections();
              } else {
                notifier.selectAllProducts();
              }
            },
            child: Row(
              children: [
                Icon(
                  isAllSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isAllSelected ? Colors.red : Colors.grey,
                  size: 20.dp,
                ),
                SizedBox(width: 8.dp),
                Text(
                  '全选',
                  style: TextStyle(
                    fontSize: 14.dp,
                    color: Colors.black87,
                    fontWeight: isAllSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '已选择 $selectedCount 件商品',
            style: TextStyle(
              fontSize: 12.dp,
              color: Colors.grey[600],
            ),
          ),
          if (selectedCount > 0 && !isAllSelected) ...[
            SizedBox(width: 16.dp),
            GestureDetector(
              onTap: () => notifier.clearAllSelections(),
              child: Text(
                '清空',
                style: TextStyle(
                  fontSize: 12.dp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
