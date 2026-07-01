import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/core/constants/api_constants.dart';
import 'package:calistenia_app/core/network/http_client.dart';

class PendingStudentsScreen extends StatefulWidget {
  const PendingStudentsScreen({super.key});

  @override
  State<PendingStudentsScreen> createState() => _PendingStudentsScreenState();
}

class _PendingStudentsScreenState extends State<PendingStudentsScreen> {
  bool _cargando = true;
  List<dynamic> _alumnosPendientes = [];

  @override
  void initState() {
    super.initState();
    _cargarPendientes();
  }

  Future<void> _cargarPendientes() async {
    final response = await ApiClient.getAuth(ApiConstants.alumnosPendientes);

    setState(() {
      _cargando = false;
      if (response.statusCode == 200) {
        _alumnosPendientes = jsonDecode(response.body);
      }
    });
  }

  // HU-06 — Aprueba o rechaza un alumno
  Future<void> _revisarAlumno(int idAlumno, String estado) async {
    final response = await ApiClient.patchAuth(
      '${ApiConstants.alumnos}/$idAlumno/revision',
      {'estado': estado},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            estado == 'aprobado'
                ? 'Alumno aprobado correctamente'
                : 'Alumno rechazado',
          ),
          backgroundColor: estado == 'aprobado' ? AppColors.success : AppColors.error,
        ),
      );
      // Recargar la lista después de revisar
      setState(() => _cargando = true);
      _cargarPendientes();
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['detail'] ?? 'Error al revisar alumno'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // Muestra un diálogo de confirmación antes de aprobar o rechazar
  void _mostrarConfirmacion(Map<String, dynamic> alumno, String accion) {
    final esAprobacion = accion == 'aprobado';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          esAprobacion ? 'Aprobar alumno' : 'Rechazar alumno',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          esAprobacion
              ? '¿Querés aprobar a ${alumno['nombre']} ${alumno['apellido']}?'
              : '¿Querés rechazar la solicitud de ${alumno['nombre']} ${alumno['apellido']}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: esAprobacion ? AppColors.success : AppColors.error,
              foregroundColor: AppColors.textPrimary,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _revisarAlumno(alumno['id'], accion);
            },
            child: Text(esAprobacion ? 'APROBAR' : 'RECHAZAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes pendientes'),
        actions: [
          // Botón para refrescar la lista manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _cargando = true);
              _cargarPendientes();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _alumnosPendientes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay solicitudes pendientes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cuando un alumno se registre con tu código, aparecerá acá',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _alumnosPendientes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alumno = _alumnosPendientes[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Avatar con inicial
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
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Badge de estado
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PENDIENTE',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 12),

                            // Botones de acción
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                    ),
                                    onPressed: () => _mostrarConfirmacion(alumno, 'rechazado'),
                                    child: const Text('RECHAZAR'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: AppColors.textPrimary,
                                    ),
                                    onPressed: () => _mostrarConfirmacion(alumno, 'aprobado'),
                                    child: const Text('APROBAR'),
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