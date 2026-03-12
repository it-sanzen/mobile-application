import '../../../../core/services/api_service.dart';
import '../../../home/data/models/property_model.dart';

class PropertiesService {
  static Future<List<PropertyModel>> getMyProperties({String? propertyType}) async {
    try {
      print('🏠 FETCHING PROPERTIES FROM BACKEND... propertyType=$propertyType');

      String endpoint = '/properties/my';
      if (propertyType != null && propertyType.isNotEmpty) {
        endpoint += '?propertyType=$propertyType';
      }

      final response = await ApiService.get(endpoint);

      print('🏠 PROPERTIES RESPONSE: $response');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        print('🏠 PROPERTIES COUNT: ${data.length}');
        final properties = data
            .map((json) => PropertyModel.fromJson(json as Map<String, dynamic>))
            .toList();
        print('🏠 PROPERTIES PARSED: ${properties.map((p) => p.name).toList()}');
        return properties;
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch properties');
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
      rethrow;
    }
  }
}
