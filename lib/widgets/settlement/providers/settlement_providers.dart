import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settlement_state.dart';
import '../models/settlement_status.dart';
import '../notifiers/settlement_notifier.dart';

/// Main settlement provider managing the settlement state
final settlementProvider = StateNotifierProvider<SettlementNotifier, SettlementState>((ref) {
  return SettlementNotifier();
});

/// Provider for selected products count
final selectedProductsCountProvider = Provider<int>((ref) {
  final state = ref.watch(settlementProvider);
  return state.selectedProductIds.length;
});

/// Provider for selected products total price
final selectedTotalPriceProvider = Provider<double>((ref) {
  final state = ref.watch(settlementProvider);
  return state.selectedTotalPrice;
});

/// Provider for whether all products are selected
final isAllProductsSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(settlementProvider);
  return state.isAllProductsSelected;
});

/// Provider for whether payment can be processed
final canProcessPaymentProvider = Provider<bool>((ref) {
  final state = ref.watch(settlementProvider);
  return state.canProcessPayment;
});

/// Provider for current settlement status display name
final settlementStatusDisplayProvider = Provider<String>((ref) {
  final state = ref.watch(settlementProvider);
  return state.status.displayName;
});

/// Provider for whether there's an error
final hasErrorProvider = Provider<bool>((ref) {
  final state = ref.watch(settlementProvider);
  return state.errorMessage != null;
});

/// Provider for the current error message
final errorMessageProvider = Provider<String?>((ref) {
  final state = ref.watch(settlementProvider);
  return state.errorMessage;
});

/// Provider for loading state
final isLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(settlementProvider);
  return state.isLoading;
});
