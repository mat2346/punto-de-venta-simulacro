import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/notification_service.dart';

class FCMProvider extends ChangeNotifier {
  String? _fcmToken;
  bool _isInitialized = false;
  
  // Getter para obtener el token
  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  bool get hasToken => _fcmToken != null && _fcmToken!.isNotEmpty;
  
  // Método para inicializar y obtener el token
  Future<void> initializeFCM() async {
    try {
      print('🔥 Inicializando FCM Provider...');
      
      // Inicializar Firebase y notificaciones
      await NotificationService.initialize();
      
      // Obtener el token FCM
      await _getFCMToken();
      
      // Configurar listener para cambios de token
      _setupTokenRefreshListener();
      
      _isInitialized = true;
      notifyListeners();
      
      print('✅ FCM Provider inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando FCM Provider: $e');
    }
  }
  
  // Método privado para obtener el token
  Future<void> _getFCMToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      
      if (token != null && token.isNotEmpty) {
        _fcmToken = token;
        print('🔑 FCM Token obtenido y guardado: ${token.substring(0, 20)}...');
        notifyListeners();
      } else {
        print('❌ No se pudo obtener el FCM token');
      }
    } catch (e) {
      print('❌ Error obteniendo FCM token: $e');
    }
  }
  
  // Configurar listener para renovación automática del token
  void _setupTokenRefreshListener() {
    try {
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        print('🔄 Token FCM renovado: ${newToken.substring(0, 20)}...');
        _fcmToken = newToken;
        notifyListeners();
      });
    } catch (e) {
      print('❌ Error configurando listener de renovación de token: $e');
    }
  }
  
  // Método para forzar renovación del token
  Future<void> refreshToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
      await _getFCMToken();
    } catch (e) {
      print('❌ Error renovando token FCM: $e');
    }
  }
  
  // Método para limpiar el token (logout)
  void clearToken() {
    _fcmToken = null;
    notifyListeners();
    print('🧹 Token FCM limpiado');
  }
  
  // Método para debug - mostrar token completo
  void showFullToken() {
    if (_fcmToken != null) {
      print('🔑 FCM Token completo: $_fcmToken');
    } else {
      print('❌ No hay token FCM disponible');
    }
  }

  // Método para debug - agregar este método
  void debugStatus() {
    print('=== FCM PROVIDER DEBUG ===');
    print('Inicializado: $_isInitialized');
    print('Tiene token: $hasToken');
    print('Token length: ${_fcmToken?.length ?? 0}');
    if (_fcmToken != null) {
      print('Token preview: ${_fcmToken!.substring(0, 30)}...');
    }
    print('========================');
  }
}