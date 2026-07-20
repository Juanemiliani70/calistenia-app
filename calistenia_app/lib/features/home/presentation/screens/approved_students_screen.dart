import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/core/constants/api_constants.dart';
import 'package:calistenia_app/core/network/http_client.dart';
import 'package:calistenia_app/features/routines/presentation/screens/routine_history_screen.dart';
import 'package:calistenia_app/features/routines/presentation/screens/routine_screen.dart';

class ApprovedStudentsScreen extends StatefulWidget {
  const ApprovedStudentsScreen({super.key});

  @override
  State<ApprovedStudentsScreen> createState() => _ApprovedStudentsScreenState();
}

class _ApprovedStudentsScreenState extends State<ApprovedStudentsScreen> {
  bool _cargando = true;
  List<dynamic> _alumnosAprobados = [];

  @override
  void initState() {
    super.initState();
    _cargarAprobados();
  }

  Future<void> _cargarAprobados() async {
    final response = await ApiClient.getAuth(ApiConstants.alumnosAprobados);
    setState(() {
      _cargando = false;
      if (response.statusCode == 200) {
        _alumnosAprobados = jsonDecode(response.body);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis alumnos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _cargando = true);
              _cargarAprobados();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _alumnosAprobados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.groups_outlined, color: AppColors.textSecondary, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          'Todavía no tenés alumnos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Aprobá solicitudes pendientes para que aparezcan acá',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _alumnosAprobados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alumno = _alumnosAprobados[index];
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info del alumno
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Center(
                                    child: Text(
                                      alumno['nombre'][0].toUpperCase(),
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
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
                                        '${alumno['nombre']} ${alumno['apellido']}',
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        'Nivel: ${alumno['nivel']}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'ACTIVO',
                                    style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 12),

                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.history, size: 16),
                                    label: const Text('HISTORIAL'),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RoutineHistoryScreen(
                                          idAlumno: alumno['id'],
                                          nombreAlumno: '${alumno['nombre']} ${alumno['apellido']}',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('RUTINA'),
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RoutineScreen(
                                          idAlumno: alumno['id'],
                                          nombreAlumno: '${alumno['nombre']} ${alumno['apellido']}',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}