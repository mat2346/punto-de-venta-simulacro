import 'package:flutter/material.dart';

class ActividadesRecientesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> actividades;
  final VoidCallback? onVerTodas;

  const ActividadesRecientesWidget({
    super.key,
    required this.actividades,
    this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 HEADER CON TÍTULO Y BOTÓN
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Colors.teal.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Actividades Recientes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onVerTodas != null)
                  TextButton(
                    onPressed: onVerTodas,
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔥 LISTA DE ACTIVIDADES
            if (actividades.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actividades.length > 5 ? 5 : actividades.length, // Máximo 5
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final actividad = actividades[index];
                  return _buildActividadItem(actividad);
                },
              ),

            // 🔥 BOTÓN VER MÁS SI HAY MÁS DE 5
            if (actividades.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: onVerTodas,
                  icon: Icon(Icons.expand_more, color: Colors.teal.shade700),
                  label: Text(
                    'Ver ${actividades.length - 5} más',
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActividadItem(Map<String, dynamic> actividad) {
    // 🔥 ADAPTARSE A LA ESTRUCTURA DEL ENDPOINT /alumno/resumen/
    final String titulo = actividad['titulo'] ?? actividad['nombre'] ?? 'Sin título';
    final String materia = actividad['materia'] ?? 'Sin materia';
    final String estado = actividad['estado'] ?? 'pendiente';

    // Configuración por estado
    final EstadoConfig config = _getConfigByEstado(estado);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 🔥 INDICADOR DE ESTADO
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: config.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              config.icono,
              color: config.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // 🔥 INFORMACIÓN PRINCIPAL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  materia,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // 🔥 ESTADO
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              config.texto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: config.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No hay actividades recientes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Las nuevas actividades aparecerán aquí',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 CONFIGURACIÓN POR ESTADO
  EstadoConfig _getConfigByEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return EstadoConfig(
          color: Colors.orange,
          icono: Icons.pending_actions,
          texto: 'Pendiente',
        );
      case 'entregada':
        return EstadoConfig(
          color: Colors.blue,
          icono: Icons.upload_file,
          texto: 'Entregada',
        );
      case 'revisada':
        return EstadoConfig(
          color: Colors.green,
          icono: Icons.task_alt,
          texto: 'Revisada',
        );
      case 'vencida':
        return EstadoConfig(
          color: Colors.red,
          icono: Icons.schedule,
          texto: 'Vencida',
        );
      default:
        return EstadoConfig(
          color: Colors.grey,
          icono: Icons.help_outline,
          texto: 'Desconocido',
        );
    }
  }

  // 🔥 FORMATEAR FECHA
  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      final DateTime ahora = DateTime.now();
      final Duration diferencia = fechaDateTime.difference(ahora);

      if (diferencia.inDays > 0) {
        return 'Vence en ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
      } else if (diferencia.inDays == 0) {
        return 'Vence hoy';
      } else {
        return 'Vencida hace ${diferencia.inDays.abs()} día${diferencia.inDays.abs() > 1 ? 's' : ''}';
      }
    } catch (e) {
      return fecha;
    }
  }

  // 🔥 COLOR POR NOTA
  Color _getColorByNota(double nota) {
    if (nota >= 80) return Colors.green;
    if (nota >= 60) return Colors.orange;
    return Colors.red;
  }
}

// 🔥 CLASE AUXILIAR PARA CONFIGURACIÓN DE ESTADO
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