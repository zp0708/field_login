import '../models/product.dart';

/// Service for handling payment processing
class PaymentService {
  /// Simulates payment processing with random success/failure
  static Future<PaymentResult> processPayment({
    required List<Product> products,
    required double amount,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Validate payment data
    if (products.isEmpty) {
      return PaymentResult.failure('没有选择商品，无法进行支付');
    }

    if (amount <= 0) {
      return PaymentResult.failure('支付金额必须大于0');
    }

    // Simulate random payment result for demo purposes
    // In real implementation, this would call actual payment APIs
    final random = DateTime.now().millisecond;
    final isSuccess = random % 4 != 0; // 75% success rate

    if (isSuccess) {
      final transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';
      return PaymentResult.success(
        transactionId: transactionId,
        amount: amount,
        products: products,
      );
    } else {
      // Random error messages for demo
      final errorMessages = [
        '支付失败，请重试',
        '网络连接失败，请检查网络',
        '银行卡余额不足',
        '支付服务暂时不可用',
        '交易超时，请重新支付',
      ];
      final errorMessage = errorMessages[random % errorMessages.length];
      return PaymentResult.failure(errorMessage);
    }
  }

  /// Validates payment amount
  static bool validatePaymentAmount(double amount) {
    return amount > 0 && amount <= 999999.99;
  }

  /// Calculates payment fee (if any)
  static double calculatePaymentFee(double amount) {
    // No fee for demo purposes
    return 0.0;
  }

  /// Gets supported payment methods
  static List<PaymentMethod> getSupportedPaymentMethods() {
    return [
      PaymentMethod.alipay,
      PaymentMethod.wechatPay,
      PaymentMethod.bankCard,
      PaymentMethod.applePay,
    ];
  }
}

/// Payment result class
class PaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final double? amount;
  final List<Product>? products;
  final String? errorMessage;

  const PaymentResult._({
    required this.isSuccess,
    this.transactionId,
    this.amount,
    this.products,
    this.errorMessage,
  });

  /// Creates a successful payment result
  factory PaymentResult.success({
    required String transactionId,
    required double amount,
    required List<Product> products,
  }) {
    return PaymentResult._(
      isSuccess: true,
      transactionId: transactionId,
      amount: amount,
      products: products,
    );
  }

  /// Creates a failed payment result
  factory PaymentResult.failure(String errorMessage) {
    return PaymentResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'PaymentResult.success(transactionId: $transactionId, amount: $amount)';
    } else {
      return 'PaymentResult.failure(error: $errorMessage)';
    }
  }
}

/// Supported payment methods
enum PaymentMethod {
  alipay,
  wechatPay,
  bankCard,
  applePay,
}

/// Extension for payment method display names
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.alipay:
        return '支付宝';
      case PaymentMethod.wechatPay:
        return '微信支付';
      case PaymentMethod.bankCard:
        return '银行卡';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }

  String get iconAsset {
    switch (this) {
      case PaymentMethod.alipay:
        return 'assets/icons/alipay.png';
      case PaymentMethod.wechatPay:
        return 'assets/icons/wechat_pay.png';
      case PaymentMethod.bankCard:
        return 'assets/icons/bank_card.png';
      case PaymentMethod.applePay:
        return 'assets/icons/apple_pay.png';
    }
  }
}
