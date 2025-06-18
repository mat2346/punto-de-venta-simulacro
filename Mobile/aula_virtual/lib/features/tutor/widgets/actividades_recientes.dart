import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActividadesRecientes extends StatelessWidget {
  final List<dynamic> actividades;

  const ActividadesRecientes({
    super.key,
    required this.actividades,
  });

  @override
  Widget build(BuildContext context) {
    if (actividades.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: actividades.length,
      itemBuilder: (context, index) {
        final actividad = actividades[index];
        return _buildActividadCard(actividad);
      },
    );
  }

  Widget _buildActividadCard(Map<String, dynamic> actividad) {
    final titulo = actividad['titulo'] ?? 'Sin título';
    final materia = actividad['materia'] ?? 'Sin materia';
    final fechaEntrega = actividad['fecha_entrega'];
    final estado = actividad['estado'] ?? 'pendiente';
    final calificacion = actividad['calificacion']?.toDouble();
    final tipo = actividad['tipo'] ?? 'tarea';

    final fechaEntregaFormatted = fechaEntrega != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(fechaEntrega))
        : 'Sin fecha';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
        left: BorderSide(
        width: 4,
        color: _getColorForEstado(estado),
      ),
      ),
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
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getColorForTipo(tipo).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconForTipo(tipo),
                  color: _getColorForTipo(tipo),
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      materia,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Estado badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorForEstado(estado),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getTextoEstado(estado),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
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
                Icons.schedule,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Entrega: $fechaEntregaFormatted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              if (calificacion != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getColorForGrade(calificacion).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${calificacion.toStringAsFixed(1)}/100',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getColorForGrade(calificacion),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
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
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay actividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No se encontraron actividades recientes.',
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

  Color _getColorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return Colors.green.shade600;
      case 'calificado':
        return Colors.blue.shade600;
      case 'retrasado':
        return Colors.red.shade600;
      case 'pendiente':
      default:
        return Colors.orange.shade600;
    }
  }

  Color _getColorForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'examen':
        return Colors.red.shade600;
      case 'proyecto':
        return Colors.blue.shade600;
      case 'laboratorio':
        return Colors.green.shade600;
      case 'tarea':
      default:
        return Colors.orange.shade600;
    }
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'examen':
        return Icons.quiz;
      case 'proyecto':
        return Icons.folder_special;
      case 'laboratorio':
        return Icons.science;
      case 'tarea':
      default:
        return Icons.assignment;
    }
  }

  String _getTextoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'entregado':
        return 'ENTREGADO';
      case 'calificado':
        return 'CALIFICADO';
      case 'retrasado':
        return 'RETRASADO';
      case 'pendiente':
      default:
        return 'PENDIENTE';
    }
  }

  Color _getColorForGrade(double grade) {
    if (grade >= 80) return Colors.green.shade600;
    if (grade >= 70) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}