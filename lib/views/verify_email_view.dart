import 'package:flutter/material.dart';
import 'package:flutterdemoapp/utility-methods/util.dart';

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
    return Scaffold(
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
                FilledButton(onPressed: toLoginPage, child: Text('Go to Login'))
              ],
            ),
          )
        ],
      ),
    );
  }

  void toLoginPage() {
    navigateToLoginPage(context);
  }
}
