// import 'package:chiroku_cafe/feature/auth/sign_in/services/sign_in_service.dart';
// import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
// import 'package:chiroku_cafe/utils/enums/user_enum.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class SignInRepositories {
//   final supabase = Supabase.instance.client;
//   final _signInService = SignInService();

//   Future<UserRole> signInUser({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _signInService.signIn(
//         email: email,
//         password: password,
//       );
//       final user = response.user;
//       final session = response.session;

//       if (user == null || session == null) {
//         throw AuthErrorModel.failedLoadUser().message;
//       }

//       // Get user role from database
//       final role = await _signInService.getUserRole(user.id);
//       if (role == null) {
//         throw AuthErrorModel.unknownError().message;
//       }
      
//     } catch (e) {
//       throw e;
//     }
//   }

//    /// Get user role from database
//   Future<UserRole?> getUserRole(String userId) async {
//     try {
//       final userData = await supabase
//           .from('users')
//           .select('role')
//           .eq('id', userId)
//           .maybeSingle();

//       if (userData == null) {
//         return null;
//       }

//       final roleString = userData['role'] as String?;
      
//       // Convert string to UserRole enum
//       if (roleString == 'admin') {
//         return UserRole.admin;
//       } else if (roleString == 'cashier') {
//         return UserRole.cashier;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
import 'package:chiroku_cafe/shared/models/auth_error_model.dart';
import 'package:chiroku_cafe/utils/enums/user_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInRepositories {
  final supabase = Supabase.instance.client;

  Future<UserRole> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw AuthErrorModel.unknownError();
      }

      // Get user profile to determine role
      final profile = await supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final roleString = profile['role'] as String;

      // Convert string to UserRole enum
      return UserRole.values.firstWhere(
        (role) => role.name.toLowerCase() == roleString.toLowerCase(),
        orElse: () => UserRole.cashier,
      );
    } on AuthException catch (e) {
      throw AuthErrorModel.unknownError();
    } catch (e) {
      throw AuthErrorModel.unknownError();
    }
  }
}