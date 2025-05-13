// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../model/api_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ApiFailure {
//   final String message;
//   ApiFailure(this.message);
// }

// // Function to parse JSON in an isolate
// List<ApiModel> _parseJson(String jsonString) {
//   final stopwatch = Stopwatch()..start();
//   final List<dynamic> data = jsonDecode(jsonString);
//   final models = data.map((item) => ApiModel.fromMap(item)).toList();
//   print('JSON parsing took: ${stopwatch.elapsedMilliseconds} ms');
//   return models;
// }

// // Dio provider
// final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
//       connectTimeout: Duration(seconds: 5),
//       receiveTimeout: Duration(seconds: 10),
//     )));

// // API call class
// class ApiCall {
//   final Dio dio;
//   final String apiUrl;
//   final bool parseOnMainThread; // Toggle for testing jank

//   ApiCall(this.dio, this.apiUrl, {this.parseOnMainThread = false});

//   Future<Either<List<ApiModel>, ApiFailure>> fetchData() async {
//     try {
//       final stopwatch = Stopwatch()..start();
//       print('Fetching data from API: $apiUrl');
//       final response = await dio.get(apiUrl);
//       print('Response status code: ${response.statusCode}, fetch took: ${stopwatch.elapsedMilliseconds} ms');

//       if (response.statusCode == 200) {
//         final jsonString = jsonEncode(response.data); // Convert response to JSON string
//         final models = parseOnMainThread
//             ? _parseJson(jsonString) // Parse on main thread to cause jank
//             : await compute(_parseJson, jsonString); // Parse in isolate for smooth performance
//         print('Total fetchData time: ${stopwatch.elapsedMilliseconds} ms, ${models.length} items');
//         return Left(models);
//       } else {
//         print('Non-200 status code: ${response.statusCode}');
//         return Right(ApiFailure('Failed to load data: ${response.statusCode}'));
//       }
//     } on DioException catch (e) {
//       print('DioException: ${e.message}');
//       return Right(ApiFailure('Network error: ${e.message}'));
//     } catch (e) {
//       print('Exception: $e');
//       return Right(ApiFailure('Unexpected error: $e'));
//     }
//   }
// }

// // Provider for ApiCall
// final apiCallProvider = Provider<ApiCall>((ref) {
//   final dio = ref.watch(dioProvider);
//   // Replace with your actual API URL (e.g., for a 40MB response)
//   return ApiCall(dio, 'https://microsoftedge.github.io/Demos/json-dummy-data/5MB-min.json', parseOnMainThread: false);
// });

// class ApiFailure {
//   final String message;
//   ApiFailure(this.message);
// }

// List<ApiModel> _parseJson(String jsonString) {
//   final stopwatch = Stopwatch()..start();
//   final List<dynamic> data = jsonDecode(jsonString);
//   final models = data.map((item) => ApiModel.fromMap(item)).toList();
//   print('JSON parsing took: ${stopwatch.elapsedMilliseconds} ms');
//   return models;
// }

// class JsonReader {
//   final String assetPath;

//   JsonReader(this.assetPath);

//   Future<Either<List<ApiModel>, ApiFailure>> fetchData() async {
//     try {
//       final stopwatch = Stopwatch()..start();
//       print('Reading JSON from asset: $assetPath');
//       final jsonString = await rootBundle.loadString(assetPath);
//       print('JSON file loaded in ${stopwatch.elapsedMilliseconds} ms, size: ${jsonString.length} bytes');

//       final models = await compute(_parseJson, jsonString);
//       print('Total fetchData time: ${stopwatch.elapsedMilliseconds} ms');
//       return Left(models);
//     } catch (e) {
//       print('Exception: $e');
//       return Right(ApiFailure('Failed to load or parse JSON: $e'));
//     }
//   }
// }

// final jsonReaderProvider = Provider<JsonReader>((ref) {
//   return JsonReader('assets/40mb.json');
// });

// ignore_for_file: avoid_print

import 'dart:isolate';

class ApiFailure {
  final String message;
  ApiFailure(this.message);
}

// Message type for isolate communication
class IsolateMessage {
  final String jsonString;
  final SendPort sendPort;

  IsolateMessage(this.jsonString, this.sendPort);
}

// Isolate entry point for parsing JSON
void _parseJsonInIsolate(IsolateMessage message) {
  try {
    final stopwatch = Stopwatch()..start();
    final List<dynamic> data = jsonDecode(message.jsonString);
    final models = data.map((item) => ApiModel.fromMap(item)).toList();
    print('Isolate: JSON parsing took: ${stopwatch.elapsedMilliseconds} ms');
    message.sendPort.send(models);
  } catch (e) {
    print('Isolate: Exception: $e');
    message.sendPort.send(ApiFailure('Failed to parse JSON: $e'));
  }
}

// Dio provider
final dioProvider = Provider<Dio>((ref) => Dio(BaseOptions(
      connectTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 10),
    )));

// API call class
class ApiCall {
  final Dio dio;
  final String apiUrl;
  final bool parseOnMainThread; // Toggle for testing jank

  ApiCall(this.dio, this.apiUrl, {this.parseOnMainThread = false});

  Future<Either<List<ApiModel>, ApiFailure>> fetchData() async {
    try {
      final stopwatch = Stopwatch()..start();
      print('Fetching data from API: $apiUrl');
      final response = await dio.get(apiUrl);
      print('Response status code: ${response.statusCode}, fetch took: ${stopwatch.elapsedMilliseconds} ms');

      if (response.statusCode == 200) {
        final jsonString = jsonEncode(response.data); // Convert response to JSON string

        if (parseOnMainThread) {
          // Parse on main thread to cause jank
          final List<dynamic> data = jsonDecode(jsonString);
          final models = data.map((item) => ApiModel.fromMap(item)).toList();
          print('Main thread parsing took: ${stopwatch.elapsedMilliseconds} ms');
          return Left(models);
        } else {
          // Parse in a separate isolate
          final receivePort = ReceivePort();
          final isolate = await Isolate.spawn(
            _parseJsonInIsolate,
            IsolateMessage(jsonString, receivePort.sendPort),
          );

          // Wait for the result or error from the isolate
          final result = await receivePort.first;
          print(result);

          // Kill the isolate to free resources
          isolate.kill(priority: Isolate.immediate);
          receivePort.close();

          if (result is List<ApiModel>) {
            print('Total fetchData time: ${stopwatch.elapsedMilliseconds} ms, ${result.length} items');
            return Left(result);
          } else if (result is ApiFailure) {
            return Right(result);
          } else {
            return Right(ApiFailure('Unexpected isolate result: $result'));
          }
        }
      } else {
        print('Non-200 status code: ${response.statusCode}');
        return Right(ApiFailure('Failed to load data: ${response.statusCode}'));
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      return Right(ApiFailure('Network error: ${e.message}'));
    } catch (e) {
      print('Exception: $e');
      return Right(ApiFailure('Unexpected error: $e'));
    }
  }
}

// Provider for ApiCall
final apiCallProvider = Provider<ApiCall>((ref) {
  final dio = ref.watch(dioProvider);
  // Replace with your actual API URL (e.g., for a large response)
  return ApiCall(dio, 'https://microsoftedge.github.io/Demos/json-dummy-data/5MB.json', parseOnMainThread: false);
});