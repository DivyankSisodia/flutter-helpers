// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Cart {
  final int id;
  final String title;
  final String description;

  Cart({
    required this.id,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) => Cart.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CartNotifier extends StateNotifier<List<Cart>> {
  CartNotifier(): super([]);

  void addToCart(Cart cart){
    state.add(cart);
    state = state.toList();
  }

  void removeFromCart(int id){
    state.removeWhere((cart)=> cart.id == id);
    state = state.toList();
  }

  void clearCart(){
    state = [];
  }
  void updateCart(int id, Cart cart){
    final index = state.indexWhere((element) => element.id == id);
    if(index != -1){
      state[index] = cart;
      state = state.toList();
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier,List<Cart>>((ref) {
  return CartNotifier();
});