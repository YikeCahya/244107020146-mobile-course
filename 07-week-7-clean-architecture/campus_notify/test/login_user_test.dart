import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure});

  final Failure? failure;
  int loginCalls = 0;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    if (failure != null) return (session: null, failure: failure);
    return (
      session: AuthSession(access: 'a-$email', refresh: 'r-$email'),
      failure: null,
    );
  }

  @override
  Future<String> refresh(String refreshToken) => throw UnimplementedError();

  @override
  Future<bool> hasSession() => throw UnimplementedError();

  @override
  Future<void> logout() => throw UnimplementedError();
}

void main() {
  test('email tanpa @ ditolak dan repository tidak dipanggil', () async {
    final repo = FakeAuthRepository();

    final result = await LoginUser(repo)
        .call(email: 'ike.test.com', password: '123456');

    expect(result.session, isNull);
    expect(result.failure, isA<ValidationFailure>());
    expect(result.failure!.message, 'Email atau kata sandi tidak valid');
    expect(repo.loginCalls, 0);
  });

  test('password kurang dari 6 karakter ditolak', () async {
    final repo = FakeAuthRepository();

    final result =
        await LoginUser(repo).call(email: 'ike@test.com', password: '123');

    expect(result.failure, isA<ValidationFailure>());
    expect(repo.loginCalls, 0);
  });

  test('input valid meneruskan sesi dari repository', () async {
    final repo = FakeAuthRepository();

    final result = await LoginUser(repo)
        .call(email: 'ike@test.com', password: '123456');

    expect(result.failure, isNull);
    expect(result.session!.access, 'a-ike@test.com');
    expect(repo.loginCalls, 1);
  });

  test('failure dari repository diteruskan tanpa melempar', () async {
    final repo = FakeAuthRepository(failure: const LocalFailure('disk penuh'));

    final result = await LoginUser(repo)
        .call(email: 'ike@test.com', password: '123456');

    expect(result.session, isNull);
    expect(result.failure, isA<LocalFailure>());
  });
}