import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_call.dart';
import '../model/api_model.dart';
import '../view/api_view.dart';

class ApiDataScreen extends ConsumerStatefulWidget {
  const ApiDataScreen({super.key});

  @override
  ConsumerState<ApiDataScreen> createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends ConsumerState<ApiDataScreen> {
  @override
  Widget build(BuildContext context) {
    final apiState = ref.watch(apiViewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(apiViewProvider.notifier).fetchData(),
          ),
        ],
      ),
      body: apiState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error is ApiFailure ? error.message : 'Error: $error',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(apiViewProvider.notifier).fetchData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No data available'));
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    item.name!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Language: ${item.email}'),
                      Text('ID: ${item.address}'),
                      SizedBox(height: 4),
                      Text(item.name!),
                      SizedBox(height: 4),
                    ],
                  ),
                  onTap: () {
                    _showItemDetails(context, item);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showItemDetails(BuildContext context, ApiModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name ?? ''),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: ${item.email}'),
              const SizedBox(height: 8),
              Text('Address: ${item.address}'),
              const SizedBox(height: 8),
              Text('ID: ${item.name}'),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
