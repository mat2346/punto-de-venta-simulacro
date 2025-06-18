import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/tutor_provider.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/resumen_cards.dart';
import '../widgets/materias_list.dart';
import '../widgets/actividades_recientes.dart';
import '../widgets/asistencia_chart.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TutorProvider>(context, listen: false).cargarEstudiantes();
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
      appBar: AppBar(
        title: const Text(
          'Dashboard Tutor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _refrescarDatos(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
          PopupMenuButton<String>(
            onSelected: _manejarOpcionMenu,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<TutorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.tieneEstudiantes) {
            return _buildLoadingState();
          }

          if (provider.errorMessage != null && !provider.tieneEstudiantes) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (!provider.tieneEstudiantes) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Selector de estudiante
              _buildEstudianteSelector(provider),
              
              // Contenido principal
              Expanded(
                child: provider.tieneHijoSeleccionado
                    ? _buildContenidoPrincipal(provider)
                    : _buildSeleccionarEstudiante(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEstudianteSelector(TutorProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selecciona a tu hijo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: provider.estudianteSeleccionado,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            hint: const Text('Selecciona un estudiante'),
            items: provider.estudiantes.map((estudiante) {
              return DropdownMenuItem<int>(
                value: estudiante['id'],
                child: Text(
                  '${estudiante['nombre']} (${estudiante['codigo']})',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                provider.seleccionarEstudiante(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoPrincipal(TutorProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        // Resumen en cards
        if (provider.resumenHijo != null)
          ResumenCards(resumen: provider.resumenHijo!),
        
        const SizedBox(height: 16),
        
        // Pestañas de contenido
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.purple.shade700,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple.shade700,
            tabs: const [
              Tab(text: 'Resumen', icon: Icon(Icons.dashboard, size: 16)),
              Tab(text: 'Materias', icon: Icon(Icons.school, size: 16)),
              Tab(text: 'Actividades', icon: Icon(Icons.assignment, size: 16)),
              Tab(text: 'Asistencia', icon: Icon(Icons.check_circle, size: 16)),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabResumen(provider),
              _buildTabMaterias(provider),
              _buildTabActividades(provider),
              _buildTabAsistencia(provider),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabResumen(TutorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen General',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Aquí puedes agregar más widgets de resumen
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Text(
              'Información general del estudiante y análisis de rendimiento.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabMaterias(TutorProvider provider) {
    return MateriasList(
      materias: provider.resumenHijo?['materias'] ?? [],
    );
  }

  Widget _buildTabActividades(TutorProvider provider) {
    return ActividadesRecientes(
      actividades: provider.resumenHijo?['actividades_recientes'] ?? [],
    );
  }

  Widget _buildTabAsistencia(TutorProvider provider) {
    return AsistenciaChart(
      datosAsistencia: provider.rendimientoDetallado?['asistencia'] ?? {},
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.purple),
          SizedBox(height: 16),
          Text(
            'Cargando información...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.family_restroom,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay estudiantes asignados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No tienes estudiantes bajo tu tutela.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeleccionarEstudiante() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Selecciona un estudiante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Elige un estudiante de la lista para ver su información.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refrescarDatos() async {
    final provider = Provider.of<TutorProvider>(context, listen: false);
    await provider.refrescarDatos();
  }

  void _manejarOpcionMenu(String opcion) {
    switch (opcion) {
      case 'perfil':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil en desarrollo')),
        );
        break;
      case 'cerrar_sesion':
        _cerrarSesion();
        break;
    }
  }

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthService>(context, listen: false).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}