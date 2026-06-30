import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/auth/data/auth_service.dart';
import 'package:calistenia_app/core/widgets/kaizen_logo.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codigoController = TextEditingController();

  String _nivelSeleccionado = 'principiante';
  bool _passwordVisible = false;
  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  // HU-02 — Maneja el submit del formulario de registro de alumno
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final resultado = await AuthService.registrarAlumno(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      // El código se normaliza a mayúsculas porque así se generan en el backend
      codigoInvitacion: _codigoController.text.trim().toUpperCase(),
      nivel: _nivelSeleccionado,
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (resultado['exito']) {
      // Registro exitoso — mostrar mensaje y volver al login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text(
            '¡Cuenta creada!',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Te enviamos un email para verificar tu cuenta. Una vez verificada, tu profesor deberá aprobar tu solicitud.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Cierra el diálogo y vuelve hasta el login (2 pantallas atrás)
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Ir a iniciar sesión',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error']),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Alumno')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Campo Nombre
                    TextFormField(
                      controller: _nombreController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Nombre',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresá tu nombre';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Apellido
                    TextFormField(
                      controller: _apellidoController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Apellido',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresá tu apellido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresá tu email';
                        if (!value.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresá una contraseña';
                        if (value.length < 8) return 'Mínimo 8 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Selector de Nivel
                    DropdownButtonFormField<String>(
                      initialValue: _nivelSeleccionado,
                      dropdownColor: AppColors.surfaceLight,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.bar_chart, color: AppColors.textSecondary),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'principiante', child: Text('Principiante')),
                        DropdownMenuItem(value: 'intermedio', child: Text('Intermedio')),
                        DropdownMenuItem(value: 'avanzado', child: Text('Avanzado')),
                      ],
                      onChanged: (value) {
                        setState(() => _nivelSeleccionado = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Separador visual antes del código de invitación
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 8),
                    const Text(
                      'Código de tu profesor',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),

                    // Campo Código de Invitación
                    TextFormField(
                      controller: _codigoController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ej: A3F9K2X1',
                        prefixIcon: Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pedile el código a tu profesor';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Botón de registro
                    ElevatedButton(
                      onPressed: _cargando ? null : _handleRegister,
                      child: _cargando
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textDark,
                              ),
                            )
                          : const Text('CREAR CUENTA'),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}