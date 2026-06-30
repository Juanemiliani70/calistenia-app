import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Maneja el almacenamiento seguro de tokens JWT en el dispositivo
class TokenStorage {
  // Instancia del storage seguro — en Android usa Keystore, en iOS usa Keychain
  static const _storage = FlutterSecureStorage();

  // Claves para identificar cada valor guardado
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserType = 'user_type';

  // ── GUARDAR ───────────────────────────────────────────────────────────────

  static Future<void> guardarTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<void> guardarTipoUsuario(String tipo) async {
    await _storage.write(key: _keyUserType, value: tipo);
  }

  // ── LEER ──────────────────────────────────────────────────────────────────

  static Future<String?> obtenerAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> obtenerRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<String?> obtenerTipoUsuario() async {
    return await _storage.read(key: _keyUserType);
  }

  // ── VERIFICAR ─────────────────────────────────────────────────────────────

  static Future<bool> estaLogueado() async {
    final token = await obtenerAccessToken();
    return token != null;
  }

  // ── ELIMINAR ──────────────────────────────────────────────────────────────

  // Se llama al cerrar sesión — borra todos los tokens guardados
  static Future<void> limpiar() async {
    await _storage.deleteAll();
  }
}