import '../../../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<UserEntity>> signUpWithPhonePassword({
    required String phone,
    required String password,
    required String name,
  });

  Future<Result<UserEntity>> signInWithPhonePassword({
    required String phone,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<UserEntity?>> getCurrentUser();
}
