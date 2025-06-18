import 'package:flutter/material.dart';

class ActividadesStatsWidget extends StatelessWidget {
  final int totalActividades;
  final int actividadesPendientes;
  final int actividadesEntregadas;
  final int actividadesRevisadas;

  const ActividadesStatsWidget({
    super.key,
    required this.totalActividades,
    required this.actividadesPendientes,
    required this.actividadesEntregadas,
    required this.actividadesRevisadas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade50,
              Colors.purple.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assignment,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Resumen de Actividades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Grid de estadísticas
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    totalActividades.toString(),
                    Icons.assignment_outlined,
                    Colors.blue.shade600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Pendientes',
                    actividadesPendientes.toString(),
                    Icons.pending_actions,
                    Colors.orange.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Entregadas',
                    actividadesEntregadas.toString(),
                    Icons.upload_file,
                    Colors.blue.shade600,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Revisadas',
                    actividadesRevisadas.toString(),
                    Icons.task_alt,
                    Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}