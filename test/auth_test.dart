import 'package:flutterdemoapp/services/auth/auth_provider.dart';
import 'package:flutterdemoapp/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Initialized should be false at start', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot logout if not initialized', () {
      expect(provider.logOut(), throwsA(isA<NotInitializedException>()));
    });
    test('Validate that a user can be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('Validate that a user can be initialized within 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Validate that a user can login', () async {
      final user =
          await provider.login(email: 'myuser', password: 'mypassword');
      expect(provider.currentUser, user);
    });
    test('Validate that a user can logout', () async {
      await provider.login(email: 'myuser', password: 'mypassword');
      await provider.logOut();
      expect(provider.currentUser, isNull);
    });

    test('Validate that a user can be created', () async {
      final user =
          await provider.createUser(email: 'myuser', password: 'mypassword');
      expect(provider.currentUser, user);
    });
  });
}

class NotInitializedException implements Exception {}

class UserNotFoundException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    const user = AuthUser(isEmailVerified: false, email: 'xg@b.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() {
    throw UnimplementedError();
  }
}
