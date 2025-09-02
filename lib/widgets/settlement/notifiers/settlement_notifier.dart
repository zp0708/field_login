import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settlement_state.dart';
import '../models/settlement_status.dart';
import '../services/mock_data_service.dart';
import '../services/payment_service.dart';

/// Settlement state notifier managing all settlement-related state changes
class SettlementNotifier extends StateNotifier<SettlementState> {
  SettlementNotifier()
      : super(
          const SettlementState(
            status: SettlementStatus.created,
            products: [],
            selectedProductIds: {},
            totalAmount: 0.0,
          ),
        ) {
    _loadInitialData();
  }

  /// Loads initial product data
  void _loadInitialData() {
    final products = MockDataService.loadMockProducts();
    final totalAmount = MockDataService.calculateTotalAmount(products);

    state = state.copyWith(
      products: products,
      totalAmount: totalAmount,
    );
  }

  /// Toggles the selection state of a product
  void toggleProductSelection(String productId) {
    final newSelectedIds = Set<String>.from(state.selectedProductIds);

    if (newSelectedIds.contains(productId)) {
      newSelectedIds.remove(productId);
    } else {
      newSelectedIds.add(productId);
    }

    state = state.copyWith(selectedProductIds: newSelectedIds);
  }

  /// Selects all products
  void selectAllProducts() {
    final allProductIds = state.products.map((product) => product.id).toSet();
    state = state.copyWith(selectedProductIds: allProductIds);
  }

  /// Clears all product selections
  void clearAllSelections() {
    state = state.copyWith(selectedProductIds: {});
  }

  /// Changes the settlement status
  void changeStatus(SettlementStatus newStatus) {
    state = state.copyWith(status: newStatus);
  }

  /// Processes payment for selected products
  Future<void> processPayment() async {
    if (!state.canProcessPayment) return;

    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await PaymentService.processPayment(
        products: state.selectedProducts,
        amount: state.selectedTotalPrice,
      );

      if (result.isSuccess) {
        // Payment successful - update status to unpaid (waiting for confirmation)
        state = state.copyWith(
          status: SettlementStatus.unpaid,
          isLoading: false,
        );
      } else {
        // Payment failed - show error
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      // Handle unexpected errors
      state = state.copyWith(
        isLoading: false,
        errorMessage: '支付过程中发生未知错误: ${e.toString()}',
      );
    }
  }

  /// Clears the current error message
  void clearError() {
    state = state.clearError();
  }

  /// Refreshes the product list (for future extension)
  Future<void> refreshProducts() async {
    // In a real app, this would fetch from an API
    _loadInitialData();
  }

  /// Updates product quantity (for future extension)
  void updateProductQuantity(String productId, int newQuantity) {
    if (newQuantity <= 0) return;

    final updatedProducts = state.products.map((product) {
      if (product.id == productId) {
        return product.copyWith(quantity: newQuantity);
      }
      return product;
    }).toList();

    final newTotalAmount = MockDataService.calculateTotalAmount(updatedProducts);

    state = state.copyWith(
      products: updatedProducts,
      totalAmount: newTotalAmount,
    );
  }

  /// Removes a product from the list (for future extension)
  void removeProduct(String productId) {
    final updatedProducts = state.products.where((product) => product.id != productId).toList();
    final newSelectedIds = Set<String>.from(state.selectedProductIds)..remove(productId);
    final newTotalAmount = MockDataService.calculateTotalAmount(updatedProducts);

    state = state.copyWith(
      products: updatedProducts,
      selectedProductIds: newSelectedIds,
      totalAmount: newTotalAmount,
    );
  }

  /// Resets the settlement to initial state
  void reset() {
    state = const SettlementState(
      status: SettlementStatus.created,
      products: [],
      selectedProductIds: {},
      totalAmount: 0.0,
    );
    _loadInitialData();
  }
}
