import 'package:flutter/material.dart';
import '../../../core/models/materia_estudiante_model.dart';

class MateriaEstudianteCard extends StatelessWidget {
  final MateriaEstudianteModel materia;
  final VoidCallback onTap;

  const MateriaEstudianteCard({
    super.key,
    required this.materia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono de materia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getColorMateria().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconoMateria(),
                  color: _getColorMateria(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Información de la materia
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      materia.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${materia.curso} - ${materia.paralelo}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prof. ${materia.profesor}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Estadísticas
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getColorPromedio().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${materia.promedio.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getColorPromedio(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${materia.asistencia.toStringAsFixed(0)}% Asist.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorMateria() {
    // Colores basados en el nombre de la materia
    final hash = materia.nombre.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[hash.abs() % colors.length];
  }

  IconData _getIconoMateria() {
    final nombre = materia.nombre.toLowerCase();
    if (nombre.contains('matemática') || nombre.contains('calculo')) {
      return Icons.functions;
    } else if (nombre.contains('física') || nombre.contains('química')) {
      return Icons.science;
    } else if (nombre.contains('literatura') || nombre.contains('lengua')) {
      return Icons.menu_book;
    } else if (nombre.contains('historia') || nombre.contains('social')) {
      return Icons.history_edu;
    } else if (nombre.contains('inglés') || nombre.contains('idioma')) {
      return Icons.language;
    } else if (nombre.contains('computación') || nombre.contains('informática')) {
      return Icons.computer;
    }
    return Icons.school;
  }

  Color _getColorPromedio() {
    if (materia.promedio >= 80) return Colors.green;
    if (materia.promedio >= 60) return Colors.orange;
    return Colors.red;
  }
}