import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
  // ✅ Verifica antes de inicializar
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
          appId: '1:123456789:android:abcdefxxxxxxxxxxxxxxxx',
          messagingSenderId: '123456789',
          projectId: 'colegio-cec69',
        ),
      );
      print("✅ Firebase Core inicializado");
    } catch (e) {
      print("❌ Error inicializando Firebase: $e");
    }
  } else {
    print("ℹ Firebase ya estaba inicializado");
  }

  // ✅ Esto se ejecuta siempre, sin importar si Firebase ya estaba iniciado
  await _requestPermissions();
  await _initializeLocalNotifications();
  _configureFirebaseHandlers();
  await _getFCMToken();
}


  
  static Future<void> _requestPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      print('📱 Permisos de notificación: ${settings.authorizationStatus}');
    } catch (e) {
      print('❌ Error solicitando permisos: $e');
    }
  }
  
  static Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          print('🔔 Notificación tocada: ${response.payload}');
        },
      );
      
      print("✅ Notificaciones locales inicializadas");
    } catch (e) {
      print('❌ Error inicializando notificaciones locales: $e');
    }
  }
  
  static void _configureFirebaseHandlers() {
    try {
      // Cuando la app está en foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📨 Mensaje recibido en foreground: ${message.notification?.title}');
        _showLocalNotification(message);
      });
      
      // Cuando la app está en background y se toca la notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📨 App abierta desde notificación: ${message.notification?.title}');
        _handleNotificationTap(message);
      });
      
      print("✅ Handlers de Firebase configurados");
    } catch (e) {
      print('❌ Error configurando handlers: $e');
    }
  }
  
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'aula_virtual_channel',
        'Aula Virtual',
        channelDescription: 'Notificaciones del aula virtual',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false,
      );
      
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
      
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        message.notification?.title ?? 'Aula Virtual',
        message.notification?.body ?? 'Nueva notificación',
        details,
        payload: message.data.toString(),
      );
    } catch (e) {
      print('❌ Error mostrando notificación local: $e');
    }
  }
  
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Aquí puedes navegar a una pantalla específica según el contenido
  }
  
  static Future<void> _getFCMToken() async {
  try {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('🔑 FCM Token obtenido en NotificationService: $token');
      // Ya no enviamos aquí, se maneja en FCMProvider y AuthService
    } else {
      print('❌ No se pudo obtener el FCM token');
    }
  } catch (e) {
    print('❌ Error obteniendo FCM token: $e');
  }
}

  
  // Método para actualizar token cuando el usuario hace login
  static Future<void> updateTokenAfterLogin() async {
    try {
      await _getFCMToken();
    } catch (e) {
      print('❌ Error actualizando token después del login: $e');
    }
  }
}