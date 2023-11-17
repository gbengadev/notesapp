import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/services/auth/auth_exceptions.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:flutterdemoapp/utility-methods/dialogs.dart';
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
  CloseDialog? _closedDialogHandle;
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
          final closeDialog = _closedDialogHandle;
          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closedDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closedDialogHandle = showLoadingDialog(
              context: context,
              text: 'Loading...',
            );
          }
          logger.d('Exception is ${state.exception}');
          if (state.exception is UserNotFoundAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'User does not exist';
            });
          } else if (state.exception is WrongCredentialAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'Username and password combination is wrong';
            });
          } else if (state.exception is GenericAuthException) {
            setState(() {
              isVisible = true;
              errorText = 'Login failed, Please try again later.';
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Login'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(hintText: 'Enter your email'),
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
                  style: const TextStyle(color: Color.fromARGB(255, 128, 4, 4)),
                  (errorText),
                ),
              ),
              FilledButton(onPressed: onPressed, child: const Text('Sign In')),
              OutlinedButton(
                  onPressed: navigateToRegisterPage,
                  child: const Text('Register an Account'))
            ],
          ),
        ),
      ),
    );
  }

  void onPressed() async {
    final email = _email.text;
    final password = _password.text;
    //try {
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
