import 'package:flutter/material.dart';
//import '../../../core/services/estudiante_service.dart';
import '../../../core/models/actividad_estudiante_model.dart';

class NotasChartWidget extends StatelessWidget {
  final List<ActividadEstudianteModel> actividades;

  const NotasChartWidget({
    super.key,
    required this.actividades,
  });

  @override
  Widget build(BuildContext context) {
    final actividadesConNota = actividades.where((a) => a.nota != null).toList();
    
    if (actividadesConNota.isEmpty) {
      return _buildEmptyState();
    }

    final stats = _calcularEstadisticas(actividadesConNota);
    
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
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Evolución de Notas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getColorByPromedio(stats['promedio']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${stats['promedio']!.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getColorByPromedio(stats['promedio']!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 GRÁFICO DE LÍNEAS
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomPaint(
                painter: NotasLineChartPainter(actividades: actividadesConNota),
                size: const Size(double.infinity, 200),
              ),
            ),
            const SizedBox(height: 20),

            // 🔥 ESTADÍSTICAS RESUMIDAS
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaCard(
                    'Promedio',
                    stats['promedio']!.toStringAsFixed(1),
                    Icons.star,
                    _getColorByPromedio(stats['promedio']!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaCard(
                    'Mejor Nota',
                    stats['maxima']!.toStringAsFixed(1),
                    Icons.emoji_events,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEstadisticaCard(
                    'Menor Nota',
                    stats['minima']!.toStringAsFixed(1),
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔥 DISTRIBUCIÓN POR RANGOS
            _buildDistribucionRangos(actividadesConNota),
            const SizedBox(height: 16),

            // 🔥 ÚLTIMAS ACTIVIDADES
            _buildUltimasActividades(actividadesConNota),
            const SizedBox(height: 16),

            // 🔥 MENSAJE DE PROGRESO
            _buildMensajeProgreso(stats['promedio']!, _calcularTendencia(actividadesConNota)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay notas disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las notas aparecerán aquí cuando las actividades sean revisadas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaCard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
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
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDistribucionRangos(List<ActividadEstudianteModel> actividadesConNota) {
    final rangos = _calcularDistribucionRangos(actividadesConNota);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.purple.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Distribución de Notas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Barras de progreso para cada rango
        _buildBarraRango('Excelente (90-100)', rangos['excelente']!, actividadesConNota.length, Colors.green),
        const SizedBox(height: 8),
        _buildBarraRango('Muy Bueno (80-89)', rangos['muyBueno']!, actividadesConNota.length, Colors.blue),
        const SizedBox(height: 8),
        _buildBarraRango('Bueno (70-79)', rangos['bueno']!, actividadesConNota.length, Colors.orange),
        const SizedBox(height: 8),
        _buildBarraRango('Regular (60-69)', rangos['regular']!, actividadesConNota.length, Colors.amber),
        const SizedBox(height: 8),
        _buildBarraRango('Insuficiente (0-59)', rangos['insuficiente']!, actividadesConNota.length, Colors.red),
      ],
    );
  }

  Widget _buildBarraRango(String titulo, int cantidad, int total, Color color) {
    final porcentaje = total > 0 ? (cantidad / total) : 0.0;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$cantidad/${total}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaje,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildUltimasActividades(List<ActividadEstudianteModel> actividadesConNota) {
    // Ordenar por fecha de revisión o creación, tomar las últimas 3
    final ultimasActividades = List<ActividadEstudianteModel>.from(actividadesConNota)
      ..sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    
    // 🔥 CAMBIAR ESTA LÍNEA - usar take() en lugar de takeLast()
    final actividades = ultimasActividades.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history, color: Colors.indigo.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Últimas Notas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ...actividades.map((actividad) => _buildActividadNotaItem(actividad)),
      ],
    );
  }

  Widget _buildActividadNotaItem(ActividadEstudianteModel actividad) {
    final color = _getColorByNota(actividad.nota!);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                actividad.nota!.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatearFecha(actividad.fechaCreacion),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getTextoByNota(actividad.nota!),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeProgreso(double promedio, String tendencia) {
    Color color;
    IconData icono;
    String mensaje;

    if (promedio >= 85) {
      color = Colors.green;
      icono = Icons.emoji_events;
      mensaje = '¡Excelente rendimiento! Sigue así 🌟';
    } else if (promedio >= 75) {
      color = Colors.blue;
      icono = Icons.thumb_up;
      mensaje = '¡Muy buen rendimiento! 👏';
    } else if (promedio >= 65) {
      color = Colors.orange;
      icono = Icons.trending_up;
      mensaje = 'Buen progreso, puedes mejorar más 📈';
    } else {
      color = Colors.red;
      icono = Icons.school;
      mensaje = 'Enfócate en mejorar tus notas 📚';
    }

    // Ajustar mensaje según tendencia
    if (tendencia == 'mejorando') {
      mensaje += ' Tu tendencia es positiva.';
    } else if (tendencia == 'empeorando') {
      mensaje += ' Intenta mantener o mejorar tu rendimiento.';
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
          if (tendencia != 'estable')
            Icon(
              tendencia == 'mejorando' ? Icons.trending_up : Icons.trending_down,
              color: tendencia == 'mejorando' ? Colors.green : Colors.red,
              size: 20,
            ),
        ],
      ),
    );
  }

  // 🔥 MÉTODOS AUXILIARES

  Map<String, double> _calcularEstadisticas(List<ActividadEstudianteModel> actividadesConNota) {
    if (actividadesConNota.isEmpty) {
      return {'promedio': 0.0, 'maxima': 0.0, 'minima': 0.0};
    }

    final notas = actividadesConNota.map((a) => a.nota!).toList();
    final promedio = notas.reduce((a, b) => a + b) / notas.length;
    final maxima = notas.reduce((a, b) => a > b ? a : b);
    final minima = notas.reduce((a, b) => a < b ? a : b);

    return {
      'promedio': promedio,
      'maxima': maxima,
      'minima': minima,
    };
  }

  Map<String, int> _calcularDistribucionRangos(List<ActividadEstudianteModel> actividadesConNota) {
    int excelente = 0; // 90-100
    int muyBueno = 0;  // 80-89
    int bueno = 0;     // 70-79
    int regular = 0;   // 60-69
    int insuficiente = 0; // 0-59

    for (final actividad in actividadesConNota) {
      final nota = actividad.nota!;
      if (nota >= 90) {
        excelente++;
      } else if (nota >= 80) {
        muyBueno++;
      } else if (nota >= 70) {
        bueno++;
      } else if (nota >= 60) {
        regular++;
      } else {
        insuficiente++;
      }
    }

    return {
      'excelente': excelente,
      'muyBueno': muyBueno,
      'bueno': bueno,
      'regular': regular,
      'insuficiente': insuficiente,
    };
  }

  String _calcularTendencia(List<ActividadEstudianteModel> actividadesConNota) {
    if (actividadesConNota.length < 3) return 'estable';

    // Ordenar por fecha y tomar las últimas 3
    final ordenadas = actividadesConNota
      ..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));
    
    if (ordenadas.length < 3) return 'estable';

    // 🔥 CAMBIAR ESTA LÍNEA - usar skip y take en lugar de takeLast
    final ultimas3 = ordenadas.skip(ordenadas.length - 3).take(3).toList();
    final promedioPrimeras2 = (ultimas3[0].nota! + ultimas3[1].nota!) / 2;
    final ultimaNota = ultimas3[2].nota!;

    if (ultimaNota > promedioPrimeras2 + 5) {
      return 'mejorando';
    } else if (ultimaNota < promedioPrimeras2 - 5) {
      return 'empeorando';
    } else {
      return 'estable';
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

  Color _getColorByPromedio(double promedio) {
    if (promedio >= 80) return Colors.green;
    if (promedio >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getColorByNota(double nota) {
    if (nota >= 90) return Colors.green;
    if (nota >= 80) return Colors.blue;
    if (nota >= 70) return Colors.orange;
    if (nota >= 60) return Colors.amber;
    return Colors.red;
  }

  String _getTextoByNota(double nota) {
    if (nota >= 90) return 'Excelente';
    if (nota >= 80) return 'Muy Bueno';
    if (nota >= 70) return 'Bueno';
    if (nota >= 60) return 'Regular';
    return 'Insuficiente';
  }
}

// 🔥 CUSTOM PAINTER PARA GRÁFICO DE LÍNEAS
class NotasLineChartPainter extends CustomPainter {
  final List<ActividadEstudianteModel> actividades;

  NotasLineChartPainter({required this.actividades});

  @override
  void paint(Canvas canvas, Size size) {
    if (actividades.isEmpty) return;

    // Ordenar actividades por fecha
    final actividadesOrdenadas = actividades
      ..sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));

    final paint = Paint()
      ..color = Colors.blue.shade600
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue.shade700
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Dibujar líneas de cuadrícula horizontales
    for (int i = 0; i <= 10; i++) {
      final y = (size.height / 10) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Dibujar líneas de cuadrícula verticales
    final stepX = size.width / (actividadesOrdenadas.length - 1);
    for (int i = 0; i < actividadesOrdenadas.length; i++) {
      final x = stepX * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    if (actividadesOrdenadas.length == 1) {
      // Solo un punto
      final x = size.width / 2;
      final y = size.height - (actividadesOrdenadas[0].nota! / 100 * size.height);
      canvas.drawCircle(Offset(x, y), 6, pointPaint);
      return;
    }

    // Crear path para la línea
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < actividadesOrdenadas.length; i++) {
      final x = stepX * i;
      final y = size.height - (actividadesOrdenadas[i].nota! / 100 * size.height);
      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Dibujar línea
    canvas.drawPath(path, paint);

    // Dibujar puntos
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 4, Paint()..color = Colors.white);
    }

    // Dibujar área bajo la curva
    final areaPaint = Paint()
      ..color = Colors.blue.shade600.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final areaPath = Path();
    areaPath.addPath(path, Offset.zero);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();

    canvas.drawPath(areaPath, areaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}