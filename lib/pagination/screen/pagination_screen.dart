import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/pagination/view/pagination.dart';

class PaginationScreen extends ConsumerWidget {
  const PaginationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationViewModelProvider);
    final viewModel = ref.read(paginationViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paginated Products')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paginationViewModelProvider);
        },
        child: state.error.isEmpty
            ? _buildListView(state, viewModel.scrollController)
            : Center(child: Text(state.error)),
      ),
    );
  }

  Widget _buildListView(PaginationState state, ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      itemCount: state.products.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.products.length && state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final product = state.products[index];
        return ListTile(
          title: Text(product.title!),
          subtitle: Text('\$${product.price!.toStringAsFixed(2)}'),
          leading: CircleAvatar(child: Text(product.id.toString())),
        );
      },
    );
  }
}