import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:field_login/widgets/settlement/settlement.dart';

void main() {
  group('Settlement Component Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Product Model Tests', () {
      test('Product model should be created correctly', () {
        const product = Product(
          id: '1',
          name: 'Test Product',
          image: 'test.jpg',
          price: 99.99,
          quantity: 2,
          description: 'Test Description',
        );

        expect(product.id, '1');
        expect(product.name, 'Test Product');
        expect(product.price, 99.99);
        expect(product.quantity, 2);
      });

      test('Product equality should work correctly', () {
        const product1 = Product(
          id: '1',
          name: 'Product 1',
          image: 'test1.jpg',
          price: 99.99,
          quantity: 1,
          description: 'Description 1',
        );

        const product2 = Product(
          id: '1',
          name: 'Product 2',
          image: 'test2.jpg',
          price: 199.99,
          quantity: 2,
          description: 'Description 2',
        );

        const product3 = Product(
          id: '2',
          name: 'Product 3',
          image: 'test3.jpg',
          price: 299.99,
          quantity: 1,
          description: 'Description 3',
        );

        expect(product1, equals(product2)); // Same ID
        expect(product1, isNot(equals(product3))); // Different ID
      });

      test('Product copyWith should work correctly', () {
        const original = Product(
          id: '1',
          name: 'Original',
          image: 'original.jpg',
          price: 99.99,
          quantity: 1,
          description: 'Original Description',
        );

        final updated = original.copyWith(name: 'Updated', price: 199.99);

        expect(updated.id, original.id);
        expect(updated.name, 'Updated');
        expect(updated.price, 199.99);
        expect(updated.quantity, original.quantity);
      });
    });

    group('SettlementState Tests', () {
      test('SettlementState should be created with default values', () {
        const state = SettlementState(
          status: SettlementStatus.created,
          products: [],
          selectedProductIds: {},
          totalAmount: 0.0,
        );

        expect(state.status, SettlementStatus.created);
        expect(state.products, isEmpty);
        expect(state.selectedProductIds, isEmpty);
        expect(state.totalAmount, 0.0);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
      });

      test('SettlementState computed properties should work correctly', () {
        const products = [
          Product(
            id: '1',
            name: 'Product 1',
            image: 'test1.jpg',
            price: 100.0,
            quantity: 2,
            description: 'Description 1',
          ),
          Product(
            id: '2',
            name: 'Product 2',
            image: 'test2.jpg',
            price: 200.0,
            quantity: 1,
            description: 'Description 2',
          ),
        ];

        const state = SettlementState(
          status: SettlementStatus.created,
          products: products,
          selectedProductIds: {'1'},
          totalAmount: 400.0,
        );

        expect(state.selectedProducts.length, 1);
        expect(state.selectedProducts.first.id, '1');
        expect(state.hasSelectedProducts, true);
        expect(state.selectedTotalPrice, 200.0); // 100.0 * 2
      });

      test('SettlementState with no selections', () {
        const products = [
          Product(
            id: '1',
            name: 'Product 1',
            image: 'test1.jpg',
            price: 100.0,
            quantity: 1,
            description: 'Description 1',
          ),
        ];

        const state = SettlementState(
          status: SettlementStatus.created,
          products: products,
          selectedProductIds: {},
          totalAmount: 100.0,
        );

        expect(state.selectedProducts, isEmpty);
        expect(state.hasSelectedProducts, false);
        expect(state.selectedTotalPrice, 0.0);
      });
    });

    group('SettlementNotifier Tests', () {
      test('Initial state should be correct', () {
        final notifier = container.read(settlementProvider.notifier);
        final state = container.read(settlementProvider);

        expect(state.status, SettlementStatus.created);
        expect(state.products.length, 6); // Mock data has 6 products
        expect(state.selectedProductIds, isEmpty);
        expect(state.isLoading, false);
        expect(state.errorMessage, isNull);
      });

      test('toggleProductSelection should work correctly', () {
        final notifier = container.read(settlementProvider.notifier);

        // Select a product
        notifier.toggleProductSelection('1');
        var state = container.read(settlementProvider);
        expect(state.selectedProductIds.contains('1'), true);

        // Deselect the same product
        notifier.toggleProductSelection('1');
        state = container.read(settlementProvider);
        expect(state.selectedProductIds.contains('1'), false);
      });

      test('selectAllProducts should select all products', () {
        final notifier = container.read(settlementProvider.notifier);

        notifier.selectAllProducts();
        final state = container.read(settlementProvider);

        expect(state.selectedProductIds.length, state.products.length);
        for (final product in state.products) {
          expect(state.selectedProductIds.contains(product.id), true);
        }
      });

      test('clearAllSelections should clear all selections', () {
        final notifier = container.read(settlementProvider.notifier);

        // First select all
        notifier.selectAllProducts();
        expect(container.read(settlementProvider).selectedProductIds.isNotEmpty, true);

        // Then clear all
        notifier.clearAllSelections();
        expect(container.read(settlementProvider).selectedProductIds.isEmpty, true);
      });

      test('changeStatus should update status correctly', () {
        final notifier = container.read(settlementProvider.notifier);

        // Change to unpaid
        notifier.changeStatus(SettlementStatus.unpaid);
        expect(container.read(settlementProvider).status, SettlementStatus.unpaid);

        // Change back to created
        notifier.changeStatus(SettlementStatus.created);
        expect(container.read(settlementProvider).status, SettlementStatus.created);
      });

      test('processPayment should handle empty selection', () async {
        final notifier = container.read(settlementProvider.notifier);

        // Try to process payment with no selections
        await notifier.processPayment();

        final state = container.read(settlementProvider);
        expect(state.isLoading, false);
        expect(state.status, SettlementStatus.created); // Status should remain unchanged
      });

      test('processPayment should update loading state', () async {
        final notifier = container.read(settlementProvider.notifier);

        // Select a product first
        notifier.toggleProductSelection('1');

        // Start payment process (but don't await)
        final paymentFuture = notifier.processPayment();

        // Check loading state immediately
        var state = container.read(settlementProvider);
        expect(state.isLoading, true);

        // Wait for completion
        await paymentFuture;

        state = container.read(settlementProvider);
        expect(state.isLoading, false);
      });
    });

    group('Price Calculation Tests', () {
      test('selectedTotalPrice should calculate correctly', () {
        const products = [
          Product(
            id: '1',
            name: 'Product 1',
            image: 'test1.jpg',
            price: 10.50,
            quantity: 3,
            description: 'Description 1',
          ),
          Product(
            id: '2',
            name: 'Product 2',
            image: 'test2.jpg',
            price: 25.99,
            quantity: 2,
            description: 'Description 2',
          ),
          Product(
            id: '3',
            name: 'Product 3',
            image: 'test3.jpg',
            price: 100.00,
            quantity: 1,
            description: 'Description 3',
          ),
        ];

        const state = SettlementState(
          status: SettlementStatus.created,
          products: products,
          selectedProductIds: {'1', '3'}, // Select products 1 and 3
          totalAmount: 0.0,
        );

        final expectedTotal = (10.50 * 3) + (100.00 * 1); // 31.50 + 100.00 = 131.50
        expect(state.selectedTotalPrice, expectedTotal);
      });

      test('selectedTotalPrice should be zero with no selections', () {
        const products = [
          Product(
            id: '1',
            name: 'Product 1',
            image: 'test1.jpg',
            price: 100.0,
            quantity: 1,
            description: 'Description 1',
          ),
        ];

        const state = SettlementState(
          status: SettlementStatus.created,
          products: products,
          selectedProductIds: {},
          totalAmount: 100.0,
        );

        expect(state.selectedTotalPrice, 0.0);
      });
    });
  });
}
