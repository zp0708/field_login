import 'product.dart';
import 'settlement_status.dart';

/// Settlement state containing all necessary data for the settlement page
class SettlementState {
  final SettlementStatus status;
  final List<Product> products;
  final Set<String> selectedProductIds;
  final double totalAmount;
  final bool isLoading;
  final String? errorMessage;

  const SettlementState({
    required this.status,
    required this.products,
    required this.selectedProductIds,
    required this.totalAmount,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the given fields replaced with new values
  SettlementState copyWith({
    SettlementStatus? status,
    List<Product>? products,
    Set<String>? selectedProductIds,
    double? totalAmount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettlementState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProductIds: selectedProductIds ?? this.selectedProductIds,
      totalAmount: totalAmount ?? this.totalAmount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Returns a copy of this state with the error message cleared
  SettlementState clearError() {
    return copyWith(errorMessage: null);
  }

  /// Get all selected products
  List<Product> get selectedProducts {
    return products.where((product) => selectedProductIds.contains(product.id)).toList();
  }

  /// Check if any products are selected
  bool get hasSelectedProducts => selectedProductIds.isNotEmpty;

  /// Calculate total price for selected products
  double get selectedTotalPrice {
    return selectedProducts.fold(0.0, (sum, product) => sum + (product.price * product.quantity));
  }

  /// Check if all products are selected
  bool get isAllProductsSelected => selectedProductIds.length == products.length;

  /// Check if payment can be processed
  bool get canProcessPayment => hasSelectedProducts && !isLoading;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettlementState &&
        other.status == status &&
        other.products == products &&
        other.selectedProductIds == selectedProductIds &&
        other.totalAmount == totalAmount &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      products,
      selectedProductIds,
      totalAmount,
      isLoading,
      errorMessage,
    );
  }

  @override
  String toString() {
    return 'SettlementState{status: $status, productsCount: ${products.length}, '
        'selectedCount: ${selectedProductIds.length}, totalAmount: $totalAmount, '
        'isLoading: $isLoading, hasError: ${errorMessage != null}}';
  }
}
