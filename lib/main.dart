import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:flutterdemoapp/services/auth/firebase_auth_provider.dart';
import 'package:flutterdemoapp/views/login_view.dart';
import 'package:flutterdemoapp/views/main_view.dart';
import 'package:flutterdemoapp/views/notes/new_noteview.dart';
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
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      verifyEmailRoute: (context) => const VerifyEmail(),
      createViewNoteRoute: (context) => const CreateUpdateNotePage(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //   const verifyEmail = VerifyEmail();
    //Retrieve authbloc from context
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthStateLoggedIn) {
        return const MainPage();
      } else if (state is AuthStateVerification) {
        return const VerifyEmail();
      } else if (state is AuthStateLoggedOut) {
        return const LoginView();
      } else if (state is AuthStateRegistering) {
        return const RegisterPage();
      } else {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      }
    });
  }
}
