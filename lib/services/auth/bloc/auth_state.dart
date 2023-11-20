//This acts as the output for the Auth bloc
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterdemoapp/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({required this.isLoading, this.loadingText = 'Please wait'});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required bool isLoading})
      : super(isLoading: isLoading);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn({
    required isLoading,
    required this.user,
  }) : super(isLoading: isLoading);
}

class AuthStateVerification extends AuthState {
  const AuthStateVerification({
    required isLoading,
  }) : super(isLoading: isLoading);
}

//To produce various mutations of this state
//(e.g isLoading=false/true and null exception), we use an equatable
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateLoggedOut({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateLoggingIn extends AuthState {
  final Exception? exception;
  const AuthStateLoggingIn({
    required isLoading,
    required this.exception,
  }) : super(isLoading: isLoading);
}

class AuthStateRegistering extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthStateRegistering({
    required this.exception,
    required bool isLoading,
    String? loadingText,
  }) : super(isLoading: isLoading, loadingText: loadingText);

  @override
  List<Object?> get props => [exception, isLoading];
}
