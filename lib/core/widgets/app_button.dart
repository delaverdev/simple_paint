import 'package:flutter/cupertino.dart';

import '../const/app_fonts.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.bgColor,
    required this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadiusGeometry.circular(8),
            color: bgColor,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppFonts.buttonText.copyWith(color: textColor),
          ),
        ),
      ),
    );
  }
}
