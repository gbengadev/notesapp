import 'package:firebase_core/firebase_core.dart';
import 'package:flutterdemoapp/firebase_options.dart';

import 'auth_user.dart';
import 'auth_exceptions.dart';
import 'auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;

class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null)
        return user;
      else
        throw UserNotLoggedInAuthException();
      // return user != null ? user : throw UserNotLoggedInAuthException();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  Future<void> logOut() async {
    final user = currentUser;
    if (user != null)
      await FirebaseAuth.instance.signOut();
    else
      throw UserNotLoggedInAuthException();
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null)
        return user;
      else
        throw UserNotLoggedInAuthException();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-login-credentials':
          throw WrongCredentialAuthException();
        default:
          throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() {
    throw UnimplementedError();
  }
}
