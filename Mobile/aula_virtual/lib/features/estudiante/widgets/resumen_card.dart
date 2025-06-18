import 'package:flutter/material.dart';

class ResumenCard extends StatelessWidget {
  final double promedio;
  final double asistencia;
  final int materiasTotal;
  final int actividadesPendientes;

  const ResumenCard({
    super.key,
    required this.promedio,
    required this.asistencia,
    required this.materiasTotal,
    required this.actividadesPendientes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.indigo.shade50,
              Colors.indigo.shade100.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Colors.indigo.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resumen Académico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Grid de estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildEstadistica(
                    'Promedio',
                    promedio.toStringAsFixed(1),
                    Icons.grade,
                    _getColorPromedio(promedio),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadistica(
                    'Asistencia',
                    '${asistencia.toStringAsFixed(0)}%',
                    Icons.how_to_reg,
                    _getColorAsistencia(asistencia),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildEstadistica(
                    'Materias',
                    materiasTotal.toString(),
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadistica(
                    'Pendientes',
                    actividadesPendientes.toString(),
                    Icons.pending_actions,
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

  Widget _buildEstadistica(
      String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorPromedio(double promedio) {
    if (promedio >= 80) return Colors.green;
    if (promedio >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getColorAsistencia(double asistencia) {
    if (asistencia >= 80) return Colors.green;
    if (asistencia >= 60) return Colors.orange;
    return Colors.red;
  }
}