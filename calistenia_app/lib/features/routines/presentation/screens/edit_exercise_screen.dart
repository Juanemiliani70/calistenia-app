import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';

class EditExerciseScreen extends StatefulWidget {
  final Map<String, dynamic> ejercicio;

  const EditExerciseScreen({super.key, required this.ejercicio});

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreController;
  late TextEditingController _dificultadController;
  late TextEditingController _repeticionesController;
  late TextEditingController _seriesController;
  late TextEditingController _aclaracionesController;
  late TextEditingController _descansoController;
  late TextEditingController _urlVideoController;
  late TextEditingController _progSemana3Controller;
  late TextEditingController _progSemana4Controller;

  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Pre-cargar los valores actuales del ejercicio
    _nombreController = TextEditingController(text: widget.ejercicio['nombre'] ?? '');
    _dificultadController = TextEditingController(text: widget.ejercicio['dificultad'] ?? '');
    _repeticionesController = TextEditingController(text: widget.ejercicio['repeticiones'] ?? '');
    _seriesController = TextEditingController(text: widget.ejercicio['series']?.toString() ?? '');
    _aclaracionesController = TextEditingController(text: widget.ejercicio['aclaraciones'] ?? '');
    _descansoController = TextEditingController(text: widget.ejercicio['descanso'] ?? '');
    _urlVideoController = TextEditingController(text: widget.ejercicio['url_video'] ?? '');
    _progSemana3Controller = TextEditingController(text: widget.ejercicio['progresion_semana3'] ?? '');
    _progSemana4Controller = TextEditingController(text: widget.ejercicio['progresion_semana4'] ?? '');
  }

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

    final resultado = await RoutineService.editarEjercicio(
      idEjercicio: widget.ejercicio['id'],
      campos: {
        'nombre': _nombreController.text.trim(),
        if (_dificultadController.text.trim().isNotEmpty)
          'dificultad': _dificultadController.text.trim(),
        if (_repeticionesController.text.trim().isNotEmpty)
          'repeticiones': _repeticionesController.text.trim(),
        if (_seriesController.text.trim().isNotEmpty)
          'series': int.tryParse(_seriesController.text.trim()),
        if (_aclaracionesController.text.trim().isNotEmpty)
          'aclaraciones': _aclaracionesController.text.trim(),
        if (_descansoController.text.trim().isNotEmpty)
          'descanso': _descansoController.text.trim(),
        if (_urlVideoController.text.trim().isNotEmpty)
          'url_video': _urlVideoController.text.trim(),
        if (_progSemana3Controller.text.trim().isNotEmpty)
          'progresion_semana3': _progSemana3Controller.text.trim(),
        if (_progSemana4Controller.text.trim().isNotEmpty)
          'progresion_semana4': _progSemana4Controller.text.trim(),
      },
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (resultado['exito']) {
      Navigator.pop(context, true); // true = hubo cambios
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['error']), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar ejercicio')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                const Text('Video explicativo (opcional)',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                const Text('Progresión dentro del mes (opcional)',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.textDark),
                        )
                      : const Text('GUARDAR CAMBIOS'),
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