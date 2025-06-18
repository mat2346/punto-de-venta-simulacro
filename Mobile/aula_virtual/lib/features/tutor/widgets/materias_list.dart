import 'package:flutter/material.dart';

class MateriasList extends StatelessWidget {
  final List<dynamic> materias;

  const MateriasList({
    super.key,
    required this.materias,
  });

  @override
  Widget build(BuildContext context) {
    if (materias.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: materias.length,
      itemBuilder: (context, index) {
        final materia = materias[index];
        return _buildMateriaCard(materia);
      },
    );
  }

  Widget _buildMateriaCard(Map<String, dynamic> materia) {
    final nombre = materia['nombre'] ?? 'Sin nombre';
    final codigo = materia['codigo'] ?? '';
    final promedio = materia['promedio']?.toDouble() ?? 0.0;
    final profesor = materia['profesor'] ?? 'Sin asignar';
    final actividades = materia['actividades_count'] ?? 0;
    final asistencia = materia['asistencia_porcentaje']?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header de la materia
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorForGrade(promedio).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.book,
                  color: _getColorForGrade(promedio),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (codigo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        codigo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Prof. $profesor',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              // Badge de promedio
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorForGrade(promedio),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${promedio.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Información adicional
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.assignment,
                  label: '$actividades actividades',
                  color: Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.check_circle,
                  label: '${asistencia.toStringAsFixed(0)}% asistencia',
                  color: _getColorForAttendance(asistencia),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay materias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'El estudiante no tiene materias asignadas.',
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