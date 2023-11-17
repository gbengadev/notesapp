//This acts as the output for the Auth bloc
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterdemoapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

class AuthStateVerification extends AuthState {
  const AuthStateVerification();
}

//To produce various mutations of this state
//(e.g isLoading=false/true and null exception), we use an equatable
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggingIn extends AuthState {
  final Exception? exception;
  const AuthStateLoggingIn(this.exception);
}

class AuthStateRegistering extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateRegistering(
      {required this.exception, required this.isLoading});

  @override
  List<Object?> get props => [exception, isLoading];
}
