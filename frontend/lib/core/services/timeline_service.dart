import '../models/timeline_milestone.dart';
import 'api_service.dart';

class TimelineService {
  static Future<List<TimelineMilestone>> getPropertyTimeline(
      String propertyId) async {
    try {
      final response = await ApiService.get('/timeline/$propertyId');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data
            .map((json) => TimelineMilestone.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch timeline');
      }
    } catch (e) {
      print('Error fetching timeline: $e');
      rethrow;
    }
  }
}
