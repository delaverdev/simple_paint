import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthError {
  final String title;
  final String message;
  final String? originalMessage;

  const SupabaseAuthError({
    required this.title,
    required this.message,
    this.originalMessage,
  });

  @override
  String toString() => message;
}

//Маппим супабейз ерроры в сообщения юзеру
class SupabaseAuthErrorMapper {
  static const Map<String, SupabaseAuthError> _errorMap = {
    'User already registered': SupabaseAuthError(
      title: 'Пользователь уже существует',
      message: 'Пользователь с таким email уже зарегистрирован',
    ),
    'Password should be at least 6 characters': SupabaseAuthError(
      title: 'Слабый пароль',
      message: 'Пароль должен содержать минимум 6 символов',
    ),
    'Invalid email': SupabaseAuthError(
      title: 'Неверный email',
      message: 'Неверный формат email',
    ),

    'Invalid login credentials': SupabaseAuthError(
      title: 'Ошибка входа',
      message: 'Неверный email или пароль',
    ),
    'Email not confirmed': SupabaseAuthError(
      title: 'Email не подтвержден',
      message:
          'Email не подтвержден. Проверьте почту и перейдите по ссылке для подтверждения',
    ),
    'Too many requests': SupabaseAuthError(
      title: 'Слишком много попыток',
      message: 'Слишком много попыток входа. Попробуйте позже',
    ),
  };

  static SupabaseAuthError mapAuthException(AuthException exception) {
    final messageError = _errorMap[exception.message];
    if (messageError != null) {
      return SupabaseAuthError(
        title: messageError.title,
        message: messageError.message,
        originalMessage: exception.message,
      );
    }

    final statusError = _errorMap[exception.statusCode ?? ''];
    if (statusError != null) {
      return SupabaseAuthError(
        title: statusError.title,
        message: statusError.message,
        originalMessage: exception.message,
      );
    }

    return SupabaseAuthError(
      title: 'Ошибка',
      message: 'Произошла неизвестная ошибка. Попробуйте позже.',
      originalMessage: exception.message,
    );
  }

  static SupabaseAuthError mapException(Exception exception) {
    final message = exception.toString().toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return SupabaseAuthError(
        title: 'Ошибка сети',
        message: 'Проверьте подключение к интернету',
        originalMessage: exception.toString(),
      );
    }

    return SupabaseAuthError(
      title: 'Ошибка',
      message: 'Произошла неизвестная ошибка. Попробуйте позже.',
      originalMessage: exception.toString(),
    );
  }
}
