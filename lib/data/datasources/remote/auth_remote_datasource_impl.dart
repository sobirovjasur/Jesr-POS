import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/common/result.dart';
import '../../../core/constants/constants.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_datasource.dart';

/// Phone + password authentication backed by Firebase email/password.
///
/// Each phone number maps to a deterministic synthetic email
/// (`<digits>@<domain>`), so Firebase's email/password provider can support a
/// password-based login while the user only ever sees their phone number.
class AuthRemoteDataSourceImpl implements AuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
  });

  @override
  Future<Result<UserModel>> signUpWithPhonePassword({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: _emailFromPhone(phone),
        password: password,
      );

      final user = credential.user;
      if (user == null) return Result.failure(error: 'User data is null after sign-up.');

      await user.updateDisplayName(name);

      final model = UserModel.fromFirebaseUser(user, authProvider: AuthProvider.phone)
        ..name = name
        ..phone = _normalizePhone(phone)
        ..email = null;

      return Result.success(data: model);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(error: _mapAuthError(e));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel>> signInWithPhonePassword({
    required String phone,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: _emailFromPhone(phone),
        password: password,
      );

      final user = credential.user;
      if (user == null) return Result.failure(error: 'User data is null after sign-in.');

      final model = UserModel.fromFirebaseUser(user, authProvider: AuthProvider.phone)
        ..phone = _normalizePhone(phone)
        ..email = null;

      return Result.success(data: model);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Result.failure(error: _mapAuthError(e));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await firebaseAuth.signOut();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      return Result.success(
        data: firebaseUser != null ? UserModel.fromFirebaseUser(firebaseUser, authProvider: AuthProvider.phone) : null,
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  /// Strips every non-digit so `+998 10 000 33 33` becomes `998100003333`.
  String _normalizePhone(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  String _emailFromPhone(String phone) => '${_normalizePhone(phone)}@${Constants.phoneAuthEmailDomain}';

  String _mapAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect phone number or password. Please try again.';
      case 'email-already-in-use':
        return 'This phone number is already registered.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'invalid-email':
        return 'Invalid phone number.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
