import 'package:flutter/material.dart';
import '../../../core/services/profesor_service.dart';

class ActividadCard extends StatelessWidget {
  final ActividadModel actividad;
  final VoidCallback? onTap;
  final VoidCallback? onCalificar;

  const ActividadCard({
    super.key,
    required this.actividad,
    this.onTap,
    this.onCalificar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con título y fecha
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de la actividad
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getActivityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getActivityIcon(),
                      color: _getActivityColor(),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Título y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          actividad.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          actividad.descripcion,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Menú de opciones
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(context, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'ver',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('Ver Detalles'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'calificar',
                        child: Row(
                          children: [
                            Icon(Icons.grade, size: 20),
                            SizedBox(width: 8),
                            Text('Calificar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Información adicional
              Row(
                children: [
                  // Fecha de creación
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(actividad.fechaCreacion),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botones de acción rápida
                  Row(
                    children: [
                      _buildQuickActionButton(
                        icon: Icons.visibility,
                        color: Colors.blue,
                        tooltip: 'Ver Detalles',
                        onPressed: onTap,
                      ),
                      const SizedBox(width: 8),
                      _buildQuickActionButton(
                        icon: Icons.grade,
                        color: Colors.green,
                        tooltip: 'Calificar',
                        onPressed: onCalificar,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getActivityColor() {
    // Puedes personalizar colores según el tipo de actividad
    return Colors.blue;
  }

  IconData _getActivityIcon() {
    // Puedes personalizar iconos según el tipo de actividad
    return Icons.assignment;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'ver':
        if (onTap != null) onTap!();
        break;
      case 'calificar':
        if (onCalificar != null) onCalificar!();
        break;
      case 'editar':
        _editarActividad(context);
        break;
      case 'eliminar':
        _confirmarEliminar(context);
        break;
    }
  }

  void _editarActividad(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Actividad'),
        content: const Text('Función de edición en desarrollo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Actividad'),
        content: Text('¿Estás seguro de que deseas eliminar "${actividad.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarActividad(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _eliminarActividad(BuildContext context) {
    // Aquí implementarás la lógica para eliminar la actividad
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de eliminación en desarrollo'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}