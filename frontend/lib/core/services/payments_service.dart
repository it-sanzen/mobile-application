import '../models/payment_model.dart';
import 'api_service.dart';

class PaymentsService {
  static Future<List<PaymentModel>> getMyPayments({String? status}) async {
    try {
      print('💳 FETCHING PAYMENTS FROM BACKEND... status=$status');

      String endpoint = '/payments/my';
      if (status != null && status.isNotEmpty) {
        endpoint += '?status=$status';
      }

      final response = await ApiService.get(endpoint);

      print('💳 PAYMENTS RESPONSE: $response');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        print('💳 PAYMENTS COUNT: ${data.length}');
        final payments = data
            .map((json) => PaymentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return payments;
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch payments');
      }
    } catch (e) {
      print('❌ Error fetching payments: $e');
      rethrow;
    }
  }

  static Future<PaymentSummary> getPaymentSummary() async {
    try {
      print('💳 FETCHING PAYMENT SUMMARY FROM BACKEND...');

      final response = await ApiService.get('/payments/summary');

      print('💳 PAYMENT SUMMARY RESPONSE: $response');

      if (response['success'] == true) {
        return PaymentSummary.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch payment summary');
      }
    } catch (e) {
      print('❌ Error fetching payment summary: $e');
      rethrow;
    }
  }
}
