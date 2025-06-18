class ApiConstants {
  // 🔥 Tu IP real de Wi-Fi
  static const String baseUrl = 'http://192.168.0.5:8000';
  static const String apiUrl = '$baseUrl/api';
  
  // Auth endpoints
  static const String loginEndpoint = '$apiUrl/login/';
  static const String tokenRefreshEndpoint = '$apiUrl/token/refresh/';
  
  // Profesor endpoints
  static const String profesorMateriasEndpoint = '$apiUrl/profesor/materias/';
  
  // Estudiante endpoints
  static const String estudianteResumenEndpoint = '$apiUrl/alumno/resumen/';
  
  // Tutor endpoints
  static const String tutorEstudiantesEndpoint = '$apiUrl/tutor/estudiantes/';
  
  // 🔥 Método para debug
  static void printCurrentConfig() {
    print('🌐 Base URL: $baseUrl');
    print('🔗 API URL: $apiUrl');
    print('🔑 Login URL: $loginEndpoint');
  }
}