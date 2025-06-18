import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/storage.util.dart';

// 🔥 MODELO ESPECÍFICO PARA DESTINATARIOS (NO USER)
class DestinatarioModel {
  final int id;
  final String nombre;
  final String codigo; // Siempre como String
  final bool tieneFcmToken;

  DestinatarioModel({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tieneFcmToken,
  });

  factory DestinatarioModel.fromJson(Map<String, dynamic> json) {
    return DestinatarioModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'].toString(), // 🔥 CONVERTIR A STRING SIEMPRE
      tieneFcmToken: json['tiene_fcm_token'] ?? false,
    );
  }

  @override
  String toString() {
    return 'DestinatarioModel(id: $id, nombre: $nombre, codigo: $codigo)';
  }
}

class MateriaModel {
  final int detalleId;
  final String materia;
  final String curso;
  final String paralelo;

  MateriaModel({
    required this.detalleId,
    required this.materia,
    required this.curso,
    required this.paralelo,
  });

  factory MateriaModel.fromJson(Map<String, dynamic> json) {
    return MateriaModel(
      detalleId: json['detalle_id'],
      materia: json['materia'],
      curso: json['curso'],
      paralelo: json['paralelo'],
    );
  }

  String get nombreCompleto => '$materia - $curso $paralelo';
}

class EstudianteModel {
  final int id;
  final String nombre;
  final int libretaId;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.libretaId,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'],
      nombre: json['nombre'],
      libretaId: json['libreta_id'],
    );
  }
}

class ActividadModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String fechaCreacion;

  ActividadModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      fechaCreacion: json['fechaCreacion'],
    );
  }
}

class MateriaInfo {
  final int id;
  final String nombre;

  MateriaInfo({required this.id, required this.nombre});

  factory MateriaInfo.fromJson(Map<String, dynamic> json) {
    return MateriaInfo(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}

// 🔥 MODELO CORREGIDO PARA DESTINATARIOS
class DestinatariosModel {
  final List<DestinatarioModel> estudiantes; // 🔥 USAR DestinatarioModel
  final List<DestinatarioModel> tutores; // 🔥 USAR DestinatarioModel
  final MateriaInfo? materiaInfo;

  DestinatariosModel({
    required this.estudiantes,
    required this.tutores,
    this.materiaInfo,
  });

  factory DestinatariosModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parseando DestinatariosModel...');
    print('🔍 JSON recibido: $json');
    
    try {
      final estudiantesJson = json['estudiantes'] as List? ?? [];
      final tutoresJson = json['tutores'] as List? ?? [];
      
      print('🔍 Estudiantes JSON: $estudiantesJson');
      print('🔍 Tutores JSON: $tutoresJson');
      
      final estudiantes = estudiantesJson
          .map((e) {
            print('🔍 Parseando estudiante: $e');
            return DestinatarioModel.fromJson(e);
          })
          .toList();
          
      final tutores = tutoresJson
          .map((e) {
            print('🔍 Parseando tutor: $e');
            return DestinatarioModel.fromJson(e);
          })
          .toList();

      print('✅ Estudiantes parseados: ${estudiantes.length}');
      print('✅ Tutores parseados: ${tutores.length}');

      return DestinatariosModel(
        estudiantes: estudiantes,
        tutores: tutores,
        materiaInfo: json['materia_info'] != null
            ? MateriaInfo.fromJson(json['materia_info'])
            : null,
      );
    } catch (e) {
      print('❌ Error parseando DestinatariosModel: $e');
      rethrow;
    }
  }
}

class ProfesorService {
  static const String baseUrl = ApiConstants.apiUrl;

  // 🔥 Headers con token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await StorageUtil.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  // 🔥 OBTENER MATERIAS DEL PROFESOR
  static Future<List<MateriaModel>> obtenerMaterias() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materias/'),
        headers: headers,
      );

      print('📚 Obteniendo materias - Status: ${response.statusCode}');
      print('📚 Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MateriaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener materias: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerMaterias: $e');
      throw Exception('Error de conexión al obtener materias');
    }
  }

  // 🔥 OBTENER ESTUDIANTES DE UNA MATERIA
  static Future<List<EstudianteModel>> obtenerEstudiantes(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/estudiantes/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EstudianteModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener estudiantes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEstudiantes: $e');
      throw Exception('Error de conexión al obtener estudiantes');
    }
  }

  // 🔥 OBTENER ACTIVIDADES DE UNA MATERIA
  static Future<List<ActividadModel>> obtenerActividades(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/actividades/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ActividadModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener actividades: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerActividades: $e');
      throw Exception('Error de conexión al obtener actividades');
    }
  }

  // 🔥 REGISTRAR ASISTENCIA
  static Future<bool> registrarAsistencia(
      int detalleId, List<Map<String, dynamic>> asistencias) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/registrar-asistencia/'),
        headers: headers,
        body: jsonEncode(asistencias),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error en registrarAsistencia: $e');
      return false;
    }
  }

  // 🔥 OBTENER DESTINATARIOS PARA NOTIFICACIONES (CORREGIDO)
  static Future<DestinatariosModel> obtenerDestinatarios({int? detalleMateriaId}) async {
    try {
      print('🔍 Iniciando obtenerDestinatarios con detalleMateriaId: $detalleMateriaId');
      
      final headers = await _getHeaders();
      print('🔍 Headers obtenidos: $headers');
      
      String url = '$baseUrl/profesor/destinatarios/';
      
      if (detalleMateriaId != null) {
        url += '?detalle_materia_id=$detalleMateriaId';
      }
      
      print('🔍 URL completa: $url');

      final response = await http.get(Uri.parse(url), headers: headers);
      
      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('🔍 JSON parseado exitosamente');
        
        final destinatarios = DestinatariosModel.fromJson(jsonData);
        print('✅ Destinatarios creados - Estudiantes: ${destinatarios.estudiantes.length}, Tutores: ${destinatarios.tutores.length}');
        
        return destinatarios;
      } else {
        print('❌ Error HTTP: ${response.statusCode} - ${response.body}');
        throw Exception('Error al obtener destinatarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception en obtenerDestinatarios: $e');
      throw Exception('Error de conexión al obtener destinatarios: $e');
    }
  }

  // 🔥 ENVIAR NOTIFICACIÓN MASIVA
  static Future<Map<String, dynamic>> enviarNotificacionMasiva({
    required List<int> destinatarios,
    required String titulo,
    required String mensaje,
    String tipo = 'general',
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/profesor/enviar-notificacion/'),
        headers: headers,
        body: jsonEncode({
          'destinatarios': destinatarios,
          'titulo': titulo,
          'mensaje': mensaje,
          'tipo': tipo,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al enviar notificación: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en enviarNotificacionMasiva: $e');
      throw Exception('Error de conexión al enviar notificación');
    }
  }

  // 🔥 OBTENER REPORTE DE ASISTENCIA
  static Future<Map<String, dynamic>> obtenerReporteAsistencia(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/reporte-asistencia/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener reporte de asistencia');
      }
    } catch (e) {
      print('❌ Error en obtenerReporteAsistencia: $e');
      throw Exception('Error de conexión al obtener reporte');
    }
  }
