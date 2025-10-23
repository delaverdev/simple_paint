import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:simple_paint/domain/errors/auth_errors.dart';
import 'package:simple_paint/features/auth/widgets/auth_input_field.dart';
import 'package:simple_paint/features/utils/utils.dart';
import 'package:simple_paint/features/viewmodels/user.dart';
import 'package:simple_paint/core/widgets/app_button.dart';

import '../../core/const/app_colors.dart';
import '../../core/const/app_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  late final _userModel = ref.read(userModelProvider);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = loginController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Нужно заполнить все поля.',
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

    setState(() {
      _isLoading = true;
    });

    Utils.showLoadingDialog(context: context, message: 'Авторизация');

    try {
      await _userModel.signIn(email: email, password: password);

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
      if (mounted) {
        Utils.hideLoadingDialog(context);
        Utils.showAuthError(context: context, error: e);
      }
    } catch (e) {
      if (mounted) {
        Utils.hideLoadingDialog(context);
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

                      Text('Вход', style: AppFonts.authHeadline),
                      SizedBox(height: 20),
                      AuthInputField(
                        controller: loginController,
                        placeholder: 'Введите электронную почту',
                        label: 'E-mail',
                        inputFormatters: [],
                      ),
                      SizedBox(height: 20),
                      AuthInputField(
                        controller: passwordController,
                        placeholder: 'Введите пароль',
                        label: 'Пароль',
                        inputFormatters: [],
                      ),
                      Spacer(flex: 2),
                      AppButton(
                        label: 'Войти',
                        onPressed: _isLoading ? null : _handleLogin,
                        textColor: AppColors.whiteColor,
                        gradient: AppColors.purpleButtonGradient,
                      ),
                      SizedBox(height: 20),
                      AppButton(
                        label: 'Регистрация',
                        onPressed: _isLoading
                            ? null
                            : () {
                                context.pushReplacement('/login/register');
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
