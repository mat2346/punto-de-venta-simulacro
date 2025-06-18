class User {
  final int id;
  final String nombre;
  final String codigo;
  final String? rol;
  final String sexo;
  final DateTime fechaNacimiento;
  final bool estado;

  User({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.rol,
    required this.sexo,
    required this.fechaNacimiento,
    required this.estado,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'].toString(),
      rol: json['rol']?['nombre'],
      sexo: json['sexo'],
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'rol': rol,
      'sexo': sexo,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'estado': estado,
    };
  }
}