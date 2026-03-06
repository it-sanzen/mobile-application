import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiService {
  // Using localhost with ADB reverse port forwarding (adb reverse tcp:3000 tcp:3000)
  // For emulator use: http://10.0.2.2:3000/api/v1
  // For real device without ADB, use your computer's local IP: http://192.168.70.249:3000/api/v1
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        String errorMsg = 'An error occurred';
        if (data['message'] != null) {
          if (data['message'] is List) {
            errorMsg = (data['message'] as List).join('\n');
          } else {
            errorMsg = data['message'].toString();
          }
        }
        
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      print('HTTP POST ERROR: \$e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'An error occurred',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'error': 'No internet connection',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await TokenService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        String errorMsg = 'An error occurred';
        if (data['message'] != null) {
          if (data['message'] is List) {
            errorMsg = (data['message'] as List).join('\n');
          } else {
            errorMsg = data['message'].toString();
          }
        }
        
        return {
          'success': false,
          'error': errorMsg,
        };
      }
    } catch (e) {
      print('HTTP PUT ERROR: \$e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
