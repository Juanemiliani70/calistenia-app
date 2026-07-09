import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';
import 'package:calistenia_app/features/routines/presentation/screens/routine_detail_screen.dart';

class RoutineScreen extends StatefulWidget {
  // Datos del alumno al que pertenece la rutina
  final int idAlumno;
  final String nombreAlumno;

  const RoutineScreen({
    super.key,
    required this.idAlumno,
    required this.nombreAlumno,
  });

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  bool _cargando = false;

  // Meses en español para el selector
  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;

  // HU-01 — Crear rutina mensual para el alumno
  Future<void> _crearRutina() async {
    setState(() => _cargando = true);

    final resultado = await RoutineService.crearRutina(
      idAlumno: widget.idAlumno,
      mes: _mesSeleccionado,
      anio: _anioSeleccionado,
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (resultado['exito']) {
      final rutina = resultado['data'];
      // Navegar a la pantalla de detalle de la rutina recién creada
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoutineDetailScreen(
            idRutina: rutina['id'],
            nombreAlumno: widget.nombreAlumno,
            mes: _mesSeleccionado,
            anio: _anioSeleccionado,
          ),
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
      appBar: AppBar(
        title: Text('Rutina de ${widget.nombreAlumno}'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  Text(
                    'Nueva rutina mensual',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seleccioná el mes y año para crear la rutina de ${widget.nombreAlumno}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 32),

                  // Selector de mes
                  DropdownButtonFormField<int>(
                    value: _mesSeleccionado,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Mes',
                      prefixIcon: Icon(Icons.calendar_month, color: AppColors.textSecondary),
                    ),
                    items: List.generate(12, (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text(_meses[i]),
                    )),
                    onChanged: (v) => setState(() => _mesSeleccionado = v!),
                  ),

                  const SizedBox(height: 16),

                  // Selector de año
                  DropdownButtonFormField<int>(
                    value: _anioSeleccionado,
                    dropdownColor: AppColors.surfaceLight,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Año',
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.textSecondary),
                    ),
                    items: [2025, 2026, 2027].map((a) => DropdownMenuItem(
                      value: a,
                      child: Text(a.toString()),
                    )).toList(),
                    onChanged: (v) => setState(() => _anioSeleccionado = v!),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _cargando ? null : _crearRutina,
                    child: _cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.textDark,
                            ),
                          )
                        : const Text('CREAR RUTINA'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}