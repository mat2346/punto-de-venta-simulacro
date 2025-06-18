import 'package:flutter/material.dart';
//import '../../../core/services/estudiante_service.dart';
import '../../../core/models/actividad_estudiante_model.dart';

class ActividadEstudianteCard extends StatelessWidget {
  final ActividadEstudianteModel actividad;
  final VoidCallback? onTap;

  const ActividadEstudianteCard({
    super.key,
    required this.actividad,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final EstadoActividad estado = _getEstadoActividad();
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                estado.color.withOpacity(0.1),
                estado.color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 HEADER CON ESTADO
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: estado.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      estado.icono,
                      color: estado.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: estado.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            estado.texto,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: estado.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔥 DESCRIPCIÓN
              if (actividad.descripcion.isNotEmpty) ...[
                Text(
                  actividad.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],

              // 🔥 INFORMACIÓN DE FECHAS Y NOTA
              Row(
                children: [
                  // Fecha de creación
                  Expanded(
                    child: _buildInfoItem(
                      'Creado',
                      _formatearFecha(actividad.fechaCreacion),
                      Icons.calendar_today,
                      Colors.grey[600]!,
                    ),
                  ),
                  
                  // Fecha de vencimiento
                  if (actividad.fechaVencimiento != null)
                    Expanded(
                      child: _buildInfoItem(
                        'Vence',
                        _formatearFechaVencimiento(actividad.fechaVencimiento!),
                        Icons.schedule,
                        _getColorVencimiento(actividad.fechaVencimiento!),
                      ),
                    ),
                ],
              ),

              // 🔥 NOTA Y COMENTARIO
              if (actividad.nota != null || actividad.comentario != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                
                if (actividad.nota != null)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: _getColorByNota(actividad.nota!),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nota: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        actividad.nota!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getColorByNota(actividad.nota!),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getColorByNota(actividad.nota!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getTextoByNota(actividad.nota!),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getColorByNota(actividad.nota!),
                          ),
                        ),
                      ),
                    ],
                  ),

                if (actividad.comentario != null && actividad.comentario!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment,
                              color: Colors.blue.shade600,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comentario del profesor:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          actividad.comentario!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // 🔥 INDICADOR DE URGENCIA
              if (_esUrgente()) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getMensajeUrgencia(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String titulo, String valor, IconData icono, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              valor,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔥 MÉTODOS AUXILIARES

  EstadoActividad _getEstadoActividad() {
    switch (actividad.estado.toLowerCase()) {
      case 'pendiente':
        return EstadoActividad(
          color: Colors.orange,
          icono: Icons.pending_actions,
          texto: 'Pendiente',
        );
      case 'entregada':
        return EstadoActividad(
          color: Colors.blue,
          icono: Icons.upload_file,
          texto: 'Entregada',
        );
      case 'revisada':
        return EstadoActividad(
          color: Colors.green,
          icono: Icons.task_alt,
          texto: 'Revisada',
        );
      default:
        return EstadoActividad(
          color: Colors.grey,
          icono: Icons.help_outline,
          texto: 'Desconocido',
        );
    }
  }

  String _formatearFecha(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      return '${fechaDateTime.day}/${fechaDateTime.month}/${fechaDateTime.year}';
    } catch (e) {
      return fecha;
    }
  }

  String _formatearFechaVencimiento(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      final DateTime ahora = DateTime.now();
      final Duration diferencia = fechaDateTime.difference(ahora);

      if (diferencia.inDays > 0) {
        return '${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
      } else if (diferencia.inDays == 0) {
        return 'Hoy';
      } else {
        return 'Vencido';
      }
    } catch (e) {
      return fecha;
    }
  }

  Color _getColorVencimiento(String fecha) {
    try {
      final DateTime fechaDateTime = DateTime.parse(fecha);
      final DateTime ahora = DateTime.now();
      final Duration diferencia = fechaDateTime.difference(ahora);

      if (diferencia.inDays < 0) {
        return Colors.red; // Vencido
      } else if (diferencia.inDays <= 1) {
        return Colors.orange; // Vence pronto
      } else {
        return Colors.green; // Tiempo suficiente
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  Color _getColorByNota(double nota) {
    if (nota >= 80) return Colors.green;
    if (nota >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getTextoByNota(double nota) {
    if (nota >= 90) return 'Excelente';
    if (nota >= 80) return 'Muy Bueno';
    if (nota >= 70) return 'Bueno';
    if (nota >= 60) return 'Regular';
    return 'Insuficiente';
  }

  bool _esUrgente() {
    if (actividad.fechaVencimiento == null || !actividad.estaPendiente) {
      return false;
    }

    try {
      final DateTime fechaDateTime = DateTime.parse(actividad.fechaVencimiento!);
      final DateTime ahora = DateTime.now();
      final Duration diferencia = fechaDateTime.difference(ahora);

      return diferencia.inDays <= 1; // Urgente si vence en 1 día o menos
    } catch (e) {
      return false;
    }
  }

  String _getMensajeUrgencia() {
    if (actividad.fechaVencimiento == null) return '';

    try {
      final DateTime fechaDateTime = DateTime.parse(actividad.fechaVencimiento!);
      final DateTime ahora = DateTime.now();
      final Duration diferencia = fechaDateTime.difference(ahora);

      if (diferencia.inDays < 0) {
        return '¡Actividad vencida!';
      } else if (diferencia.inDays == 0) {
        return '¡Vence hoy!';
      } else if (diferencia.inDays == 1) {
        return '¡Vence mañana!';
      } else {
        return '¡Entregar pronto!';
      }
    } catch (e) {
      return '¡Revisar fecha!';
    }
  }
}

// 🔥 CLASE AUXILIAR PARA ESTADO DE ACTIVIDAD
class EstadoActividad {
  final Color color;
  final IconData icono;
  final String texto;

  EstadoActividad({
    required this.color,
    required this.icono,
    required this.texto,
  });
}