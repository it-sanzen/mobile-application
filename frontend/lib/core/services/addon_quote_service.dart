import 'api_service.dart';

class AddonQuoteService {
  static Future<Map<String, dynamic>> submitQuote({
    required String propertyId,
    required List<String> addonOfferIds,
  }) async {
    final response = await ApiService.post('/addon-quotes', {
      'propertyId': propertyId,
      'addonOfferIds': addonOfferIds,
    });
    if (response['success'] == true) {
      return response['data'] as Map<String, dynamic>;
    }
    throw Exception(response['error'] ?? 'Failed to submit quote');
  }

  static Future<List<dynamic>> getMyQuotes() async {
    final response = await ApiService.get('/addon-quotes');
    if (response['success'] == true) {
      return response['data'] as List;
    }
    throw Exception(response['error'] ?? 'Failed to fetch quotes');
  }
}
