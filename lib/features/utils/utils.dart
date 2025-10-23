import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/errors/auth_errors.dart';

class Utils {
  static void showCupertinoAlert({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Закрыть'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static void showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Закрыть'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onOk,
  }) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('ОК'),
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
          ),
        ],
      ),
    );
  }

  static void showAuthErrorDialog({
    required BuildContext context,
    required AuthException error,
  }) {
    final authError = SupabaseAuthErrorMapper.mapAuthException(error);
    showErrorDialog(
      context: context,
      title: authError.title,
      message: authError.message,
    );
  }

  static void showAuthError({
    required BuildContext context,
    required SupabaseAuthError error,
  }) {
    showErrorDialog(
      context: context,
      title: error.title,
      message: error.message,
    );
  }

  static void showLoadingDialog({
    required BuildContext context,
    String message = '',
  }) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
