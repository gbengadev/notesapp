import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/services/auth/auth_exceptions.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
        title: const Text('Register'),
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
                style: const TextStyle(color: Color.fromARGB(255, 128, 4, 4)),
                (errorText),
              ),
            ),
            FilledButton(onPressed: onPressed, child: const Text('Register')),
            OutlinedButton(
                onPressed: navigateToLoginPage,
                child: const Text('Go To Login'))
          ],
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }

  void onPressed() async {
    try {
      final email = _email.text;
      final password = _password.text;
      await AuthService.firebase().createUser(email: email, password: password);
      Navigator.of(context)
          .pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
    } on WeakPasswordException {
      setState(() {
        isVisible = true;
        errorText = 'Please enter a password of at least 8 characters';
      });
    } on EmailAlreadyInUseAuthException {
      setState(() {
        isVisible = true;
        errorText = 'Email is already in use';
      });
    } on InvalidEmailAuthException {
      setState(() {
        isVisible = true;
        errorText = 'Please enter a valid email address';
      });
    } catch (e) {
      throw GenericAuthException();
    }
  }

  void navigateToLoginPage() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(loginPageRoute, (route) => false);
  }
}
