import '../../../../core/failures.dart';
import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  });
  Future<String> refresh(String refreshToken);
  Future<bool> hasSession();
  Future<void> logout();
}