import 'package:supabase_flutter/supabase_flutter.dart';

class ExistingEmail {
  //check if email already exists
  Future<bool> isEmailExists(String email) async {
    final SupabaseClient supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from('users')
          .select('email')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}