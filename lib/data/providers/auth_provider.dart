import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  
  // Instance Dio pour les requêtes HTTP
  late final Dio _dio;

  AuthProvider() {
    // Récupération de l'URL de base depuis le fichier .env
    final baseUrl = dotenv.get('API_URL', fallback: 'http://localhost:3002');
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5), // Bonne pratique : ajout d'un timeout
      receiveTimeout: const Duration(seconds: 3),
    ));
  }
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Méthode de connexion pour les Agents (Desktop)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // CORRECTION : On envoie 'password' pour correspondre au DTO du Backend
      final response = await _dio.post('/auth/agent/login', data: {
        'email': email,
        'password': password, 
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Stockage sécurisé du jeton JWT
        String token = response.data['access_token'];
        await _storage.write(key: 'token', value: token);
        
        // Optionnel : Tu pourrais aussi stocker les infos de l'agent (nom, role) ici
        // await _storage.write(key: 'agent_role', value: response.data['agent']['role']);

        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
      
    } on DioException catch (e) {
      // Gestion plus fine des erreurs avec DioException
      _isLoading = false;
      notifyListeners();
      
      print('Erreur Auth: ${e.response?.data['message'] ?? e.message}');
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}