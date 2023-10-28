import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/services/auth/auth_exceptions.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';

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
    return Scaffold(
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
              controller: _password,
            ),
            Visibility(
              visible: isVisible,
              child: Text(
                style: TextStyle(color: Color.fromARGB(255, 128, 4, 4)),
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
    );
  }

  void onPressed() async {
    try {
      final email = _email.text;
      final password = _password.text;
      await AuthService.firebase().login(email: email, password: password);
      // ignore: use_build_context_synchronously
      Navigator.of(context)
          .pushNamedAndRemoveUntil(mainPageRoute, (route) => false);
    } on WrongCredentialAuthException catch (_) {
      setState(() {
        isVisible = true;
        errorText = 'Username and password combination is wrong';
      });
      //  print("o " + e.code);
      //print(e.message);
    } catch (e) {
      setState(() {
        isVisible = true;
        errorText = 'Login failed, Please try again later.';
      });

      print(e);
    }
  }

  void navigateToRegisterPage() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(registerPageRoute, (route) => false);
  }
}
