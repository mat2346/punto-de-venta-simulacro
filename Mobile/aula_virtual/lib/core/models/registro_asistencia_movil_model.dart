class RegistroAsistenciaMovilModel {
  final bool success;
  final String message;
  final String? materia;
  final String? horaRegistro;
  final String? fechaRegistro;
  final String? estadoAsistencia;
  final Map<String, dynamic>? detalles;

  RegistroAsistenciaMovilModel({
    required this.success,
    required this.message,
    this.materia,
    this.horaRegistro,
    this.fechaRegistro,
    this.estadoAsistencia,
    this.detalles,
  });

  factory RegistroAsistenciaMovilModel.fromJson(Map<String, dynamic> json) {
    return RegistroAsistenciaMovilModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      materia: json['materia'],
      horaRegistro: json['hora_registro'],
      fechaRegistro: json['fecha_registro'],
      estadoAsistencia: json['estado_asistencia'],
      detalles: json['detalles'],
    );
  }

  factory RegistroAsistenciaMovilModel.success({
    required String message,
    String? materia,
    String? horaRegistro,
    String? fechaRegistro,
    String? estadoAsistencia,
  }) {
    return RegistroAsistenciaMovilModel(
      success: true,
      message: message,
      materia: materia,
      horaRegistro: horaRegistro,
      fechaRegistro: fechaRegistro,
      estadoAsistencia: estadoAsistencia,
    );
  }

  factory RegistroAsistenciaMovilModel.error(String message) {
    return RegistroAsistenciaMovilModel(
      success: false,
      message: message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'materia': materia,
      'hora_registro': horaRegistro,
      'fecha_registro': fechaRegistro,
      'estado_asistencia': estadoAsistencia,
      'detalles': detalles,
    };
  }

  @override
  String toString() {
    return 'RegistroAsistenciaMovilModel(success: $success, message: $message, materia: $materia)';
  }
}
