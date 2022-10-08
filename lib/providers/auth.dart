import 'dart:convert';
import '../models/http_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// AIzaSyBdJYLswsqQ_muRv0Fxpx384Lo0zc1XeyI
class Auth with ChangeNotifier {
  String _token = "";
  DateTime _expiryDate = DateTime.now();
  String _userId = "";

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyBdJYLswsqQ_muRv0Fxpx384Lo0zc1XeyI');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(message: responseData['error']['message']);
      }
      print(json.decode(response.body));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBdJYLswsqQ_muRv0Fxpx384Lo0zc1XeyI');
    final response = await http.post(
      url,
      body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print(json.decode(response.body));
  }
}
