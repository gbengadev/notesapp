import 'package:flutter/material.dart';
import 'package:flutterdemoapp/extensions/buildcontext/loc.dart';

typedef DialogOptionBuilder<T> = Map<String, T?> Function();

//Create generic dialog to be customized
//for different dialogs within the application
Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle) {
          final T value = options[optionTitle];
          return TextButton(
            onPressed: () {
              if (value != null) {
                Navigator.of(context).pop(value);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showCustomDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {
      context.loc.ok: null,
    },
  );
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showCustomDialog<bool>(
    context: context,
    title: context.loc.logout_button,
    content: context.loc.logout_dialog_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.logout_button: true,
    },
    //return false if the value is null
  ).then((value) => value ?? false);
}

Future<bool> showDeleteDialog(BuildContext context) {
  return showCustomDialog<bool>(
    context: context,
    title: context.loc.delete,
    content: context.loc.delete_note_prompt,
    optionsBuilder: () => {
      context.loc.cancel: false,
      context.loc.yes: true,
    },
    //return false if the value is null
  ).then((value) => value ?? false);
}

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showCustomDialog(
      context: context,
      title: context.loc.sharing,
      content: context.loc.cannot_share_empty_note_prompt,
      optionsBuilder: () => {
            context.loc.ok: null,
          });
}

typedef CloseDialog = void Function();

CloseDialog showLoadingDialog({
  required BuildContext context,
  required String text,
}) {
  final dialog = AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 10.0),
        Text(text)
      ],
    ),
  );

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => dialog,
  );

  return () => Navigator.of(context).pop();
}
