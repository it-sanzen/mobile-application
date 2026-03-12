import '../models/addon_offer.dart';
import 'api_service.dart';

class AddonOffersService {
  static Future<List<AddonOffer>> getAllActiveOffers() async {
    try {
      print('🔥 FETCHING ADDON OFFERS FROM BACKEND...');
      final response = await ApiService.get('/addon-offers');

      print('🔥 ADDON OFFERS RESPONSE: $response');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        print('🔥 ADDON OFFERS COUNT: ${data.length}');
        final offers = data
            .map((json) => AddonOffer.fromJson(json as Map<String, dynamic>))
            .toList();
        print('🔥 ADDON OFFERS PARSED: ${offers.map((o) => o.title).toList()}');
        return offers;
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch addon offers');
      }
    } catch (e) {
      print('❌ Error fetching addon offers: $e');
      rethrow;
    }
  }
}
