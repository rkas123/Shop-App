import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  // ignore: prefer_final_fields
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemcount {
    return _items.length;
  }

  void addItem(String id, double price, String title) {
    if (_items.containsKey(id)) {
      _items.update(
          id,
          (existingItem) => CartItem(
                id: existingItem.id,
                title: existingItem.title,
                quantity: existingItem.quantity + 1,
                price: existingItem.price,
              ));
    } else {
      _items.putIfAbsent(
          id,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                quantity: 1,
                price: price,
              ));
    }
    notifyListeners();
  }

  double get totalAmount {
    double sum = 0.0;
    _items.forEach((key, value) {
      sum += (value.price * value.quantity);
    });
    return sum;
  }

  void removeItem(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String id) {
    if (!_items.containsKey(id)) {
      return;
    }
    if (_items[id]!.quantity > 1) {
      _items.update(
          id,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                price: existingCartItem.price,
                title: existingCartItem.title,
                quantity: existingCartItem.quantity - 1,
              ));
    } else {
      _items.remove(id);
    }
    notifyListeners();
  }
}
