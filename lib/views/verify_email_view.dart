import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';
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
          title: Text(context.loc.verify_email),
        ),
        body: Column(
          children: [
            Text(context.loc.verify_email_view_prompt),
            TextButton(
                onPressed: () {
                  setState(() {
                    isVerified = true;
                    isVisible = true;
                  });
                },
                child: Text(context.loc.verify_email)),
            Visibility(
              visible: isVisible,
              child: Column(
                children: [
                  Text(
                    style:
                        const TextStyle(color: Color.fromARGB(255, 1, 71, 3)),
                    (context.loc.verify_email_success),
                  ),
                  FilledButton(
                    onPressed: goToLoginPage,
                    child: Text(context.loc.back_to_login),
                  )
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
