import 'dart:convert';

import 'package:course_unit_7/models/http_exception.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/products/$id.json');
    try {
      final resp = await http.patch(url,
          body: json.encode({
            'isFavorite': isFavorite,
          }));

      if (resp.statusCode >= 400) {
        isFavorite = !isFavorite;
        notifyListeners();
        throw HttpException(message: 'Change favorite Status Failed');
      }
    } catch (error) {
      rethrow;
    }
  }
}
