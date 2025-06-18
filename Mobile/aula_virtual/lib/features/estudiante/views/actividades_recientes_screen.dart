import 'package:flutter/material.dart';
import '../../../core/models/actividad_estudiante_model.dart';

class ActividadesRecientesScreen extends StatelessWidget {
  final List<ActividadEstudianteModel> actividadesRecientes;

  const ActividadesRecientesScreen({
    super.key,
    required this.actividadesRecientes,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actividades Recientes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: actividadesRecientes.isEmpty 
          ? _buildEmptyState() 
          : _buildListaActividades(),
    );
  }

  Widget _buildListaActividades() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: actividadesRecientes.length,
      itemBuilder: (context, index) {
        final actividad = actividadesRecientes[index];
        return _buildActividadCard(actividad, index);
      },
    );
  }

  Widget _buildActividadCard(ActividadEstudianteModel actividad, int index) {
    // 🔥 ADAPTARSE A LA NUEVA ESTRUCTURA
    final String titulo = actividad.nombre;
    final String materia = actividad.materia; // Usa el getter que definimos
    final String estado = actividad.estado;
    
    // Configuración por estado
    final EstadoConfig config = _getConfigByEstado(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                config.color.withOpacity(0.1),
                config.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con estado
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: config.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      config.icono,
                      color: config.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          materia, // 🔥 MOSTRAR LA MATERIA CORRECTAMENTE
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: config.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      config.texto,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  Icon(
                    Icons.assignment,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Actividad de $materia', // 🔥 MOSTRAR INFO DE LA MATERIA
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (actividad.nota != null && actividad.nota! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${actividad.nota!.toStringAsFixed(0)}/100',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
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
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay actividades recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las actividades aparecerán aquí cuando estén disponibles',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  EstadoConfig _getConfigByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return EstadoConfig(
          color: Colors.orange.shade600,
          icono: Icons.pending_actions,
          texto: 'Pendiente',
        );
      case 'entregado':
        return EstadoConfig(
          color: Colors.green.shade600,
          icono: Icons.upload_file,
          texto: 'Entregado',
        );
      case 'revisado':
        return EstadoConfig(
          color: Colors.blue.shade600,
          icono: Icons.task_alt,
          texto: 'Revisado',
        );
      default:
        return EstadoConfig(
          color: Colors.grey.shade600,
          icono: Icons.help_outline,
          texto: 'Desconocido',
        );
    }
  }
}

class EstadoConfig {
  final Color color;
  final IconData icono;
  final String texto;

  EstadoConfig({
    required this.color,
    required this.icono,
    required this.texto,
  });
}