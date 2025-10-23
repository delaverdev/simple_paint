import 'dart:ui';

import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color whiteColor = Color.fromRGBO(238, 238, 238, 1);
  static const Color greyColor = Color.fromRGBO(135, 133, 143, 1);
  static const Color greyDarkColor = Color.fromRGBO(64, 64, 64, 1);
  static const Color blackColor = Color.fromRGBO(19, 19, 19, 1);
  static const Color redColor = Color.fromRGBO(233, 70, 71, 1);

  static const LinearGradient purpleButtonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF8924E7), Color(0xFF6A46F9)],
  );
}
