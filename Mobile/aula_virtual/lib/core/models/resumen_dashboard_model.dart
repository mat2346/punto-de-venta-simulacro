import 'actividad_estudiante_model.dart';

class ResumenDashboardModel {
  final double promedioGeneral;
  final double asistenciaGeneral;
  final int materiasTotal;
  final int actividadesPendientes;
  final List<ActividadEstudianteModel> ultimasActividades;

  ResumenDashboardModel({
    required this.promedioGeneral,
    required this.asistenciaGeneral,
    required this.materiasTotal,
    required this.actividadesPendientes,
    required this.ultimasActividades,
  });

  factory ResumenDashboardModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing ResumenDashboardModel: $json');
    
    // 🔥 PARSEAR LAS ACTIVIDADES RECIENTES CORRECTAMENTE
    final actividadesJson = json['actividades_recientes'] as List<dynamic>? ?? [];
    print('🔍 Actividades raw: $actividadesJson');
    
    final actividades = actividadesJson.map((item) {
      final Map<String, dynamic> actividadMap = item as Map<String, dynamic>;
      
      // 🔥 CREAR UN NUEVO MAP CON LA ESTRUCTURA QUE ESPERA ActividadEstudianteModel
      final actividadAdaptada = {
        'id': 0, // No viene del API
        'nombre': actividadMap['titulo'] ?? 'Sin título',
        'descripcion': actividadMap['materia'] ?? '',
        'estado': actividadMap['estado'] ?? 'pendiente',
        'fecha_creacion': '',
        'fecha_vencimiento': null,
        'nota': null,
        'comentario': null,
        // 🔥 MANTENER EL CAMPO ORIGINAL PARA REFERENCIA
        'materia_original': actividadMap['materia'],
      };
      
      print('🔍 Actividad adaptada: $actividadAdaptada');
      return ActividadEstudianteModel.fromJson(actividadAdaptada);
    }).toList();

    print('✅ Total actividades parseadas: ${actividades.length}');

    return ResumenDashboardModel(
      promedioGeneral: _parseDouble(json['porcentaje_asistencia']), // Nota: usa asistencia como promedio por ahora
      asistenciaGeneral: _parseDouble(json['porcentaje_asistencia']),
      materiasTotal: (json['materias'] as List<dynamic>?)?.length ?? 0,
      actividadesPendientes: actividades.where((a) => a.estaPendiente).length,
      ultimasActividades: actividades,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promedio_general': promedioGeneral,
      'asistencia_general': asistenciaGeneral,
      'materias_total': materiasTotal,
      'actividades_pendientes': actividadesPendientes,
      'ultimas_actividades': ultimasActividades.map((item) => item.toJson()).toList(),
    };
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  String toString() {
    return 'ResumenDashboardModel(promedio: $promedioGeneral, asistencia: $asistenciaGeneral, actividades: ${ultimasActividades.length})';
  }
}