import '../../../core/common/result.dart';
import '../../models/user_model.dart';

abstract class AuthDataSource {
  /// Registers a new user with a phone number + password.
  ///
  /// The phone number is used as the login identifier; [name] is stored on the
  /// account profile.
  Future<Result<UserModel>> signUpWithPhonePassword({
    required String phone,
    required String password,
    required String name,
  });

  /// Authenticates an existing user with a phone number + password.
  Future<Result<UserModel>> signInWithPhonePassword({
    required String phone,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<UserModel?>> getCurrentUser();
}
