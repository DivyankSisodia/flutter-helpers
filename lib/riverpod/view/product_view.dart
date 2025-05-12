import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/riverpod/data/api_call.dart';
import 'package:helper_1/riverpod/model/product.dart';

class ProductViewModel extends StateNotifier<AsyncValue<ProductModel>> {
  final ApiService apiService;
  ProductViewModel(this.apiService) : super(const AsyncValue.loading());

  // Future<void> fetchProduct() async {
  //   if (state.isLoading) return; // Prevent multiple calls
  //   state = const AsyncValue.loading();
  //   final result = await apiService.getSingleProduct();
  //   result.fold(
  //     (error) => state = AsyncValue.error(error, StackTrace.current),
  //     (product) => state = AsyncValue.data(product),
  //   );
  // }
  Future<void> fetchSingleProduct() async {
    try {
      if (!state.isLoading) {
        state = const AsyncValue.loading();
      }

      final result = await apiService.getSingleProduct();

      result.fold(
        (error) {
          state = AsyncValue.error(error, StackTrace.current);
          print('State: Error - $error');
        },
        (project) {
          state = AsyncValue.data(project);
          print('State: Data - ${project.title}');
        },
      );

      // if success, naviagte to the project screen
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final productviewmodelProvider = StateNotifierProvider<ProductViewModel, AsyncValue<ProductModel>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProductViewModel(apiService);
});
