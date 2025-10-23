import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simple_paint/features/home/screens/draw_screen.dart';
import 'package:simple_paint/features/home/widgets/home_nav_bar.dart';
import 'package:simple_paint/features/home/widgets/home_nav_button.dart';
import 'package:simple_paint/features/viewmodels/draws.dart';
import 'package:simple_paint/features/viewmodels/user.dart';

import '../../../core/const/app_colors.dart';
import '../../../core/widgets/app_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.read(userModelProvider);
    final drawsState = ref.watch(drawsStateProvider);

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Image.asset(
            'assets/images/bg.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                HomeNavBar(
                  title: 'Галерея',
                  leading: HomeNavButton(
                    icon: SvgPicture.asset('assets/icons/logout.svg'),
                    onPressed: () {
                      userModel.signOut();
                    },
                  ),
                  trailing: drawsState.draws.isEmpty
                      ? null
                      : HomeNavButton(
                          icon: SvgPicture.asset('assets/icons/new.svg'),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (builder) => DrawScreen(),
                              ),
                            );
                          },
                        ),
                ),
                if (drawsState.loading)
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(child: CupertinoActivityIndicator()),
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 46,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: drawsState.draws.length,
                      itemBuilder: (context, index) {
                        final draw = drawsState.draws[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (builder) =>
                                    DrawScreen(initialDraw: draw),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(12),
                            child: Container(
                              color: CupertinoColors.white,
                              child: draw.backgroundImageBytes != null
                                  ? Image.memory(
                                      draw.backgroundImageBytes!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(color: CupertinoColors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (drawsState.draws.isEmpty && !drawsState.loading)
            Positioned(
              bottom: 0,
              left: 20,
              right: 20,
              child: SafeArea(
                child: AppButton(
                  label: 'Создать',
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (builder) => DrawScreen()),
                    );
                  },
                  textColor: AppColors.whiteColor,
                  gradient: AppColors.purpleButtonGradient,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
