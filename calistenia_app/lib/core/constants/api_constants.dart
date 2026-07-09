// Constantes de la API — URL base y endpoints
class ApiConstants {
  // URL base de la API — en desarrollo apunta a FastAPI local
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // ── AUTH ──────────────────────────────────────────────────────────────────
  static const String registerAlumno = '$baseUrl/auth/register/alumno';
  static const String registerProfesor = '$baseUrl/auth/register/profesor';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';
  static const String verificarEmail = '$baseUrl/auth/verificar-email';
  static const String recuperarPassword = '$baseUrl/auth/recuperar-password';
  static const String resetearPassword = '$baseUrl/auth/resetear-password';
  static const String miCodigoInvitacion = '$baseUrl/auth/mi-codigo-invitacion';


  // ── ALUMNOS ───────────────────────────────────────────────────────────────
  static const String alumnosPendientes = '$baseUrl/alumnos/pendientes';
  static const String alumnosAprobados = '$baseUrl/alumnos/aprobados';
  static const String alumnos = '$baseUrl/alumnos'; // base para /{id}/revision

  // ── USUARIOS ──────────────────────────────────────────────────────────────
  static const String usuarios = '$baseUrl/usuarios';
  static const String miPerfil = '$baseUrl/usuarios/me/perfil';

  // ── RUTINAS ───────────────────────────────────────────────────────────────
  static const String rutinas = '$baseUrl/rutinas';
  static String rutinaActiva(int idAlumno) => '$baseUrl/rutinas/alumno/$idAlumno/activa';
  static String historialRutinas(int idAlumno) => '$baseUrl/rutinas/alumno/$idAlumno/historial';
  static String diasRutina(int idRutina) => '$baseUrl/rutinas/$idRutina/dias';
  static String bloquesdia(int idDia) => '$baseUrl/rutinas/dias/$idDia/bloques';
  static String ejerciciosBloque(int idBloque) => '$baseUrl/rutinas/bloques/$idBloque/ejercicios';
  static String editarEjercicio(int idEjercicio) => '$baseUrl/rutinas/ejercicios/$idEjercicio';
}

