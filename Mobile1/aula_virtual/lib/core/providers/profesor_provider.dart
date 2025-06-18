import 'package:flutter/foundation.dart';
import '../services/profesor_service.dart';

class ProfesorProvider with ChangeNotifier {
  // 🔥 VARIABLES PRINCIPALES
  List<MateriaModel> _materias = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 🔥 VARIABLES PARA DETALLE DE MATERIA
  List<EstudianteModel> _estudiantes = [];
  List<ActividadModel> _actividades = [];
  DestinatariosModel? _destinatarios;

  // 🔥 VARIABLES PARA ASISTENCIA MÓVIL
  EstadoAsistenciaMovil? _estadoAsistenciaMovil;
  List<EstudianteRegistradoMovil> _estudiantesRegistradosMovil = [];
  bool _isLoadingAsistenciaMovil = false;

  // 🔥 GETTERS PRINCIPALES
  List<MateriaModel> get materias => _materias;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 🔥 GETTERS PARA DETALLE DE MATERIA
  List<EstudianteModel> get estudiantes => _estudiantes;
  List<ActividadModel> get actividades => _actividades;
  DestinatariosModel? get destinatarios => _destinatarios;

  // 🔥 GETTERS PARA ASISTENCIA MÓVIL
  EstadoAsistenciaMovil? get estadoAsistenciaMovil => _estadoAsistenciaMovil;
  List<EstudianteRegistradoMovil> get estudiantesRegistradosMovil => _estudiantesRegistradosMovil;
  bool get isLoadingAsistenciaMovil => _isLoadingAsistenciaMovil;

  // 🔥 MÉTODO PRINCIPAL - CARGAR MATERIAS
  Future<void> cargarMaterias() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _materias = await ProfesorService.obtenerMaterias();
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarMaterias: $e');
      _errorMessage = 'Error al cargar materias: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR ESTUDIANTES DE UNA MATERIA
  Future<void> cargarEstudiantes(int detalleId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _estudiantes = await ProfesorService.obtenerEstudiantes(detalleId);
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarEstudiantes: $e');
      _errorMessage = 'Error al cargar estudiantes: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR ACTIVIDADES DE UNA MATERIA
  Future<void> cargarActividades(int detalleId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _actividades = await ProfesorService.obtenerActividades(detalleId);
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarActividades: $e');
      _errorMessage = 'Error al cargar actividades: $e';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR DESTINATARIOS PARA NOTIFICACIONES
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

  // 🔥 MÉTODOS PARA ASISTENCIA MÓVIL

  /// Habilita la asistencia móvil para una materia
  Future<bool> habilitarAsistenciaMovil(int detalleId, {int duracion = 15}) async {
    try {
      _isLoadingAsistenciaMovil = true;
      notifyListeners();

      final resultado = await ProfesorService.habilitarAsistenciaMovil(
        detalleId,
        duracion: duracion,
      );

      if (resultado['success'] == true) {
        // Actualizar el estado local
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

  /// Carga el estado actual de la asistencia móvil
  Future<void> cargarEstadoAsistenciaMovil(int detalleId) async {
    try {
      final estado = await ProfesorService.obtenerEstadoAsistenciaMovil(detalleId);
      _estadoAsistenciaMovil = estado;
      
      // Si está habilitada, cargar también los estudiantes registrados
      if (estado.habilitada) {
        await cargarEstudiantesRegistradosMovil(detalleId);
      } else {
        _estudiantesRegistradosMovil.clear();
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
      final estudiantes = await ProfesorService.obtenerEstudiantesRegistradosMovil(detalleId);
      _estudiantesRegistradosMovil = estudiantes;
      notifyListeners();
    } catch (e) {
      print('❌ Error en cargarEstudiantesRegistradosMovil: $e');
      // No mostramos error aquí porque es una carga automática
    }
  }

  

  /// Método para refrescar automáticamente los datos cada cierto tiempo
  Future<void> refrescarAsistenciaMovil(int detalleId) async {
    // Solo refrescar si hay una sesión activa
    if (_estadoAsistenciaMovil?.habilitada == true) {
      await cargarEstadoAsistenciaMovil(detalleId);
    }
  }

  // 🔥 MÉTODOS DE UTILIDAD

  /// Limpia todos los datos
  void limpiarTodo() {
    _materias.clear();
    _estudiantes.clear();
    _actividades.clear();
    _destinatarios = null;
    _estadoAsistenciaMovil = null;
    _estudiantesRegistradosMovil.clear();
    _isLoading = false;
    _isLoadingAsistenciaMovil = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia solo los datos de asistencia móvil
  void limpiarAsistenciaMovil() {
    _estadoAsistenciaMovil = null;
    _estudiantesRegistradosMovil.clear();
    _isLoadingAsistenciaMovil = false;
    notifyListeners();
  }

  /// Limpia solo el error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia datos de detalle de materia
  void limpiarDetalleMateria() {
    _estudiantes.clear();
    _actividades.clear();
    notifyListeners();
  }
  
}