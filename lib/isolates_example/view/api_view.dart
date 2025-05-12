import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/isolates_example/data/api_call.dart';
import 'package:helper_1/isolates_example/model/api_model.dart';

class ApiView extends StateNotifier<AsyncValue<List<ApiModel>>> {
  final ApiCall apiCall;

  ApiView(this.apiCall) : super(const AsyncValue.loading()) {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      state = AsyncValue.loading();
      final result = await apiCall.fetchData();
      result.fold(
        (data) {
          print('Updating state with data: ${data.length} items');
          state = AsyncValue.data(data);
        },
        (error) {
          print('Updating state with error: ${error.message}');
          state = AsyncValue.error(error, StackTrace.current);
        },
      );
    } catch (e, stack) {
      print('Unexpected error in fetchData: $e');
      state = AsyncValue.error(e, stack);
    }
  }
}

final apiViewProvider = StateNotifierProvider<ApiView, AsyncValue<List<ApiModel>>>((ref) {
  final apiCall = ref.watch(apiCallProvider);
  return ApiView(apiCall);
});