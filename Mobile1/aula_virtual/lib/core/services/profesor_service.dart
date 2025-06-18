import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// 🔥 MODELOS ÚNICOS - SIN DUPLICADOS

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
  final String libretaId;
  final String? email;

  EstudianteModel({
    required this.id,
    required this.nombre,
    required this.libretaId,
    this.email,
  });

  factory EstudianteModel.fromJson(Map<String, dynamic> json) {
    return EstudianteModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      libretaId: json['libreta_id']?.toString() ?? json['codigo']?.toString() ?? '',
      email: json['email'],
    );
  }
}

class ActividadModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String fechaCreacion;
  final String? fechaVencimiento;

  ActividadModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaCreacion,
    this.fechaVencimiento,
  });

  factory ActividadModel.fromJson(Map<String, dynamic> json) {
    return ActividadModel(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaCreacion: json['fecha_creacion'] ?? '',
      fechaVencimiento: json['fecha_vencimiento'],
    );
  }
}

class DestinatarioModel {
  final int id;
  final String nombre;
  final String codigo;
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
      codigo: json['codigo']?.toString() ?? '',
      tieneFcmToken: json['tiene_fcm_token'] ?? false,
    );
  }

  @override
  String toString() {
    return 'DestinatarioModel(id: $id, nombre: $nombre, codigo: $codigo)';
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

class DestinatariosModel {
  final List<DestinatarioModel> estudiantes;
  final List<DestinatarioModel> tutores;
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

// 🔥 MODELOS PARA ASISTENCIA MÓVIL
class SesionAsistenciaMovil {
  final int id;
  final String codigo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int tiempoRestante;
  final int estudiantesRegistrados;
  final int duracionOriginal;

  SesionAsistenciaMovil({
    required this.id,
    required this.codigo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.tiempoRestante,
    required this.estudiantesRegistrados,
    required this.duracionOriginal,
  });

  factory SesionAsistenciaMovil.fromJson(Map<String, dynamic> json) {
    return SesionAsistenciaMovil(
      id: json['id'],
      codigo: json['codigo'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFin: DateTime.parse(json['fecha_fin']),
      tiempoRestante: json['tiempo_restante'] ?? 0,
      estudiantesRegistrados: json['estudiantes_registrados'] ?? 0,
      duracionOriginal: json['duracion_original'] ?? 15,
    );
  }
}

class EstadoAsistenciaMovil {
  final bool habilitada;
  final SesionAsistenciaMovil? sesion;

  EstadoAsistenciaMovil({
    required this.habilitada,
    this.sesion,
  });

  factory EstadoAsistenciaMovil.fromJson(Map<String, dynamic> json) {
    return EstadoAsistenciaMovil(
      habilitada: json['habilitada'] ?? false,
      sesion: json['sesion'] != null 
          ? SesionAsistenciaMovil.fromJson(json['sesion'])
          : null,
    );
  }
}

class EstudianteRegistradoMovil {
  final int id;
  final String nombre;
  final String codigo;
  final DateTime horaRegistro;
  final String tiempoTranscurrido;

  EstudianteRegistradoMovil({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.horaRegistro,
    required this.tiempoTranscurrido,
  });

  factory EstudianteRegistradoMovil.fromJson(Map<String, dynamic> json) {
    return EstudianteRegistradoMovil(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'] ?? '',
      horaRegistro: DateTime.parse(json['hora_registro']),
      tiempoTranscurrido: json['tiempo_transcurrido'] ?? '',
    );
  }
}

// 🔥 CLASE DE SERVICIO ÚNICA
class ProfesorService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador
  // static const String baseUrl = 'http://192.168.1.100:8000'; // Para dispositivo físico

  // 🔥 MÉTODO PARA OBTENER HEADERS CON TOKEN
  static Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('❌ Error obteniendo token: $e');
      return {
        'Content-Type': 'application/json',
      };
    }
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
        Uri.parse('$baseUrl/materia/profesor/materia/$detalleId/estudiantes/'),
        headers: headers,
      );

      print('🔥 obtenerEstudiantes - Status: ${response.statusCode}');
      print('🔥 obtenerEstudiantes - Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final estudiantesJson = jsonData['estudiantes'] as List;
        
        return estudiantesJson
            .map((json) => EstudianteModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al obtener estudiantes: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en obtenerEstudiantes: $e');
      rethrow;
    }
  }

  // 🔥 OBTENER ACTIVIDADES DE UNA MATERIA
  static Future<List<ActividadModel>> obtenerActividades(int detalleId) async {
    try {
      // Por ahora retornamos lista vacía, implementar cuando tengamos el endpoint
      return [];
    } catch (e) {
      print('❌ Error en obtenerActividades: $e');
      return [];
    }
  }

  // 🔥 OBTENER DESTINATARIOS PARA NOTIFICACIONES
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

  // 🔥 MÉTODOS PARA ASISTENCIA MÓVIL

  /// Habilita la asistencia móvil para una materia
  static Future<Map<String, dynamic>> habilitarAsistenciaMovil(
    int detalleId, {
    int duracion = 15,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/materia/profesor/materia/$detalleId/asistencia-movil/habilitar/'),
        headers: headers,
        body: jsonEncode({
          'duracion': duracion,
        }),
      );

      print('🔥 habilitarAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 habilitarAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al habilitar asistencia');
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
      final response = await http.post(
        Uri.parse('$baseUrl/materia/profesor/materia/$detalleId/asistencia-movil/deshabilitar/'),
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
  static Future<EstadoAsistenciaMovil> obtenerEstadoAsistenciaMovil(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/materia/profesor/materia/$detalleId/asistencia-movil/estado/'),
        headers: headers,
      );

      print('🔥 obtenerEstadoAsistenciaMovil - Status: ${response.statusCode}');
      print('🔥 obtenerEstadoAsistenciaMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return EstadoAsistenciaMovil.fromJson(jsonData);
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
  static Future<List<EstudianteRegistradoMovil>> obtenerEstudiantesRegistradosMovil(int detalleId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/materia/profesor/materia/$detalleId/asistencia-movil/registrados/'),
        headers: headers,
      );

      print('🔥 obtenerEstudiantesRegistradosMovil - Status: ${response.statusCode}');
      print('🔥 obtenerEstudiantesRegistradosMovil - Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final estudiantesJson = jsonData['estudiantes'] as List;
        
        return estudiantesJson
            .map((json) => EstudianteRegistradoMovil.fromJson(json))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['error'] ?? 'Error al obtener estudiantes');
      }
    } catch (e) {
      print('❌ Error en obtenerEstudiantesRegistradosMovil: $e');
      rethrow;
    }
  }
}