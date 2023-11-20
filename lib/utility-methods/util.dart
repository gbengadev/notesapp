import 'package:flutter/material.dart';

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
