import '../../domain/entities/auth_session.dart';

// GANTI dengan FirebaseAuth / panggilan Dio saat backend siap.
Future<AuthSession> mockSignIn(String email, String password) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return AuthSession(
    access: 'mock-access-for-$email',
    refresh: 'mock-refresh-for-$email',
  );
}

Future<String> mockRenew(String refreshToken) async {
  await Future.delayed(const Duration(milliseconds: 300));
  if (refreshToken.isEmpty) throw Exception('Refresh token hilang');
  return 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}';
}