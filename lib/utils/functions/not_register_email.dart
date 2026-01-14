import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotRegisterEmail {
  //check if email is not registered
  Future<bool> isEmailNotRegistered(String email) async {
    final SupabaseClient supabase = Supabase.instance.client;
    try {
      final response = await supabase
          .from(ApiConstant.usersTable)
          .select('email')
          .eq('email', email.trim())
          .maybeSingle();

      return response == null;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }
}
