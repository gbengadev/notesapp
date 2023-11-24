import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/style.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';
import 'package:flutterdemoapp/services/auth/auth_exceptions.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // CloseDialog? _closedDialogHandle;
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

//
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.register_error_weak_password;
            });
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.register_error_email_already_in_use;
            });
          } else if (state.exception is GenericAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.register_error_generic;
            });
          } else if (state.exception is InvalidEmailAuthException) {
            setState(() {
              isVisible = true;
              errorText = context.loc.register_error_invalid_email;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(context.loc.register),
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
                  FilledButton(
                    onPressed: _register,
                    child: Text(context.loc.register),
                  ),
                  OutlinedButton(
                      onPressed: navigateToLoginPage,
                      child: Text(context.loc.register_view_already_registered))
                ],
              ),
            ),
          ),
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _register() async {
    final email = _email.text;
    final password = _password.text;
    if (email.isEmpty) {
      setState(() {
        isVisible = true;
        errorText = 'Please enter you email address';
      });
      return;
    } else if (password.isEmpty) {
      setState(() {
        isVisible = true;
        errorText = 'Please enter you password';
      });
      return;
    }
    context.read<AuthBloc>().add(
          AuthEventRegister(email, password),
        );
  }

  void navigateToLoginPage() {
    context.read<AuthBloc>().add(
          const AuthEventLogout(),
        );
  }
}
