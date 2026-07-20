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

  static const List<Map<String, dynamic>> _coloresBloque = [
    {'fondo': Color(0xFFFFF9E6), 'texto': Color(0xFF7A6000)},
    {'fondo': Color(0xFFF0FFF0), 'texto': Color(0xFF1A5C1A)},
    {'fondo': Color(0xFFF0F4FF), 'texto': Color(0xFF1A2E7A)},
    {'fondo': Color(0xFFFFF0F0), 'texto': Color(0xFF7A1A1A)},
    {'fondo': Color(0xFFF5F0FF), 'texto': Color(0xFF3A1A7A)},
    {'fondo': Color(0xFFF0FAFA), 'texto': Color(0xFF1A5A5A)},
  ];

  @override
  void initState() {
    super.initState();
    _cargarRutina();
  }

  Future<void> _cargarRutina() async {
    setState(() {
      _cargando = true;
      _sinRutina = false;
    });
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
          const Text('Sin rutina este mes',
              style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.surface,
          child: Text(
            '$mes $anio',
            style: const TextStyle(
                color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w700),
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
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
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
                color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        children: bloques.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Sin bloques',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              ]
            : [_buildTablaRutina(bloques)],
      ),
    );
  }

  Widget _buildTablaRutina(List bloques) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeaderColumnas(),
          ...bloques.asMap().entries.map((entry) {
            return _buildFilaBloque(entry.value as Map<String, dynamic>, entry.key);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderColumnas() {
    return Container(
      color: AppColors.surface,
      child: Row(
        children: [
          SizedBox(width: 110, child: _headerCell('Bloque')),
          Expanded(flex: 3, child: _headerCell('Ejercicio')),
          Expanded(flex: 2, child: _headerCell('Dificultad')),
          Expanded(flex: 2, child: _headerCell('Repeticiones')),
          SizedBox(width: 70, child: _headerCell('Descanso')),
          SizedBox(width: 85, child: _headerCell('Series')),
        ],
      ),
    );
  }

  Widget _buildFilaBloque(Map<String, dynamic> bloque, int indexBloque) {
    final ejercicios = bloque['ejercicios'] as List? ?? [];
    final color = _coloresBloque[indexBloque % _coloresBloque.length];
    final colorFondo = color['fondo'] as Color;
    final colorTexto = color['texto'] as Color;
    final series = ejercicios.isNotEmpty ? ejercicios[0]['series']?.toString() ?? '' : '';

    return Container(
      decoration: BoxDecoration(
        color: colorFondo,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre del bloque
            Container(
              width: 110,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                  right: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Text(
                    bloque['nombre'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: colorTexto, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
            ),

            // Ejercicios
            Expanded(
              child: Column(
                children: ejercicios.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text('Sin ejercicios',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorTexto, fontSize: 12)),
                        )
                      ]
                    : ejercicios.map((ejercicio) =>
                        _buildFilaEjercicio(ejercicio as Map<String, dynamic>)).toList(),
              ),
            ),

            // Series — centrado verticalmente abarcando todos los ejercicios
            Container(
              width: 55,
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: Center(
                child: Text(
                  series.isNotEmpty ? '×$series' : '—',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: colorTexto, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaEjercicio(Map<String, dynamic> ejercicio) {
    final tieneVideo = ejercicio['url_video'] != null;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: InkWell(
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
        child: Row(
          children: [
            // Ejercicio
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    if (tieneVideo)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.play_circle_outline,
                            color: AppColors.primary, size: 14),
                      ),
                    Expanded(
                      child: Text(
                        ejercicio['nombre'],
                        style: TextStyle(
                          color: tieneVideo ? AppColors.primary : const Color(0xFF1A1A1A),
                          fontSize: 13,
                          fontWeight: tieneVideo ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Dificultad
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  ejercicio['dificultad'] ?? '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
                ),
              ),
            ),
            // Repeticiones
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  ejercicio['repeticiones'] ?? '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // Descanso por ejercicio
            SizedBox(
              width: 65,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text(
                  ejercicio['descanso'] ?? '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}