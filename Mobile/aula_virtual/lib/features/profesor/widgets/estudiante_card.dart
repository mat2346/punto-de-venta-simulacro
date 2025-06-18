import 'package:flutter/material.dart';
import '../../../core/services/profesor_service.dart';

class EstudianteCard extends StatelessWidget {
  final EstudianteModel estudiante;
  final VoidCallback? onTap;

  const EstudianteCard({
    super.key,
    required this.estudiante,
    this.onTap,
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
          child: Row(
            children: [
              // Avatar del estudiante
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.blue[700],
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Información del estudiante
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estudiante.nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${estudiante.libretaId}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botón de opciones
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'perfil',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 20),
                        SizedBox(width: 8),
                        Text('Ver Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'notas',
                    child: Row(
                      children: [
                        Icon(Icons.grade, size: 20),
                        SizedBox(width: 8),
                        Text('Ver Notas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'asistencia',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20),
                        SizedBox(width: 8),
                        Text('Asistencia'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'contactar',
                    child: Row(
                      children: [
                        Icon(Icons.message, size: 20),
                        SizedBox(width: 8),
                        Text('Contactar'),
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
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'perfil':
        _mostrarPerfilEstudiante(context);
        break;
      case 'notas':
        _mostrarNotasEstudiante(context);
        break;
      case 'asistencia':
        _mostrarAsistenciaEstudiante(context);
        break;
      case 'contactar':
        _contactarEstudiante(context);
        break;
    }
  }

  void _mostrarPerfilEstudiante(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            // Avatar grande
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person,
                color: Colors.blue[700],
                size: 40,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Nombre
            Text(
              estudiante.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${estudiante.libretaId}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarNotasEstudiante(context);
                    },
                    icon: const Icon(Icons.grade),
                    label: const Text('Ver Notas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _contactarEstudiante(context);
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Contactar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarNotasEstudiante(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Notas de ${estudiante.nombre}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Funcionalidad en desarrollo'),
            SizedBox(height: 16),
            Text('Aquí se mostrarán las calificaciones del estudiante'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _mostrarAsistenciaEstudiante(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Asistencia de ${estudiante.nombre}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Funcionalidad en desarrollo'),
            SizedBox(height: 16),
            Text('Aquí se mostrará el historial de asistencia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _contactarEstudiante(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contactar a ${estudiante.nombre}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Cómo deseas contactar al estudiante?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de contacto en desarrollo'),
                ),
              );
            },
            child: const Text('Enviar Mensaje'),
          ),
        ],
      ),
    );
  }
}