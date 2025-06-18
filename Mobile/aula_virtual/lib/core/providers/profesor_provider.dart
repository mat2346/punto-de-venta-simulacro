import 'package:flutter/material.dart';
import '../services/profesor_service.dart';

class ProfesorProvider with ChangeNotifier {
  List<MateriaModel> _materias = [];
  List<EstudianteModel> _estudiantes = [];
  List<ActividadModel> _actividades = [];
  DestinatariosModel? _destinatarios;
  
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<MateriaModel> get materias => _materias;
  List<EstudianteModel> get estudiantes => _estudiantes;
  List<ActividadModel> get actividades => _actividades;
  DestinatariosModel? get destinatarios => _destinatarios;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
 //variables para hacer funcionar la asistencia 
 // 🔥 NUEVAS VARIABLES PARA ASISTENCIA MÓVIL
  Map<String, dynamic>? _estadoAsistenciaMovil;
  List<Map<String, dynamic>> _estudiantesRegistradosMovil = [];
  bool _isLoadingAsistenciaMovil = false;
  String? _codigoAsistencia;

  // 🔥 NUEVOS GETTERS PARA ASISTENCIA MÓVIL
  Map<String, dynamic>? get estadoAsistenciaMovil => _estadoAsistenciaMovil;
  List<Map<String, dynamic>> get estudiantesRegistradosMovil => _estudiantesRegistradosMovil;
  bool get isLoadingAsistenciaMovil => _isLoadingAsistenciaMovil;
  String? get codigoAsistencia => _codigoAsistencia;
  // Helper getters
  bool get asistenciaHabilitada => _estadoAsistenciaMovil?['habilitada'] ?? false;
  int get tiempoRestante => _estadoAsistenciaMovil?['tiempo_restante'] ?? 0;
  int get totalRegistrados => _estudiantesRegistradosMovil.length;



