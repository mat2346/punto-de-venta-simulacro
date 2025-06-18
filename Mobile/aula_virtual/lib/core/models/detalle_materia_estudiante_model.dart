import 'actividad_estudiante_model.dart';
import 'asistencia_estudiante_model.dart';

class DetalleMateriaEstudianteModel {
  final int id;
  final String nombre;
  final String curso;
  final String paralelo;
  final String profesor;
  final double promedio;
  final double asistencia;
  final List<ActividadEstudianteModel> actividades;
  final List<AsistenciaEstudianteModel> historialAsistencia;

  DetalleMateriaEstudianteModel({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.paralelo,
    required this.profesor,
    required this.promedio,
    required this.asistencia,
    required this.actividades,
    required this.historialAsistencia,
  });

  factory DetalleMateriaEstudianteModel.fromJson(Map<String, dynamic> json) {
    return DetalleMateriaEstudianteModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      curso: json['curso'] ?? '',
      paralelo: json['paralelo'] ?? '',
      profesor: json['profesor'] ?? '',
      promedio: (json['promedio'] ?? 0).toDouble(),
      asistencia: (json['asistencia'] ?? 0).toDouble(),
      actividades: (json['actividades'] as List<dynamic>? ?? [])
          .map((item) => ActividadEstudianteModel.fromJson(item))
          .toList(),
      historialAsistencia: (json['historial_asistencia'] as List<dynamic>? ?? [])
          .map((item) => AsistenciaEstudianteModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'curso': curso,
      'paralelo': paralelo,
      'profesor': profesor,
      'promedio': promedio,
      'asistencia': asistencia,
      'actividades': actividades.map((item) => item.toJson()).toList(),
      'historial_asistencia': historialAsistencia.map((item) => item.toJson()).toList(),
    };
  }

  // 🔥 GETTERS ÚTILES
  int get totalActividades => actividades.length;
  int get actividadesPendientes => actividades.where((a) => a.estaPendiente).length;
  int get actividadesEntregadas => actividades.where((a) => a.estaEntregada).length;
  int get actividadesRevisadas => actividades.where((a) => a.estaRevisada).length;

  @override
  String toString() {
    return 'DetalleMateriaEstudianteModel(id: $id, nombre: $nombre, promedio: $promedio)';
  }
}