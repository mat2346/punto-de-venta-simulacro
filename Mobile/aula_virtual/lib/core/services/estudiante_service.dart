import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/storage.util.dart';
import '../models/materia_estudiante_model.dart';
import '../models/resumen_dashboard_model.dart';
import '../models/detalle_materia_estudiante_model.dart';
import '../models/actividad_estudiante_model.dart';
import '../models/asistencia_estudiante_model.dart';
import '../models/registro_asistencia_movil_model.dart';

// 🔥 SERVICIO PRINCIPAL PARA ESTUDIANTES
class EstudianteService {
  static const String baseUrl = ApiConstants.apiUrl;

  // 🔥 Headers con token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageUtil.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // 🔥 OBTENER RESUMEN DEL DASHBOARD
  static Future<ResumenDashboardModel> obtenerResumenDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/resumen/'), // ✅ Correcto
        headers: headers,
      );

      print('📊 Obteniendo resumen dashboard - Status: ${response.statusCode}');
      print('📊 Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ResumenDashboardModel.fromJson(jsonData);
      } else {
        throw Exception('Error al obtener resumen: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerResumenDashboard: $e');
      throw Exception('Error de conexión al obtener resumen');
    }
  }

  // 🔥 OBTENER MATERIAS DEL ESTUDIANTE - CORREGIDO
  static Future<List<MateriaEstudianteModel>> obtenerMaterias() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/materias/'), // 🔥 CAMBIADO: de estudiante a alumno
        headers: headers,
      );

      print('📚 Obteniendo materias estudiante - Status: ${response.statusCode}');
      print('📚 Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MateriaEstudianteModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener materias: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerMaterias: $e');
      throw Exception('Error de conexión al obtener materias');
    }
  }

  // 🔥 OBTENER DETALLE DE UNA MATERIA - CORREGIDO
  static Future<DetalleMateriaEstudianteModel> obtenerDetalleMateria(int materiaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/materia/$materiaId/detalle/'), // 🔥 CAMBIADO: agregado /detalle/
        headers: headers,
      );

      print('🔍 Obteniendo detalle materia $materiaId - Status: ${response.statusCode}');
      print('🔍 Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DetalleMateriaEstudianteModel.fromJson(jsonData);
      } else {
        throw Exception('Error al obtener detalle de materia: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerDetalleMateria: $e');
      throw Exception('Error de conexión al obtener detalle de materia');
    }
  }

  // 🔥 OBTENER ACTIVIDADES DE UNA MATERIA - CORREGIDO
  static Future<List<ActividadEstudianteModel>> obtenerActividadesMateria(int materiaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/materia/$materiaId/actividades/'), // 🔥 CAMBIADO: de estudiante a alumno
        headers: headers,
      );

      print('📝 Obteniendo actividades materia $materiaId - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActividadEstudianteModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener actividades: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerActividadesMateria: $e');
      throw Exception('Error de conexión al obtener actividades');
    }
  }

  // 🔥 OBTENER HISTORIAL DE ASISTENCIA - CORREGIDO
  static Future<List<AsistenciaEstudianteModel>> obtenerHistorialAsistencia(int materiaId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/materia/$materiaId/asistencias/'), // 🔥 CAMBIADO: de estudiante a alumno
        headers: headers,
      );

      print('📅 Obteniendo historial asistencia $materiaId - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AsistenciaEstudianteModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener historial: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerHistorialAsistencia: $e');
      throw Exception('Error de conexión al obtener historial');
    }
  }

  // 🔥 REGISTRARSE EN ASISTENCIA MÓVIL (MANTENER)
  static Future<RegistroAsistenciaMovilModel> registrarseAsistenciaMovil(String codigo) async {
    try {
      final headers = await _getHeaders();
      
      print('🔥 Registrando asistencia móvil con código: $codigo');
      
      final response = await http.post(
        Uri.parse('$baseUrl/estudiante/asistencia-movil/registrarse/'), // ✅ Esta URL es correcta según urls.py de materia
        headers: headers,
        body: jsonEncode({
          'codigo': codigo,
        }),
      );

      print('🔥 registrarseAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 registrarseAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return RegistroAsistenciaMovilModel.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        return RegistroAsistenciaMovilModel(
          success: false,
          message: errorData['error'] ?? 'Error al registrarse',
        );
      }
    } catch (e) {
      print('❌ Error en registrarseAsistenciaMovil: $e');
      return RegistroAsistenciaMovilModel(
        success: false,
        message: 'Error de conexión al registrarse',
      );
    }
  }

  // 🔥 OBTENER ESTADÍSTICAS GENERALES - CORREGIDO
  static Future<Map<String, dynamic>> obtenerEstadisticasGenerales() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alumno/estadisticas/'), // 🔥 CAMBIADO: de estudiante a alumno
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEstadisticasGenerales: $e');
      throw Exception('Error de conexión al obtener estadísticas');
    }
  }

  // 🔥 BUSCAR ACTIVIDADES POR FILTRO - CORREGIDO
  static Future<List<ActividadEstudianteModel>> buscarActividades({
    String? filtro,
    String? estado,
    int? materiaId,
  }) async {
    try {
      final headers = await _getHeaders();
      
      String url = '$baseUrl/alumno/actividades/'; // 🔥 CAMBIADO: de estudiante a alumno
      List<String> queryParams = [];
      
      if (filtro != null && filtro.isNotEmpty) {
        queryParams.add('buscar=$filtro');
      }
      if (estado != null && estado.isNotEmpty) {
        queryParams.add('estado=$estado');
      }
      if (materiaId != null) {
        queryParams.add('materia=$materiaId');
      }
      
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActividadEstudianteModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al buscar actividades: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en buscarActividades: $e');
      throw Exception('Error de conexión al buscar actividades');
    }
  }
}