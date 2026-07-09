import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';
import 'package:calistenia_app/features/routines/presentation/screens/video_player_screen.dart';

class StudentRoutineScreen extends StatefulWidget {
  final int idAlumno;

  const StudentRoutineScreen({super.key, required this.idAlumno});

  @override
  State<StudentRoutineScreen> createState() => _StudentRoutineScreenState();
}

class _StudentRoutineScreenState extends State<StudentRoutineScreen> {
  bool _cargando = true;
  Map<String, dynamic>? _rutina;
  bool _sinRutina = false;

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
    setState(() { _cargando = true; _sinRutina = false; });

    final resultado = await RoutineService.obtenerRutinaActiva(widget.idAlumno);

    setState(() {
      _cargando = false;
      if (resultado['exito']) {
        _rutina = resultado['data'];
      } else if (resultado['sinRutina'] == true) {
        _sinRutina = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi rutina'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarRutina),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _sinRutina
                ? _buildSinRutina()
                : _buildRutina(),
      ),
    );
  }

  Widget _buildSinRutina() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, color: AppColors.textSecondary, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Sin rutina este mes',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu profesor todavía no cargó tu rutina para este mes',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRutina() {
    final dias = _rutina?['dias'] as List? ?? [];
    final mes = _meses[(_rutina?['mes'] ?? 1) - 1];
    final anio = _rutina?['anio'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del mes
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.surface,
          child: Text(
            '$mes $anio',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dias.length,
            itemBuilder: (context, i) => _buildDia(dias[i]),
          ),
        ),
      ],
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
      child: ExpansionTile(
        // Día expandible — por defecto colapsado
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Text(
            'Día ${dia['numero_dia']} — ${dia['nombre']}',
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        children: bloques.isEmpty
            ? [const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Sin ejercicios', style: TextStyle(color: AppColors.textSecondary)),
              )]
            : bloques.map((b) => _buildBloque(b)).toList(),
      ),
    );
  }

  Widget _buildBloque(Map<String, dynamic> bloque) {
    final ejercicios = bloque['ejercicios'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del bloque
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            bloque['nombre'],
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        ...ejercicios.map((e) => _buildEjercicio(e)).toList(),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }

  Widget _buildEjercicio(Map<String, dynamic> ejercicio) {
    final tieneVideo = ejercicio['url_video'] != null;

    return InkWell(
      onTap: tieneVideo
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(
                    urlVideo: ejercicio['url_video'],
                    nombreEjercicio: ejercicio['nombre'],
                  ),
                ),
              )
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tieneVideo)
              const Padding(
                padding: EdgeInsets.only(right: 8, top: 2),
                child: Icon(Icons.play_circle_outline, color: AppColors.primary, size: 20),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio['nombre'],
                    style: TextStyle(
                      color: tieneVideo ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (ejercicio['series'] != null || ejercicio['repeticiones'] != null)
                    Text(
                      _formatearReps(ejercicio),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  if (ejercicio['dificultad'] != null)
                    Text('Dificultad: ${ejercicio['dificultad']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  if (ejercicio['descanso'] != null)
                    Text('Descanso: ${ejercicio['descanso']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  if (ejercicio['aclaraciones'] != null)
                    Text(ejercicio['aclaraciones'],
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontStyle: FontStyle.italic)),
                  if (ejercicio['progresion_semana3'] != null)
                    Text('Semana 3: ${ejercicio['progresion_semana3']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  if (ejercicio['progresion_semana4'] != null)
                    Text('Semana 4: ${ejercicio['progresion_semana4']}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
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