import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_pos/data/datasources/remote/auth_remote_datasource_impl.dart';
import 'package:flutter_pos/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_datasource_test.mocks.dart';

@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.UserCredential,
  firebase_auth.User,
])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    dataSource = AuthRemoteDataSourceImpl(firebaseAuth: mockFirebaseAuth);
  });

  void stubUser() {
    when(mockUser.uid).thenReturn('test_uid');
    when(mockUser.email).thenReturn('998901234567@pocketpos.app');
    when(mockUser.displayName).thenReturn('Test User');
    when(mockUser.photoURL).thenReturn(null);
    when(mockUser.phoneNumber).thenReturn(null);
    when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
  }

  group('signUpWithPhonePassword', () {
    test('creates a user and returns a UserModel with normalized phone and name', () async {
      stubUser();
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await dataSource.signUpWithPhonePassword(
        phone: '+998 90 123 45 67',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isSuccess, true);
      expect(result.data, isA<UserModel>());
      expect(result.data?.id, 'test_uid');
      expect(result.data?.phone, '998901234567');
      expect(result.data?.name, 'Test User');
      expect(result.data?.email, null);
      verify(mockUser.updateDisplayName('Test User')).called(1);
    });

    test('returns failure when user is null after sign-up', () async {
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(null);

      final result = await dataSource.signUpWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isFailure, true);
      expect(result.error, 'User data is null after sign-up.');
    });

    test('maps email-already-in-use to a friendly message', () async {
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(firebase_auth.FirebaseAuthException(code: 'email-already-in-use'));

      final result = await dataSource.signUpWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
        name: 'Test User',
      );

      expect(result.isFailure, true);
      expect(result.error, 'This phone number is already registered.');
    });
  });

  group('signInWithPhonePassword', () {
    test('signs in and returns a UserModel with normalized phone', () async {
      stubUser();
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);

      final result = await dataSource.signInWithPhonePassword(
        phone: '+998901234567',
        password: 'secret123',
      );

      expect(result.isSuccess, true);
      expect(result.data?.id, 'test_uid');
      expect(result.data?.phone, '998901234567');
    });

    test('maps invalid-credential to a friendly message', () async {
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(firebase_auth.FirebaseAuthException(code: 'invalid-credential'));

      final result = await dataSource.signInWithPhonePassword(
        phone: '+998901234567',
        password: 'wrongpass',
      );

      expect(result.isFailure, true);
      expect(result.error, 'Incorrect phone number or password. Please try again.');
    });
  });

  group('signOut', () {
    test('successfully signs out from Firebase', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      final result = await dataSource.signOut();

      expect(result.isSuccess, true);
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('returns failure when sign-out throws', () async {
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Firebase sign-out failed'));

      final result = await dataSource.signOut();

      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
    });
  });

  group('getCurrentUser', () {
    test('returns UserModel when a user is signed in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('998901234567@pocketpos.app');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.photoURL).thenReturn(null);
      when(mockUser.phoneNumber).thenReturn(null);

      final result = await dataSource.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.data?.id, 'test_uid');
    });

    test('returns null when no user is signed in', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      final result = await dataSource.getCurrentUser();

      expect(result.isSuccess, true);
      expect(result.data, null);
    });

    test('returns failure when getting current user throws', () async {
      when(mockFirebaseAuth.currentUser).thenThrow(Exception('Failed to get current user'));

      final result = await dataSource.getCurrentUser();

      expect(result.isFailure, true);
      expect(result.error, isA<Exception>());
    });
  });
}
