import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:calistenia_app/core/storage/token_storage.dart';

// Cliente HTTP centralizado — todos los requests a la API pasan por acá
class ApiClient {
  
  // ── HEADERS ───────────────────────────────────────────────────────────────

  // Headers básicos para requests sin autenticación
  static Map<String, String> _headersPublicos() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Headers con JWT — para endpoints protegidos
  static Future<Map<String, String>> _headersPrivados() async {
    final token = await TokenStorage.obtenerAccessToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── MÉTODOS HTTP ──────────────────────────────────────────────────────────

  // GET sin autenticación
  static Future<http.Response> get(String url) async {
    return await http.get(
      Uri.parse(url),
      headers: _headersPublicos(),
    );
  }

  // GET con autenticación JWT
  static Future<http.Response> getAuth(String url) async {
    return await http.get(
      Uri.parse(url),
      headers: await _headersPrivados(),
    );
  }

  // POST sin autenticación — usado para login y registro
  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse(url),
      headers: _headersPublicos(),
      body: jsonEncode(body),
    );
  }

  // POST con autenticación JWT
  static Future<http.Response> postAuth(String url, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse(url),
      headers: await _headersPrivados(),
      body: jsonEncode(body),
    );
  }

  // POST con form data — usado para el login de OAuth2 que espera form-urlencoded
  static Future<http.Response> postForm(String url, Map<String, String> body) async {
    return await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: body,
    );
  }

  // PATCH con autenticación JWT — usado para editar perfil
  static Future<http.Response> patchAuth(String url, Map<String, dynamic> body) async {
    return await http.patch(
      Uri.parse(url),
      headers: await _headersPrivados(),
      body: jsonEncode(body),
    );
  }

  // DELETE con autenticación JWT
  static Future<http.Response> deleteAuth(String url) async {
    return await http.delete(
      Uri.parse(url),
      headers: await _headersPrivados(),
    );
  }
}