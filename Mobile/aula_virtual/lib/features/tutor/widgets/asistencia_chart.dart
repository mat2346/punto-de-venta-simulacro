import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AsistenciaChart extends StatelessWidget {
  final Map<String, dynamic> datosAsistencia;

  const AsistenciaChart({
    super.key,
    required this.datosAsistencia,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          const Text(
            'Análisis de Asistencia',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Resumen de asistencia
          _buildResumenAsistencia(),
          
          const SizedBox(height: 24),
          
          // Gráfica circular
          _buildGraficaCircular(),
          
          const SizedBox(height: 24),
          
          // Detalle por materia
          _buildDetallePorMateria(),
        ],
      ),
    );
  }

  Widget _buildResumenAsistencia() {
    final totalClases = datosAsistencia['total_clases'] ?? 0;
    final clasesAsistidas = datosAsistencia['clases_asistidas'] ?? 0;
    final clasesFaltadas = totalClases - clasesAsistidas;
    final porcentaje = totalClases > 0 ? (clasesAsistidas / totalClases) * 100 : 0.0;

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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total Clases',
              totalClases.toString(),
              Icons.calendar_today,
              Colors.blue.shade600,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Asistidas',
              clasesAsistidas.toString(),
              Icons.check_circle,
              Colors.green.shade600,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Faltadas',
              clasesFaltadas.toString(),
              Icons.cancel,
              Colors.red.shade600,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Porcentaje',
              '${porcentaje.toStringAsFixed(1)}%',
              Icons.percent,
              _getColorForAttendance(porcentaje),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
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
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGraficaCircular() {
    final totalClases = datosAsistencia['total_clases'] ?? 0;
    final clasesAsistidas = datosAsistencia['clases_asistidas'] ?? 0;
    final clasesFaltadas = totalClases - clasesAsistidas;

    if (totalClases == 0) {
      return _buildNoDataChart();
    }

    return Container(
      height: 200,
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: clasesAsistidas.toDouble(),
                    title: '$clasesAsistidas',
                    color: Colors.green.shade600,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: clasesFaltadas.toDouble(),
                    title: '$clasesFaltadas',
                    color: Colors.red.shade600,
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Asistidas', Colors.green.shade600),
                const SizedBox(height: 8),
                _buildLegendItem('Faltadas', Colors.red.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetallePorMateria() {
    final materias = datosAsistencia['materias'] as List<dynamic>? ?? [];

    if (materias.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
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
        child: const Center(
          child: Text(
            'No hay datos de asistencia por materia',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
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
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Asistencia por Materia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...materias.map((materia) => _buildMateriaAsistenciaItem(materia)),
        ],
      ),
    );
  }

  Widget _buildMateriaAsistenciaItem(Map<String, dynamic> materia) {
    final nombre = materia['nombre'] ?? 'Sin nombre';
    final asistidas = materia['clases_asistidas'] ?? 0;
    final total = materia['total_clases'] ?? 0;
    final porcentaje = total > 0 ? (asistidas / total) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$asistidas de $total clases',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getColorForAttendance(porcentaje).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${porcentaje.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getColorForAttendance(porcentaje),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataChart() {
    return Container(
      height: 200,
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay datos de asistencia',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForAttendance(double attendance) {
    if (attendance >= 90) return Colors.green.shade600;
    if (attendance >= 75) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}