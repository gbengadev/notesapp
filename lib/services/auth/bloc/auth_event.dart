//This serves as thr input to the Auth bloc

import 'package:flutter/foundation.dart';
import 'package:flutterdemoapp/services/auth/auth_provider.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  final AuthProvider provider;

  const AuthEventLogin(this.email, this.password, this.provider);
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
}

class AuthEventLogout extends AuthEvent {
  const AuthEventLogout();
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventShouldLogin extends AuthEvent {
  const AuthEventShouldLogin();
}
