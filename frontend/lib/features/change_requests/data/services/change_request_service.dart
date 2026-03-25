import '../../../../core/models/change_request.dart';
import '../../../../core/services/api_service.dart';

class ChangeRequestService {
  static Future<List<ChangeRequestModel>> getMyRequests() async {
    final response = await ApiService.get('/change-requests');
    if (response['success'] == true) {
      final list = response['data'] as List;
      return list
          .map((json) => ChangeRequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response['error'] ?? 'Failed to fetch change requests');
  }

  static Future<ChangeRequestModel> getById(String id) async {
    final response = await ApiService.get('/change-requests/$id');
    if (response['success'] == true) {
      return ChangeRequestModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['error'] ?? 'Failed to fetch change request');
  }

  static Future<ChangeRequestModel> submit({
    required String propertyId,
    required String title,
    required String description,
    required String category,
  }) async {
    final response = await ApiService.post('/change-requests', {
      'propertyId': propertyId,
      'title': title,
      'description': description,
      'category': category,
    });
    if (response['success'] == true) {
      return ChangeRequestModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['error'] ?? 'Failed to submit change request');
  }
}
