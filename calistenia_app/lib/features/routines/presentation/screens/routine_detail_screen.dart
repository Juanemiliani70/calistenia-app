import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';
import 'package:calistenia_app/features/routines/presentation/screens/add_exercise_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  final int idRutina;
  final String nombreAlumno;
  final int mes;
  final int anio;

  const RoutineDetailScreen({
    super.key,
    required this.idRutina,
    required this.nombreAlumno,
    required this.mes,
    required this.anio,
  });

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  bool _cargando = true;
  Map<String, dynamic>? _rutina;

  final List<String> _meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    _cargarRutina();
  }

  Future<void> _cargarRutina() async {
    setState(() => _cargando = true);
    final resultado = await RoutineService.obtenerRutina(widget.idRutina);
    setState(() {
      _cargando = false;
      if (resultado['exito']) _rutina = resultado['data'];
    });
  }

  // HU-02 — Diálogo para agregar un día
  void _mostrarDialogoAgregarDia() {
    final controlador = TextEditingController();
    final dias = _rutina?['dias'] as List? ?? [];
    final numeroDia = dias.length + 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Día $numeroDia',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controlador,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nombre del día (ej: Muscle Up)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controlador.text.trim().isEmpty) return;
              Navigator.pop(context);
              final resultado = await RoutineService.agregarDia(
                idRutina: widget.idRutina,
                numeroDia: numeroDia,
                nombre: controlador.text.trim(),
              );
              if (resultado['exito']) {
                _cargarRutina();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resultado['error']), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('AGREGAR'),
          ),
        ],
      ),
    );
  }

  // HU-03 — Diálogo para agregar un bloque
  void _mostrarDialogoAgregarBloque(int idDia, int ordenActual) {
    final controlador = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Agregar bloque', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controlador,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nombre del bloque (ej: Calentamiento, P1)',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controlador.text.trim().isEmpty) return;
              Navigator.pop(context);
              final resultado = await RoutineService.agregarBloque(
                idDia: idDia,
                nombre: controlador.text.trim(),
                orden: ordenActual + 1,
              );
              if (resultado['exito']) {
                _cargarRutina();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(resultado['error']), backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('AGREGAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mes = _meses[widget.mes - 1];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.nombreAlumno} — $mes ${widget.anio}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarRutina,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregarDia,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textDark,
        icon: const Icon(Icons.add),
        label: const Text('Agregar día'),
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _rutina == null
                ? const Center(child: Text('Error al cargar la rutina'))
                : _buildContenido(),
      ),
    );
  }

  Widget _buildContenido() {
    final dias = _rutina?['dias'] as List? ?? [];

    if (dias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 56),
            const SizedBox(height: 16),
            const Text('Rutina vacía', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tocá "Agregar día" para empezar', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dias.length,
      itemBuilder: (context, i) => _buildDia(dias[i]),
    );
  }

  Widget _buildDia(Map<String, dynamic> dia) {
    final bloques = dia['bloques'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del día
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Día ${dia['numero_dia']} — ${dia['nombre']}',
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                GestureDetector(
                  onTap: () => _mostrarDialogoAgregarBloque(dia['id'], bloques.length),
                  child: const Icon(Icons.add_circle_outline, color: AppColors.textDark),
                ),
              ],
            ),
          ),

          // Bloques del día
          if (bloques.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin bloques — tocá + para agregar', style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...bloques.map((bloque) => _buildBloque(bloque)).toList(),
        ],
      ),
    );
  }

  Widget _buildBloque(Map<String, dynamic> bloque) {
    final ejercicios = bloque['ejercicios'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del bloque
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bloque['nombre'],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExerciseScreen(
                      idBloque: bloque['id'],
                      nombreBloque: bloque['nombre'],
                      ordenActual: ejercicios.length,
                    ),
                  ),
                ).then((_) => _cargarRutina()),
                child: const Icon(Icons.add, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        ),

        // Ejercicios del bloque
        if (ejercicios.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text('Sin ejercicios', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          )
        else
          ...ejercicios.map((e) => _buildEjercicio(e)).toList(),

        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }

  Widget _buildEjercicio(Map<String, dynamic> ejercicio) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono de video si tiene URL
          if (ejercicio['url_video'] != null)
            const Padding(
              padding: EdgeInsets.only(right: 8, top: 2),
              child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 18),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ejercicio['nombre'],
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                ),
                // Mostrar solo los campos que no son nulos
                if (ejercicio['repeticiones'] != null || ejercicio['series'] != null)
                  Text(
                    _formatearReps(ejercicio),
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                if (ejercicio['dificultad'] != null)
                  Text('Dificultad: ${ejercicio['dificultad']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (ejercicio['descanso'] != null)
                  Text('Descanso: ${ejercicio['descanso']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                if (ejercicio['aclaraciones'] != null)
                  Text(ejercicio['aclaraciones'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatearReps(Map<String, dynamic> ejercicio) {
    final reps = ejercicio['repeticiones'];
    final series = ejercicio['series'];
    if (series != null && reps != null) return '${series}x$reps';
    if (reps != null) return reps;
    if (series != null) return '$series series';
    return '';
  }
}