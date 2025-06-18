import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/estudiante_provider.dart';
import '../../../core/services/auth_service.dart'; // 🔥 CAMBIAR ESTA LÍNEA
import '../widgets/resumen_card.dart';
import '../widgets/materia_estudiante_card.dart';
import '../widgets/actividades_recientes_widget.dart';
import '../widgets/estadisticas_widget.dart';
import 'registro_asistencia_screen.dart';
import 'estudiante_detalle_materia_screen.dart';
//import '../../../core/services/estudiante_service.dart';
import '../../../core/models/materia_estudiante_model.dart';
import 'actividades_recientes_screen.dart';

class EstudianteDashboard extends StatefulWidget {
  const EstudianteDashboard({super.key});

  @override
  State<EstudianteDashboard> createState() => _EstudianteDashboardState();
}

class _EstudianteDashboardState extends State<EstudianteDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  void _cargarDatosIniciales() {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.cargarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 🔥 BOTÓN DE ASISTENCIA MÓVIL
          IconButton(
            onPressed: () => _navegarARegistroAsistencia(),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Registrar Asistencia',
          ),
          // 🔥 BOTÓN DE REFRESCAR
          IconButton(
            onPressed: _refrescarDatos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
          // 🔥 MENÚ DE OPCIONES
          PopupMenuButton<String>(
            onSelected: _manejarOpcionMenu,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'perfil',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Mi Perfil'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'configuracion',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Configuración'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cerrar_sesion',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<EstudianteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando dashboard...'),
                ],
              ),
            );
          }

          if (provider.tieneErrores) {
            return _buildErrorState(provider);
          }

          if (!provider.tieneDatos) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refrescarDatos,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 SALUDO PERSONALIZADO
                  _buildSaludoPersonalizado(),
                  const SizedBox(height: 20),

                  // 🔥 RESUMEN PRINCIPAL
                  ResumenCard(
                    promedio: provider.resumenDashboard!.promedioGeneral,
                    asistencia: provider.resumenDashboard!.asistenciaGeneral,
                    materiasTotal: provider.resumenDashboard!.materiasTotal,
                    actividadesPendientes: provider.resumenDashboard!.actividadesPendientes,
                  ),
                  const SizedBox(height: 20),

                  // 🔥 SECCIÓN DE MATERIAS - CAMBIAR ESTA PARTE
                  _buildSeccionMaterias(provider),
                  const SizedBox(height: 20),

                  // 🔥 ESTADÍSTICAS
                  EstadisticasWidget(
                    promedioGeneral: provider.resumenDashboard!.promedioGeneral,
                    asistenciaGeneral: provider.resumenDashboard!.asistenciaGeneral,
                    materiasTotal: provider.resumenDashboard!.materiasTotal,
                    actividadesPendientes: provider.resumenDashboard!.actividadesPendientes,
                  ),
                  const SizedBox(height: 20),

                  // 🔥 ACTIVIDADES RECIENTES
                  ActividadesRecientesWidget(
                    actividades: provider.resumenDashboard!.ultimasActividades.map((a) => a.toJson()).toList(),
                    onVerTodas: () => _navegarAActividades(),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
      // 🔥 FLOATING ACTION BUTTON PARA ASISTENCIA RÁPIDA
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarARegistroAsistencia,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Asistencia'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  // 🔥 SALUDO PERSONALIZADO
  Widget _buildSaludoPersonalizado() {
    final authService = Provider.of<AuthService>(context, listen: false); // 🔥 CAMBIAR ESTA LÍNEA
    final nombreUsuario = authService.currentUser?.nombre ?? 'Estudiante';
    final horaActual = DateTime.now().hour;
    
    String saludo;
    Color colorSaludo;
    IconData iconoSaludo;

    if (horaActual < 12) {
      saludo = 'Buenos días';
      colorSaludo = Colors.orange;
      iconoSaludo = Icons.wb_sunny;
    } else if (horaActual < 18) {
      saludo = 'Buenas tardes';
      colorSaludo = Colors.blue;
      iconoSaludo = Icons.wb_cloudy;
    } else {
      saludo = 'Buenas noches';
      colorSaludo = Colors.indigo;
      iconoSaludo = Icons.brightness_3;
    }

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [colorSaludo.withOpacity(0.1), colorSaludo.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorSaludo.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconoSaludo, color: colorSaludo, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$saludo, $nombreUsuario',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Listo para un día productivo de aprendizaje!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  // 🔥 ACCESO RÁPIDO A ASISTENCIA MÓVIL
  Widget _buildAccesoRapidoAsistencia() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: _navegarARegistroAsistencia,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registrar Asistencia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Escanea el código de tu profesor',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 SECCIÓN DE MATERIAS
  Widget _buildSeccionMaterias(EstudianteProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.school, color: Colors.indigo.shade700, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Mis Materias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${provider.totalMaterias}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (provider.materias.isEmpty)
          _buildEmptyMaterias()
        else
          // 🔥 CAMBIAR ListView.separated POR Column
          Column(
            children: [
              for (int index = 0; index < provider.materias.length; index++) ...[
                MateriaEstudianteCard(
                  materia: provider.materias[index],
                  onTap: () => _navegarADetalleMateria(provider.materias[index]),
                ),
                if (index < provider.materias.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyMaterias() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay materias disponibles',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 ESTADO DE ERROR
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
              'Error al cargar datos',
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

  // 🔥 ESTADO VACÍO
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Parece que aún no tienes materias asignadas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refrescarDatos,
              icon: const Icon(Icons.refresh),
              label: const Text('Refrescar'),
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

  // 🔥 MÉTODOS DE NAVEGACIÓN Y ACCIONES

  void _navegarARegistroAsistencia() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegistroAsistenciaScreen(),
      ),
    );
  }

  void _navegarADetalleMateria(MateriaEstudianteModel materia) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstudianteDetalleMateriaScreen(
          materiaId: materia.id,
          nombreMateria: materia.nombreCompleto,
        ),
      ),
    );
  }

  void _navegarAActividades() {
    // 🔥 OBTENER EL PROVIDER CORRECTAMENTE
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActividadesRecientesScreen(
          actividadesRecientes: provider.resumenDashboard?.ultimasActividades ?? [],
        ),
      ),
    );
  }

  Future<void> _refrescarDatos() async {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    await provider.refrescarDatos();
  }

  void _manejarOpcionMenu(String opcion) {
    switch (opcion) {
      case 'perfil':
        // Navegar a perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil en desarrollo')),
        );
        break;
      case 'configuracion':
        // Navegar a configuración
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración en desarrollo')),
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
              Provider.of<AuthService>(context, listen: false).logout(); // 🔥 CAMBIAR ESTA LÍNEA
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}