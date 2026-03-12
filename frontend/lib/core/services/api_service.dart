import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiService {
  // Local development backend
  static const String baseUrl = 'http://127.0.0.1:3000/api/v1';
  // Production backend hosted on Render
  // static const String baseUrl = 'https://sanzen-new-demo.onrender.com/api/v1';

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

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required List<int> fileBytes,
    required String filename,
    required Map<String, String> fields,
  }) async {
    try {
      final token = await TokenService.getToken();
      final headers = <String, String>{};
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll(headers);
      
      request.fields.addAll(fields);
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: filename,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Upload failed',
        };
      }
    } catch (e) {
      print('HTTP MULTIPART ERROR: $e');
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
      final tokenToUse = token ?? await TokenService.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (tokenToUse != null) {
        headers['Authorization'] = 'Bearer $tokenToUse';
      }

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
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
      print('HTTP GET ERROR: \$e');
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