// -----
// ... mantener todo el código existente ...

// 🔥 AGREGAR AL FINAL DE LA CLASE ProfesorService:

  // 🔥 MÉTODOS PARA ASISTENCIA MÓVIL

  /// Habilita la asistencia móvil para una materia
  static Future<Map<String, dynamic>> habilitarAsistenciaMovil(
  int detalleId, {
  int duracion = 15,
}) async {
  try {
    final headers = await _getHeaders();
    
    // 🔥 URL CORREGIDA - QUITAR "/materia" DEL INICIO
    final url = '$baseUrl/profesor/materia/$detalleId/asistencia-movil/habilitar/';
    print('🔍 URL completa: $url');
    print('🔍 Headers: $headers');
    print('🔍 Body: ${jsonEncode({'duracion': duracion})}');
    
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode({
        'duracion': duracion,
      }),
    );

    print('🔥 Response Status: ${response.statusCode}');
    print('🔥 Response Headers: ${response.headers}');
    print('🔥 Response Body: ${response.body}');

    // 🔥 VERIFICAR SI LA RESPUESTA ES HTML
    if (response.body.startsWith('<!DOCTYPE html>') || response.body.startsWith('<html>')) {
      throw Exception('El servidor devolvió HTML en lugar de JSON. URL incorrecta: $url');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al habilitar asistencia');
      } catch (e) {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('❌ Error en habilitarAsistenciaMovil: $e');
    rethrow;
  }
}
  /// Deshabilita la asistencia móvil para una materia
  static Future<Map<String, dynamic>> deshabilitarAsistenciaMovil(int detalleId) async {
    try {
      final headers = await _getHeaders();
      // 🔥 URL CORREGIDA
      final response = await http.post(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/asistencia-movil/deshabilitar/'),
        headers: headers,
      );

      print('🔥 deshabilitarAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 deshabilitarAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al deshabilitar asistencia');
      }
    } catch (e) {
      print('❌ Error en deshabilitarAsistenciaMovil: $e');
      rethrow;
    }
  }

  /// Obtiene el estado actual de la asistencia móvil
  static Future<Map<String, dynamic>> obtenerEstadoAsistenciaMovil(int detalleId) async {
    try {
      final headers = await _getHeaders();
      // 🔥 URL CORREGIDA
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/asistencia-movil/estado/'),
        headers: headers,
      );

      print('🔥 obtenerEstadoAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 obtenerEstadoAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al obtener estado');
      }
    } catch (e) {
      print('❌ Error en obtenerEstadoAsistenciaMovil: $e');
      rethrow;
    }
  }

  /// Obtiene la lista de estudiantes registrados en la sesión activa
  static Future<Map<String, dynamic>> obtenerEstudiantesRegistradosMovil(int detalleId) async {
    try {
      final headers = await _getHeaders();
      // 🔥 URL CORREGIDA
      final response = await http.get(
        Uri.parse('$baseUrl/profesor/materia/$detalleId/asistencia-movil/registrados/'),
        headers: headers,
      );

      print('🔥 obtenerEstudiantesRegistradosMovil - Status: ${response.statusCode}');
      print('🔥 obtenerEstudiantesRegistradosMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al obtener estudiantes');
      }
    } catch (e) {
      print('❌ Error en obtenerEstudiantesRegistradosMovil: $e');
      rethrow;
    }
  }

  /// Método para que el estudiante se registre con código
  static Future<Map<String, dynamic>> registrarseAsistenciaMovil(String codigo) async {
    try {
      final headers = await _getHeaders();
      // 🔥 URL CORREGIDA
      final response = await http.post(
        Uri.parse('$baseUrl/materia/estudiante/asistencia-movil/registrarse/'),
        headers: headers,
        body: jsonEncode({
          'codigo': codigo,
        }),
      );

      print('🔥 registrarseAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 registrarseAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al registrarse');
      }
    } catch (e) {
      print('❌ Error en registrarseAsistenciaMovil: $e');
      rethrow;
    }
  }
}