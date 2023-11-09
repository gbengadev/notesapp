import 'package:flutter/material.dart';
import 'package:flutterdemoapp/constants/routes.dart';

//Navigate to login page
void navigateToLoginPage(BuildContext context) {
  // return const LoginView();
  Navigator.of(context).pushNamed(loginPageRoute);
}

//Parse argument between pages
extension GetArgument on BuildContext {
  T? getArgument<T>() {
    //'this' refers to the build context
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
