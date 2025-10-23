import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:simple_paint/features/auth/widgets/auth_input_field.dart';
import 'package:simple_paint/features/utils/utils.dart';

import '../../core/const/app_colors.dart';
import '../../core/const/app_fonts.dart';
import '../../domain/errors/auth_errors.dart';
import '../viewmodels/user.dart';
import '../../core/widgets/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordRepeatController =
      TextEditingController();
  bool _isLoading = false;

  late final _userModel = ref.read(userModelProvider);

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    final name = nameController.text.trim();
    final email = loginController.text.trim();
    final password = passwordController.text.trim();
    final passwordRepeat = passwordRepeatController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordRepeat.isEmpty) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Нужно заполнить все поля',
      );
      return;
    }

    if (!Utils.isValidEmail(email)) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Введите корректный email',
      );
      return;
    }

    if (password.length < 6) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Пароль должен содержать минимум 6 символов',
      );
      return;
    }

    if (password != passwordRepeat) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Пароли не совпадают',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Utils.showLoadingDialog(context: context, message: 'Регистрация');

    try {
      await _userModel.signUp(email: email, password: password, name: name);

      Utils.hideLoadingDialog(context);

      final user = ref.read(userStateProvider);

      if (user == null && context.mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Ошибка',
          message: 'Произошла неизвестная ошибка. Попробуйте еще раз.',
        );
      }
    } on SupabaseAuthError catch (e) {
      Utils.hideLoadingDialog(context);
      if (mounted) {
        Utils.showAuthError(context: context, error: e);
      }
    } catch (e) {
      Utils.hideLoadingDialog(context);
      if (mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Ошибка',
          message: 'Произошла неизвестная ошибка. Попробуйте еще раз.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context);

    return KeyboardDismisser(
      gestures: [GestureType.onTap],
      child: CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/bg.png',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: insets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height,
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Spacer(flex: 3),
                      Text('Регистрация', style: AppFonts.authHeadline),
                      SizedBox(height: 20),
                      AuthInputField(
                        controller: nameController,
                        placeholder: 'Введите ваше имя',
                        label: 'Имя',
                        inputFormatters: [],
                      ),
                      SizedBox(height: 20),
                      AuthInputField(
                        controller: loginController,
                        placeholder: 'Введите электронную почту',
                        label: 'e-mail',
                        inputFormatters: [],
                      ),
                      Container(
                        width: double.infinity,
                        height: 0.5,
                        color: AppColors.greyDarkColor,
                        margin: EdgeInsetsGeometry.symmetric(vertical: 20),
                      ),
                      AuthInputField(
                        controller: passwordController,
                        placeholder: '8-16 символов',
                        label: 'Пароль',
                        inputFormatters: [],
                      ),
                      SizedBox(height: 20),
                      AuthInputField(
                        controller: passwordRepeatController,
                        placeholder: '8-16 символов',
                        label: 'Подтверждение пароля',
                        inputFormatters: [],
                      ),
                      Spacer(flex: 2),
                      AppButton(
                        label: 'Зарегистрироваться',
                        onPressed: _isLoading ? null : _handleRegister,
                        textColor: AppColors.whiteColor,
                        gradient: AppColors.purpleButtonGradient,
                      ),
                      SizedBox(height: 20),
                      AppButton(
                        label: 'Авторизация',
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.pushReplacement('/login');
                              },
                        textColor: AppColors.blackColor,
                        bgColor: AppColors.whiteColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
