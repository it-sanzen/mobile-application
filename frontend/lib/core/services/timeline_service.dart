import '../models/timeline_milestone.dart';
import '../models/milestone_update.dart';
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

  static Future<List<MilestoneUpdate>> getMilestoneUpdates(
      String milestoneId) async {
    try {
      final response =
          await ApiService.get('/timeline/milestone/$milestoneId/updates');

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data
            .map((u) => MilestoneUpdate.fromJson(u as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch updates');
      }
    } catch (e) {
      print('Error fetching milestone updates: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPropertyFeed(
      String propertyId, {int page = 1, int limit = 10}) async {
    try {
      final response = await ApiService.get(
          '/timeline/$propertyId/feed?page=$page&limit=$limit');

      if (response['success'] == true) {
        final feedData = response['data'] as Map<String, dynamic>;
        final List<dynamic> items = feedData['data'] as List<dynamic>;
        return {
          'data': items
              .map((u) => MilestoneUpdate.fromJson(u as Map<String, dynamic>))
              .toList(),
          'total': feedData['total'] as int,
          'page': feedData['page'] as int,
          'limit': feedData['limit'] as int,
        };
      } else {
        throw Exception(response['error'] ?? 'Failed to fetch feed');
      }
    } catch (e) {
      print('Error fetching update feed: $e');
      rethrow;
    }
  }
}
