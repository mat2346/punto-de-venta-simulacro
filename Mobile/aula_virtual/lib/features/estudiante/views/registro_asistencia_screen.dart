import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/estudiante_provider.dart';
import '../../../core/models/registro_asistencia_movil_model.dart';

class RegistroAsistenciaScreen extends StatefulWidget {
  const RegistroAsistenciaScreen({super.key});

  @override
  State<RegistroAsistenciaScreen> createState() => _RegistroAsistenciaScreenState();
}

class _RegistroAsistenciaScreenState extends State<RegistroAsistenciaScreen>
    with TickerProviderStateMixin {
  final TextEditingController _codigoController = TextEditingController();
  final FocusNode _codigoFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _codigoIngresado = '';
  bool _isValidando = false;

  @override
  void initState() {
    super.initState();
    
    // Animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Iniciar animaciones
    _animationController.forward();
    _pulseController.repeat(reverse: true);

    // Auto-focus en el campo de código
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codigoFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _codigoFocusNode.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text(
          'Registrar Asistencia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<EstudianteProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // 🔥 HEADER CON ANIMACIÓN
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: _buildHeader(),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // 🔥 FORMULARIO DE CÓDIGO
                _buildFormularioCodigo(provider),
                const SizedBox(height: 30),

                // 🔥 INSTRUCCIONES
                _buildInstrucciones(),
                const SizedBox(height: 30),

                // 🔥 RESULTADO DEL ÚLTIMO REGISTRO
                if (provider.ultimoRegistroAsistencia != null)
                  _buildResultadoRegistro(provider.ultimoRegistroAsistencia!),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔥 HEADER CON ICONO Y TÍTULO
  Widget _buildHeader() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.indigo.shade600, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Asistencia Móvil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingresa el código que proporcionó tu profesor',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FORMULARIO PARA INGRESAR CÓDIGO
  Widget _buildFormularioCodigo(EstudianteProvider provider) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔥 TÍTULO DEL FORMULARIO
            Row(
              children: [
                Icon(Icons.pin, color: Colors.indigo.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Código de Asistencia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🔥 CAMPO DE TEXTO PARA CÓDIGO
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getColorBordeCodigo(),
                  width: 2,
                ),
                color: _getColorFondoCodigo(),
              ),
              child: TextField(
                controller: _codigoController,
                focusNode: _codigoFocusNode,
                onChanged: _onCodigoChanged,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  hintText: 'Ingresa el código aquí',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Colors.indigo.shade700,
                  ),
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 INFORMACIÓN DEL CÓDIGO
            _buildInfoCodigo(),
            const SizedBox(height: 20),

            // 🔥 BOTÓN DE REGISTRO
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _puedeRegistrarse() && !provider.isLoadingAsistenciaMovil
                    ? () => _registrarAsistencia(provider)
                    : null,
                icon: provider.isLoadingAsistenciaMovil
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  provider.isLoadingAsistenciaMovil 
                      ? 'Registrando...' 
                      : 'Registrar Asistencia',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _puedeRegistrarse() 
                      ? Colors.green.shade600 
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _puedeRegistrarse() ? 4 : 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 INFORMACIÓN SOBRE EL CÓDIGO
  Widget _buildInfoCodigo() {
    final longitudCodigo = _codigoIngresado.length;
    final longitudMinima = 6;
    final esValido = longitudCodigo >= longitudMinima;

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: esValido ? Colors.green : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            esValido ? Icons.check : Icons.info_outline,
            size: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            esValido 
                ? 'Código válido - Listo para registrar'
                : 'Mínimo $longitudMinima caracteres ($longitudCodigo/$longitudMinima)',
            style: TextStyle(
              fontSize: 12,
              color: esValido ? Colors.green : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 INSTRUCCIONES DE USO
  Widget _buildInstrucciones() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Instrucciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInstruccionItem(
              '1',
              'Tu profesor debe habilitar la asistencia móvil',
              Icons.power_settings_new,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildInstruccionItem(
              '2',
              'Solicita el código único generado automáticamente',
              Icons.qr_code,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInstruccionItem(
              '3',
              'Ingresa el código exactamente como se muestra',
              Icons.keyboard,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildInstruccionItem(
              '4',
              'Confirma tu asistencia presionando el botón',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruccionItem(
    String numero,
    String texto,
    IconData icono,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              numero,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // 🔥 RESULTADO DEL REGISTRO
  Widget _buildResultadoRegistro(RegistroAsistenciaMovilModel resultado) {
    final esExitoso = resultado.success;
    final color = esExitoso ? Colors.green : Colors.red;
    final icono = esExitoso ? Icons.check_circle : Icons.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 48),
          const SizedBox(height: 12),
          Text(
            esExitoso ? '¡Asistencia Registrada!' : 'Error en el Registro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultado.message,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          if (esExitoso && resultado.materia != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Materia: ${resultado.materia}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (resultado.horaRegistro != null)
                    Text(
                      'Hora: ${resultado.horaRegistro}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _limpiarResultado,
            icon: const Icon(Icons.refresh),
            label: const Text('Registrar Nueva Asistencia'),
          ),
        ],
      ),
    );
  }

  // 🔥 MÉTODOS DE LÓGICA

  void _onCodigoChanged(String valor) {
    setState(() {
      _codigoIngresado = valor.toUpperCase();
    });
  }

  bool _puedeRegistrarse() {
    return _codigoIngresado.length >= 6 && !_isValidando;
  }

  Color _getColorBordeCodigo() {
    if (_codigoIngresado.isEmpty) return Colors.grey.shade300;
    if (_codigoIngresado.length >= 6) return Colors.green;
    return Colors.orange;
  }

  Color _getColorFondoCodigo() {
    if (_codigoIngresado.isEmpty) return Colors.grey.shade50;
    if (_codigoIngresado.length >= 6) return Colors.green.shade50;
    return Colors.orange.shade50;
  }

  Future<void> _registrarAsistencia(EstudianteProvider provider) async {
    if (!_puedeRegistrarse()) return;

    // Limpiar resultado anterior
    provider.limpiarUltimoRegistroAsistencia();

    final exitoso = await provider.registrarseAsistenciaMovil(_codigoIngresado);

    if (exitoso) {
      // Limpiar campo y mostrar feedback
      _codigoController.clear();
      setState(() {
        _codigoIngresado = '';
      });
      
      // Vibración de éxito
      HapticFeedback.heavyImpact();
      
      // Auto-scroll hacia el resultado
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } else {
      // Vibración de error
      HapticFeedback.selectionClick();
    }
  }

  void _limpiarResultado() {
    final provider = Provider.of<EstudianteProvider>(context, listen: false);
    provider.limpiarUltimoRegistroAsistencia();
    _codigoFocusNode.requestFocus();
  }
}

// 🔥 FORMATTER PARA MAYÚSCULAS
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}