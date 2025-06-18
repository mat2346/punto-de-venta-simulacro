import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/profesor_provider.dart';
import '../../../core/services/profesor_service.dart';
import '../widgets/estudiante_card.dart';
import '../widgets/actividad_card.dart';

class MateriaDetalleScreen extends StatefulWidget {
  final int detalleId;
  final String nombreMateria;

  const MateriaDetalleScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  State<MateriaDetalleScreen> createState() => _MateriaDetalleScreenState();
}

class _MateriaDetalleScreenState extends State<MateriaDetalleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar datos al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
      profesorProvider.cargarEstudiantes(widget.detalleId);
      profesorProvider.cargarActividades(widget.detalleId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.nombreMateria,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'asistencia':
                  _navegarAAsistencia();
                  break;
                case 'reporte':
                  _navegarAReporteAsistencia();
                  break;
                case 'notificar':
                  _navegarANotificaciones();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'asistencia',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Tomar Asistencia'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reporte',
                child: Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Reporte Asistencia'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'notificar',
                child: Row(
                  children: [
                    Icon(Icons.notifications, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Enviar Notificación'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Estudiantes', icon: Icon(Icons.people)),
            Tab(text: 'Actividades', icon: Icon(Icons.assignment)),
            Tab(text: 'Resumen', icon: Icon(Icons.dashboard)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEstudiantesTab(),
          _buildActividadesTab(),
          _buildResumenTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildEstudiantesTab() {
    return Consumer<ProfesorProvider>(
      builder: (context, profesorProvider, child) {
        if (profesorProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profesorProvider.estudiantes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay estudiantes registrados',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => profesorProvider.cargarEstudiantes(widget.detalleId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profesorProvider.estudiantes.length,
            itemBuilder: (context, index) {
              final estudiante = profesorProvider.estudiantes[index];
              return EstudianteCard(
                estudiante: estudiante,
                onTap: () => _verDetalleEstudiante(estudiante),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActividadesTab() {
    return Consumer<ProfesorProvider>(
      builder: (context, profesorProvider, child) {
        if (profesorProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profesorProvider.actividades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No hay actividades creadas',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _crearActividad,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Primera Actividad'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => profesorProvider.cargarActividades(widget.detalleId),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profesorProvider.actividades.length,
            itemBuilder: (context, index) {
              final actividad = profesorProvider.actividades[index];
              return ActividadCard(
                actividad: actividad,
                onTap: () => _verDetalleActividad(actividad),
                onCalificar: () => _calificarActividad(actividad),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildResumenTab() {
    return Consumer<ProfesorProvider>(
      builder: (context, profesorProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estadísticas generales
              _buildStatsCards(profesorProvider),
              
              const SizedBox(height: 24),
              
              // Acciones rápidas
              _buildQuickActions(),
              
              const SizedBox(height: 24),
              
              // Actividades recientes
              _buildRecentActivities(profesorProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(ProfesorProvider profesorProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Estudiantes',
            value: '${profesorProvider.estudiantes.length}',
            icon: Icons.people,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Actividades',
            value: '${profesorProvider.actividades.length}',
            icon: Icons.assignment,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildQuickActionButton(
                title: 'Tomar Asistencia',
                icon: Icons.check_circle,
                color: Colors.green,
                onTap: _navegarAAsistencia,
              ),
              _buildQuickActionButton(
                title: 'Crear Actividad',
                icon: Icons.add_task,
                color: Colors.blue,
                onTap: _crearActividad,
              ),
              _buildQuickActionButton(
                title: 'Ver Reportes',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: _navegarAReporteAsistencia,
              ),
              _buildQuickActionButton(
                title: 'Notificar',
                icon: Icons.notifications,
                color: Colors.orange,
                onTap: _navegarANotificaciones,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities(ProfesorProvider profesorProvider) {
    final actividadesRecientes = profesorProvider.actividades.take(3).toList();
    
    if (actividadesRecientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Actividades Recientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...actividadesRecientes.map((actividad) =>
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.assignment, color: Colors.blue[700], size: 20),
              ),
              title: Text(actividad.nombre),
              subtitle: Text(actividad.descripcion),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _verDetalleActividad(actividad),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _crearActividad,
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: const Text('Nueva Actividad'),
    );
  }

  // Métodos de navegación
  void _navegarAAsistencia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsistenciaScreen(
          detalleId: widget.detalleId,
          nombreMateria: widget.nombreMateria,
        ),
      ),
    );
  }

  void _navegarAReporteAsistencia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReporteAsistenciaScreen(
          detalleId: widget.detalleId,
          nombreMateria: widget.nombreMateria,
        ),
      ),
    );
  }

  void _navegarANotificaciones() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificacionesScreen(
          detalleId: widget.detalleId,
          nombreMateria: widget.nombreMateria,
        ),
      ),
    );
  }

  void _crearActividad() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearActividadScreen(
          detalleId: widget.detalleId,
          nombreMateria: widget.nombreMateria,
        ),
      ),
    );
  }

  void _verDetalleEstudiante(EstudianteModel estudiante) {
    showModalBottomSheet(
      context: context,
      builder: (context) => EstudianteDetalleModal(
        estudiante: estudiante,
        detalleId: widget.detalleId,
      ),
    );
  }

  void _verDetalleActividad(ActividadModel actividad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActividadDetalleScreen(
          actividad: actividad,
          detalleId: widget.detalleId,
        ),
      ),
    );
  }

  void _calificarActividad(ActividadModel actividad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalificarActividadScreen(
          actividad: actividad,
          detalleId: widget.detalleId,
        ),
      ),
    );
  }
}

// Importaciones ficticias - necesitarás crear estas pantallas
class AsistenciaScreen extends StatelessWidget {
  final int detalleId;
  final String nombreMateria;

  const AsistenciaScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asistencia - $nombreMateria')),
      body: const Center(child: Text('Pantalla de Asistencia')),
    );
  }
}

class ReporteAsistenciaScreen extends StatelessWidget {
  final int detalleId;
  final String nombreMateria;

  const ReporteAsistenciaScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reporte - $nombreMateria')),
      body: const Center(child: Text('Pantalla de Reporte')),
    );
  }
}

class NotificacionesScreen extends StatelessWidget {
  final int detalleId;
  final String nombreMateria;

  const NotificacionesScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones - $nombreMateria')),
      body: const Center(child: Text('Pantalla de Notificaciones')),
    );
  }
}

class CrearActividadScreen extends StatelessWidget {
  final int detalleId;
  final String nombreMateria;

  const CrearActividadScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Actividad - $nombreMateria')),
      body: const Center(child: Text('Pantalla Crear Actividad')),
    );
  }
}

class EstudianteDetalleModal extends StatelessWidget {
  final EstudianteModel estudiante;
  final int detalleId;

  const EstudianteDetalleModal({
    super.key,
    required this.estudiante,
    required this.detalleId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Detalle: ${estudiante.nombre}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class ActividadDetalleScreen extends StatelessWidget {
  final ActividadModel actividad;
  final int detalleId;

  const ActividadDetalleScreen({
    super.key,
    required this.actividad,
    required this.detalleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(actividad.nombre)),
      body: const Center(child: Text('Detalle de Actividad')),
    );
  }
}

class CalificarActividadScreen extends StatelessWidget {
  final ActividadModel actividad;
  final int detalleId;

  const CalificarActividadScreen({
    super.key,
    required this.actividad,
    required this.detalleId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calificar: ${actividad.nombre}')),
      body: const Center(child: Text('Pantalla de Calificación')),
    );
  }
}