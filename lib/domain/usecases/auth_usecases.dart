import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'params/auth_params.dart';
import 'params/no_param.dart';

class SignUpWithPhonePasswordUsecase extends Usecase<Result, SignUpParams> {
  SignUpWithPhonePasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(SignUpParams params) async => _authRepository.signUpWithPhonePassword(
    phone: params.phone,
    password: params.password,
    name: params.name,
  );
}

class SignInWithPhonePasswordUsecase extends Usecase<Result, SignInParams> {
  SignInWithPhonePasswordUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(SignInParams params) async => _authRepository.signInWithPhonePassword(
    phone: params.phone,
    password: params.password,
  );
}

class SignOutUsecase extends Usecase<Result, NoParam> {
  SignOutUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<void>> call(NoParam params) async => _authRepository.signOut();
}

class GetCurrentUserUsecase extends Usecase<Result, NoParam> {
  GetCurrentUserUsecase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<Result<UserEntity?>> call(NoParam params) async => _authRepository.getCurrentUser();
}
