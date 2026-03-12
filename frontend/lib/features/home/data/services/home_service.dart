import '../../../../core/services/api_service.dart';
import '../models/property_model.dart';
import '../models/unit_update_model.dart';
import '../models/company_news_model.dart';

class HomeService {
  Future<PropertyModel?> getMyPrimaryProperty() async {
    try {
      final response = await ApiService.get('/properties/my-primary');

      if (!response['success'] || response['data'] == null) {
        return null;
      }

      return PropertyModel.fromJson(response['data']);
    } catch (e) {
      print('Error fetching primary property: $e');
      return null;
    }
  }

  Future<List<UnitUpdateModel>> getUnitUpdates() async {
    try {
      final response = await ApiService.get('/unit-updates');

      if (!response['success'] || response['data'] == null) {
        return [];
      }

      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => UnitUpdateModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching unit updates: $e');
      return [];
    }
  }

  Future<List<CompanyNewsModel>> getCompanyNews() async {
    try {
      final response = await ApiService.get('/company-news');

      if (!response['success'] || response['data'] == null) {
        return [];
      }

      final List<dynamic> data = response['data'] as List<dynamic>;
      return data.map((json) => CompanyNewsModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching company news: $e');
      return [];
    }
  }
}
