import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/auth/data/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _cargando = false;
  bool _enviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // HU-08 — Maneja el submit de solicitud de recuperación
  Future<void> _handleSolicitar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final resultado = await AuthService.recuperarPassword(
      _emailController.text.trim(),
    );

    setState(() {
      _cargando = false;
      // Siempre mostramos el mismo mensaje de éxito — el backend no revela
      // si el email existe o no, por seguridad
      if (resultado['exito']) {
        _enviado = true;
      }
    });

    if (!resultado['exito'] && mounted) {
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
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _enviado ? _buildMensajeExito() : _buildFormulario(),
            ),
          ),
        ),
      ),
    );
  }

  // Pantalla de formulario — pide el email
  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Icon(Icons.lock_reset, color: AppColors.primary, size: 56),
          const SizedBox(height: 24),
          Text(
            '¿Olvidaste tu contraseña?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresá tu email y te enviaremos un enlace para restablecerla',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),

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

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _cargando ? null : _handleSolicitar,
            child: _cargando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textDark,
                    ),
                  )
                : const Text('ENVIAR ENLACE'),
          ),
        ],
      ),
    );
  }

  // Pantalla de confirmación — se muestra tras enviar la solicitud
  Widget _buildMensajeExito() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 64),
        const SizedBox(height: 24),
        Text(
          'Revisá tu email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Si el email existe en nuestro sistema, vas a recibir un enlace para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('VOLVER AL LOGIN'),
        ),
      ],
    );
  }
}