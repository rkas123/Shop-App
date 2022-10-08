// ignore_for_file: prefer_final_fields
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

import '../models/http_exception.dart';

class Products with ChangeNotifier {
  var _showFavoritesOnly = false;
  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((element) => element.isFavorite == true).toList();
  }

  Product? findById(String id) {
    for (int index = 0; index < _items.length; index++) {
      if (_items[index].id == id) {
        return _items[index];
      }
    }
    return null;
  }

  Future<void> addProduct(Product product) {
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/products.json');
    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'descripton': product.description,
              'imageUrl': product.imageUrl,
              'price': product.price,
              'isFavorite': product.isFavorite,
            }))
        .then((response) {
      final id = json.decode(response.body)['name'];
      final newProduct = Product(
        id: id,
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    }).catchError((err) {
      throw err;
    });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/products/$id.json');
    try {
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/products/$id.json');
    final existingProdIndex = _items.indexWhere((element) => element.id == id);
    Product? existingProduct = _items[existingProdIndex];
    _items.removeAt(existingProdIndex);
    notifyListeners();

    final resp = await http.delete(url);
    if (resp.statusCode >= 400) {
      _items.insert(existingProdIndex, existingProduct);
      notifyListeners();
      throw HttpException(message: 'Could not delete the product');
    }
    existingProduct = null;
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/products.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
          id: key,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          imageUrl: value['imageUrl'],
          isFavorite: value['isFavorite'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }
}
