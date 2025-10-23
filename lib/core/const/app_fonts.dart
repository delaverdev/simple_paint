import 'dart:ui';

import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppFonts {
  static final authHeadline = GoogleFonts.pressStart2p(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1,
    color: AppColors.whiteColor,
    shadows: [
      Shadow(
        color: Color.fromRGBO(106, 70, 249, 1),
        offset: const Offset(0, 0),
        blurRadius: 40,
      ),
    ],
  );

  static final navbarTitle = GoogleFonts.roboto(
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: 1,
    color: AppColors.whiteColor,
  );

  static final inputTitle = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1,
    color: AppColors.greyColor,
  );

  static final inputPlaceholder = GoogleFonts.roboto(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1,
    color: AppColors.greyColor,
  );

  static final buttonText = GoogleFonts.roboto(
    fontWeight: FontWeight.w500,
    fontSize: 17,
    height: 1,
  );
}
