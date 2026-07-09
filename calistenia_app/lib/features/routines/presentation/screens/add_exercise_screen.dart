import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';

class AddExerciseScreen extends StatefulWidget {
  final int idBloque;
  final String nombreBloque;
  final int ordenActual;

  const AddExerciseScreen({
    super.key,
    required this.idBloque,
    required this.nombreBloque,
    required this.ordenActual,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _dificultadController = TextEditingController();
  final _repeticionesController = TextEditingController();
  final _seriesController = TextEditingController();
  final _aclaracionesController = TextEditingController();
  final _descansoController = TextEditingController();
  final _urlVideoController = TextEditingController();
  final _progSemana3Controller = TextEditingController();
  final _progSemana4Controller = TextEditingController();

  bool _cargando = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _dificultadController.dispose();
    _repeticionesController.dispose();
    _seriesController.dispose();
    _aclaracionesController.dispose();
    _descansoController.dispose();
    _urlVideoController.dispose();
    _progSemana3Controller.dispose();
    _progSemana4Controller.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    final resultado = await RoutineService.agregarEjercicio(
      idBloque: widget.idBloque,
      nombre: _nombreController.text.trim(),
      dificultad: _dificultadController.text.trim().isEmpty ? null : _dificultadController.text.trim(),
      repeticiones: _repeticionesController.text.trim().isEmpty ? null : _repeticionesController.text.trim(),
      series: _seriesController.text.trim().isEmpty ? null : int.tryParse(_seriesController.text.trim()),
      aclaraciones: _aclaracionesController.text.trim().isEmpty ? null : _aclaracionesController.text.trim(),
      descanso: _descansoController.text.trim().isEmpty ? null : _descansoController.text.trim(),
      urlVideo: _urlVideoController.text.trim().isEmpty ? null : _urlVideoController.text.trim(),
      progresionSemana3: _progSemana3Controller.text.trim().isEmpty ? null : _progSemana3Controller.text.trim(),
      progresionSemana4: _progSemana4Controller.text.trim().isEmpty ? null : _progSemana4Controller.text.trim(),
      orden: widget.ordenActual + 1,
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (resultado['exito']) {
      Navigator.pop(context);
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
        title: Text('Ejercicio — ${widget.nombreBloque}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── CAMPOS PRINCIPALES ──────────────────────────────────
                TextFormField(
                  controller: _nombreController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Nombre del ejercicio *',
                    prefixIcon: Icon(Icons.fitness_center, color: AppColors.textSecondary),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _seriesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Series'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _repeticionesController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Repeticiones'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _dificultadController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Dificultad (ej: explosivas, banda baja)',
                    prefixIcon: Icon(Icons.speed, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descansoController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: "Descanso (ej: 2', 2'30'')",
                    prefixIcon: Icon(Icons.timer_outlined, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _aclaracionesController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Aclaraciones',
                    prefixIcon: Icon(Icons.notes, color: AppColors.textSecondary),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                const Text(
                  'Video explicativo (opcional)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _urlVideoController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'URL de YouTube',
                    prefixIcon: Icon(Icons.play_circle_outline, color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                const Text(
                  'Progresión dentro del mes (opcional)',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _progSemana3Controller,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Semana 3'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _progSemana4Controller,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Semana 4'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _cargando ? null : _guardar,
                  child: _cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textDark),
                        )
                      : const Text('GUARDAR EJERCICIO'),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}