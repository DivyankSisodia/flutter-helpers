import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/riverpod/data/api_call.dart';

import '../model/product.dart';

class MultipleProductViewModel extends StateNotifier<AsyncValue<List<ProductModel>>> {
  final ApiService apiService;
  MultipleProductViewModel(this.apiService) : super(const AsyncValue.loading());

  Future<void> fetchMultipleProducts() async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await apiService.getAllProducts();

      result.fold(
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          print('State: Error - $error');
        },
        (products) {
          state = AsyncValue.data(products);
          print('State: Data - ${products.length} products');
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final multipleproductviewmodelProvider = StateNotifierProvider<MultipleProductViewModel, AsyncValue<List<ProductModel>>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MultipleProductViewModel(apiService);
});