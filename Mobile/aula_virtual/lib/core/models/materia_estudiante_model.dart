class MateriaEstudianteModel {
  final int id;
  final String nombre;
  final String curso;
  final String paralelo;
  final String profesor;
  final double promedio;
  final double asistencia;
  final int actividadesPendientes;

  MateriaEstudianteModel({
    required this.id,
    required this.nombre,
    required this.curso,
    required this.paralelo,
    required this.profesor,
    required this.promedio,
    required this.asistencia,
    required this.actividadesPendientes,
  });

  factory MateriaEstudianteModel.fromJson(Map<String, dynamic> json) {
    return MateriaEstudianteModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      curso: json['curso'] ?? '',
      paralelo: json['paralelo'] ?? '',
      profesor: json['profesor'] ?? '',
      promedio: (json['promedio'] ?? 0).toDouble(),
      asistencia: (json['asistencia'] ?? 0).toDouble(),
      actividadesPendientes: json['actividades_pendientes'] ?? 0,
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
      'actividades_pendientes': actividadesPendientes,
    };
  }

  String get nombreCompleto => '$nombre - $curso $paralelo';

  @override
  String toString() {
    return 'MateriaEstudianteModel(id: $id, nombre: $nombre, promedio: $promedio)';
  }
}