  // 🔥 CARGAR MATERIAS
  Future<void> cargarMaterias() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _materias = await ProfesorService.obtenerMaterias();
      print('✅ Materias cargadas: ${_materias.length}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar materias: $e';
      _isLoading = false;
      notifyListeners();
      print('❌ Error cargando materias: $e');
    }
  }

  // 🔥 CARGAR ESTUDIANTES
  Future<void> cargarEstudiantes(int detalleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _estudiantes = await ProfesorService.obtenerEstudiantes(detalleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar estudiantes: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR ACTIVIDADES
  Future<void> cargarActividades(int detalleId) async {
    try {
      _actividades = await ProfesorService.obtenerActividades(detalleId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al cargar actividades: $e';
      notifyListeners();
    }
  }

  // 🔥 CARGAR DESTINATARIOS (CORREGIDO)
  Future<void> cargarDestinatarios({int? detalleMateriaId}) async {
    print('🚀 Iniciando cargarDestinatarios con materia: $detalleMateriaId');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _destinatarios = await ProfesorService.obtenerDestinatarios(
        detalleMateriaId: detalleMateriaId
      );
      
      print('✅ Destinatarios cargados exitosamente');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarDestinatarios: $e');
      _errorMessage = 'Error al cargar destinatarios: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 ENVIAR NOTIFICACIÓN
  Future<Map<String, dynamic>?> enviarNotificacionMasiva({
    required List<int> destinatarios,
    required String titulo,
    required String mensaje,
    String tipo = 'general',
  }) async {
    try {
      final resultado = await ProfesorService.enviarNotificacionMasiva(
        destinatarios: destinatarios,
        titulo: titulo,
        mensaje: mensaje,
        tipo: tipo,
      );
      return resultado;
    } catch (e) {
      _errorMessage = 'Error al enviar notificación: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  // 🔥 NUEVAS FUNCIONES PARA ASISTENCIA MÓVI
  Future<bool> habilitarAsistenciaMovil(int detalleId, {int duracion = 15}) async {
    try {
      _isLoadingAsistenciaMovil = true;
      _errorMessage = null;
      notifyListeners();

      final resultado = await ProfesorService.habilitarAsistenciaMovil(
        detalleId,
        duracion: duracion,
      );

      if (resultado['success'] == true) {
        _codigoAsistencia = resultado['codigo'];
        // Cargar el estado actualizado
        await cargarEstadoAsistenciaMovil(detalleId);
        return true;
      } else {
        _errorMessage = resultado['message'] ?? 'Error al habilitar asistencia';
        return false;
      }
    } catch (e) {
      print('❌ Error en habilitarAsistenciaMovil: $e');
      _errorMessage = 'Error de conexión al habilitar asistencia';
      return false;
    } finally {
      _isLoadingAsistenciaMovil = false;
      notifyListeners();
    }
  }

  /// Deshabilita la asistencia móvil para una materia
  Future<bool> deshabilitarAsistenciaMovil(int detalleId) async {
    try {
      _isLoadingAsistenciaMovil = true;
      notifyListeners();

      final resultado = await ProfesorService.deshabilitarAsistenciaMovil(detalleId);

      if (resultado['success'] == true) {
        // Limpiar el estado local
        _estadoAsistenciaMovil = null;
        _estudiantesRegistradosMovil.clear();
        _codigoAsistencia = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = resultado['message'] ?? 'Error al deshabilitar asistencia';
        return false;
      }
    } catch (e) {
      print('❌ Error en deshabilitarAsistenciaMovil: $e');
      _errorMessage = 'Error de conexión al deshabilitar asistencia';
      return false;
       } finally {
      _isLoadingAsistenciaMovil = false;
      notifyListeners();
    }
  }
  
  /// Carga el estado actual de la asistencia móvil
  Future<void> cargarEstadoAsistenciaMovil(int detalleId) async {
    try {
      final estado = await ProfesorService.obtenerEstadoAsistenciaMovil(detalleId);
      _estadoAsistenciaMovil = estado;
      
      // Si está habilitada, también obtener el código
      if (estado['habilitada'] == true && estado['sesion'] != null) {
        _codigoAsistencia = estado['sesion']['codigo'];
        // Cargar estudiantes registrados
        await cargarEstudiantesRegistradosMovil(detalleId);
      } else {
        _estudiantesRegistradosMovil.clear();
        _codigoAsistencia = null;
      }
      
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarEstadoAsistenciaMovil: $e');
      _errorMessage = 'Error al cargar estado de asistencia';
      notifyListeners();
    }
  }

  /// Carga los estudiantes que se han registrado en la sesión activa
  Future<void> cargarEstudiantesRegistradosMovil(int detalleId) async {
    try {
      final response = await ProfesorService.obtenerEstudiantesRegistradosMovil(detalleId);
      _estudiantesRegistradosMovil = List<Map<String, dynamic>>.from(response['estudiantes'] ?? []);
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarEstudiantesRegistradosMovil: $e');
      // No mostramos error aquí porque es una carga automática
    }
  }

  /// Método para refrescar automáticamente los datos cada cierto tiempo
  Future<void> refrescarAsistenciaMovil(int detalleId) async {
    // Solo refrescar si hay una sesión activa
    if (asistenciaHabilitada) {
      await cargarEstadoAsistenciaMovil(detalleId);
    }
  }

   /// Registrarse en asistencia móvil (para estudiantes)
  Future<bool> registrarseAsistenciaMovil(String codigo) async {
    try {
      _isLoadingAsistenciaMovil = true;
      _errorMessage = null;
      notifyListeners();

      final resultado = await ProfesorService.registrarseAsistenciaMovil(codigo);

      if (resultado['success'] == true) {
        return true;
      } else {
        _errorMessage = resultado['message'] ?? 'Error al registrarse';
        return false;
      }
    } catch (e) {
      print('❌ Error en registrarseAsistenciaMovil: $e');
      _errorMessage = 'Error de conexión al registrarse';
      return false;
    } finally {
      _isLoadingAsistenciaMovil = false;
      notifyListeners();
    }
    }

  // ... mantener todos los métodos de utilidad existentes ...

  /// Limpia solo los datos de asistencia móvil
  void limpiarAsistenciaMovil() {
    _estadoAsistenciaMovil = null;
    _estudiantesRegistradosMovil.clear();
    _codigoAsistencia = null;
    _isLoadingAsistenciaMovil = false;
    notifyListeners();
  }
}