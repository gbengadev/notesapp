import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';

void navigateToLoginPage(BuildContext context) {
  // return const LoginView();
  Navigator.of(context).pushNamed(loginPageRoute);
}
