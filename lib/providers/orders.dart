import 'dart:convert';
import 'package:course_unit_7/models/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;
  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/orders.json');
    final timestamp = DateTime.now();
    try {
      final res = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts.map((cp) {
              return {
                'id': cp.id,
                'title': cp.title,
                'quantity': cp.quantity,
                'price': cp.price,
              };
            }).toList(),
            'dateTime': timestamp.toIso8601String(),
          }));
      final id = json.decode(res.body)['name'];
      final newOrder = OrderItem(
        id: id,
        amount: total,
        products: cartProducts,
        datetime: timestamp,
      );
      orders.insert(0, newOrder);
      notifyListeners();
    } catch (err) {
      throw HttpException(message: err.toString());
    }
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shops-app-8f216-default-rtdb.firebaseio.com/orders.json');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedData.forEach((key, value) {
        loadedOrders.add(OrderItem(
          id: key,
          amount: value['amount'],
          products: (value['products'] as List<dynamic>)
              .map((value) => CartItem(
                    id: value['id'],
                    title: value['title'],
                    quantity: value['quantity'],
                    price: value['price'],
                  ))
              .toList(),
          datetime: DateTime.parse(value['dateTime']),
        ));
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }
}
