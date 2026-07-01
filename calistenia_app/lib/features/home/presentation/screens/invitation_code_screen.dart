import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/core/network/http_client.dart';
import 'package:calistenia_app/core/constants/api_constants.dart';
import 'dart:convert';

class InvitationCodeScreen extends StatefulWidget {
  const InvitationCodeScreen({super.key});

  @override
  State<InvitationCodeScreen> createState() => _InvitationCodeScreenState();
}

class _InvitationCodeScreenState extends State<InvitationCodeScreen> {
  bool _cargando = true;
  String? _codigo;

  @override
  void initState() {
    super.initState();
    _cargarCodigo();
  }

  Future<void> _cargarCodigo() async {
    final response = await ApiClient.getAuth(ApiConstants.miCodigoInvitacion);
    final data = jsonDecode(response.body);

    setState(() {
      _cargando = false;
      if (response.statusCode == 200) {
        _codigo = data['codigo_invitacion'];
      }
    });
  }

  void _copiarCodigo() {
    if (_codigo == null) return;
    Clipboard.setData(ClipboardData(text: _codigo!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado'),
        backgroundColor: AppColors.surfaceLight,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi código de invitación')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _cargando
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.vpn_key_outlined,
                        color: AppColors.primary,
                        size: 56,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Compartí este código con tus alumnos',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tus alumnos lo van a necesitar al registrarse para ver sus rutinas',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 40),

                      // Código de invitación
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _codigo ?? '--------',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _copiarCodigo,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('COPIAR CÓDIGO'),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tip
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Este código es único para tus alumnos. Podés compartirlo por WhatsApp o en persona.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}