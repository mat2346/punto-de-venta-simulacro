import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/storage.util.dart';

class TutorService {
  static const String baseUrl = ApiConstants.apiUrl;

  // Headers con token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageUtil.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // Obtener lista de estudiantes hijos
  static Future<List<Map<String, dynamic>>> obtenerEstudiantes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tutor/estudiantes/'),
        headers: headers,
      );

      print('🔍 Estudiantes response: ${response.statusCode}');
      print('🔍 Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception('Error al obtener estudiantes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEstudiantes: $e');
      throw Exception('Error de conexión al obtener estudiantes');
    }
  }

  // Obtener resumen general de un hijo
  static Future<Map<String, dynamic>> obtenerResumenHijo(int estudianteId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tutor/hijo/$estudianteId/resumen/'),
        headers: headers,
      );

      print('🔍 Resumen hijo response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener resumen: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerResumenHijo: $e');
      throw Exception('Error de conexión al obtener resumen');
    }
  }

  // Obtener rendimiento detallado
  static Future<Map<String, dynamic>> obtenerRendimientoDetallado(int estudianteId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tutor/hijo/$estudianteId/rendimiento/'),
        headers: headers,
      );

      print('🔍 Rendimiento detallado response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener rendimiento: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerRendimientoDetallado: $e');
      throw Exception('Error de conexión al obtener rendimiento');
    }
  }
}