import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/style.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';
import 'package:flutterdemoapp/services/auth/auth_exceptions.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool isVisible = false;
  String errorText = '';

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          logger.d('Login Exception is ${state.exception}');
          if (state.exception is UserNotFoundAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.login_error_cannot_find_user;
            });
          } else if (state.exception is WrongCredentialAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.login_error_wrong_credentials;
            });
          } else if (state.exception is GenericAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.login_error_auth_error;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(context.loc.login),
        ),
        body: Padding(
          padding: const EdgeInsets.all(pagePadding),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: context.loc.email_text_field_placeholder),
                    controller: _email,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        hintText: context.loc.password_text_field_placeholder),
                    obscureText: true,
                    controller: _password,
                  ),
                  Visibility(
                    visible: isVisible,
                    child: Text(
                      style: const TextStyle(
                          color: Color.fromARGB(255, 128, 4, 4)),
                      (errorText),
                    ),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: Center(
                          child: FilledButton(
                            onPressed: _login,
                            child: Text(context.loc.login),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: navigateToRegisterPage,
                            child: Text(
                                textAlign: TextAlign.end,
                                context.loc.login_view_not_registered_yet),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    final email = _email.text;
    final password = _password.text;
    // Validate email and password fields
    if (email.isEmpty) {
      setState(() {
        isVisible = true;
        errorText = 'Please enter you email address';
        logger.d('no email');
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        isVisible = true;
        errorText = 'Please enter you password';
        logger.d('no password');
      });
      return;
    }
    //Read authbloc from build context
    context.read<AuthBloc>().add(
          AuthEventLogin(email, password),
        );
  }

  void navigateToRegisterPage() {
    context.read<AuthBloc>().add(
          const AuthEventShouldRegister(),
        );
  }
}
