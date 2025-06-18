import 'package:flutter/material.dart';
import '../../../core/services/profesor_service.dart';
import '../views/materia_detalle_screen.dart';
import '../views/asistencia_movil_screen.dart'; // 🔥 AGREGAR ESTE IMPORT

class MateriaCard extends StatelessWidget {
  final MateriaModel materia;

  const MateriaCard({
    super.key,
    required this.materia,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navegarADetalle(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getColorBySubject(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconBySubject(),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materia.materia,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${materia.curso} ${materia.paralelo}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Botones de acción rápida
              Row(
                children: [
                  _buildQuickAction(
                    icon: Icons.people,
                    label: 'Estudiantes',
                    color: Colors.blue,
                    onTap: () => _navegarADetalle(context, tab: 0),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAction(
                    icon: Icons.assignment,
                    label: 'Actividades',
                    color: Colors.green,
                    onTap: () => _navegarADetalle(context, tab: 1),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickAction(
                    icon: Icons.qr_code,
                    label: 'Asistencia',
                    color: Colors.orange,
                    onTap: () => _navegarAAsistenciaMovil(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navegarADetalle(BuildContext context, {int tab = 0}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MateriaDetalleScreen(
          detalleId: materia.detalleId,
          nombreMateria: materia.nombreCompleto,
        ),
      ),
    );
  }

  // 🔥 MÉTODO CORREGIDO PARA NAVEGACIÓN A ASISTENCIA MÓVIL
  void _navegarAAsistenciaMovil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AsistenciaMovilScreen(
          detalleId: materia.detalleId,
          nombreMateria: materia.nombreCompleto,
        ),
      ),
    );
  }

  Color _getColorBySubject() {
    switch (materia.materia.toLowerCase()) {
      case 'matematicas':
      case 'matemáticas':
        return Colors.blue;
      case 'lenguaje':
      case 'lengua':
        return Colors.green;
      case 'ciencias':
        return Colors.purple;
      case 'historia':
        return Colors.orange;
      case 'religion':
      case 'religión':
        return Colors.indigo;
      case 'educacion fisica':
      case 'educación física':
        return Colors.red;
      case 'arte':
      case 'artes':
        return Colors.pink;
      case 'musica':
      case 'música':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconBySubject() {
    switch (materia.materia.toLowerCase()) {
      case 'matematicas':
      case 'matemáticas':
        return Icons.calculate;
      case 'lenguaje':
      case 'lengua':
        return Icons.book;
      case 'ciencias':
        return Icons.science;
      case 'historia':
        return Icons.history_edu;
      case 'religion':
      case 'religión':
        return Icons.church;
      case 'educacion fisica':
      case 'educación física':
        return Icons.sports;
      case 'arte':
      case 'artes':
        return Icons.palette;
      case 'musica':
      case 'música':
        return Icons.music_note;
      default:
        return Icons.school;
    }
  }
}