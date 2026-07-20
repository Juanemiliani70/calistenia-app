import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/features/routines/data/routine_service.dart';
import 'package:calistenia_app/features/routines/presentation/screens/add_exercise_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:calistenia_app/features/routines/presentation/screens/edit_exercise_screen.dart';

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
  bool _fabHover = false;

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


  final ScrollController _scrollController = ScrollController();
  bool _mostrarFab = true;

  @override
  void initState() {
    super.initState();
    _cargarRutina();   
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  

  Future<void> _cargarRutina() async {
    setState(() => _cargando = true);
    final resultado = await RoutineService.obtenerRutina(widget.idRutina);
    setState(() {
      _cargando = false;
      if (resultado['exito']) _rutina = resultado['data'];
    });
  }

  void _mostrarDialogoAgregarDia() {
    final controlador = TextEditingController();
    final dias = _rutina?['dias'] as List? ?? [];
    final numeroDia = dias.length + 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Día $numeroDia', style: const TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controlador,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Nombre del día (ej: Muscle Up)'),
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
          decoration: const InputDecoration(hintText: 'Nombre (ej: Calentamiento, P1)'),
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

  void _mostrarOpcionesEjercicio(Map<String, dynamic> ejercicio) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre del ejercicio como título del modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              ejercicio['nombre'],
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(color: AppColors.border),

          // Editar
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: const Text('Editar ejercicio',
                style: TextStyle(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditExerciseScreen(ejercicio: ejercicio),
                ),
              ).then((hubocambios) {
                if (hubocambios == true) _cargarRutina();
              });
            },
          ),

          // Eliminar
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.error),
            title: const Text('Eliminar ejercicio',
                style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _confirmarEliminarEjercicio(ejercicio);
            },
          ),
        ],
      ),
    ),
  );
}

void _confirmarEliminarEjercicio(Map<String, dynamic> ejercicio) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Eliminar ejercicio',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Text(
        '¿Seguro que querés eliminar este ejercicio?',
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () async {
            Navigator.pop(context);
            final resultado =
                await RoutineService.eliminarEjercicio(ejercicio['id']);
            if (resultado['exito']) {
              _cargarRutina();
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(resultado['error']),
                    backgroundColor: AppColors.error),
              );
            }
          },
          child: const Text('ELIMINAR'),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarRutina),
        ],
      ),
      
      floatingActionButton: MouseRegion(
        onEnter: (_) => setState(() => _fabHover = true),
        onExit: (_) => setState(() => _fabHover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: _fabHover
              ? FloatingActionButton.extended(
                  onPressed: _mostrarDialogoAgregarDia,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar día'),
                )
              : FloatingActionButton(
                  onPressed: _mostrarDialogoAgregarDia,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textDark,
                  child: const Icon(Icons.add),
                ),
        ),
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
            const Text('Rutina vacía',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Tocá "Agregar día" para empezar',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
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
                      color: AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                GestureDetector(
                  onTap: () => _mostrarDialogoAgregarBloque(dia['id'], bloques.length),
                  child: const Icon(Icons.add_circle_outline, color: AppColors.textDark),
                ),
              ],
            ),
          ),

          if (bloques.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin bloques — tocá + para agregar',
                  style: TextStyle(color: AppColors.textSecondary)),
            )
          else
            _buildTablaRutina(bloques),
        ],
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
            // Nombre del bloque — se estira a la altura de todos los ejercicios
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
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('Sin ejercicios',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: colorTexto, fontSize: 12)),
                              ),
                              // Botón agregar cuando está vacío
                              IconButton(
                                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddExerciseScreen(
                                      idBloque: bloque['id'],
                                      nombreBloque: bloque['nombre'],
                                      ordenActual: 0,
                                    ),
                                  ),
                                ).then((_) => _cargarRutina()),
                              ),
                            ],
                          ),
                        )
                      ]
                    : ejercicios.asMap().entries.map((ejEntry) {
                        final ejercicio = ejEntry.value as Map<String, dynamic>;
                        final esUltimo = ejEntry.key == ejercicios.length - 1;
                        return _buildFilaEjercicio(
                          ejercicio,
                          esUltimo: esUltimo,
                          idBloque: bloque['id'],
                          nombreBloque: bloque['nombre'],
                          totalEjercicios: ejercicios.length,
                        );
                      }).toList(),
              ),
            ),

            // Series — se estira a la altura de todos los ejercicios
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

  Widget _buildFilaEjercicio(
    Map<String, dynamic> ejercicio, {
    required bool esUltimo,
    required int idBloque,
    required String nombreBloque,
    required int totalEjercicios,
  }) {
    return InkWell(
      onTap: () => _mostrarOpcionesEjercicio(ejercicio),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
            color: esUltimo ? AppColors.border : AppColors.border,
            width: esUltimo ? 1.5 : 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ejercicio
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 205, right: 8, top: 8, bottom: 8),
              child: Text(
                ejercicio['nombre'],
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 13),
              ),
            ),
          ),
          // Dificultad
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 8),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  ejercicio['dificultad'] ?? '—',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
                ),
              ),
            ),
          ),
          // Repeticiones
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6, top: 8, bottom: 8),
              child: Align(
                alignment: Alignment.center,
              child: Text(
                ejercicio['repeticiones'] ?? '—',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF1A1A1A), fontSize: 13, fontWeight: FontWeight.w600),
                ),
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
          // Botón agregar — solo en el último ejercicio
          if (esUltimo)
            SizedBox(
              width: 36,
              child: IconButton(
                icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExerciseScreen(
                      idBloque: idBloque,
                      nombreBloque: nombreBloque,
                      ordenActual: totalEjercicios,
                    ),
                  ),
                ).then((_) => _cargarRutina()),
              ),
            )
          else
            const SizedBox(width: 36),
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