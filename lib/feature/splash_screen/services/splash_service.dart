import 'package:supabase_flutter/supabase_flutter.dart';

class SplashService {
  final _supabase = Supabase.instance.client;

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      return await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      return null;
    }
  }
}
