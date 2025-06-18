import 'package:flutter/material.dart';
import '../services/estudiante_service.dart';
import 'package:aula_virtual/core/models/resumen_dashboard_model.dart';
import 'package:aula_virtual/core/models/materia_estudiante_model.dart';
import 'package:aula_virtual/core/models/detalle_materia_estudiante_model.dart';
import 'package:aula_virtual/core/models/actividad_estudiante_model.dart';
import 'package:aula_virtual/core/models/asistencia_estudiante_model.dart';
import 'package:aula_virtual/core/models/registro_asistencia_movil_model.dart';

class EstudianteProvider extends ChangeNotifier {
  // 🔥 VARIABLES DE ESTADO PRINCIPAL
  bool _isLoading = false;
  bool _isLoadingDetalle = false;
  bool _isLoadingAsistenciaMovil = false;
  String? _errorMessage;

  // 🔥 DATOS DEL DASHBOARD
  ResumenDashboardModel? _resumenDashboard;
  List<MateriaEstudianteModel> _materias = [];

  // 🔥 DATOS DE DETALLE DE MATERIA
  DetalleMateriaEstudianteModel? _detalleMateria;
  List<ActividadEstudianteModel> _actividades = [];
  List<AsistenciaEstudianteModel> _historialAsistencia = [];

  // 🔥 ASISTENCIA MÓVIL
  RegistroAsistenciaMovilModel? _ultimoRegistroAsistencia;

  // 🔥 FILTROS Y BÚSQUEDA
  String _filtroActividades = '';
  String _estadoFiltroActividades = '';
  int? _materiaFiltroActividades;

  // ==================== GETTERS ====================

  // Estados generales
  bool get isLoading => _isLoading;
  bool get isLoadingDetalle => _isLoadingDetalle;
  bool get isLoadingAsistenciaMovil => _isLoadingAsistenciaMovil;
  String? get errorMessage => _errorMessage;

  // Dashboard
  ResumenDashboardModel? get resumenDashboard => _resumenDashboard;
  List<MateriaEstudianteModel> get materias => _materias;

  // Detalle de materia
  DetalleMateriaEstudianteModel? get detalleMateria => _detalleMateria;
  List<ActividadEstudianteModel> get actividades => _actividades;
  List<AsistenciaEstudianteModel> get historialAsistencia => _historialAsistencia;

  // Asistencia móvil
  RegistroAsistenciaMovilModel? get ultimoRegistroAsistencia => _ultimoRegistroAsistencia;

  // Filtros
  String get filtroActividades => _filtroActividades;
  String get estadoFiltroActividades => _estadoFiltroActividades;
  int? get materiaFiltroActividades => _materiaFiltroActividades;

  // Helper getters
  bool get tieneErrores => _errorMessage != null;
  bool get tieneDatos => _resumenDashboard != null && _materias.isNotEmpty;
  int get totalMaterias => _materias.length;
  double get promedioGeneral => _resumenDashboard?.promedioGeneral ?? 0.0;
  double get asistenciaGeneral => _resumenDashboard?.asistenciaGeneral ?? 0.0;

  // Actividades por estado
  List<ActividadEstudianteModel> get actividadesPendientes =>
      _actividades.where((act) => act.estaPendiente).toList();
  List<ActividadEstudianteModel> get actividadesEntregadas =>
      _actividades.where((act) => act.estaEntregada).toList();
  List<ActividadEstudianteModel> get actividadesRevisadas =>
      _actividades.where((act) => act.estaRevisada).toList();

  // ==================== MÉTODOS PRINCIPALES ====================

