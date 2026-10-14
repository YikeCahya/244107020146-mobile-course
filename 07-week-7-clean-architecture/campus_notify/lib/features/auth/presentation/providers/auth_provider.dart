import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_mock_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';
import '../../../../core/failures.dart';

// Data layer
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    tokenStore: ref.watch(tokenStoreProvider),
    signIn: mockSignIn,
    renew: mockRenew,
  );
});

// Domain layer: use case menerima abstraksi
final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

// Presentation: state untuk UI
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(authRepositoryProvider).hasSession();

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref
        .read(loginUserProvider)
        .call(email: email, password: password);
    if (result.failure != null) {
      state = AsyncError(
        FailureException(result.failure!),
        StackTrace.current,
      );
    } else {
      state = const AsyncData(true);
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidateSelf();
  }
}