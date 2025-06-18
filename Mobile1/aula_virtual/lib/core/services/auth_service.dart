import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';
import '../utils/storage.util.dart';
import '../models/user_model.dart';
import '../providers/fcm_provider.dart';  // 🔥 Agregar

class LoginResult {
  final bool success;
  final String message;
  
  LoginResult.success(this.message) : success = true;
  LoginResult.error(this.message) : success = false;
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  FCMProvider? _fcmProvider;  // 🔥 Referencia al FCM Provider
  
  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get userRole => _currentUser?.rol;
  
  // 🔥 Método para inyectar el FCM Provider
  void setFCMProvider(FCMProvider fcmProvider) {
    _fcmProvider = fcmProvider;
  }
  
  Future<void> init() async {
    try {
      // Verificar si hay una sesión guardada
      final accessToken = await StorageUtil.getAccessToken();
      final userData = await StorageUtil.getUserData();
      
      if (accessToken != null && userData != null) {
        _currentUser = User.fromJson(userData);
        _isLoggedIn = true;
        print('✅ Sesión restaurada para: ${_currentUser?.nombre}');
        
        // 🔥 Enviar token FCM si está disponible
        _sendFCMTokenIfAvailable();
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error inicializando AuthService: $e');
    }
  }
  
  Future<LoginResult> login(String codigo, String password) async {
    print('🚀 === INICIANDO LOGIN DEBUG ===');
    print('📍 URL: ${ApiConstants.apiUrl}/login/');
    print('👤 Código: $codigo');
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // 🔥 Preparar datos de login con FCM token
      final loginData = {
        'codigo': codigo,
        'password': password,
      };
      
      // 🔥 Debug del FCM Provider
      print('🔥 FCM Provider estado:');
      print('   - Provider disponible: ${_fcmProvider != null}');
      print('   - Provider inicializado: ${_fcmProvider?.isInitialized}');
      print('   - Tiene token: ${_fcmProvider?.hasToken}');
      
      // 🔥 Agregar FCM token si está disponible
      if (_fcmProvider?.hasToken == true) {
        final token = _fcmProvider!.fcmToken!;
        loginData['fcm_token'] = token;
        print('🔑 FCM Token agregado:');
        print('   - Length: ${token.length}');
        print('   - Preview: ${token.substring(0, 30)}...');
      } else {
        print('⚠️ NO hay FCM token disponible');
        print('   - Provider null: ${_fcmProvider == null}');
        print('   - Token null: ${_fcmProvider?.fcmToken == null}');
        print('   - Token empty: ${_fcmProvider?.fcmToken?.isEmpty}');
      }
      
      print('📤 Datos a enviar: ${json.encode(loginData)}');
      
      final response = await http.post(
        Uri.parse('${ApiConstants.apiUrl}/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(loginData),
      );
      
      print('📥 Respuesta recibida:');
      print('   - Status: ${response.statusCode}');
      print('   - Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // 🔥 Verificar respuesta del FCM token
        bool fcmUpdated = responseData['fcm_token_updated'] ?? false;
        print('🔥 FCM Token actualizado según servidor: $fcmUpdated');
        
        // Guardar tokens y datos del usuario
        await StorageUtil.saveTokens(
          responseData['access'], 
          responseData['refresh']
        );
        
        _currentUser = User.fromJson(responseData['usuario']);
        await StorageUtil.saveUserData(_currentUser!.toJson());
        
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        
        print('✅ Login exitoso para: ${_currentUser?.nombre} (${_currentUser?.rol})');
        return LoginResult.success('Login exitoso');
      } else {
        _isLoading = false;
        notifyListeners();
        
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Error en las credenciales';
        print('❌ Error de login: $errorMessage');
        return LoginResult.error(errorMessage);
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      
      print('❌ Excepción en login: $e');
      return LoginResult.error('Error de conexión. Verifica tu internet.');
    }
  }
  
  // 🔥 Método privado para enviar FCM token
  void _sendFCMTokenIfAvailable() {
    if (_fcmProvider?.hasToken == true && _isLoggedIn) {
      _sendFCMTokenToServer(_fcmProvider!.fcmToken!);
    }
  }
  
  // 🔥 Enviar FCM token al servidor
  Future<void> _sendFCMTokenToServer(String fcmToken) async {
    try {
      final accessToken = await StorageUtil.getAccessToken();
      if (accessToken == null) return;
      
      final response = await http.post(
        Uri.parse('${ApiConstants.apiUrl}/usuario/fcm-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({'fcm_token': fcmToken}),
      );
      
      if (response.statusCode == 200) {
        print('✅ FCM token enviado al servidor exitosamente desde AuthService');
      } else {
        print('❌ Error enviando FCM token desde AuthService: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error enviando FCM token desde AuthService: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      // 🔥 Limpiar FCM token
      _fcmProvider?.clearToken();
      
      // Limpiar datos locales
      await StorageUtil.clearAll();
      
      _currentUser = null;
      _isLoggedIn = false;
      notifyListeners();
      
      print('✅ Logout exitoso');
    } catch (e) {
      print('❌ Error en logout: $e');
    }
  }
  
  // 🔥 Método para debug - mostrar estado completo
  void debugStatus() {
    print('=== AUTH SERVICE DEBUG ===');
    print('Usuario logueado: $_isLoggedIn');
    print('Usuario actual: ${_currentUser?.nombre} (${_currentUser?.rol})');
    print('FCM Provider disponible: ${_fcmProvider != null}');
    print('FCM Token disponible: ${_fcmProvider?.hasToken}');
    if (_fcmProvider?.hasToken == true) {
      _fcmProvider!.showFullToken();
    }
    print('========================');
  }
}