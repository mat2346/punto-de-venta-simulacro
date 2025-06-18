import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/estudiante_provider.dart';
import '../../../core/models/actividad_estudiante_model.dart';
import '../../../core/models/materia_estudiante_model.dart';
import '../widgets/actividad_estudiante_card.dart';

class EstudianteActividadesScreen extends StatefulWidget {
  const EstudianteActividadesScreen({super.key});

  @override
  State<EstudianteActividadesScreen> createState() => _EstudianteActividadesScreenState();
}

class _EstudianteActividadesScreenState extends State<EstudianteActividadesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _buscarController = TextEditingController();
  String _filtroActual = '';
  int? _materiaSeleccionada;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Cargar actividades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarActividades();
    });
    
    // Listener para cambios de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _filtrarPorTab();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscarController.dispose();
    super.dispose();
  }

  void _cargarActividades() {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.buscarActividades();
  }

  void _filtrarPorTab() {
    String estado = '';
    switch (_tabController.index) {
      case 0:
        estado = ''; // Todas
        break;
      case 1:
        estado = 'pendiente';
        break;
      case 2:
        estado = 'entregada';
        break;
      case 3:
        estado = 'revisada';
        break;
    }
    
    _buscarActividades(estado: estado);
  }

  void _buscarActividades({String? estado}) {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.buscarActividades(
      filtro: _filtroActual.isEmpty ? null : _filtroActual,
      estado: estado,
      materiaId: _materiaSeleccionada,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Actividades',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _mostrarFiltros,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
          ),
          IconButton(
            onPressed: _cargarActividades,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Barra de búsqueda
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _buscarController,
                  decoration: InputDecoration(
                    hintText: 'Buscar actividades...',
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _buscarController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _limpiarBusqueda,
                            icon: const Icon(Icons.clear, color: Colors.white70),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _onBusquedaChanged,
                ),
              ),
              
              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: 'Todas'),
                  Tab(text: 'Pendientes'),
                  Tab(text: 'Entregadas'),
                  Tab(text: 'Revisadas'),
                ],
              ),
            ],
          ),
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
                  Text('Cargando actividades...'),
                ],
              ),
            );
          }

          if (provider.tieneErrores) {
            return _buildErrorState(provider);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildListaActividades(provider.actividades, 'todas'),
              _buildListaActividades(provider.actividadesPendientes, 'pendientes'),
              _buildListaActividades(provider.actividadesEntregadas, 'entregadas'),
              _buildListaActividades(provider.actividadesRevisadas, 'revisadas'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListaActividades(List<ActividadEstudianteModel> actividades, String tipo) {
    if (actividades.isEmpty) {
      return _buildEmptyState(tipo);
    }

    return RefreshIndicator(
      onRefresh: () async => _cargarActividades(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actividades.length,
        itemBuilder: (context, index) {
          final actividad = actividades[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ActividadEstudianteCard(
              actividad: actividad,
              onTap: () => _verDetalleActividad(actividad),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String tipo) {
    String mensaje;
    IconData icono;
    
    switch (tipo) {
      case 'pendientes':
        mensaje = 'No tienes actividades pendientes';
        icono = Icons.task_alt;
        break;
      case 'entregadas':
        mensaje = 'No has entregado actividades aún';
        icono = Icons.upload_file;
        break;
      case 'revisadas':
        mensaje = 'No tienes actividades revisadas';
        icono = Icons.check_circle;
        break;
      default:
        mensaje = 'No hay actividades disponibles';
        icono = Icons.assignment_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarActividades,
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
              'Error al cargar actividades',
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
              onPressed: _cargarActividades,
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

  void _onBusquedaChanged(String value) {
    setState(() {
      _filtroActual = value;
    });
    
    // Buscar con delay para evitar muchas requests
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_filtroActual == value) {
        _filtrarPorTab();
      }
    });
  }

  void _limpiarBusqueda() {
    _buscarController.clear();
    setState(() {
      _filtroActual = '';
    });
    _filtrarPorTab();
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFiltrosBottomSheet(),
    );
  }

  Widget _buildFiltrosBottomSheet() {
    return Consumer<EstudianteProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _limpiarFiltros,
                    child: const Text('Limpiar'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Filtro por materia
              const Text(
                'Materia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _materiaSeleccionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Selecciona una materia'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Todas las materias'),
                  ),
                  ...provider.materias.map((materia) {
                    return DropdownMenuItem<int?>(
                      value: materia.id,
                      child: Text(materia.nombreCompleto),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _materiaSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _filtrarPorTab();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aplicar Filtros'),
                    ),
                  ),
                ],
              ),
              
              // Espacio para el teclado
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _materiaSeleccionada = null;
      _filtroActual = '';
    });
    _buscarController.clear();
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.limpiarFiltrosActividades();
    Navigator.of(context).pop();
    _filtrarPorTab();
  }

  void _verDetalleActividad(ActividadEstudianteModel actividad) {
    // Implementar navegación al detalle de la actividad
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalle de: ${actividad.nombre}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}