import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  Map<String, dynamic>? _agentProfile;
  Map<String, dynamic>? get agentProfile => _agentProfile;

  AuthProvider() {
    final baseUrl = dotenv.get('API_URL', fallback: 'http://localhost:3002');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          logout(); 
        }
        return handler.next(e);
      },
    ));
  }
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    try {
      final response = await _dio.get('/auth/agent/me');
      _agentProfile = response.data;
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors de la récupération du profil: $e');
    }
  }

  Future<bool> checkAuthStatus() async {
    String? token = await _storage.read(key: 'token');
    return token != null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.post('/auth/agent/login', data: {
        'email': email.trim(),
        'pass': password, 
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        String token = response.data['access_token'];
        await _storage.write(key: 'token', value: token);
        
        await fetchProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
      
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erreur Auth détaillée: ${e.response?.data ?? e.message}');
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Erreur système : $e');
      return false;
    }
  }

  Future<void> logout() async {
    _agentProfile = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}