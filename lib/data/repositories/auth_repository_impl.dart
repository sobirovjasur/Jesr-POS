import '../../../../core/common/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSourceImpl authRemoteDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
  });

  @override
  Future<Result<UserEntity>> signUpWithPhonePassword({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      final res = await authRemoteDataSource.signUpWithPhonePassword(
        phone: phone,
        password: password,
        name: name,
      );
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserEntity>> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await authRemoteDataSource.signInWithPhonePassword(
        phone: phone,
        password: password,
      );
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data!.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final res = await authRemoteDataSource.signOut();
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final res = await authRemoteDataSource.getCurrentUser();
      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: res.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
