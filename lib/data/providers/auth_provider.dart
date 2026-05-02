import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _dio = Dio(BaseOptions(baseUrl: "URL_DE_TON_ENV"));
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post('/auth/agent/login', data: {
        'email': email,
        'pass': password, // Correspond à ton backend NestJS[cite: 7]
      });

      if (response.statusCode == 201) {
        String token = response.data['access_token'];
        await _storage.write(key: 'token', value: token);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}