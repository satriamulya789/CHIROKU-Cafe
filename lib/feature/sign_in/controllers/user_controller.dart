import 'package:chiroku_cafe/constant/api_constant.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_sign_in_model.dart';

class AuthController extends GetxController
    with StateMixin<UserSignInModel> {

  final supabase = Supabase.instance.client;

  final emailC = TextEditingController();
  final passwordC = TextEditingController();

  Future<void> signIn() async {
    change(null, status: RxStatus.loading());

    try {
      // 1. Login Supabase Auth
      final res = await supabase.auth.signInWithPassword(
        email: emailC.text.trim(),
        password: passwordC.text.trim(),
      );

      final userId = res.user!.id;

      // 2. Ambil data user dari public.users
      final data = await supabase
          .from(ApiConstant.usersTable)
          .select()
          .eq('id', userId)
          .single();

      final user = UserSignInModel.fromJson(data);

      change(user, status: RxStatus.success());

      // 3. Redirect berdasarkan role
      if (user.role == UserRole.admin) {
        Get.offAllNamed('/admin');
      } else {
        Get.offAllNamed('/cashier');
      }

    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }
}
