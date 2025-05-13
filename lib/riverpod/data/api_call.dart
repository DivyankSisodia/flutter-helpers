import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:helper_1/api_provider.dart';

import '../../isolates_example/data/api_call.dart';
import '../model/product.dart';

class ApiService{

  final Dio dio;
  ApiService(this.dio);

  Future<Either<ApiFailure, ProductModel>> getSingleProduct() async {
    try {
      print('Fetching single product...');
      final res = await dio.get('products/1');
      print('Response: ${res.statusCode}');
      if(res.statusCode == 200){
        final data = res.data;
        print(data);
        return right(ProductModel.fromJson(data));
      }
      if(res.statusCode == 404){
        return left(ApiFailure('Product not found'));
      }
      // Add a fallback return for other status codes
      return left(ApiFailure('Unexpected status code: ${res.statusCode}'));
    } on DioException catch (e) {
      return left(ApiFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(ApiFailure(e.toString()));
    }
  }

  Future<Either<ApiFailure, List<ProductModel>>> getAllProducts() async {
    try {
      print('Fetching all products...');
      final res = await dio.get('products');
      print('Response: ${res.statusCode}');
      if(res.statusCode == 200){
        final data = res.data['products'] as List;
        return right(data.map((e) => ProductModel.fromJson(e)).toList());
      }
      if(res.statusCode == 404){
        return left(ApiFailure('Products not found'));
      }
      // Add a fallback return for other status codes
      return left(ApiFailure('Unexpected status code: ${res.statusCode}'));
    } on DioException catch (e) {
      return left(ApiFailure(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(ApiFailure(e.toString()));
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(apidioProvider);
  return ApiService(dio);
});