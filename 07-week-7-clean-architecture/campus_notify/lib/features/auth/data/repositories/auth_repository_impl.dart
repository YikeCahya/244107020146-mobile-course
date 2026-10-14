import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../token_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.tokenStore,
    required this.signIn,
    required this.renew,
  });

  final TokenStore tokenStore;
  final Future<AuthSession> Function(String email, String password) signIn;
  final Future<String> Function(String refreshToken) renew;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await signIn(email, password);
      await tokenStore.save(access: session.access, refresh: session.refresh);
      return (session: session, failure: null);
    } catch (e) {
      return (session: null, failure: LocalFailure('Gagal login. Coba lagi.'));
    }
  }

  @override
  Future<String> refresh(String refreshToken) => renew(refreshToken);

  @override
  Future<bool> hasSession() async => (await tokenStore.readAccess()) != null;

  @override
  Future<void> logout() => tokenStore.clear();
}