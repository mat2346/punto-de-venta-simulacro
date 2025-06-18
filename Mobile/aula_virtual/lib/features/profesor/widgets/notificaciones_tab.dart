import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/profesor_provider.dart';
import '../../../core/services/profesor_service.dart';

class NotificacionesTab extends StatefulWidget {
  final int? materiaPreseleccionada;

  const NotificacionesTab({
    super.key,
    this.materiaPreseleccionada,
  });

  @override
  State<NotificacionesTab> createState() => _NotificacionesTabState();
}

class _NotificacionesTabState extends State<NotificacionesTab> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  
  String _tipoSeleccionado = 'general';
  int? _materiaSeleccionada;
  List<int> _destinatariosSeleccionados = [];
  bool _enviando = false;
  Map<String, dynamic>? _resultadoEnvio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
      profesorProvider.cargarMaterias();
      
      if (widget.materiaPreseleccionada != null) {
        _materiaSeleccionada = widget.materiaPreseleccionada;
        profesorProvider.cargarDestinatarios(detalleMateriaId: widget.materiaPreseleccionada);
      } else {
        profesorProvider.cargarDestinatarios();
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfesorProvider>(
      builder: (context, profesorProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enviar Notificaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Comunícate con estudiantes y tutores',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Filtro por materia
                _buildMateriaSelector(profesorProvider),

                const SizedBox(height: 16),

                // Información de materia seleccionada
                if (profesorProvider.destinatarios?.materiaInfo != null)
                  _buildMateriaInfo(profesorProvider.destinatarios!.materiaInfo!),

                const SizedBox(height: 16),

                // Seleccionar destinatarios
                _buildDestinatariosSelector(profesorProvider),

                const SizedBox(height: 16),

                // Formulario de notificación
                _buildNotificationForm(),

                const SizedBox(height: 16),

                // Botones de acción
                _buildActionButtons(profesorProvider),

                const SizedBox(height: 16),

                // Resultado del envío
                if (_resultadoEnvio != null) _buildResultado(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMateriaSelector(ProfesorProvider profesorProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Filtrar por materia (opcional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int?>(
            value: _materiaSeleccionada,
            decoration: const InputDecoration(
              hintText: 'Todos los estudiantes y tutores',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todos los estudiantes y tutores'),
              ),
              ...profesorProvider.materias.map((materia) =>
                DropdownMenuItem<int?>(
                  value: materia.detalleId,
                  child: Text(materia.nombreCompleto),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _materiaSeleccionada = value;
                _destinatariosSeleccionados.clear();
              });
              profesorProvider.cargarDestinatarios(detalleMateriaId: value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMateriaInfo(MateriaInfo materiaInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Enviando a estudiantes y tutores de: ${materiaInfo.nombre}',
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinatariosSelector(ProfesorProvider profesorProvider) {
    final destinatarios = profesorProvider.destinatarios;
    
    // 🔥 MOSTRAR LOADING CON MÁS INFORMACIÓN
    if (profesorProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando destinatarios...'),
            SizedBox(height: 8),
            Text(
              'Por favor espera un momento',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    // 🔥 MOSTRAR ERROR SI HAY
    if (profesorProvider.errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar destinatarios',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profesorProvider.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600], fontSize: 12),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                profesorProvider.clearError();
                profesorProvider.cargarDestinatarios(
                  detalleMateriaId: _materiaSeleccionada
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    // 🔥 VERIFICAR SI ES NULL (nunca se cargó)
    if (destinatarios == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('No se han cargado destinatarios'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                profesorProvider.cargarDestinatarios(
                  detalleMateriaId: _materiaSeleccionada
                );
              },
              child: const Text('Cargar Destinatarios'),
            ),
          ],
        ),
      );
    }

    final estudiantes = destinatarios.estudiantes;
    final tutores = destinatarios.tutores;

    if (estudiantes.isEmpty && tutores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.people_outline, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron destinatarios',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Seleccionar Destinatarios',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),

          // Botones de selección rápida
          Wrap(
            spacing: 8,
            children: [
              _buildQuickSelectButton('Todos', Colors.blue, () {
                setState(() {
                  _destinatariosSeleccionados = [
                    ...estudiantes.map((e) => e.id),
                    ...tutores.map((t) => t.id),
                  ];
                });
              }),
              _buildQuickSelectButton('Ninguno', Colors.grey, () {
                setState(() {
                  _destinatariosSeleccionados.clear();
                });
              }),
              _buildQuickSelectButton('Solo Estudiantes', Colors.green, () {
                setState(() {
                  _destinatariosSeleccionados = estudiantes.map((e) => e.id).toList();
                });
              }),
              _buildQuickSelectButton('Solo Tutores', Colors.purple, () {
                setState(() {
                  _destinatariosSeleccionados = tutores.map((t) => t.id).toList();
                });
              }),
            ],
          ),

          const SizedBox(height: 16),

          // Lista de estudiantes
          if (estudiantes.isNotEmpty) ...[
            Text(
              '🎓 Estudiantes (${estudiantes.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: estudiantes.length,
                itemBuilder: (context, index) {
                  final estudiante = estudiantes[index];
                  return CheckboxListTile(
                    dense: true,
                    title: Text(estudiante.nombre),
                    subtitle: Text(estudiante.codigo),
                    value: _destinatariosSeleccionados.contains(estudiante.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _destinatariosSeleccionados.add(estudiante.id);
                        } else {
                          _destinatariosSeleccionados.remove(estudiante.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],

          // Lista de tutores
          if (tutores.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '👨‍👩‍👧‍👦 Tutores (${tutores.length})',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: tutores.length,
                itemBuilder: (context, index) {
                  final tutor = tutores[index];
                  return CheckboxListTile(
                    dense: true,
                    title: Text(tutor.nombre),
                    subtitle: Text(tutor.codigo),
                    value: _destinatariosSeleccionados.contains(tutor.id),
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _destinatariosSeleccionados.add(tutor.id);
                        } else {
                          _destinatariosSeleccionados.remove(tutor.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 12),
          Text(
            'Seleccionados: ${_destinatariosSeleccionados.length} destinatarios',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSelectButton(String label, Color color, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildNotificationForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Contenido de la Notificación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),

          // Título
          TextFormField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título *',
              hintText: 'Ingrese el título de la notificación',
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El título es requerido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Mensaje
          TextFormField(
            controller: _mensajeController,
            decoration: const InputDecoration(
              labelText: 'Mensaje *',
              hintText: 'Escriba el mensaje de la notificación',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            maxLength: 500,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El mensaje es requerido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Tipo
          DropdownButtonFormField<String>(
            value: _tipoSeleccionado,
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'general', child: Text('📢 General')),
              DropdownMenuItem(value: 'tarea', child: Text('📝 Tarea')),
              DropdownMenuItem(value: 'examen', child: Text('📊 Examen')),
              DropdownMenuItem(value: 'evento', child: Text('📅 Evento')),
              DropdownMenuItem(value: 'urgente', child: Text('🚨 Urgente')),
            ],
            onChanged: (value) {
              setState(() {
                _tipoSeleccionado = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProfesorProvider profesorProvider) {
    // 🔥 CORREGIDO: Usar currentState en lugar de currentForm
    final puedeEnviar = _destinatariosSeleccionados.isNotEmpty &&
                       _tituloController.text.trim().isNotEmpty &&
                       _mensajeController.text.trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: puedeEnviar && !_enviando ? _enviarNotificacion : null,
            icon: _enviando 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_enviando ? 'Enviando...' : 'Enviar Notificación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _enviando ? null : _limpiarFormulario,
          icon: const Icon(Icons.clear),
          label: const Text('Limpiar'),
        ),
      ],
    );
  }

  Widget _buildResultado() {
    final esExito = _resultadoEnvio!['success'] == true;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: esExito ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esExito ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esExito ? Icons.check_circle : Icons.error,
                color: esExito ? Colors.green[700] : Colors.red[700],
              ),
              const SizedBox(width: 8),
              Text(
                esExito ? 'Notificación Enviada' : 'Error al Enviar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: esExito ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ],
          ),
          if (esExito) ...[
            const SizedBox(height: 8),
            Text('📊 Enviadas: ${_resultadoEnvio!['enviadas']}'),
            Text('❌ Fallidas: ${_resultadoEnvio!['fallidas']}'),
            Text('📱 Total: ${_resultadoEnvio!['total']}'),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              _resultadoEnvio!['error'] ?? 'Error desconocido',
              style: TextStyle(color: Colors.red[700]),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _enviarNotificacion() async {
    if (!_formKey.currentState!.validate() || _destinatariosSeleccionados.isEmpty) {
      return;
    }

    setState(() {
      _enviando = true;
      _resultadoEnvio = null;
    });

    try {
      final profesorProvider = Provider.of<ProfesorProvider>(context, listen: false);
      
      final resultado = await profesorProvider.enviarNotificacionMasiva(
        destinatarios: _destinatariosSeleccionados,
        titulo: _tituloController.text.trim(),
        mensaje: _mensajeController.text.trim(),
        tipo: _tipoSeleccionado,
      );

      setState(() {
        _resultadoEnvio = resultado != null 
            ? {'success': true, ...resultado}
            : {'success': false, 'error': 'Error desconocido'};
        _enviando = false;
      });

      if (resultado != null) {
        _limpiarFormulario();
      }
    } catch (e) {
      setState(() {
        _resultadoEnvio = {'success': false, 'error': e.toString()};
        _enviando = false;
      });
    }
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _mensajeController.clear();
    setState(() {
      _tipoSeleccionado = 'general';
      _destinatariosSeleccionados.clear();
      _resultadoEnvio = null;
    });
  }
}