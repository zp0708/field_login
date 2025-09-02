import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../style/adapt.dart';
import '../providers/settlement_providers.dart';
import '../services/payment_service.dart';
import '../models/settlement_state.dart';

/// Widget that displays the bottom payment section
class PaymentSection extends ConsumerStatefulWidget {
  const PaymentSection({super.key});

  @override
  ConsumerState<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends ConsumerState<PaymentSection> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.alipay;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final state = ref.watch(settlementProvider);
    final totalPrice = ref.watch(selectedTotalPriceProvider);
    final canPay = ref.watch(canProcessPaymentProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final errorMessage = ref.watch(errorMessageProvider);
    final notifier = ref.read(settlementProvider.notifier);

    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Payment summary section
          _buildPaymentSummary(state),

          // Payment methods section
          _buildPaymentMethods(),

          // Bottom action section
          Container(
            padding: EdgeInsets.all(16.dp),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Error message
                  if (errorMessage != null) _buildErrorMessage(errorMessage, notifier),

                  // Payment button
                  _buildPaymentButton(totalPrice, canPay, isLoading, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(SettlementState state) {
    final selectedProducts = state.selectedProducts;
    final hasDiscount = selectedProducts.any((p) => p.hasDiscount);
    final originalTotal = selectedProducts.fold(0.0, (sum, p) => sum + (p.originalPrice ?? p.price) * p.quantity);
    final currentTotal = selectedProducts.fold(0.0, (sum, p) => sum + p.price * p.quantity);
    final discountAmount = originalTotal - currentTotal;

    return Container(
      padding: EdgeInsets.all(16.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付信息',
            style: TextStyle(
              fontSize: 16.dp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.dp),

          // Original amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('商品总额', style: _summaryTextStyle()),
              Text('¥${originalTotal.toStringAsFixed(2)}', style: _summaryTextStyle()),
            ],
          ),
          SizedBox(height: 4.dp),

          // Discount
          if (hasDiscount) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('优惠减免', style: _summaryTextStyle()),
                Text(
                  '-¥${discountAmount.toStringAsFixed(2)}',
                  style: _summaryTextStyle().copyWith(color: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 8.dp),
            const Divider(height: 1),
            SizedBox(height: 8.dp),
          ],

          // Final total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '合计',
                style: TextStyle(
                  fontSize: 16.dp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '¥${currentTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.dp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          // Coupon section
          SizedBox(height: 8.dp),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('优惠券', style: _summaryTextStyle()),
              Row(
                children: [
                  Text('无可用', style: _summaryTextStyle().copyWith(color: Colors.grey)),
                  SizedBox(width: 4.dp),
                  Icon(Icons.chevron_right, size: 16.dp, color: Colors.grey),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  TextStyle _summaryTextStyle() {
    return TextStyle(
      fontSize: 14.dp,
      color: Colors.grey[700],
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.dp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付方式',
            style: TextStyle(
              fontSize: 16.dp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.dp),
          ...PaymentService.getSupportedPaymentMethods().map((method) => _buildPaymentMethodItem(method)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.dp),
        padding: EdgeInsets.all(12.dp),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.dp),
          color: isSelected ? Colors.green.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            // Payment method icon
            Container(
              width: 32.dp,
              height: 32.dp,
              decoration: BoxDecoration(
                color: _getPaymentMethodColor(method),
                borderRadius: BorderRadius.circular(6.dp),
              ),
              child: Icon(
                _getPaymentMethodIcon(method),
                color: Colors.white,
                size: 18.dp,
              ),
            ),
            SizedBox(width: 12.dp),

            // Payment method name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.displayName,
                    style: TextStyle(
                      fontSize: 14.dp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (_getPaymentMethodSubtitle(method) != null)
                    Text(
                      _getPaymentMethodSubtitle(method)!,
                      style: TextStyle(
                        fontSize: 12.dp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            // Selection indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey,
              size: 20.dp,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.alipay:
        return Colors.blue;
      case PaymentMethod.wechatPay:
        return Colors.green;
      case PaymentMethod.bankCard:
        return Colors.orange;
      case PaymentMethod.applePay:
        return Colors.black;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.alipay:
        return Icons.account_balance_wallet;
      case PaymentMethod.wechatPay:
        return Icons.chat;
      case PaymentMethod.bankCard:
        return Icons.credit_card;
      case PaymentMethod.applePay:
        return Icons.apple;
    }
  }

  String? _getPaymentMethodSubtitle(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.wechatPay:
        return '限额¥1-40万';
      case PaymentMethod.bankCard:
        return '余额299.10元';
      case PaymentMethod.applePay:
        return '刷余次3次';
      default:
        return null;
    }
  }

  Widget _buildErrorMessage(String errorMessage, notifier) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.dp),
      margin: EdgeInsets.only(bottom: 16.dp),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8.dp),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red, size: 16.dp),
          SizedBox(width: 8.dp),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12.dp,
                color: Colors.red,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => notifier.clearError(),
            child: Icon(Icons.close, color: Colors.red, size: 16.dp),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(double totalPrice, bool canPay, bool isLoading, notifier) {
    return SizedBox(
      width: double.infinity,
      height: 48.dp,
      child: ElevatedButton(
        onPressed: canPay ? () => notifier.processPayment() : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPay ? Colors.green : Colors.grey[300],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.dp),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20.dp,
                height: 20.dp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                '继续支付',
                style: TextStyle(
                  fontSize: 16.dp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
