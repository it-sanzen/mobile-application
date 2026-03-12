import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  static const _userPhoneKey = 'user_phone';
  static const _userAddressKey = 'user_address';
  static const _userUnitKey = 'user_unit';
  static const _userCreatedAtKey = 'user_created_at';
  
  static const _rememberedEmailKey = 'remembered_email';
  static const _rememberedPasswordKey = 'remembered_password';

  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required String name,
    required String email,
    String? phone,
    String? address,
    String? unit,
    String? createdAt,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userNameKey, value: name);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userPhoneKey, value: phone ?? '');
    await _storage.write(key: _userAddressKey, value: address ?? '');
    await _storage.write(key: _userUnitKey, value: unit ?? '');
    if (createdAt != null) await _storage.write(key: _userCreatedAtKey, value: createdAt);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<Map<String, String?>> getUserData() async {
    return {
      'id': await _storage.read(key: _userIdKey),
      'name': await _storage.read(key: _userNameKey),
      'email': await _storage.read(key: _userEmailKey),
      'phone': await _storage.read(key: _userPhoneKey),
      'address': await _storage.read(key: _userAddressKey),
      'unit': await _storage.read(key: _userUnitKey),
      'createdAt': await _storage.read(key: _userCreatedAtKey),
    };
  }

  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userNameKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userPhoneKey);
    await _storage.delete(key: _userAddressKey);
    await _storage.delete(key: _userUnitKey);
    await _storage.delete(key: _userCreatedAtKey);
  }

  static Future<void> saveRememberedCredentials(String email, String password) async {
    await _storage.write(key: _rememberedEmailKey, value: email);
    await _storage.write(key: _rememberedPasswordKey, value: password);
  }

  static Future<Map<String, String?>> getRememberedCredentials() async {
    return {
      'email': await _storage.read(key: _rememberedEmailKey),
      'password': await _storage.read(key: _rememberedPasswordKey),
    };
  }

  static Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: _rememberedEmailKey);
    await _storage.delete(key: _rememberedPasswordKey);
  }
}