  // 🔥 CARGAR DASHBOARD INICIAL
  Future<void> cargarDashboard({bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();
      }

      // Cargar resumen y materias en paralelo
      final futures = await Future.wait([
        EstudianteService.obtenerResumenDashboard(),
        EstudianteService.obtenerMaterias(),
      ]);

      _resumenDashboard = futures[0] as ResumenDashboardModel;
      _materias = futures[1] as List<MateriaEstudianteModel>;

      print('✅ Dashboard cargado: ${_materias.length} materias');
    } catch (e) {
      print('❌ Error al cargar dashboard: $e');
      _errorMessage = 'Error al cargar el dashboard';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR DETALLE DE UNA MATERIA
  Future<void> cargarDetalleMateria(int materiaId, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _isLoadingDetalle = true;
        _errorMessage = null;
        notifyListeners();
      }

      _detalleMateria = await EstudianteService.obtenerDetalleMateria(materiaId);
      _actividades = _detalleMateria?.actividades ?? [];
      _historialAsistencia = _detalleMateria?.historialAsistencia ?? [];

      print('✅ Detalle materia cargado: ${_actividades.length} actividades');
    } catch (e) {
      print('❌ Error al cargar detalle materia: $e');
      _errorMessage = 'Error al cargar detalle de la materia';
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR ACTIVIDADES ESPECÍFICAS
  Future<void> cargarActividades(int materiaId, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _isLoadingDetalle = true;
        notifyListeners();
      }

      _actividades = await EstudianteService.obtenerActividadesMateria(materiaId);
      print('✅ Actividades cargadas: ${_actividades.length}');
    } catch (e) {
      print('❌ Error al cargar actividades: $e');
      _errorMessage = 'Error al cargar actividades';
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  // 🔥 CARGAR HISTORIAL DE ASISTENCIA
  Future<void> cargarHistorialAsistencia(int materiaId, {bool silencioso = false}) async {
    try {
      if (!silencioso) {
        _isLoadingDetalle = true;
        notifyListeners();
      }

      _historialAsistencia = await EstudianteService.obtenerHistorialAsistencia(materiaId);
      print('✅ Historial asistencia cargado: ${_historialAsistencia.length}');
    } catch (e) {
      print('❌ Error al cargar historial asistencia: $e');
      _errorMessage = 'Error al cargar historial de asistencia';
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  // 🔥 REGISTRARSE EN ASISTENCIA MÓVIL
  Future<bool> registrarseAsistenciaMovil(String codigo) async {
    try {
      _isLoadingAsistenciaMovil = true;
      _errorMessage = null;
      notifyListeners();

      final resultado = await EstudianteService.registrarseAsistenciaMovil(codigo);
      _ultimoRegistroAsistencia = resultado;

      if (resultado.success) {
        // Refrescar datos del dashboard después del registro exitoso
        await cargarDashboard(silencioso: true);
        return true;
      } else {
        _errorMessage = resultado.message;
        return false;
      }
    } catch (e) {
      print('❌ Error al registrarse en asistencia móvil: $e');
      _errorMessage = 'Error de conexión al registrarse';
      return false;
    } finally {
      _isLoadingAsistenciaMovil = false;
      notifyListeners();
    }
  }

  // 🔥 BUSCAR ACTIVIDADES CON FILTROS
  Future<void> buscarActividades({
    String? filtro,
    String? estado,
    int? materiaId,
    bool silencioso = false,
  }) async {
    try {
      if (!silencioso) {
        _isLoadingDetalle = true;
        notifyListeners();
      }

      // Actualizar filtros internos
      _filtroActividades = filtro ?? '';
      _estadoFiltroActividades = estado ?? '';
      _materiaFiltroActividades = materiaId;

      _actividades = await EstudianteService.buscarActividades(
        filtro: filtro,
        estado: estado,
        materiaId: materiaId,
      );

      print('✅ Búsqueda actividades: ${_actividades.length} encontradas');
    } catch (e) {
      print('❌ Error al buscar actividades: $e');
      _errorMessage = 'Error al buscar actividades';
    } finally {
      _isLoadingDetalle = false;
      notifyListeners();
    }
  }

  // ==================== MÉTODOS DE UTILIDAD ====================

  // 🔥 REFRESCAR DATOS GENERALES
  Future<void> refrescarDatos() async {
    await cargarDashboard();
  }

  // 🔥 REFRESCAR DETALLE DE MATERIA ACTUAL
  Future<void> refrescarDetalleMateria() async {
    if (_detalleMateria != null) {
      await cargarDetalleMateria(_detalleMateria!.id);
    }
  }

  // 🔥 LIMPIAR FILTROS DE ACTIVIDADES
  void limpiarFiltrosActividades() {
    _filtroActividades = '';
    _estadoFiltroActividades = '';
    _materiaFiltroActividades = null;
    notifyListeners();
  }

  // 🔥 LIMPIAR DETALLE DE MATERIA
  void limpiarDetalleMateria() {
    _detalleMateria = null;
    _actividades.clear();
    _historialAsistencia.clear();
    notifyListeners();
  }

  // 🔥 LIMPIAR ÚLTIMO REGISTRO DE ASISTENCIA
  void limpiarUltimoRegistroAsistencia() {
    _ultimoRegistroAsistencia = null;
    notifyListeners();
  }

  // 🔥 LIMPIAR ERRORES
  void limpiarErrores() {
    _errorMessage = null;
    notifyListeners();
  }

  // 🔥 LIMPIAR TODO EL ESTADO
  void limpiarTodo() {
    _isLoading = false;
    _isLoadingDetalle = false;
    _isLoadingAsistenciaMovil = false;
    _errorMessage = null;
    
    _resumenDashboard = null;
    _materias.clear();
    _detalleMateria = null;
    _actividades.clear();
    _historialAsistencia.clear();
    _ultimoRegistroAsistencia = null;
    
    _filtroActividades = '';
    _estadoFiltroActividades = '';
    _materiaFiltroActividades = null;
    
    notifyListeners();
  }

  // ==================== GETTERS ESPECÍFICOS ====================

  // 🔥 OBTENER MATERIA POR ID
  MateriaEstudianteModel? obtenerMateriaPorId(int id) {
    try {
      return _materias.firstWhere((materia) => materia.id == id);
    } catch (e) {
      return null;
    }
  }

  // 🔥 OBTENER ESTADÍSTICAS DE ASISTENCIA
  Map<String, int> get estadisticasAsistencia {
    final presentes = _historialAsistencia.where((a) => a.esPresente).length;
    final ausentes = _historialAsistencia.where((a) => a.esAusente).length;
    final tardanzas = _historialAsistencia.where((a) => a.esTardanza).length;
    
    return {
      'presentes': presentes,
      'ausentes': ausentes,
      'tardanzas': tardanzas,
      'total': _historialAsistencia.length,
    };
  }

  // 🔥 OBTENER ESTADÍSTICAS DE ACTIVIDADES
  Map<String, int> get estadisticasActividades {
    return {
      'pendientes': actividadesPendientes.length,
      'entregadas': actividadesEntregadas.length,
      'revisadas': actividadesRevisadas.length,
      'total': _actividades.length,
    };
  }

  // 🔥 OBTENER PROMEDIO POR MATERIA
  double obtenerPromedioPorMateria(int materiaId) {
    final materia = obtenerMateriaPorId(materiaId);
    return materia?.promedio ?? 0.0;
  }

  // 🔥 OBTENER ASISTENCIA POR MATERIA
  double obtenerAsistenciaPorMateria(int materiaId) {
    final materia = obtenerMateriaPorId(materiaId);
    return materia?.asistencia ?? 0.0;
  }

  // 🔥 VERIFICAR SI HAY ACTIVIDADES PENDIENTES
  bool tieneActividadesPendientes() {
    return actividadesPendientes.isNotEmpty;
  }

  // 🔥 OBTENER MATERIAS CON ACTIVIDADES PENDIENTES
  List<MateriaEstudianteModel> get materiasConActividadesPendientes {
    return _materias.where((materia) => materia.actividadesPendientes > 0).toList();
  }

  // 🔥 OBTENER MATERIAS ORDENADAS POR PROMEDIO
  List<MateriaEstudianteModel> get materiasOrdendasPorPromedio {
    final materiasCopia = List<MateriaEstudianteModel>.from(_materias);
    materiasCopia.sort((a, b) => b.promedio.compareTo(a.promedio));
    return materiasCopia;
  }

  // 🔥 OBTENER MATERIAS ORDENADAS POR ASISTENCIA
  List<MateriaEstudianteModel> get materiasOrdenadasPorAsistencia {
    final materiasCopia = List<MateriaEstudianteModel>.from(_materias);
    materiasCopia.sort((a, b) => b.asistencia.compareTo(a.asistencia));
    return materiasCopia;
  }
}