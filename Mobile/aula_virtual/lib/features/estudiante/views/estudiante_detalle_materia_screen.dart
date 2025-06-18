import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/estudiante_provider.dart';
import '../widgets/actividad_estudiante_card.dart';
import '../widgets/asistencia_chart_widget.dart';
import '../widgets/notas_chart_widget.dart';
import 'package:aula_virtual/core/models/detalle_materia_estudiante_model.dart';
import 'package:aula_virtual/core/models/actividad_estudiante_model.dart';
import 'package:aula_virtual/core/models/asistencia_estudiante_model.dart';





class EstudianteDetalleMateriaScreen extends StatefulWidget {
  final int materiaId;
  final String nombreMateria;

  const EstudianteDetalleMateriaScreen({
    super.key,
    required this.materiaId,
    required this.nombreMateria,
  });

  @override
  State<EstudianteDetalleMateriaScreen> createState() => _EstudianteDetalleMateriaScreenState();
}

class _EstudianteDetalleMateriaScreenState extends State<EstudianteDetalleMateriaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarDatosIniciales() {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.cargarDetalleMateria(widget.materiaId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.nombreMateria,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refrescarDatos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.info_outline),
              text: 'Resumen',
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Actividades',
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline),
              text: 'Asistencia',
            ),
          ],
        ),
      ),
      body: Consumer<EstudianteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetalle) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando información de la materia...'),
                ],
              ),
            );
          }

          if (provider.tieneErrores) {
            return _buildErrorState(provider);
          }

          if (provider.detalleMateria == null) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTabResumen(provider),
              _buildTabActividades(provider),
              _buildTabAsistencia(provider),
            ],
          );
        },
      ),
    );
  }

  // 🔥 TAB 1: RESUMEN DE LA MATERIA
  Widget _buildTabResumen(EstudianteProvider provider) {
    final detalle = provider.detalleMateria!;
    
    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 INFORMACIÓN GENERAL
            _buildInformacionGeneral(detalle),
            const SizedBox(height: 20),

            // 🔥 MÉTRICAS PRINCIPALES
            _buildMetricasPrincipales(detalle),
            const SizedBox(height: 20),

            // 🔥 GRÁFICO DE NOTAS
            NotasChartWidget(
              actividades: detalle.actividades.where((a) => a.nota != null).toList(),
            ),
            const SizedBox(height: 20),

            // 🔥 PROGRESO DE ACTIVIDADES
            _buildProgresoActividades(detalle),
            const SizedBox(height: 20),

            // 🔥 ESTADÍSTICAS ADICIONALES
            _buildEstadisticasAdicionales(detalle),
          ],
        ),
      ),
    );
  }

  // 🔥 TAB 2: ACTIVIDADES
  Widget _buildTabActividades(EstudianteProvider provider) {
    final actividades = provider.actividades;
    
    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: Column(
        children: [
          // 🔥 FILTROS DE ACTIVIDADES
          _buildFiltrosActividades(provider),
          
          // 🔥 LISTA DE ACTIVIDADES
          Expanded(
            child: actividades.isEmpty
                ? _buildEmptyActividades()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: actividades.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final actividad = actividades[index];
                      return ActividadEstudianteCard(
                        actividad: actividad,
                        onTap: () => _verDetalleActividad(actividad),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // 🔥 TAB 3: ASISTENCIA
  Widget _buildTabAsistencia(EstudianteProvider provider) {
    final historial = provider.historialAsistencia;
    
    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 GRÁFICO DE ASISTENCIA
            AsistenciaChartWidget(
              historialAsistencia: historial,
              asistenciaGeneral: provider.detalleMateria?.asistencia ?? 0,
            ),
            const SizedBox(height: 20),

            // 🔥 ESTADÍSTICAS DE ASISTENCIA
            _buildEstadisticasAsistencia(provider),
            const SizedBox(height: 20),

            // 🔥 HISTORIAL DETALLADO
            _buildHistorialAsistencia(historial),
          ],
        ),
      ),
    );
  }

  // 🔥 INFORMACIÓN GENERAL
  Widget _buildInformacionGeneral(DetalleMateriaEstudianteModel detalle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school,
                    color: Colors.indigo.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detalle.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${detalle.curso} ${detalle.paralelo}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Profesor: ${detalle.profesor}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 MÉTRICAS PRINCIPALES
  Widget _buildMetricasPrincipales(DetalleMateriaEstudianteModel detalle) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricaCard(
            'Promedio',
            detalle.promedio.toStringAsFixed(1),
            Icons.star,
            _getColorByPromedio(detalle.promedio),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricaCard(
            'Asistencia',
            '${detalle.asistencia.toStringAsFixed(1)}%',
            Icons.check_circle,
            _getColorByAsistencia(detalle.asistencia),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricaCard(String titulo, String valor, IconData icono, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 PROGRESO DE ACTIVIDADES
  Widget _buildProgresoActividades(DetalleMateriaEstudianteModel detalle) {
    final totalActividades = detalle.actividades.length;
    final actividadesRevisadas = detalle.actividades.where((a) => a.estaRevisada).length;
    final progreso = totalActividades > 0 ? (actividadesRevisadas / totalActividades) : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Progreso de Actividades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progreso,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progreso > 0.7 ? Colors.green : 
                  progreso > 0.4 ? Colors.orange : Colors.red,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$actividadesRevisadas de $totalActividades completadas',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(progreso * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 ESTADÍSTICAS ADICIONALES
  Widget _buildEstadisticasAdicionales(DetalleMateriaEstudianteModel detalle) {
    final pendientes = detalle.actividades.where((a) => a.estaPendiente).length;
    final entregadas = detalle.actividades.where((a) => a.estaEntregada).length;
    final revisadas = detalle.actividades.where((a) => a.estaRevisada).length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Estadísticas Detalladas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Pendientes',
                    '$pendientes',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Entregadas',
                    '$entregadas',
                    Icons.upload_file,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Revisadas',
                    '$revisadas',
                    Icons.task_alt,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // 🔥 FILTROS DE ACTIVIDADES
  Widget _buildFiltrosActividades(EstudianteProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: provider.estadoFiltroActividades.isEmpty 
                  ? null 
                  : provider.estadoFiltroActividades,
              decoration: InputDecoration(
                labelText: 'Filtrar por estado',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('Todas')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendientes')),
                DropdownMenuItem(value: 'entregada', child: Text('Entregadas')),
                DropdownMenuItem(value: 'revisada', child: Text('Revisadas')),
              ],
              onChanged: (valor) {
                provider.buscarActividades(
                  estado: valor == '' ? null : valor,
                  materiaId: widget.materiaId,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              provider.limpiarFiltrosActividades();
              provider.cargarActividades(widget.materiaId);
            },
            icon: const Icon(Icons.clear),
            tooltip: 'Limpiar filtros',
          ),
        ],
      ),
    );
  }

  // 🔥 ESTADÍSTICAS DE ASISTENCIA
  Widget _buildEstadisticasAsistencia(EstudianteProvider provider) {
    final stats = provider.estadisticasAsistencia;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Resumen de Asistencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Presentes',
                    '${stats['presentes']}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Ausentes',
                    '${stats['ausentes']}',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Tardanzas',
                    '${stats['tardanzas']}',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 HISTORIAL DE ASISTENCIA
  Widget _buildHistorialAsistencia(List<AsistenciaEstudianteModel> historial) {
    if (historial.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'No hay historial de asistencia',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.indigo.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Historial Detallado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: historial.length > 10 ? 10 : historial.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final asistencia = historial[index];
              return _buildAsistenciaItem(asistencia);
            },
          ),
          if (historial.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Mostrar historial completo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidad en desarrollo')),
                    );
                  },
                  child: Text('Ver ${historial.length - 10} registros más'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAsistenciaItem(AsistenciaEstudianteModel asistencia) {
    Color color;
    IconData icono;
    
    if (asistencia.esPresente) {
      color = Colors.green;
      icono = Icons.check_circle;
    } else if (asistencia.esTardanza) {
      color = Colors.orange;
      icono = Icons.schedule;
    } else {
      color = Colors.red;
      icono = Icons.cancel;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, color: color, size: 20),
      ),
      title: Text(
        _formatearFecha(asistencia.fecha),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: asistencia.observacion != null
          ? Text(asistencia.observacion!)
          : null,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          asistencia.estado.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // 🔥 ESTADOS VACÍOS Y DE ERROR

  Widget _buildEmptyActividades() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividades',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las actividades aparecerán aquí cuando estén disponibles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(EstudianteProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontró información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar la información de esta materia',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 MÉTODOS AUXILIARES

  Future<void> _refrescarDatos() async {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    await provider.refrescarDetalleMateria();
  }

  void _verDetalleActividad(ActividadEstudianteModel actividad) {
    // Implementar navegación a detalle de actividad
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalle de: ${actividad.nombre}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}';
    } catch (e) {
      return fecha;
    }
  }

  Color _getColorByPromedio(double promedio) {
    if (promedio >= 80) return Colors.green;
    if (promedio >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getColorByAsistencia(double asistencia) {
    if (asistencia >= 80) return Colors.green;
    if (asistencia >= 60) return Colors.orange;
    return Colors.red;
  }
}