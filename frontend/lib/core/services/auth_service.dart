import 'api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    return {
      'success': true,
      'data': {
        'token': 'fake_jwt_token_for_demo_app_only',
        'user': {
          'id': '12345',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
        }
      }
    };
  }

  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    return await ApiService.post('/auth/signin', {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return await ApiService.post('/auth/forgot-password', {
      'email': email,
    });
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return await ApiService.post('/auth/verify-otp', {
      'email': email,
      'otp': otp,
    });
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    return await ApiService.post('/auth/reset-password', {
      'email': email,
      'token': otp,
      'password': newPassword,
    });
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await ApiService.post('/auth/change-password', {
      'currentPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? unit,
  }) async {
    return await ApiService.put('/auth/profile', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (unit != null) 'unit': unit,
    });
  }
}
