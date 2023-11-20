import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_bloc.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_event.dart';
import 'package:flutterdemoapp/services/auth/bloc/auth_state.dart';
import 'package:flutterdemoapp/services/crud/notes_service.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  bool isVerified() {
    return _VerifyEmailState().isVerified;
  }

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  bool isVerified = false;
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateVerification) {
          logger.d('Verification loading state: ${state.isLoading}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("Verify Email"),
        ),
        body: Column(
          children: [
            const Text("Please click the button below to verify your email"),
            TextButton(
                onPressed: () {
                  setState(() {
                    isVerified = true;
                    isVisible = true;
                  });
                },
                child: const Text('Verify Email')),
            Visibility(
              visible: isVisible,
              child: Column(
                children: [
                  const Text(
                    style: TextStyle(color: Color.fromARGB(255, 1, 71, 3)),
                    ("Email successfully verified!!"),
                  ),
                  FilledButton(
                      onPressed: goToLoginPage,
                      child: const Text('Go to Login'))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void goToLoginPage() {
    context.read<AuthBloc>().add(const AuthEventLogout());
  }
}
