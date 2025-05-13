import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apidioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://dummyjson.com/'));
});