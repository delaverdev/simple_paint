import 'package:flutter/cupertino.dart';

import '../../../core/const/app_fonts.dart';

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(8)),
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage('assets/images/appbar.png'),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 44,
          width: double.infinity,
          margin: EdgeInsetsGeometry.only(top: 14),
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              leading ?? SizedBox(width: 24),
              Text(title, style: AppFonts.navbarTitle),
              trailing ?? SizedBox(width: 24),
            ],
          ),
        ),
      ),
    );
  }
}
