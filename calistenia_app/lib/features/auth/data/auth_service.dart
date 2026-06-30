import 'dart:convert';
import 'package:calistenia_app/core/constants/api_constants.dart';
import 'package:calistenia_app/core/network/http_client.dart';
import 'package:calistenia_app/core/storage/token_storage.dart';

// Servicio de autenticación — maneja todos los requests relacionados a auth
class AuthService {

  // ── HU-02 — REGISTRO DE ALUMNO ────────────────────────────────────────────

  static Future<Map<String, dynamic>> registrarAlumno({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String codigoInvitacion,
    String nivel = 'principiante',
  }) async {
    final response = await ApiClient.post(
      ApiConstants.registerAlumno,
      {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        'nivel': nivel,
        'codigo_invitacion': codigoInvitacion,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    } else {
      return {'exito': false, 'error': data['detail'] ?? 'Error al registrar'};
    }
  }

  // ── HU-03 — REGISTRO DE PROFESOR ─────────────────────────────────────────

  static Future<Map<String, dynamic>> registrarProfesor({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? especialidad,
    int? aniosExperiencia,
    String? descripcionBio,
  }) async {
    final response = await ApiClient.post(
      ApiConstants.registerProfesor,
      {
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'password': password,
        if (especialidad != null) 'especialidad': especialidad,
        if (aniosExperiencia != null) 'años_experiencia': aniosExperiencia,
        if (descripcionBio != null) 'descripcion_bio': descripcionBio,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    } else {
      return {'exito': false, 'error': data['detail'] ?? 'Error al registrar'};
    }
  }

  // ── HU-07 — LOGIN ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // El login usa form-urlencoded porque FastAPI usa OAuth2PasswordRequestForm
    final response = await ApiClient.postForm(
      ApiConstants.login,
      {
        'username': email,
        'password': password,
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Guardar tokens en almacenamiento seguro
      await TokenStorage.guardarTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
      );

      // Obtener y guardar el tipo de usuario
      final perfil = await obtenerPerfil();
      if (perfil['exito']) {
        await TokenStorage.guardarTipoUsuario(perfil['data']['tipo']);
      }

      return {'exito': true, 'data': data};
    } else {
      return {'exito': false, 'error': data['detail'] ?? 'Credenciales incorrectas'};
    }
  }

  // ── OBTENER PERFIL ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> obtenerPerfil() async {
    final response = await ApiClient.getAuth(ApiConstants.me);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'exito': true, 'data': data};
    } else {
      return {'exito': false, 'error': data['detail'] ?? 'Error al obtener perfil'};
    }
  }

  // ── HU-08 — RECUPERAR PASSWORD ────────────────────────────────────────────

  static Future<Map<String, dynamic>> recuperarPassword(String email) async {
    final response = await ApiClient.post(
      ApiConstants.recuperarPassword,
      {'email': email},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'exito': true, 'mensaje': data['message']};
    } else {
      return {'exito': false, 'error': data['detail'] ?? 'Error al recuperar password'};
    }
  }

  // ── CERRAR SESIÓN ─────────────────────────────────────────────────────────

  static Future<void> logout() async {
    // Borra todos los tokens del almacenamiento seguro
    await TokenStorage.limpiar();
  }
}