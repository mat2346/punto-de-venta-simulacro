import 'package:flutter/material.dart';

class EstadisticasWidget extends StatelessWidget {
  final double promedioGeneral;
  final double asistenciaGeneral;
  final int materiasTotal;
  final int actividadesPendientes;

  const EstadisticasWidget({
    super.key,
    required this.promedioGeneral,
    required this.asistenciaGeneral,
    required this.materiasTotal,
    required this.actividadesPendientes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 GRÁFICOS CIRCULARES
            Row(
              children: [
                Expanded(
                  child: _buildCircularProgress(
                    'Promedio',
                    promedioGeneral,
                    100,
                    _getColorByPromedio(promedioGeneral),
                    Icons.star,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildCircularProgress(
                    'Asistencia',
                    asistenciaGeneral,
                    100,
                    _getColorByAsistencia(asistenciaGeneral),
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 INDICADORES ADICIONALES
            Row(
              children: [
                Expanded(
                  child: _buildIndicador(
                    'Materias',
                    '$materiasTotal',
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildIndicador(
                    'Pendientes',
                    '$actividadesPendientes',
                    Icons.pending_actions,
                    actividadesPendientes > 0 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),

            // 🔥 MENSAJE MOTIVACIONAL
            const SizedBox(height: 16),
            _buildMensajeMotivacional(),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(
    String titulo,
    double valor,
    double maximo,
    Color color,
    IconData icono,
  ) {
    final porcentaje = valor / maximo;
    
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: porcentaje,
                strokeWidth: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, color: color, size: 20),
                const SizedBox(height: 2),
                Text(
                  valor.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildIndicador(String titulo, String valor, IconData icono, Color color) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildMensajeMotivacional() {
    String mensaje;
    Color color;
    IconData icono;

    if (promedioGeneral >= 80 && asistenciaGeneral >= 80) {
      mensaje = '¡Excelente trabajo! Sigue así 🌟';
      color = Colors.green;
      icono = Icons.emoji_events;
    } else if (promedioGeneral >= 60 && asistenciaGeneral >= 60) {
      mensaje = '¡Vas bien! Puedes mejorar aún más 💪';
      color = Colors.orange;
      icono = Icons.trending_up;
    } else {
      mensaje = 'Enfócate en mejorar tu rendimiento 📚';
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

  Color _getColorByPromedio(double promedio) {
    if (promedio >= 80) return Colors.green;
    if (promedio >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getColorByAsistencia(double asistencia) {
    if (asistencia >= 80) return Colors.green;
    if (asistencia >= 60) return Colors.orange;
    return Colors.red;
  }
}