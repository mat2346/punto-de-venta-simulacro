class AsistenciaEstudianteModel {
  final int id;
  final String fecha;
  final String estado;
  final String? observacion;
  final String? horaEntrada;
  final String? horaSalida;

  AsistenciaEstudianteModel({
    required this.id,
    required this.fecha,
    required this.estado,
    this.observacion,
    this.horaEntrada,
    this.horaSalida,
  });

  factory AsistenciaEstudianteModel.fromJson(Map<String, dynamic> json) {
    return AsistenciaEstudianteModel(
      id: json['id'] ?? 0,
      fecha: json['fecha'] ?? '',
      estado: json['estado'] ?? '',
      observacion: json['observacion'],
      horaEntrada: json['hora_entrada'],
      horaSalida: json['hora_salida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha,
      'estado': estado,
      'observacion': observacion,
      'hora_entrada': horaEntrada,
      'hora_salida': horaSalida,
    };
  }

  // 🔥 GETTERS ÚTILES
  bool get esPresente => estado.toLowerCase() == 'presente';
  bool get esTardanza => estado.toLowerCase() == 'tardanza';
  bool get esAusente => estado.toLowerCase() == 'ausente';

  @override
  String toString() {
    return 'AsistenciaEstudianteModel(id: $id, fecha: $fecha, estado: $estado)';
  }
}
