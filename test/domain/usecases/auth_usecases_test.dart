import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_pos/domain/repositories/auth_repository.dart';
import 'package:flutter_pos/domain/usecases/auth_usecases.dart';
import 'package:flutter_pos/domain/usecases/params/auth_params.dart';
import 'package:flutter_pos/domain/usecases/params/no_param.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_usecases_test.mocks.dart';

// This will generate the mock class
@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    provideDummy<Result<UserEntity?>>(Result<UserEntity?>.success(data: null));
    provideDummy<Result<UserEntity>>(
      Result<UserEntity>.success(data: UserEntity(id: 'user123', name: 'John Doe')),
    );
    provideDummy<Result<void>>(Result<void>.success(data: null));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });

  group('SignUpWithPhonePasswordUsecase', () {
    late SignUpWithPhonePasswordUsecase usecase;

    setUp(() {
      usecase = SignUpWithPhonePasswordUsecase(mockAuthRepository);
    });

    test('should return user from repository on successful sign up', () async {
      final user = UserEntity(id: 'user123', name: 'John Doe', phone: '998901234567');
      final result = Result<UserEntity>.success(data: user);

      when(
        mockAuthRepository.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      ).thenAnswer((_) async => result);

      final response = await usecase.call(
        const SignUpParams(phone: '+998901234567', password: 'secret123', name: 'John Doe'),
      );

      expect(response, result);
      verify(
        mockAuthRepository.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      final result = Result<UserEntity>.failure(error: 'Sign up failed');

      when(
        mockAuthRepository.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      ).thenAnswer((_) async => result);

      final response = await usecase.call(
        const SignUpParams(phone: '+998901234567', password: 'secret123', name: 'John Doe'),
      );

      expect(response, result);
    });
  });

  group('SignInWithPhonePasswordUsecase', () {
    late SignInWithPhonePasswordUsecase usecase;

    setUp(() {
      usecase = SignInWithPhonePasswordUsecase(mockAuthRepository);
    });

    test('should return user from repository on successful sign in', () async {
      final user = UserEntity(id: 'user123', name: 'John Doe', phone: '998901234567');
      final result = Result<UserEntity>.success(data: user);

      when(
        mockAuthRepository.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => result);

      final response = await usecase.call(
        const SignInParams(phone: '+998901234567', password: 'secret123'),
      );

      expect(response, result);
      verify(
        mockAuthRepository.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      );
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      final result = Result<UserEntity>.failure(error: 'Sign in failed');

      when(
        mockAuthRepository.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => result);

      final response = await usecase.call(
        const SignInParams(phone: '+998901234567', password: 'secret123'),
      );

      expect(response, result);
    });
  });

  group('SignOutUsecase', () {
    late SignOutUsecase usecase;

    setUp(() {
      usecase = SignOutUsecase(mockAuthRepository);
    });

    test('should return success from repository', () async {
      final result = Result<void>.success(data: null);

      when(mockAuthRepository.signOut()).thenAnswer((_) async => result);

      final response = await usecase.call(NoParam());

      expect(response, result);
      verify(mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      final result = Result<void>.failure(error: 'Sign out failed');

      when(mockAuthRepository.signOut()).thenAnswer((_) async => result);

      final response = await usecase.call(NoParam());

      expect(response, result);
    });
  });

  group('GetCurrentUserUsecase', () {
    late GetCurrentUserUsecase usecase;

    setUp(() {
      usecase = GetCurrentUserUsecase(mockAuthRepository);
    });

    test('should return current user from repository', () async {
      final user = UserEntity(id: 'user123', name: 'John Doe', phone: '998901234567');
      final result = Result<UserEntity?>.success(data: user);

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => result);

      final response = await usecase.call(NoParam());

      expect(response, result);
      verify(mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return failure from repository', () async {
      final result = Result<UserEntity?>.failure(error: 'Failed to get user');

      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => result);

      final response = await usecase.call(NoParam());

      expect(response, result);
    });
  });
}
