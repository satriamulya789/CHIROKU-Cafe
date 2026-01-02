import 'package:chiroku_cafe/feature/auth/complete_profile/repositories/complete_profile_repositories.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileController extends GetxController {

  //================== Dependencies ===================//
   final _repository = CompleteProfileRepository();
  final supabase = Supabase.instance.client;

}