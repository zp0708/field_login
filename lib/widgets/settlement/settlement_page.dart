import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../style/adapt.dart';
import 'providers/settlement_providers.dart';
import 'components/customer_info.dart';
import 'components/product_item.dart';
import 'components/payment_section.dart';
import 'models/settlement_status.dart';

/// Main settlement page widget
class SettlementPage extends ConsumerStatefulWidget {
  const SettlementPage({super.key});

  @override
  ConsumerState<SettlementPage> createState() => _SettlementPageState();
}

class _SettlementPageState extends ConsumerState<SettlementPage> {
  final bool _showPaymentDetails = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settlementProvider);
    final notifier = ref.read(settlementProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context, state.status, notifier),
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                // Customer info section
                CustomerInfo(
                  name: '李女士',
                  phone: '135****5678',
                  avatarUrl: 'https://picsum.photos/100/100?random=avatar',
                  location: '🍭',
                  badge: 'lv.3',
                ),

                // Divider
                Container(
                  height: 8.dp,
                  color: const Color(0xFFF5F5F5),
                ),

                // Service shop info
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.dp),
                  child: Row(
                    children: [
                      Text(
                        '服务店铺',
                        style: TextStyle(
                          fontSize: 14.dp,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '上海武康路店',
                        style: TextStyle(
                          fontSize: 14.dp,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 8.dp,
                  color: const Color(0xFFF5F5F5),
                ),

                // Product list as slivers
                ..._buildProductSlivers(state, notifier),

                // Bottom padding to prevent content from being hidden behind floating button
                SizedBox(height: 10.dp),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.dp),
                  child: const PaymentSection(),
                ),
                Divider(height: 1, color: Colors.grey[200]),
              ],
            ),
          ),

          // Floating payment section at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingPaymentBar(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, SettlementStatus status, notifier) {
    return AppBar(
      title: Text(
        status == SettlementStatus.created ? '结算单' : '继续支付',
        style: TextStyle(
          fontSize: 18.dp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.dp),
        child: Container(
          height: 1.dp,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  List<Widget> _buildProductSlivers(state, notifier) {
    if (state.products.isEmpty) {
      return [
        Container(
          height: 200.dp,
          color: Colors.white,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无商品',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return state.products.asMap().entries.map<Widget>((entry) {
      final index = entry.key;
      final product = entry.value;
      final isSelected = state.selectedProductIds.contains(product.id);

      return ProductItem(
        product: product,
        isSelected: isSelected,
        onToggleSelection: () => notifier.toggleProductSelection(product.id),
      );
    }).toList();
  }

  Widget _buildFloatingPaymentBar() {
    final totalPrice = ref.watch(selectedTotalPriceProvider);
    final canPay = ref.watch(canProcessPaymentProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final notifier = ref.read(settlementProvider.notifier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Main payment bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.dp, vertical: 12.dp),
              child: Row(
                children: [
                  // Total price section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '合计',
                          style: TextStyle(
                            fontSize: 12.dp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '¥${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20.dp,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Payment button
                  SizedBox(
                    width: 140.dp,
                    height: 44.dp,
                    child: ElevatedButton(
                      onPressed: canPay ? () => notifier.processPayment() : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPay ? Colors.red : Colors.grey[300],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22.dp),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 16.dp,
                              height: 16.dp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              '前往支付',
                              style: TextStyle(
                                fontSize: 14.dp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
