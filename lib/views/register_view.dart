import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/style.dart';
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
              errorText = 'Please enter a password of at least 8 characters';
            });
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'Email is already in use';
            });
          } else if (state.exception is GenericAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'Registration Failed. Please try again.';
            });
          } else if (state.exception is InvalidEmailAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'Please enter a valid email address';
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(pagePadding),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Enter your email'),
                  controller: _email,
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(hintText: 'Enter your password'),
                  obscureText: true,
                  controller: _password,
                ),
                Visibility(
                  visible: isVisible,
                  child: Text(
                    style:
                        const TextStyle(color: Color.fromARGB(255, 128, 4, 4)),
                    (errorText),
                  ),
                ),
                FilledButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                OutlinedButton(
                    onPressed: navigateToLoginPage,
                    child: const Text('Go To Login'))
              ],
            ),
          ),
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

  void _register() async {
    final email = _email.text;
    final password = _password.text;
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
