import 'package:flutter/material.dart';
//import '../../../core/services/estudiante_service.dart';
import '../../../core/models/asistencia_estudiante_model.dart';
class AsistenciaChartWidget extends StatelessWidget {
  final List<AsistenciaEstudianteModel> historialAsistencia;
  final double asistenciaGeneral;

  const AsistenciaChartWidget({
    super.key,
    required this.historialAsistencia,
    required this.asistenciaGeneral,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calcularEstadisticas();
    
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 TÍTULO
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Análisis de Asistencia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorByAsistencia(asistenciaGeneral).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${asistenciaGeneral.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorByAsistencia(asistenciaGeneral),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 GRÁFICO CIRCULAR
            Row(
              children: [
                // Gráfico circular principal
                Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: AsistenciaCircularChartPainter(
                        presentes: stats['presentes']!,
                        ausentes: stats['ausentes']!,
                        tardanzas: stats['tardanzas']!,
                        total: stats['total']!,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${asistenciaGeneral.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getColorByAsistencia(asistenciaGeneral),
                              ),
                            ),
                            const Text(
                              'Asistencia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                
                // Leyenda
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildLeyendaItem(
                        'Presente',
                        stats['presentes']!,
                        stats['total']!,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildLeyendaItem(
                        'Ausente',
                        stats['ausentes']!,
                        stats['total']!,
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildLeyendaItem(
                        'Tardanza',
                        stats['tardanzas']!,
                        stats['total']!,
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 ESTADÍSTICAS ADICIONALES
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildEstadisticaItem(
                          'Total Clases',
                          '${stats['total']}',
                          Icons.calendar_today,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildEstadisticaItem(
                          'Presente',
                          '${stats['presentes']}',
                          Icons.check_circle,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEstadisticaItem(
                          'Ausente',
                          '${stats['ausentes']}',
                          Icons.cancel,
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildEstadisticaItem(
                          'Tardanza',
                          '${stats['tardanzas']}',
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 MENSAJE MOTIVACIONAL
            _buildMensajeMotivacional(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeyendaItem(String texto, int valor, int total, Color color) {
    final porcentaje = total > 0 ? (valor / total * 100) : 0.0;
    
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                texto,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$valor (${porcentaje.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono, Color color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          valor,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMensajeMotivacional() {
    String mensaje;
    Color color;
    IconData icono;

    if (asistenciaGeneral >= 90) {
      mensaje = '¡Excelente asistencia! Sigue así 🌟';
      color = Colors.green;
      icono = Icons.emoji_events;
    } else if (asistenciaGeneral >= 80) {
      mensaje = '¡Muy buena asistencia! 👏';
      color = Colors.blue;
      icono = Icons.thumb_up;
    } else if (asistenciaGeneral >= 60) {
      mensaje = 'Puedes mejorar tu asistencia 📈';
      color = Colors.orange;
      icono = Icons.trending_up;
    } else {
      mensaje = 'Es importante asistir a clases 📚';
      color = Colors.red;
      icono = Icons.schedule;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calcularEstadisticas() {
    int presentes = 0;
    int ausentes = 0;
    int tardanzas = 0;

    for (final asistencia in historialAsistencia) {
      if (asistencia.esPresente) {
        presentes++;
      } else if (asistencia.esTardanza) {
        tardanzas++;
      } else {
        ausentes++;
      }
    }

    return {
      'presentes': presentes,
      'ausentes': ausentes,
      'tardanzas': tardanzas,
      'total': historialAsistencia.length,
    };
  }

  Color _getColorByAsistencia(double asistencia) {
    if (asistencia >= 80) return Colors.green;
    if (asistencia >= 60) return Colors.orange;
    return Colors.red;
  }
}

// 🔥 CUSTOM PAINTER PARA GRÁFICO CIRCULAR
class AsistenciaCircularChartPainter extends CustomPainter {
  final int presentes;
  final int ausentes;
  final int tardanzas;
  final int total;

  AsistenciaCircularChartPainter({
    required this.presentes,
    required this.ausentes,
    required this.tardanzas,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    if (total == 0) {
      // Dibujar círculo gris si no hay datos
      final paint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Calcular ángulos
    final presenteAngle = (presentes / total) * 2 * 3.14159;
    final ausenteAngle = (ausentes / total) * 2 * 3.14159;
    final tardanzaAngle = (tardanzas / total) * 2 * 3.14159;

    double startAngle = -3.14159 / 2; // Empezar desde arriba

    // Dibujar arco de presentes
    if (presentes > 0) {
      final paint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        presenteAngle,
        false,
        paint,
      );
      startAngle += presenteAngle;
    }

    // Dibujar arco de tardanzas
    if (tardanzas > 0) {
      final paint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        tardanzaAngle,
        false,
        paint,
      );
      startAngle += tardanzaAngle;
    }

    // Dibujar arco de ausentes
    if (ausentes > 0) {
      final paint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        ausenteAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}