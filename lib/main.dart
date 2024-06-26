import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/constants/routes.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';
import 'package:flutterdemoapp/services/auth/auth_provider.dart';
import 'package:flutterdemoapp/services/auth/auth_service.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:flutterdemoapp/services/auth/firebase_auth_provider.dart';
import 'package:flutterdemoapp/utility-methods/loading_screens/loading_screen.dart';
import 'package:flutterdemoapp/views/login_view.dart';
import 'package:flutterdemoapp/views/main_view.dart';
import 'package:flutterdemoapp/views/notes/new_noteview.dart';
import 'package:flutterdemoapp/views/register_view.dart';
import 'package:flutterdemoapp/views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  AuthProvider authProvider = AuthService.firebase().provider;
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: BlocProvider<AuthBloc>(
      // create: (context) =>  AuthBloc(FirebaseAuthProvider()),
      create: (context) => AuthBloc(authProvider),
      child: const HomePage(),
    ),
    routes: {
      createViewNoteRoute: (context) => const CreateUpdateNotePage(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Retrieve authbloc from context
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? context.loc.loadingPrompt,
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (context, state) {
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
