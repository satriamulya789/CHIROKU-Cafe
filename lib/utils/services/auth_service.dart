import 'package:chiroku_cafe/feature/sign_in/models/error_sign_in_model.dart';
import 'package:chiroku_cafe/feature/sign_in/models/sign_in_model.dart';
import 'package:chiroku_cafe/feature/sign_in/repositories/sign_in_auth_repositories.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthService {
  final AuthRepository _repo =
      AuthRepository(Supabase.instance.client);

  Future<UserModel> signIn(UserModel user, String password, {required email}) async {
    try {
      return await _repo.signIn(user, password, email: email);
    } catch (e) {
      throw SignInError.fromException(e);
    }
  }

  Future currentUser() async {}
}

//   Future<UserModel> register(UserModel user) async {
//     try {
//       return await _repo.register(user);
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   Future<UserModel?> currentUser() async {
//     try {
//       return await _repo.currentUserProfile();
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   Future<UserModel?> getUserById(String id) async {
//     try {
//       return await _repo.getUserById(id);
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   Future<UserModel> updateUserProfile(UserModel user) async {
//     try {
//       return await _repo.updateUserProfile(user);
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   Future<void> forgotPassword(String email) async {
//     try {
//       await _repo.forgotPassword(email);
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   Future<void> signOut() async {
//     try {
//       await _repo.signOut();
//     } catch (e) {
//       throw SignInError.fromException(e);
//     }
//   }

//   void redirect(UserModel user) {
//     if (user.isAdmin) {
//       Get.offAllNamed('/admin');
//     } else {
//       Get.offAllNamed('/cashier');
//     }
//   }
// }
