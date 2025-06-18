class ActividadEstudianteModel {
  final int id;
  final String nombre;
  final String descripcion;
  final String estado;
  final String fechaCreacion;
  final String? fechaVencimiento;
  final double? nota;
  final String? comentario;

  ActividadEstudianteModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.estado,
    required this.fechaCreacion,
    this.fechaVencimiento,
    this.nota,
    this.comentario,
  });

  factory ActividadEstudianteModel.fromJson(Map<String, dynamic> json) {
    return ActividadEstudianteModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? json['materia'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      fechaCreacion: json['fecha_creacion'] ?? '',
      fechaVencimiento: json['fecha_vencimiento'],
      nota: _parseDouble(json['nota']),
      comentario: json['comentario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'fecha_creacion': fechaCreacion,
      'fecha_vencimiento': fechaVencimiento,
      'nota': nota,
      'comentario': comentario,
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // 🔥 GETTERS PARA ESTADOS (TODAS LAS VARIANTES)
  bool get estaPendiente => estado.toLowerCase() == 'pendiente';
  
  // Variantes para "entregado"
  bool get estaEntregado => estado.toLowerCase() == 'entregado';
  bool get estaEntregada => estaEntregado; // Alias
  
  // Variantes para "revisado"
  bool get estaRevisado => estado.toLowerCase() == 'revisado';
  bool get estaRevisada => estaRevisado; // Alias

  // 🔥 GETTER PARA OBTENER LA MATERIA DESDE LA DESCRIPCIÓN
  String get materia => descripcion.isNotEmpty ? descripcion : 'Sin materia';

  @override
  String toString() {
    return 'ActividadEstudianteModel(id: $id, nombre: $nombre, estado: $estado)';
  }
}
