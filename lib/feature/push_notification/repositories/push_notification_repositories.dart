import '../models/push_notification_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PushNotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PushNotificationModel>> fetchNotifications(String userId) async {
    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => PushNotificationModel.fromJson(e))
        .toList();
  }
}