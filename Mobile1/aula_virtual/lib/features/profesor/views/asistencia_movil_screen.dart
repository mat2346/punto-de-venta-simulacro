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
    _cargarDatos();
    _iniciarTimerAutorefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _cargarDatos() {
    final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
    profesorProvider.cargarEstadoAsistenciaMovil(widget.detalleId);
  }

  void _iniciarTimerAutorefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
      profesorProvider.refrescarAsistenciaMovil(widget.detalleId);
    });
  }

  Future<void> _habilitarAsistencia() async {
    final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
    
    final success = await profesorProvider.habilitarAsistenciaMovil(
      widget.detalleId,
      duracion: _duracionSeleccionada,
    );

    if (success) {
      _mostrarExito('¡Asistencia habilitada correctamente!');
    } else {
      _mostrarError(profesorProvider.errorMessage ?? 'Error al habilitar asistencia');
    }
  }

  Future<void> _deshabilitarAsistencia() async {
    final confirmar = await _mostrarConfirmacion(
      '¿Deshabilitar Asistencia?',
      'Los estudiantes ya no podrán registrar su asistencia.',
    );

    if (!confirmar) return;

    final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
    
    final success = await profesorProvider.deshabilitarAsistenciaMovil(widget.detalleId);

    if (success) {
      _mostrarExito('Asistencia deshabilitada correctamente');
      _timer?.cancel();
    } else {
      _mostrarError(profesorProvider.errorMessage ?? 'Error al deshabilitar asistencia');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asistencia Móvil', style: TextStyle(fontSize: 18)),
            Text(
              widget.nombreMateria,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _cargarDatos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Consumer<ProfesorProvider>(
        builder: (context, profesorProvider, child) {
          return RefreshIndicator(
            onRefresh: () async => _cargarDatos(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildEstadoCard(profesorProvider),
                  const SizedBox(height: 20),
                  
                  if (profesorProvider.estadoAsistenciaMovil?.habilitada == true) ...[
                    _buildCodigoCard(profesorProvider),
                    const SizedBox(height: 20),
                    _buildEstudiantesCard(profesorProvider),
                  ] else
                    _buildConfiguracionCard(profesorProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoCard(ProfesorProvider profesorProvider) {
    final estado = profesorProvider.estadoAsistenciaMovil;
    final habilitada = estado?.habilitada ?? false;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: habilitada 
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.grey[400]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (habilitada ? Colors.green : Colors.grey).withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            habilitada ? Icons.check_circle : Icons.cancel,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            habilitada ? 'ASISTENCIA ACTIVA' : 'ASISTENCIA INACTIVA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            habilitada 
                ? 'Los estudiantes pueden registrarse'
                : 'Habilita la asistencia para que los estudiantes se registren',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (habilitada && estado?.sesion != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${estado!.sesion!.tiempoRestante}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'min restantes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${estado.sesion!.estudiantesRegistrados}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Text(
                        'registrados',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCodigoCard(ProfesorProvider profesorProvider) {
    final sesion = profesorProvider.estadoAsistenciaMovil?.sesion;
    if (sesion == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Código de Asistencia',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _copiarCodigo(sesion.codigo),
                icon: const Icon(Icons.copy),
                tooltip: 'Copiar código',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...sesion.codigo.split('').map((digit) => 
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      digit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copiarCodigo(sesion.codigo),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar Código'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: profesorProvider.isLoadingAsistenciaMovil 
                      ? null 
                      : _deshabilitarAsistencia,
                  icon: profesorProvider.isLoadingAsistenciaMovil
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.stop),
                  label: const Text('Detener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEstudiantesCard(ProfesorProvider profesorProvider) {
    final estudiantes = profesorProvider.estudiantesRegistradosMovil;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estudiantes Registrados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${estudiantes.length}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (estudiantes.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Aún no hay estudiantes registrados',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comparte el código con tus estudiantes para que puedan registrarse',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: estudiantes.length,
              itemBuilder: (context, index) {
                final estudiante = estudiantes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(Icons.check, color: Colors.green[700]),
                    ),
                    title: Text(
                      estudiante.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Código: ${estudiante.codigo}'),
                        Text(
                          estudiante.tiempoTranscurrido,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      _formatearHora(estudiante.horaRegistro),
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildConfiguracionCard(ProfesorProvider profesorProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configurar Asistencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Duración de la sesión:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 10, 15, 20, 30, 45, 60].map((minutos) =>
              ChoiceChip(
                label: Text('$minutos min'),
                selected: _duracionSeleccionada == minutos,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _duracionSeleccionada = minutos);
                  }
                },
                selectedColor: Colors.blue[100],
                labelStyle: TextStyle(
                  color: _duracionSeleccionada == minutos 
                      ? Colors.blue[700] 
                      : Colors.grey[700],
                  fontWeight: _duracionSeleccionada == minutos 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: profesorProvider.isLoadingAsistenciaMovil 
                  ? null 
                  : _habilitarAsistencia,
              icon: profesorProvider.isLoadingAsistenciaMovil 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(
                profesorProvider.isLoadingAsistenciaMovil 
                    ? 'Habilitando...' 
                    : 'Habilitar Asistencia'
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Cómo funciona:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '1. Habilita la asistencia con la duración deseada\n'
                  '2. Comparte el código con tus estudiantes\n'
                  '3. Los estudiantes usan el código en su app móvil\n'
                  '4. Monitorea quién se ha registrado en tiempo real',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copiarCodigo(String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    _mostrarExito('Código copiado al portapapeles: $codigo');
  }

  String _formatearHora(DateTime hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<bool> _mostrarConfirmacion(String titulo, String mensaje) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}