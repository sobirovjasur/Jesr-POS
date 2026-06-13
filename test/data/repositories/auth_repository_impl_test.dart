import 'package:flutter_pos/core/common/result.dart';
import 'package:flutter_pos/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_pos/data/repositories/auth_repository_impl.dart';
import 'package:flutter_pos/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

// Generate mocks with: flutter pub run build_runner build
@GenerateMocks([AuthRemoteDataSourceImpl, UserModel, UserEntity])
void main() {
  late MockAuthRemoteDataSourceImpl mockRemoteDataSource;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceImpl();
    repository = AuthRepositoryImpl(authRemoteDataSource: mockRemoteDataSource);

    provideDummy<Result<UserModel>>(Result.success(data: UserModel(id: '')));
    provideDummy<Result<UserModel?>>(Result.success(data: null));
    provideDummy<Result<void>>(Result.success(data: null));
  });

  group('AuthRepositoryImpl - signUpWithPhonePassword', () {
    test('should return UserEntity on successful sign up', () async {
      final mockUserModel = MockUserModel();
      final mockUserEntity = MockUserEntity();

      when(mockUserModel.toEntity()).thenReturn(mockUserEntity);
      when(
        mockRemoteDataSource.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      ).thenAnswer((_) async => Result.success(data: mockUserModel));

      final result = await repository.signUpWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isSuccess, true);
      expect(result.data, mockUserEntity);
      verify(mockUserModel.toEntity()).called(1);
    });

    test('should return failure when remote datasource fails', () async {
      final error = Exception('Sign up failed');
      when(
        mockRemoteDataSource.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      ).thenAnswer((_) async => Result.failure(error: error));

      final result = await repository.signUpWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isFailure, true);
      expect(result.error, error);
    });

    test('should catch and return exception as failure', () async {
      final exception = Exception('Network error');
      when(
        mockRemoteDataSource.signUpWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
          name: anyNamed('name'),
        ),
      ).thenThrow(exception);

      final result = await repository.signUpWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });

  group('AuthRepositoryImpl - signInWithPhonePassword', () {
    test('should return UserEntity on successful sign in', () async {
      final mockUserModel = MockUserModel();
      final mockUserEntity = MockUserEntity();

      when(mockUserModel.toEntity()).thenReturn(mockUserEntity);
      when(
        mockRemoteDataSource.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Result.success(data: mockUserModel));

      final result = await repository.signInWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
      );

      expect(result.isSuccess, true);
      expect(result.data, mockUserEntity);
      verify(mockUserModel.toEntity()).called(1);
    });

    test('should return failure when remote datasource fails', () async {
      final error = Exception('Sign in failed');
      when(
        mockRemoteDataSource.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => Result.failure(error: error));

      final result = await repository.signInWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
      );

      expect(result.isFailure, true);
      expect(result.error, error);
    });

    test('should catch and return exception as failure', () async {
      final exception = Exception('Network error');
      when(
        mockRemoteDataSource.signInWithPhonePassword(
          phone: anyNamed('phone'),
          password: anyNamed('password'),
        ),
      ).thenThrow(exception);

      final result = await repository.signInWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
      );

      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });

  group('AuthRepositoryImpl - signOut', () {
    test('should return success on successful sign out', () async {
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.signOut();

      expect(result.isSuccess, true);
      verify(mockRemoteDataSource.signOut()).called(1);
    });

    test('should return failure when remote datasource fails', () async {
      final error = Exception('Sign out failed');
      when(mockRemoteDataSource.signOut()).thenAnswer((_) async => Result.failure(error: error));

      final result = await repository.signOut();

      expect(result.isFailure, true);
      expect(result.error, error);
    });

    test('should catch and return exception as failure', () async {
      final exception = Exception('Unexpected error');
      when(mockRemoteDataSource.signOut()).thenThrow(exception);

      final result = await repository.signOut();

      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });

  group('AuthRepositoryImpl - getCurrentUser', () {
    test('should return UserEntity when user is logged in', () async {
      final mockUserModel = MockUserModel();
      final mockUserEntity = MockUserEntity();

      when(mockUserModel.toEntity()).thenReturn(mockUserEntity);
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => Result.success(data: mockUserModel));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.data, mockUserEntity);
      verify(mockUserModel.toEntity()).called(1);
    });

    test('should return null when no user is logged in', () async {
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => Result.success(data: null));

      final result = await repository.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.data, null);
    });

    test('should return failure when remote datasource fails', () async {
      final error = Exception('Failed to get user');
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => Result.failure(error: error));

      final result = await repository.getCurrentUser();

      expect(result.isFailure, true);
      expect(result.error, error);
    });

    test('should catch and return exception as failure', () async {
      final exception = Exception('Unexpected error');
      when(mockRemoteDataSource.getCurrentUser()).thenThrow(exception);

      final result = await repository.getCurrentUser();

      expect(result.isFailure, true);
      expect(result.error, exception);
    });
  });
}
