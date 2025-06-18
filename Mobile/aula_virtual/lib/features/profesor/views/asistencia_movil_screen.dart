import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/providers/profesor_provider.dart';

class AsistenciaMovilScreen extends StatefulWidget {
  final int detalleId;
  final String nombreMateria;

  const AsistenciaMovilScreen({
    super.key,
    required this.detalleId,
    required this.nombreMateria,
  });

  @override
  State<AsistenciaMovilScreen> createState() => _AsistenciaMovilScreenState();
}

class _AsistenciaMovilScreenState extends State<AsistenciaMovilScreen> {
  Timer? _timer;
  int _duracionSeleccionada = 15;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cargarDatosIniciales() {
    final provider = Provider.of<ProfesorProvider>(context, listen: false);
    provider.cargarEstadoAsistenciaMovil(widget.detalleId);
  }

  void _iniciarRefrescoAutomatico() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final provider = Provider.of<ProfesorProvider>(context, listen: false);
      if (provider.asistenciaHabilitada) {
        provider.refrescarAsistenciaMovil(widget.detalleId);
      } else {
        timer.cancel();
      }
    });
  }

  void _detenerRefrescoAutomatico() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Asistencia Móvil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<ProfesorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingAsistenciaMovil && !provider.asistenciaHabilitada) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔥 INFORMACIÓN DE LA MATERIA
                _buildMateriaInfo(),
                const SizedBox(height: 20),

                // 🔥 ESTADO ACTUAL DE ASISTENCIA
                if (provider.asistenciaHabilitada)
                  _buildAsistenciaActiva(provider)
                else
                  _buildAsistenciaInactiva(provider),

                const SizedBox(height: 20),

                // 🔥 LISTA DE ESTUDIANTES REGISTRADOS
                if (provider.asistenciaHabilitada) ...[
                  _buildEstudiantesRegistrados(provider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMateriaInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.school,
                color: Colors.blue.shade700,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nombreMateria,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sistema de asistencia móvil',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAsistenciaActiva(ProfesorProvider provider) {
    return Column(
      children: [
        // 🔥 TARJETA CON CÓDIGO GRANDE
        Card(
          elevation: 6,
          color: Colors.green.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'Asistencia Habilitada',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // 🔥 CÓDIGO EN GRANDE
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'CÓDIGO DE ASISTENCIA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _copiarCodigo(provider.codigoAsistencia ?? ''),
                        child: Text(
                          provider.codigoAsistencia ?? '------',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Toca para copiar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 🔥 INFORMACIÓN DE TIEMPO Y REGISTROS
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Tiempo Restante',
                        _formatearTiempo(provider.tiempoRestante),
                        Icons.timer,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Registrados',
                        '${provider.totalRegistrados}',
                        Icons.people,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 🔥 BOTÓN DESHABILITAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoadingAsistenciaMovil 
                        ? null 
                        : () => _deshabilitarAsistencia(provider),
                    icon: provider.isLoadingAsistenciaMovil
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.stop),
                    label: Text(
                      provider.isLoadingAsistenciaMovil 
                          ? 'Cerrando...' 
                          : 'Cerrar Asistencia',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAsistenciaInactiva(ProfesorProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.mobile_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            const Text(
              'Asistencia Móvil Deshabilitada',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Los estudiantes podrán registrar su asistencia usando un código único cuando habilites esta función.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // 🔥 SELECTOR DE DURACIÓN
            const Text(
              'Duración de la sesión:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [15, 30, 45, 60].map((minutos) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('${minutos}min'),
                      selected: _duracionSeleccionada == minutos,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _duracionSeleccionada = minutos;
                          });
                        }
                      },
                      selectedColor: Colors.blue.shade100,
                      labelStyle: TextStyle(
                        color: _duracionSeleccionada == minutos 
                            ? Colors.blue.shade700 
                            : Colors.grey[700],
                        fontWeight: _duracionSeleccionada == minutos 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // 🔥 BOTÓN HABILITAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoadingAsistenciaMovil 
                    ? null 
                    : () => _habilitarAsistencia(provider),
                icon: provider.isLoadingAsistenciaMovil
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(
                  provider.isLoadingAsistenciaMovil 
                      ? 'Habilitando...' 
                      : 'Habilitar Asistencia',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String valor, IconData icono, Color color) {
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
              fontSize: 20,
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

  Widget _buildEstudiantesRegistrados(ProfesorProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Estudiantes Registrados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.totalRegistrados}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (provider.estudiantesRegistradosMovil.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Aún no se ha registrado ningún estudiante',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.estudiantesRegistradosMovil.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final estudiante = provider.estudiantesRegistradosMovil[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.check,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      estudiante['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Código: ${estudiante['codigo'] ?? 'N/A'}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      estudiante['tiempo_transcurrido'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // 🔥 MÉTODOS DE ACCIÓN

  Future<void> _habilitarAsistencia(ProfesorProvider provider) async {
    final exito = await provider.habilitarAsistenciaMovil(
      widget.detalleId,
      duracion: _duracionSeleccionada,
    );

    if (exito) {
      _iniciarRefrescoAutomatico();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Asistencia habilitada por $_duracionSeleccionada minutos'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Error al habilitar asistencia'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deshabilitarAsistencia(ProfesorProvider provider) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Asistencia'),
        content: const Text(
          '¿Estás seguro de que quieres cerrar la sesión de asistencia? '
          'Los estudiantes ya no podrán registrarse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      _detenerRefrescoAutomatico();
      final exito = await provider.deshabilitarAsistenciaMovil(widget.detalleId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              exito 
                  ? 'Asistencia cerrada exitosamente'
                  : provider.errorMessage ?? 'Error al cerrar asistencia',
            ),
            backgroundColor: exito ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _copiarCodigo(String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado al portapapeles'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 🔥 MÉTODOS AUXILIARES

  String _formatearTiempo(int segundos) {
    if (segundos <= 0) return '0:00';
    
    final int minutos = segundos ~/ 60;
    final int seg = segundos % 60;
    return '$minutos:${seg.toString().padLeft(2, '0')}';
  }
}