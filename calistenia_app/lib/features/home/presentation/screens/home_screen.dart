import 'package:flutter/material.dart';
import 'package:calistenia_app/core/constants/app_colors.dart';
import 'package:calistenia_app/core/storage/token_storage.dart';
import 'package:calistenia_app/features/auth/data/auth_service.dart';
import 'package:calistenia_app/features/auth/presentation/screens/login_screen.dart';
import 'package:calistenia_app/core/widgets/kaizen_logo.dart';
import 'package:calistenia_app/features/home/presentation/screens/pending_students_screen.dart';
import 'package:calistenia_app/features/home/presentation/screens/approved_students_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _cargando = true;
  Map<String, dynamic>? _perfil;

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  // Carga los datos del usuario autenticado al entrar a la pantalla
  Future<void> _cargarPerfil() async {
    final resultado = await AuthService.obtenerPerfil();

    setState(() {
      _cargando = false;
      if (resultado['exito']) {
        _perfil = resultado['data'];
      }
    });
  }

  // Cierra la sesión y vuelve al login
  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final esProfesor = _perfil?['tipo'] == 'profesor';

    return Scaffold(
      appBar: AppBar(
        title: KaizenLogo(tamanioKanji: 28, mostrarSubtitulo: false),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo con el nombre del usuario
              Text(
                'Hola, ${_perfil?['nombre'] ?? _perfil?['email'] ?? ''}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              
              const SizedBox(height: 4),
              Text(
                esProfesor ? 'Profesor' : 'Alumno',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // Contenido distinto según el rol
              Expanded(
                child: esProfesor ? _buildVistaProfesor() : _buildVistaAlumno(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Vista para profesores — accesos directos a gestión de alumnos
  Widget _buildVistaProfesor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuCard(
          icono: Icons.vpn_key_outlined,
          titulo: 'Mi código de invitación',
          subtitulo: 'Compartí este código con tus alumnos',
          onTap: () {
            // TODO: navegar a pantalla de código de invitación
          },
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icono: Icons.pending_actions,
          titulo: 'Solicitudes pendientes',
          subtitulo: 'Aprobá o rechazá nuevos alumnos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PendingStudentsScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icono: Icons.groups_outlined,
          titulo: 'Mis alumnos',
          subtitulo: 'Gestioná las rutinas y el progreso de tus alumnos',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApprovedStudentsScreen()),
            );
          },
        ),
      ],
    );
  }

  // Vista para alumnos — estado de su cuenta y rutinas
  Widget _buildVistaAlumno() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MenuCard(
          icono: Icons.fitness_center,
          titulo: 'Mis rutinas',
          subtitulo: 'Próximamente',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icono: Icons.trending_up,
          titulo: 'Mi progreso',
          subtitulo: 'Próximamente',
          onTap: () {},
        ),
      ],
    );
  }
}

// Card reutilizable del menú principal
class _MenuCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icono, color: AppColors.primary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}