import 'package:flutter/material.dart';
import '../services/tutor_service.dart';

class TutorProvider with ChangeNotifier {
  List<Map<String, dynamic>> _estudiantes = [];
  Map<String, dynamic>? _resumenHijo;
  Map<String, dynamic>? _rendimientoDetallado;
  
  bool _isLoading = false;
  String? _errorMessage;
  int? _estudianteSeleccionado;

  // Getters
  List<Map<String, dynamic>> get estudiantes => _estudiantes;
  Map<String, dynamic>? get resumenHijo => _resumenHijo;
  Map<String, dynamic>? get rendimientoDetallado => _rendimientoDetallado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get estudianteSeleccionado => _estudianteSeleccionado;

  // Helper getters
  bool get tieneEstudiantes => _estudiantes.isNotEmpty;
  bool get tieneHijoSeleccionado => _estudianteSeleccionado != null;

  // Cargar estudiantes
  Future<void> cargarEstudiantes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _estudiantes = await TutorService.obtenerEstudiantes();
      
      // Si hay estudiantes, seleccionar el primero automáticamente
      if (_estudiantes.isNotEmpty) {
        _estudianteSeleccionado = _estudiantes.first['id'];
        await cargarDatosHijo(_estudianteSeleccionado!);
      }
    } catch (e) {
      _errorMessage = 'Error al cargar estudiantes: $e';
      print('❌ Error cargando estudiantes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Seleccionar estudiante
  Future<void> seleccionarEstudiante(int estudianteId) async {
    if (_estudianteSeleccionado == estudianteId) return;

    _estudianteSeleccionado = estudianteId;
    await cargarDatosHijo(estudianteId);
  }

  // Cargar datos del hijo seleccionado
  Future<void> cargarDatosHijo(int estudianteId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Cargar resumen y rendimiento en paralelo
      final futures = await Future.wait([
        TutorService.obtenerResumenHijo(estudianteId),
        TutorService.obtenerRendimientoDetallado(estudianteId),
      ]);

      _resumenHijo = futures[0];
      _rendimientoDetallado = futures[1];
    } catch (e) {
      _errorMessage = 'Error al cargar datos del estudiante: $e';
      print('❌ Error cargando datos del hijo: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refrescar datos
  Future<void> refrescarDatos() async {
    if (_estudianteSeleccionado != null) {
      await cargarDatosHijo(_estudianteSeleccionado!);
    }
  }

  // Limpiar datos
  void limpiarDatos() {
    _estudiantes.clear();
    _resumenHijo = null;
    _rendimientoDetallado = null;
    _estudianteSeleccionado = null;
    _errorMessage = null;
    notifyListeners();
  }
}