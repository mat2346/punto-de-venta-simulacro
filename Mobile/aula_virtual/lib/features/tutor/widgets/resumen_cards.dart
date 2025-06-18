import 'package:flutter/material.dart';

class ResumenCards extends StatelessWidget {
  final Map<String, dynamic> resumen;

  const ResumenCards({
    super.key,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    final promedioGeneral = resumen['promedio_general']?.toDouble() ?? 0.0;
    final totalMaterias = resumen['total_materias'] ?? 0;
    final asistenciaPromedio = resumen['asistencia_promedio']?.toDouble() ?? 0.0;
    final actividadesPendientes = resumen['actividades_pendientes'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Primera fila de cards
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  title: 'Promedio General',
                  value: '${promedioGeneral.toStringAsFixed(1)}%',
                  icon: Icons.school,
                  color: _getColorForGrade(promedioGeneral),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  title: 'Materias',
                  value: totalMaterias.toString(),
                  icon: Icons.book,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Segunda fila de cards
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  title: 'Asistencia',
                  value: '${asistenciaPromedio.toStringAsFixed(1)}%',
                  icon: Icons.check_circle,
                  color: _getColorForAttendance(asistenciaPromedio),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCard(
                  title: 'Pendientes',
                  value: actividadesPendientes.toString(),
                  icon: Icons.assignment_late,
                  color: actividadesPendientes > 0 
                      ? Colors.orange.shade600 
                      : Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForGrade(double grade) {
    if (grade >= 80) return Colors.green.shade600;
    if (grade >= 70) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getColorForAttendance(double attendance) {
    if (attendance >= 90) return Colors.green.shade600;
    if (attendance >= 75) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}