import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/const/app_colors.dart';
import '../../../core/const/app_fonts.dart';

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.label,
    required this.inputFormatters,
  });

  final TextEditingController controller;
  final String placeholder;
  final String label;
  final List<TextInputFormatter> inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 78,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/input.png'),
        ),
        border: Border.all(color: AppColors.greyColor, width: 0.5),
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      padding: EdgeInsetsGeometry.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.inputTitle),
          Spacer(),
          SizedBox(
            width: double.infinity,
            height: 24,
            child: CupertinoTextField(
              cursorColor: AppColors.whiteColor,
              controller: controller,
              inputFormatters: inputFormatters,
              padding: EdgeInsetsGeometry.zero,
              placeholder: placeholder,
              placeholderStyle: AppFonts.inputPlaceholder,
              style: AppFonts.inputPlaceholder.copyWith(
                color: AppColors.whiteColor,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.3, color: AppColors.greyColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
