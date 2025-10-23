import 'package:flutter/cupertino.dart';

class HomeNavButton extends StatelessWidget {
  const HomeNavButton({super.key, required this.icon, required this.onPressed});

  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: icon,
      ),
    );
  }
}
