import '../../../../core/services/api_service.dart';

class RoomDesignerService {
  static Future<List<dynamic>> getShowroomCategories() async {
    try {
      final response = await ApiService.get('/showrooms/categories');
      if (response['success'] == true) return response['data'] as List<dynamic>;
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getUserDesigns() async {
    try {
      final response = await ApiService.get('/user-designs');
      if (response['success'] == true) return response['data'] as List<dynamic>;
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> deleteDesign(String designId) async {
    try {
      final response = await ApiService.delete('/user-designs/$designId');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
