import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/views/login_view.dart';
import 'package:flutterdemoapp/views/main_view.dart';
import 'package:flutterdemoapp/views/register_view.dart';
import 'package:flutterdemoapp/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginPageRoute: (context) => const LoginView(),
      registerPageRoute: (context) => const RegisterPage(),
      mainPageRoute: (context) => const MainPage(),
      verifyEmailRoute: (context) => const VerifyEmail(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    VerifyEmail verifyEmail = new VerifyEmail();
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              print("Verified status: " + verifyEmail.isVerified().toString());
              if (verifyEmail.isVerified()) {
                return const MainPage();
              } else {
                return const VerifyEmail();
              }
            } else {
              return const LoginView();
            }
          }
          return const CircularProgressIndicator();
        });
  }
}
