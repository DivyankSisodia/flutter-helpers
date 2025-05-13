// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:helper_1/pagination/data/pagination_api.dart';

import 'package:helper_1/riverpod/model/product.dart';

import '../model/model.dart';

class PaginationState {
  final List<Product> products;
  final bool isLoading;
  final String error;
  final int skip;
  final int limit;
  final int total;
  final bool hasReachedEnd;

  PaginationState({
    this.products = const [],
    this.isLoading = false,
    this.error =  '',
    this.skip = 0,
    this.limit = 10,
    this.total = 0,
    this.hasReachedEnd = false,
  });

  PaginationState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? skip,
    int? limit,
    int? total,
    bool? hasReachedEnd,
  }) {
    return PaginationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }
}

class PaginationViewModel extends StateNotifier<PaginationState>{

  final ScrollController myscrollController = ScrollController();
  final PaginationApiService paginationApiService;

  PaginationViewModel(this.paginationApiService) : super(PaginationState()) {
    myscrollController.addListener(_onScroll);
    fetchProducts();
  }

  ScrollController get scrollController => myscrollController;

  Future<void> fetchProducts() async {
    if (state.isLoading || state.hasReachedEnd) return;

    state = state.copyWith(isLoading: true, error: '');

    final result = await paginationApiService.getPaginatedData(state.skip, state.limit);
    result.fold(
      (error) => state = state.copyWith(
        isLoading: false,
        error: error.message,
      ),
      (data) {
        final newProducts = data;
        final updatedProducts = [...state.products, ...newProducts];
        state = state.copyWith(
          products: updatedProducts,
          isLoading: false,
          skip: state.skip + state.limit,
          total: state.total, // or update this if you have a way to get total
          hasReachedEnd: newProducts.isEmpty,
        );
      },
    );
  }

  void _onScroll() {
    if (myscrollController.position.pixels >=
        myscrollController.position.maxScrollExtent * 0.9) {
      fetchProducts();
    }
  }

  @override
  void dispose() {
    myscrollController.dispose();
    super.dispose();
  }
}

// / Providers
final paginationViewModelProvider = StateNotifierProvider<PaginationViewModel, PaginationState>(
  (ref) => PaginationViewModel(ref.read(paginationapiServiceProvider)),
);