import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:helper_1/isolates_example/data/api_call.dart';

import '../../api_provider.dart';
import '../model/model.dart';

final

class PaginationApiService {
  final Dio dio;
  PaginationApiService(this.dio);
  Future<Either<ApiFailure, List<Product>>> getPaginatedData(int skip, int limit) async {
    try {
      final response = await dio.get('products', queryParameters: {
        'limit': limit,
        'skip': skip,
        'select': 'title,price',
      });

      if(response.statusCode == 200){
        final data = response.data['products'] as List;
        return right(data.map((e)=> Product.fromJson(e)).toList());
      }
      if(response.statusCode == 404){
        return left(ApiFailure('Products not found'));
      }
      // Add a fallback return for other status codes
      return left(ApiFailure('Unexpected status code: ${response.statusCode}'));
    } on DioException catch (e) {
      return left(ApiFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(ApiFailure(e.toString()));
    }
  }
}

final paginationapiServiceProvider = Provider<PaginationApiService>((ref) {
  final dio = ref.watch(apidioProvider);
  return PaginationApiService(dio);
});