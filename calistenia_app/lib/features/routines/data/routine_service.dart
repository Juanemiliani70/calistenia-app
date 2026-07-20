import 'dart:convert';
import 'package:calistenia_app/core/constants/api_constants.dart';
import 'package:calistenia_app/core/network/http_client.dart';

class RoutineService {

  // ── HU-01 — CREAR RUTINA ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> crearRutina({
    required int idAlumno,
    required int mes,
    required int anio,
  }) async {
    final response = await ApiClient.postAuth(
      ApiConstants.rutinas,
      {
        'id_alumno': idAlumno,
        'mes': mes,
        'anio': anio,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al crear rutina'};
  }

  // ── HU-02 — AGREGAR DÍA ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>> agregarDia({
    required int idRutina,
    required int numeroDia,
    required String nombre,
  }) async {
    final response = await ApiClient.postAuth(
      ApiConstants.diasRutina(idRutina),
      {'numero_dia': numeroDia, 'nombre': nombre},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al agregar día'};
  }

  // ── HU-03 — AGREGAR BLOQUE ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> agregarBloque({
    required int idDia,
    required String nombre,
    required int orden,
  }) async {
    final response = await ApiClient.postAuth(
      ApiConstants.bloquesdia(idDia),
      {'nombre': nombre, 'orden': orden},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al agregar bloque'};
  }

  // ── HU-04 — AGREGAR EJERCICIO ────────────────────────────────────────────

  static Future<Map<String, dynamic>> agregarEjercicio({
    required int idBloque,
    required String nombre,
    String? dificultad,
    String? repeticiones,
    int? series,
    String? aclaraciones,
    String? descanso,
    String? urlVideo,
    String? progresionSemana3,
    String? progresionSemana4,
    int orden = 0,
  }) async {
    final response = await ApiClient.postAuth(
      ApiConstants.ejerciciosBloque(idBloque),
      {
        'nombre': nombre,
        if (dificultad != null) 'dificultad': dificultad,
        if (repeticiones != null) 'repeticiones': repeticiones,
        if (series != null) 'series': series,
        if (aclaraciones != null) 'aclaraciones': aclaraciones,
        if (descanso != null) 'descanso': descanso,
        if (urlVideo != null) 'url_video': urlVideo,
        if (progresionSemana3 != null) 'progresion_semana3': progresionSemana3,
        if (progresionSemana4 != null) 'progresion_semana4': progresionSemana4,
        'orden': orden,
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al agregar ejercicio'};
  }

  // ── HU-05 — EDITAR EJERCICIO ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> editarEjercicio({
    required int idEjercicio,
    required Map<String, dynamic> campos,
  }) async {
    final response = await ApiClient.patchAuth(
      ApiConstants.editarEjercicio(idEjercicio),
      campos,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al editar ejercicio'};
  }

  // ── ELIMINAR EJERCICIO ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> eliminarEjercicio(int idEjercicio) async {
    final response = await ApiClient.deleteAuth(
      ApiConstants.editarEjercicio(idEjercicio),
    );

    if (response.statusCode == 204) {
      return {'exito': true};
    }
    final data = jsonDecode(response.body);
    return {'exito': false, 'error': data['detail'] ?? 'Error al eliminar ejercicio'};
  }

  // ── HU-06 — RUTINA ACTIVA DEL ALUMNO ────────────────────────────────────

  static Future<Map<String, dynamic>> obtenerRutinaActiva(int idAlumno) async {
    final response = await ApiClient.getAuth(ApiConstants.rutinaActiva(idAlumno));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'exito': true, 'data': data};
    }
    if (response.statusCode == 404) {
      return {'exito': false, 'sinRutina': true, 'error': data['detail']};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al obtener rutina'};
  }

  // ── HU-08 — HISTORIAL DE RUTINAS ─────────────────────────────────────────

  static Future<Map<String, dynamic>> obtenerHistorial(int idAlumno) async {
    final response = await ApiClient.getAuth(ApiConstants.historialRutinas(idAlumno));
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al obtener historial'};
  }

  // ── OBTENER RUTINA COMPLETA ───────────────────────────────────────────────

  static Future<Map<String, dynamic>> obtenerRutina(int idRutina) async {
    final response = await ApiClient.getAuth('${ApiConstants.rutinas}/$idRutina');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'exito': true, 'data': data};
    }
    return {'exito': false, 'error': data['detail'] ?? 'Error al obtener rutina'};
  }
}