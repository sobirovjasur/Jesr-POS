import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/ordered_product_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../domain/usecases/transaction_usecases.dart';
import '../auth/auth_notifier.dart';
import '../products/products_notifier.dart';
import '../transactions/transactions_notifier.dart';
import 'home_state.dart';

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  /// Cart items that are checked (to be sold).
  List<OrderedProductEntity> get selectedProducts =>
      state.orderedProducts.where((e) => !state.unselectedProductIds.contains(e.productId)).toList();

  /// Cart items that are unchecked (recorded as a "returned" transaction).
  List<OrderedProductEntity> get unselectedProducts =>
      state.orderedProducts.where((e) => state.unselectedProductIds.contains(e.productId)).toList();

  int getSelectedTotal() => selectedProducts.fold(0, (sum, e) => sum + e.price * e.quantity);

  void toggleSelection(int productId) {
    final ids = {...state.unselectedProductIds};

    if (!ids.add(productId)) ids.remove(productId);

    state = state.copyWith(unselectedProductIds: ids);
  }

  Future<Result<int>> _createTransaction(
    List<OrderedProductEntity> items, {
    required String status,
    required int receivedAmount,
  }) async {
    final user = ref.read(authNotifierProvider).user!;
    final total = items.fold<int>(0, (sum, e) => sum + e.price * e.quantity);

    final transaction = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch,
      paymentMethod: state.selectedPaymentMethod,
      status: status,
      customerName: state.customerName,
      description: state.description,
      orderedProducts: items,
      createdById: user.id,
      createdBy: user,
      receivedAmount: receivedAmount,
      returnAmount: status == 'sold' ? receivedAmount - total : 0,
      totalOrderedProduct: items.length,
      totalAmount: total,
    );

    final transactionRepository = ref.read(transactionRepositoryProvider);
    final res = await CreateTransactionUsecase(transactionRepository).call(transaction);

    if (res.isSuccess) {
      // Auto print receipt (fire-and-forget, ignore failure)
      ref.read(printerServiceProvider).printTransaction(transaction);
    }

    return res;
  }

  /// Checkout: checked items become a `sold` transaction; unchecked items
  /// become a separate `returned` transaction. Returns the primary (sold, or
  /// returned if nothing was sold) transaction id.
  Future<Result<int>> pay() async {
    try {
      if (!ref.read(authNotifierProvider).isAuthenticated) throw 'Unauthenticated!';

      final selected = selectedProducts;
      final unselected = unselectedProducts;
      if (selected.isEmpty && unselected.isEmpty) throw 'Корзина пуста';

      Result<int>? primary;

      if (selected.isNotEmpty) {
        primary = await _createTransaction(selected, status: 'sold', receivedAmount: state.receivedAmount);
        if (primary.isFailure) return primary;
      }

      if (unselected.isNotEmpty) {
        final returned = await _createTransaction(unselected, status: 'returned', receivedAmount: 0);
        if (returned.isFailure) return returned;
        primary ??= returned;
      }

      ref.read(productsNotifierProvider.notifier).getAllProducts();
      state = const HomeState();

      return primary!;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Postpone the whole cart as a `postponed` transaction.
  Future<Result<int>> postpone() async {
    try {
      if (!ref.read(authNotifierProvider).isAuthenticated) throw 'Unauthenticated!';
      if (state.orderedProducts.isEmpty) throw 'Корзина пуста';

      final res = await _createTransaction(state.orderedProducts, status: 'postponed', receivedAmount: 0);
      if (res.isSuccess) state = const HomeState();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Reopen a postponed transaction back into the cart.
  void loadFromTransaction(TransactionEntity transaction) {
    state = state.copyWith(
      orderedProducts: transaction.orderedProducts ?? const [],
      unselectedProductIds: {},
    );
  }

  /// Resume a postponed transaction: load its items into the cart and remove
  /// the postponed record (it is being completed now).
  Future<void> resumePostponed(TransactionEntity transaction) async {
    loadFromTransaction(transaction);

    if (transaction.id != null) {
      final transactionRepository = ref.read(transactionRepositoryProvider);
      await DeleteTransactionUsecase(transactionRepository).call(transaction.id!);
      ref.read(transactionsNotifierProvider.notifier).getAllTransactions();
    }
  }

  void onChangedIsPanelExpanded(bool val) {
    state = state.copyWith(isPanelExpanded: val);
  }

  void onAddOrderedProduct(ProductEntity product, int qty) {
    final orderedProducts = [...state.orderedProducts];
    var currentIndex = orderedProducts.indexWhere((e) => e.productId == product.id);

    if (currentIndex != -1) {
      orderedProducts[currentIndex] = orderedProducts[currentIndex].copyWith(quantity: qty);
    } else {
      var order = OrderedProductEntity(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: product.id!,
        quantity: qty,
        stock: product.stock,
        name: product.name,
        imageUrl: product.imageUrl,
        price: product.price,
      );

      orderedProducts.add(order);
    }

    state = state.copyWith(orderedProducts: orderedProducts);
  }

  void onRemoveOrderedProduct(OrderedProductEntity val) {
    state = state.copyWith(
      orderedProducts: state.orderedProducts.where((e) => e != val).toList(),
    );
  }

  void onRemoveAllOrderedProduct() {
    state = const HomeState();
  }

  void onChangedOrderedProductQuantity(int index, int value) {
    final orderedProducts = [...state.orderedProducts];
    orderedProducts[index] = orderedProducts[index].copyWith(quantity: value);
    state = state.copyWith(orderedProducts: orderedProducts);
  }

  void onChangedReceivedAmount(int value) {
    state = state.copyWith(receivedAmount: value);
  }

  void onChangedPaymentMethod(String? value) {
    state = state.copyWith(selectedPaymentMethod: value ?? state.selectedPaymentMethod);
  }

  void onChangedCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void onChangedDescription(String value) {
    state = state.copyWith(description: value);
  }

  int getTotalAmount() {
    if (state.orderedProducts.isEmpty) return 0;
    return state.orderedProducts.map((e) => e.price * e.quantity).reduce((a, b) => a + b);
  }
}
