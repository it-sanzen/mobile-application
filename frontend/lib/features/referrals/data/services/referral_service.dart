import '../../../../core/models/referral.dart';
import '../../../../core/services/api_service.dart';

class ReferralService {
  static Future<ReferralDashboard> getDashboard() async {
    final response = await ApiService.get('/referrals/dashboard');
    if (response['success'] == true) {
      return ReferralDashboard.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['error'] ?? 'Failed to fetch referral dashboard');
  }

  static Future<ReferralCodeModel> getMyCode() async {
    final response = await ApiService.get('/referrals/my-code');
    if (response['success'] == true) {
      return ReferralCodeModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['error'] ?? 'Failed to fetch referral code');
  }

  static Future<ReferralModel> submit({
    required String referredName,
    required String referredPhone,
    String? referredEmail,
  }) async {
    final body = <String, dynamic>{
      'referredName': referredName,
      'referredPhone': referredPhone,
    };
    if (referredEmail != null && referredEmail.isNotEmpty) {
      body['referredEmail'] = referredEmail;
    }

    final response = await ApiService.post('/referrals', body);
    if (response['success'] == true) {
      return ReferralModel.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['error'] ?? 'Failed to submit referral');
  }
}
