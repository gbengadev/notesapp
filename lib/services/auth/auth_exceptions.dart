//Login exceptions
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class UserNotFoundAuthException implements Exception {}

class WrongCredentialAuthException implements Exception, FirebaseException {
  @override
  String get code => throw FirebaseException(plugin: plugin).code;

  @override
  String? get message => FirebaseException(plugin: plugin).message;

  @override
  String get plugin => throw UnimplementedError();
  @override
  StackTrace? get stackTrace => FirebaseException(plugin: plugin).stackTrace;
}

//Register
class WeakPasswordException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
